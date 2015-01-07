//
//  SkyS3SyncManager.m
//  TestS3
//
//  Created by Eugene Dorfman on 11/28/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "SkyS3SyncManager.h"

#import <AFAmazonS3Manager/AFAmazonS3Manager.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFOnoResponseSerializer/AFOnoResponseSerializer.h>
#import <Ono/Ono.h>
#import <libextobjc/extobjc.h>
#import <FileMD5Hash/FileHash.h>

#import "SkyS3ResourceData.h"

NSString * const SkyS3SyncDidUpdateResourceNotification = @"SkyS3SyncDidUpdateResource";
NSString * const SkyS3ResourceFileName = @"SkyS3ResourceFileName";
NSString * const SkyS3ResourceURL = @"SkyS3ResourceURL";

@interface SkyS3SyncManager ()
/**
 *  Amazon S3 Access Key
 */
@property (nonatomic,strong) NSString *S3AccessKey;

/**
 *  Amazon S3 Secret Key
 */
@property (nonatomic,strong) NSString *S3SecretKey;

/**
 *  a name of the S3 bucket to sync the resources from
 */
@property (nonatomic,strong) NSString *S3BucketName;

/**
 *  local directory containing original versions of resources to be used as a starting point over which the synced
 *  versions will be downloaded
 */
@property (nonatomic,strong) NSURL *originalResourcesDirectory;

/**
 *  This property is set when we start syncing to not start a new sync while the current is in progress
 */
@property (atomic,assign) BOOL syncInProgress;

/**
 *  Copying of original resources makes sense once at the start of the application, so we set this flag to not copy it again
 */
@property (atomic,assign) BOOL originalResourcesCopied;


@property (nonatomic,strong) AFAmazonS3Manager *amazonS3Manager;

/**
 *  By default the sync directory is auto-created in an internal location.  You can specify your own directory
 *  with this property, however make sure this directory exists.
 */
@property (nonatomic,readwrite,strong) NSURL *syncDirectoryURL;

@property (nonatomic,strong) dispatch_queue_t dispatchQueue;
@end

@implementation SkyS3SyncManager

#pragma mark - public methods:
- (instancetype) initWithS3AccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey bucketName:(NSString *)bucketName originalResourcesDirectory:(NSURL *)originalResourcesDirectory {
    if (self = [super init]) {
        self.dispatchQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
        self.S3AccessKey = accessKey;
        self.S3SecretKey = secretKey;
        self.S3BucketName = bucketName;
        self.originalResourcesDirectory = originalResourcesDirectory;
    }
    return self;
}

#pragma mark - SkyResourceProvider

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext {
    NSString *resourceFileName = [name stringByAppendingPathExtension:ext];
    return [self URLForResourceWithFileName:resourceFileName];
}

- (NSURL *)URLForResourceWithFileName:(NSString *)fileName {
    NSURL *URL = [NSURL URLWithString:fileName relativeToURL:self.syncDirectoryURL];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        return URL;
    }
    
    URL = [NSURL URLWithString:fileName relativeToURL:self.originalResourcesDirectory];
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]) {
        return URL;
    }
    
    return nil;
}

#pragma mark - lazy initializers

- (NSURL *)syncDirectoryURL {
    if (!_syncDirectoryURL) {
        NSURL *baseURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
        NSString *syncDirectoryName = self.syncDirectoryName;
        if ([syncDirectoryName characterAtIndex:syncDirectoryName.length-1]!='/') {
             syncDirectoryName = [syncDirectoryName stringByAppendingString:@"/"];
        }

        _syncDirectoryURL = [NSURL URLWithString:syncDirectoryName relativeToURL:baseURL];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[_syncDirectoryURL path]]) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] createDirectoryAtURL:_syncDirectoryURL withIntermediateDirectories:YES attributes:nil error:&error]) {
                [self.class log:@"SkyS3SyncManager: failed to create directory at URL: %@, with error: %@",_syncDirectoryURL, error];
                _syncDirectoryURL = nil;
            }
        }
    }
    return _syncDirectoryURL;
}

- (NSString *)syncDirectoryName {
    if (!_syncDirectoryName) {
        _syncDirectoryName = @"SkyS3Sync";
    }
    return _syncDirectoryName;
}

