//
//  SkyS3SyncManager.m
//  TestS3
//
//  Created by Eugene Dorfman on 11/28/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "SkyS3SyncManager.h"

#import "SkyS3AmazonS3Manager.h"
#import "SkyS3OnoResponseSerializer.h"
#import "SkyS3Directory.h"
#import "SkyS3ResourceData.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <Ono/Ono.h>
#import <libextobjc/extobjc.h>
#import <FileMD5Hash/FileHash.h>

#define _SkyS3SafeString(x) (x ? x : @"")

NSString * const SkyS3SyncDidFinishSyncNotification = @"SkyS3SyncDidFinishSyncNotification";
NSString * const SkyS3SyncDidRemoveResourceNotification = @"SkyS3SyncDidRemoveResourceNotification";
NSString * const SkyS3SyncDidUpdateResourceNotification = @"SkyS3SyncDidUpdateResourceNotification";
NSString * const SkyS3SyncDidCopyOriginalResourceNotification = @"SkyS3SyncDidCopyOriginalResourceNotification";
NSString * const SkyS3SyncDidFailToListBucket = @"SkyS3SyncDidFailToListBucket";
NSString * const SkyS3SyncDidFailToDownloadResource = @"SkyS3SyncDidFailToDownloadResource";;

NSString * const SkyS3ResourceFileName = @"SkyS3ResourceFileName";
NSString * const SkyS3ResourceURL = @"SkyS3ResourceURL";
NSString * const SkyS3BucketName = @"SkyS3BucketName";
NSString * const SkyS3Error = @"SkyS3Error";

static NSInteger const SkyS3MaxRetries = 3;

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


/** 
 * These manager objects will have different responseSerializers
 */
@property (nonatomic,strong) SkyS3AmazonS3Manager *amazonS3BucketListManager;
@property (nonatomic,strong) SkyS3AmazonS3Manager *amazonS3DownloadResourceManager;

/**
 *  By default the sync directory is auto-created in an internal location.  You can specify your own directory
 *  with this property, however make sure this directory exists.
 */
@property (nonatomic,readwrite,strong) NSURL *syncDirectoryURL;
@property (nonatomic,strong) SkyS3Directory *actualSyncDirectory;
@property (nonatomic,strong) dispatch_queue_t dispatchQueue;

@property (nonatomic,assign) NSInteger listBucketRetries;
@end

@implementation SkyS3SyncManager

#pragma mark - public methods:
- (instancetype) initWithS3AccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey bucketName:(NSString *)bucketName originalResourcesDirectory:(NSURL *)originalResourcesDirectory {
    if (self = [super init]) {
        self.dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.S3AccessKey = accessKey;
        self.S3SecretKey = secretKey;
        self.S3BucketName = bucketName;
        self.originalResourcesDirectory = originalResourcesDirectory;
        self.remoteSyncEnabled = YES;
    }
    return self;
}

#pragma mark - SkyResourceProvider

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext {
    if (!name) {
        return nil;
    }
    NSString *resourceFileName = ext.length > 0 ? [name stringByAppendingPathExtension:ext] : name;
    return [self URLForResourceWithFileName:resourceFileName];
}

