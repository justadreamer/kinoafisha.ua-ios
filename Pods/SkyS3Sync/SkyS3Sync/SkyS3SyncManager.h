//
//  SkyS3SyncManager.h
//  TestS3
//
//  Created by Eugene Dorfman on 11/28/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SkyS3Sync/SkyS3ResourceURLProvider.h>

/**
 *  Posted when a particular original resource is first time copied to sync directory with the userInfo containing keys:
 *
 *  SkyS3ResourceFileName - the filename (with extension) of the resource that has
 *  been copied
 *
 *  SkyS3ResourceURL - the local file URL of the resource that has just been copied
 */
extern NSString * const SkyS3SyncDidCopyOriginalResourceNotification;

/**
 *  Posted when a particular resource is removed with the userInfo containing keys:
 *
 *  SkyS3ResourceFileName - the filename (with extension) of the resource that has
 *  been removed
 *
 */
extern NSString * const SkyS3SyncDidRemoveResourceNotification;

/**
 *  Posted when a particular resource is updated with the userInfo containing keys:
 *
 *  SkyS3ResourceFileName - the filename (with extension) of the resource that has
 *  been updated
 * 
 *  SkyS3ResourceURL - the local file URL of the resource that has just been updated
 */
extern NSString * const SkyS3SyncDidUpdateResourceNotification;

/**
 *  Posted when the syncing has finished (either all appropriate resources
 *  have been updated, or there are no updates, or there was a network failure
 */
extern NSString * const SkyS3SyncDidFinishSyncNotification;

/**
 *  This key is part of userInfo dictionary for the 
 *  SkyS3SyncDidUpdateResourceNotification, contains the filename (with extension) of the resource that has
 *  been updated
 */
extern NSString * const SkyS3ResourceFileName;

/**
 *  This key is part of the userInfo dictionary for the 
 *  SkyS3SyncDidUpdateResourceNotification, contains the local file URL of the 
 *  resource that has just been updated
 */
extern NSString * const SkyS3ResourceURL;

/**
 *  A simple S3 syncing service, which syncs the contents of the S3BucketName to 
 *  an internal local directory
 */
@interface SkyS3SyncManager : NSObject<SkyS3ResourceURLProvider>

/**
 *  by default the sync directory name is SkyS3Sync, and it is stored under Documents, you can specify an arbitrary name for it (in case f.e. of name 
 *  collission, or if you are working with several instances of SkyS3SyncManager
 */
@property (nonatomic,strong) NSString *syncDirectoryName;

/**
 *  The directory where the synced resources are stored
 */
@property (nonatomic,readonly) NSURL *syncDirectoryURL;

/**
 *  By default YES, and in case the remote file differs in md5 from local - it will be pulled. 
 *  Set to NO if you like to only sync with local resources - convenient for debugging and testing
 *  locally, should not be set to NO for production environment.
 */
@property (nonatomic,assign) BOOL remoteSyncEnabled;

/**
 *  Designated initializer
 *
 *  @param accessKey                  Amazon S3 Access Key
 *  @param secretKey                  Amazon S3 Secret Key
 *  @param bucketName                 Amazon S3 Bucket Name
 *  @param originalResourcesDirectory URL of the local directory, which contains original versions of resources to be used as startig poit over which the synced 
 *   versions will be downloaded
 *
 *  @return returns a fully initialized SkyS3SyncManager
 */
- (instancetype) initWithS3AccessKey:(NSString *)accessKey secretKey:(NSString *)secretKey bucketName:(NSString *)bucketName originalResourcesDirectory:(NSURL *)originalResourcesDirectory NS_DESIGNATED_INITIALIZER;

- (instancetype) init NS_UNAVAILABLE;

/**
 *  To be called from AppDelegate's applicationDidBecomeActive: method to check if anything has been updated on S3
 *  and sync down any updated files.
 */
- (void) sync;

/**
 *  To get a URL of the particular resource of the latest synced version
 *  Note: if the resource in question is not present in the sync directory -
 *  we try to get it from the original resources directory. 
 *  To obtain the resource from the sync directory without a fallback to original  
 *  resource directory - use
 *  -[SkyS3Manager syncDirectory] object and call the same method on that object.
 *      
 *  @param name filename of the resource
 *  @param ext  extension of the resource
 *
 *  @return a URL to the particular resource if it exists, or nil if it does not
 */
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext;

/**
 *  This object can be used to obtain the resource URL without fallback to original
 *  resource directory
 *
 *  @return SkyS3ResourceURLProvider
 */
- (NSObject<SkyS3ResourceURLProvider> *)syncDirectory;

@end