- (AFAmazonS3Manager *)amazonS3Manager {
    if (!_amazonS3Manager) {
        _amazonS3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:self.S3AccessKey secret:self.S3SecretKey];
        _amazonS3Manager.completionQueue = self.dispatchQueue;
        _amazonS3Manager.requestSerializer.bucket = self.S3BucketName;
    }
    return _amazonS3Manager;
}

#pragma mark - actual sync

- (void) sync {
    if (!self.syncInProgress) {
        self.syncInProgress = YES;
        @weakify(self)
        dispatch_async(self.dispatchQueue, ^{
            @strongify(self)
            [self doSync];
        });
    }
}

- (void) doSync {
    self.syncInProgress = YES;

    NSAssert(self.S3AccessKey, @"S3AccessKey not set");
    NSAssert(self.S3SecretKey, @"S3SecretKey not set");
    NSAssert(self.S3BucketName, @"S3BucketName not set");
    NSAssert(self.originalResourcesDirectory, @"originalResourcesDirectory not set");

    [self doOriginalResourcesCopying];
    [self doAmazonS3Sync];
}

- (void) doOriginalResourcesCopying {
    if (self.originalResourcesCopied) {
        return;
    }

    NSArray *resources = [self resourcesFromDirectory:self.originalResourcesDirectory];
    [[resources reject:^BOOL(NSURL *srcURL) { //then for each resource we decide whether it needs to be copied over - we reject those that have the same modification date
        NSURL *dstURL = [self dstURLForSrcURL:srcURL];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dstURL path]]) {
            //getting src modification date:
            NSDate *srcDate = [self.class modificationDateForURL:srcURL];
            //getting dst modification date:
            NSDate *dstDate = [self.class modificationDateForURL:dstURL];
            
            //comparing dates
            if (srcDate && dstDate) {
                //if dates are equal or srcDate is older then we don't copy a resource over
                if ([srcDate timeIntervalSinceDate:dstDate] < 0) {
                    return YES;
                } else {
                    //src file is newer - was modified later, let's compare the md5 to check if the content is really modified
                    NSString *srcMD5 = [self md5ForURL:srcURL];
                    NSString *dstMD5 = [self md5ForURL:dstURL];
                    return [srcMD5 isEqualToString:dstMD5];
                }
            }
        }
        return NO;
    }] each:^(NSURL *srcURL) { //then each of the picked resources gets copied
        NSURL *dstURL = [self dstURLForSrcURL:srcURL];
        [self copyFrom:srcURL to:dstURL];
        [self postDidUpdateNotificationWithResource:[dstURL lastPathComponent]];
    }];
    
    self.originalResourcesCopied = YES;
}

- (void) doAmazonS3Sync {
    @weakify(self);
    self.amazonS3Manager.responseSerializer = [AFOnoResponseSerializer serializer];
    [self.amazonS3Manager getBucket:@"/" success:^(id responseObject) {
        @strongify(self);
        [self processS3ListBucket:responseObject];
    } failure:^(NSError *error) {
        @strongify(self);
        [self.class log:@"error = %@", error];
        self.syncInProgress = NO;
    }];
}

- (void) processS3ListBucket:(id)responseObject {
    __block NSArray *remoteResources = [self remoteResourcesFromBucketListXML:responseObject];

    __block NSUInteger completedCounter = 0;

    @weakify(self);
    void (^finishSyncing)() = ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            self.syncInProgress = NO;
        });
    };

    void(^completedBlock)() = ^{
        if (++completedCounter == remoteResources.count) {
            finishSyncing();
        };
    };

    NSString* cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                                NSUserDomainMask,
                                                                YES) lastObject];

    NSURL *cachesURL = [NSURL fileURLWithPath:cachesPath];
    remoteResources = [[remoteResources reject:^BOOL(SkyS3ResourceData *resource) {
        return [resource.lastModifiedDate timeIntervalSinceDate:[self.class modificationDateForURL:resource.localURL]]<0;
    }] reject:^BOOL(SkyS3ResourceData *resource) {
        return [resource.etag isEqualToString:[self md5ForURL:resource.localURL]];
    }];

    [remoteResources each:^(SkyS3ResourceData *resource) {
        [self.class log:@"updating %@",resource.name];
        NSURL *tmpURL = [cachesURL URLByAppendingPathComponent:resource.name];
        NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:[tmpURL path] append:NO];
        self.amazonS3Manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.amazonS3Manager getObjectWithPath:resource.name outputStream:stream progress:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        } success:^(id responseObject) {
            [self copyFrom:tmpURL to:resource.localURL];
            completedBlock();
            [self.class log:@"did update %@",resource.name];
            [self postDidUpdateNotificationWithResource:resource.name];
        } failure:^(NSError *error) {
            completedBlock();
        }];
    }];

    if (remoteResources.count == 0) {
        finishSyncing();
    }
}