- (NSURL *)URLForResourceWithFileName:(NSString *)fileName {
    if (!fileName) {
        return nil;
    }

    NSURL *URL = [self.actualSyncDirectory URLForResourceWithFileName:fileName];
    if (URL) {
        return URL;
    }

    URL = [self.originalResourcesDirectory URLByAppendingPathComponent:fileName];
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

        _syncDirectoryURL = [baseURL URLByAppendingPathComponent:syncDirectoryName];
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

- (SkyS3Directory *) actualSyncDirectory {
    if (!_actualSyncDirectory) {
        _actualSyncDirectory = [[SkyS3Directory alloc] initWithDirectoryURL:self.syncDirectoryURL];
    }
    return _actualSyncDirectory;
}

- (NSObject<SkyS3ResourceURLProvider> *)syncDirectory {
    return self.actualSyncDirectory;
}

- (NSString *)syncDirectoryName {
    if (_syncDirectoryName.length == 0) {
        _syncDirectoryName = @"SkyS3Sync";
    }
    return _syncDirectoryName;
}

- (SkyS3AmazonS3Manager *)makeAFManager {
    SkyS3AmazonS3Manager *manager = [[SkyS3AmazonS3Manager alloc] initWithAccessKeyID:self.S3AccessKey secret:self.S3SecretKey];
    manager.completionQueue = self.dispatchQueue;
    manager.requestSerializer.bucket = self.S3BucketName;
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    return manager;
}

- (SkyS3AmazonS3Manager *)amazonS3BucketListManager {
    if (!_amazonS3BucketListManager) {
        _amazonS3BucketListManager = [self makeAFManager];
        _amazonS3BucketListManager.responseSerializer = [SkyS3OnoResponseSerializer serializer];
    }
    return _amazonS3BucketListManager;
}

- (SkyS3AmazonS3Manager *)amazonS3DownloadResourceManager {
    if (!_amazonS3DownloadResourceManager) {
        _amazonS3DownloadResourceManager = [self makeAFManager];
        _amazonS3DownloadResourceManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return _amazonS3DownloadResourceManager;
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
    if (self.remoteSyncEnabled) {
        self.listBucketRetries = 0;
        [self doAmazonS3Sync];
    } else {
        [self finishSync];
    }
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
        BOOL fileExistedAtPath = [[NSFileManager defaultManager] fileExistsAtPath:[dstURL path]];
        NSString* resourceName = [dstURL lastPathComponent];
        [self copyFrom:srcURL to:dstURL];
        if (fileExistedAtPath) {
            [self postDidUpdateNotificationWithResourceFileName:resourceName andURL:dstURL];
        } else {
            [self postDidCopyOriginalNotificationWithResourceFileName:resourceName andURL:dstURL];
        }
    }];
    
    self.originalResourcesCopied = YES;
}

- (void) doAmazonS3Sync {
    @weakify(self);
    [self.amazonS3BucketListManager getBucket:@"/" success:^(id responseObject) {
        @strongify(self);
        [self processS3ListBucket:responseObject];
    } failure:^(NSError *error) {
        @strongify(self);
        if (self.listBucketRetries < SkyS3MaxRetries) {
            [self performSelector:@selector(doAmazonS3Sync)];
            self.listBucketRetries++;
            return;
        }
        [self.class log:@"error = %@", error];
        [self postNotificationName:SkyS3SyncDidFailToListBucket userInfo:@{SkyS3BucketName:_SkyS3SafeString(self.S3BucketName), SkyS3Error: error}];
        [self finishSync];
    }];
}

- (void) processS3ListBucket:(id)responseObject {
    __block NSArray *remoteResources = [self remoteResourcesFromBucketListXML:responseObject];

    __block NSUInteger completedCounter = 0;

    @weakify(self);
    void(^completedBlock)(void) = ^{
        @strongify(self);
        @synchronized(self) {
            if (++completedCounter == remoteResources.count) {
                [self finishSync];
            };
        }
    };

    // delete local files that are absent on the remote host
    NSArray* remoteResourcesNames = [remoteResources map:^id(SkyS3ResourceData* resource) {
        return resource.name;
    }];
    for (NSString *localFileName in [[NSFileManager defaultManager] enumeratorAtPath:self.syncDirectoryURL.path]) {
        if (!localFileName) {
            continue;
        }
        if (![remoteResourcesNames containsObject:localFileName]) {
            NSError* error = nil;
            NSURL *resourceURL = [self.syncDirectoryURL URLByAppendingPathComponent:localFileName];
            if ([[NSFileManager defaultManager] removeItemAtURL:resourceURL error:&error]) {
                [self postDidRemoveNotificationWithResourceFileName:localFileName andURL:resourceURL];
            } else {
                [self.class log:@"fail to remove local legacy resource %@ error: %@", localFileName, error];
            }
        }
    }
    

    remoteResources = [remoteResources reject:^BOOL(SkyS3ResourceData *resource) {
        return [resource.etag isEqualToString:[self md5ForURL:resource.localURL]];
    }];

    [remoteResources each:^(SkyS3ResourceData *resource) {
        [self downloadResource:resource withCompletedBlock:completedBlock];
    }];

    if (remoteResources.count == 0) {
        [self finishSync];
    }
}

- (void)downloadResource:(SkyS3ResourceData *)resource withCompletedBlock:(void(^)(void))completedBlock {
    NSString* cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSURL *cachesURL = [NSURL fileURLWithPath:cachesPath];
    [self.class log:@"updating %@",resource.name];
    if (!resource.name) {
        return;
    }
    NSURL *tmpURL = [cachesURL URLByAppendingPathComponent:resource.name];
    // remove previous temporary file to avoid sync collisions
    [[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
    [self.amazonS3DownloadResourceManager getObjectWithPath:resource.name outputFileURL:tmpURL success:^(id responseObject) {
        [self copyFrom:tmpURL to:resource.localURL];
        [self.class log:@"did update %@",resource.name];
        [self postDidUpdateNotificationWithResourceFileName:resource.name andURL:resource.localURL];
        completedBlock();
    } failure:^(NSError *error) {
        if (resource.retries < SkyS3MaxRetries) {
            resource.retries++;
            [self downloadResource:resource withCompletedBlock:completedBlock];
        } else {
            [self postNotificationName:SkyS3SyncDidFailToDownloadResource userInfo:@{SkyS3ResourceFileName:_SkyS3SafeString(resource.name), SkyS3BucketName:_SkyS3SafeString(self.S3BucketName), SkyS3Error: error}];
            completedBlock();
        }
    }];
}

#pragma mark - Notifications

- (void) postDidRemoveNotificationWithResourceFileName:(NSString *)resourceFileName andURL:(NSURL *)resourceURL {
    [self postNotificationName:SkyS3SyncDidRemoveResourceNotification withResourceFileName:resourceFileName andURL:resourceURL];
}

- (void) postDidCopyOriginalNotificationWithResourceFileName:(NSString *)resourceFileName andURL:(NSURL *)resourceURL {
    [self postNotificationName:SkyS3SyncDidCopyOriginalResourceNotification withResourceFileName:resourceFileName andURL:resourceURL];
}

- (void) postDidUpdateNotificationWithResourceFileName:(NSString *)resourceFileName andURL:(NSURL *)resourceURL {
    [self postNotificationName:SkyS3SyncDidUpdateResourceNotification withResourceFileName:resourceFileName andURL:resourceURL];
}

- (void) postNotificationName:(NSString*)notificationName withResourceFileName:(NSString*)resourceFileName andURL:(NSURL *)resourceURL {

    NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
    if (resourceFileName) {
        userInfo[SkyS3ResourceFileName] = resourceFileName;
    }

    if (resourceURL) {
        userInfo[SkyS3ResourceURL] = resourceURL;
    }

    [self postNotificationName:notificationName userInfo:userInfo];
}

- (void)postNotificationName:(NSString *)notificationName userInfo:(NSDictionary *)userInfo {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    });
}

- (void) finishSync {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
        self.syncInProgress = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:SkyS3SyncDidFinishSyncNotification object:self];
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
    NSString *lpc = [srcURL lastPathComponent];
    if (lpc) {
        return [self.syncDirectoryURL URLByAppendingPathComponent:lpc];
    }
    return nil;
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
            if (resource.name) {
                resource.localURL = [self.syncDirectoryURL URLByAppendingPathComponent:resource.name];
                [remoteResources addObject:resource];
            }
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
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *coordinatorError = nil;
    BOOL __block coordinatorSuccess = NO;

    [coordinator coordinateWritingItemAtURL:dstURL options:NSFileCoordinatorWritingForReplacing error:&coordinatorError byAccessor:^(NSURL * _Nonnull newURL) {
        coordinatorSuccess = YES;

        NSError *error = nil;
        if ([[NSFileManager defaultManager] fileExistsAtPath:[newURL path]]) {
            if (![[NSFileManager defaultManager] removeItemAtURL:newURL error:&error]) {
                [self.class log:@"Failed to remove existing file before copying: %@ to %@ error: %@",srcURL,dstURL,error];
            }
        }
        if (![[NSFileManager defaultManager] copyItemAtURL:srcURL toURL:newURL error:&error]) {
            [self.class log:@"Failed to copy: %@ to %@ error: %@",srcURL,dstURL,error];
        }
    }];

    if (!coordinatorSuccess) {
        [self.class log:@"Failed to coordinate copying: %@ to %@ error: %@",srcURL,dstURL,coordinatorSuccess];
    }
}

@end