- (void) postDidUpdateNotificationWithResource:(NSString *)resourceFileName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SkyS3SyncDidUpdateResourceNotification
                                                            object:self
                                                          userInfo:@{
                                                                     SkyS3ResourceFileName:resourceFileName,
                                                                     SkyS3ResourceURL:[self URLForResourceWithFileName:resourceFileName]
                                                                     }];
    });
}

#pragma mark - logging

+ (void) log:(NSString *)format,... {
    #ifdef DEBUG
        va_list args;
        va_start(args, format);
        NSString *contents = [[NSString alloc] initWithFormat:[@"SkyS3SyncManager: " stringByAppendingString:format] arguments:args];
        NSLog(@"%@",contents);
        va_end(args);
    #endif
}

#pragma mark - auxiliary functions

+ (NSDate *) modificationDateForURL:(NSURL *)URL {
    NSDate *date = nil;
    NSError *error = nil;
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[URL path] error:&error];
    if (!attributes || error) {
        [self log:@"error getting NSURLContentModificationDateKey from URL: %@ error: %@",URL,error];
    }
    date = attributes[NSFileModificationDate];
    return date;    
}

- (NSURL *)dstURLForSrcURL:(NSURL *)srcURL {
    return [self.syncDirectoryURL URLByAppendingPathComponent:[srcURL lastPathComponent]];
}

- (NSString *)md5ForURL:(NSURL *)URL {
    NSString *path = [URL path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return [FileHash md5HashOfFileAtPath:path];
    }
    return nil;
}

- (NSArray *)remoteResourcesFromBucketListXML:(ONOXMLDocument *)document {
    document.dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZ";
    NSMutableArray *remoteResources = [NSMutableArray array];
    [document enumerateElementsWithXPath:@"/*/*" usingBlock:^(ONOXMLElement *element, NSUInteger idx, BOOL *stop) {
        if ([element.tag isEqualToString:@"Contents"]) {
            SkyS3ResourceData *resource = [[SkyS3ResourceData alloc] init];
            [element.children each:^(ONOXMLElement *child) {
                if ([child.tag isEqualToString:@"Key"]) {
                    resource.name = [child stringValue];
                } else if ([child.tag isEqualToString:@"LastModified"]) {
                    resource.lastModifiedDate = [child dateValue];
                } else if ([child.tag isEqualToString:@"ETag"]) {
                    resource.etag = [[child stringValue] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
                }
            }];
            resource.localURL = [self.syncDirectoryURL URLByAppendingPathComponent:resource.name];
            [remoteResources addObject:resource];
        }
    }];
    return remoteResources;
}

- (NSArray *) resourcesFromDirectory:(NSURL *)URL {
    NSError *error = nil;
    NSArray *resources = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:URL includingPropertiesForKeys:@[NSURLIsDirectoryKey,NSURLContentModificationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    if (!resources || error) {
        [self.class log:@"Failed to get directory contents: %@ error: %@",self.originalResourcesDirectory, error];
    }
    
    [resources reject:^BOOL(NSURL *URL) { //first we filter out any directories - we work only with files
        id value;
        NSError *error = nil;
        if (![URL getResourceValue:&value forKey:NSURLIsDirectoryKey error:&error]) {
            [self.class log:@"error getting NSURLIsDirectoryKey from URL: %@ error: %@",URL,error];
            return NO;
        }
        return [value boolValue];
    }];

    return resources;
}

- (void) copyFrom:(NSURL *)srcURL to:(NSURL *)dstURL {
    NSError *error = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[dstURL path]]) {
        if (![[NSFileManager defaultManager] removeItemAtURL:dstURL error:&error]) {
            [self.class log:@"Failed to remove existing file before copying: %@ to %@ error: %@",srcURL,dstURL,error];
        }
    }
    if (![[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:dstURL error:&error]) {
        [self.class log:@"Failed to copy: %@ to %@ error: %@",srcURL,dstURL,error];
    }
}

@end
