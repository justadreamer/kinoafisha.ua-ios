SkyS3SyncManager
================

A simple resource manager which downsyncs a full mirror of a remote Amazon S3 bucket.  This allows to remotely update app's resources via Amazon S3.  Full mirror means that if some resource changes at Amazon S3 - it is considered to be more relevant than the local copy and it is downloaded, also if some resource is added or deleted on Amazon - it is added or deleted correspondingly in the local mirror.

## Cocoapod

```
source 'git@git.postindustria.com:mobile-components.git'
pod 'SkyS3Sync'
```

## Integration

SkyS3SyncManager class is not a singleton (to allow f.e. for syncing several S3 buckets each with its own separate manager).  Thus it is best to create a 'sticky' instance belonging to an object which has a significantly long life-time.  For the simplest use case it can be your application delegate object.  Below is a suggested integration snippet (taken from the Example project):

AppDelegate.h:

```objc
	
#import <SkyS3Sync/SkyS3Sync.h>
	
#define AD ((AppDelegate *)[[UIApplication sharedApplication] delegate])

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic,readonly) SkyS3SyncManager *s3SyncManager;
@property (strong, nonatomic) UIWindow *window;
@end

```

AppDelegate.m:

```objc
@interface AppDelegate ()
@property (nonatomic,readwrite,strong) SkyS3SyncManager *s3SyncManager;
@end
	
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSURL *resourcesDirectory = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"test_dir"];
    
    #include "S3Secrets.h"
    self.s3SyncManager = [[SkyS3SyncManager alloc] initWithS3AccessKey:S3AccessKey
                                                             secretKey:S3SecretKey
                                                            bucketName:S3BucketName
                                            originalResourcesDirectory:resourcesDirectory];

    return YES;
}
	
- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.s3SyncManager sync];
}
	
@end

```

Then in code you can call:

```objc  
#include "AppDelegate.h"
	
//...
NSURL *URL = [AD.s3SyncManager URLForResourceWithFileName:@"<#filename#>"];
//or:
NSURL *URL = [AD.s3Sync URLForResource:@"<#filename#>" withExtension:@"<#extension#>"];
```

Note if the resource is not present in the sync-directory (mirroring the bucket) - this call will **fallback** to the local resource version.  In order to always get the resource from the mirror you should use this API:

```objc
[[AD.s3Sync syncDirectory] URLForResource:withExtension:]
```

## Notifications

To be able to react to changes when some resource has been updated and downsynced - you can listen to `SkyS3SyncDidUpdateResourceNotification` notification.  The `userInfo` dictionary will contain:`SkyS3ResourceFileName` and `SkyS3ResourceURL` keys which you can use to make sure that the resource in question has been updated - and then re-read its contents and update the UI correspondingly.

There are other notifications documented in `SkyS3SyncManager.h` - they can be used to react to differentiate other events, such as:

```objc
SkyS3SyncDidCopyOriginalResourceNotification
SkyS3SyncDidRemoveResourceNotification
SkyS3SyncDidUpdateResourceNotification
SkyS3SyncDidFinishSyncNotification
```
The last notification is sent when S3SyncManager completed syncing all of the managed resources - so either all of them are up to date, or a network error has occurred, which is not exposed as of right now, since we consider that we have the local default version of each resource provided on initialization.


## Directories
By default `SkyS3SyncManager` creates `SkyS3Sync` directory under app's `Documents` directory.  However you can specify a different directory (f.e. if syncing several different buckets and they appear to have files with the same names) using the property of SkyS3SyncManager:

```objc
@property (nonatomic,strong) NSString *syncDirectoryName;
```

## Syncing strategy
The local file under sync directory is updated (fetched from Amazon or overwritten by a newer version provided under app's resource bundle) only in case the remote file has a different md5 than the local file (the remote file has a different content).

Addition and deletion are correspondingly mirrored into the local sync directory.

## SkyS3ResourceURLProvider API
There is a single API for now, which allows to substitute the SkyS3SyncManager with an NSBundle if needed:

```objc    
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext;
```

the difference of this API from NSBundle's is that it returns nil if resource does not actually exist.  The check for existance is an unexpected behavior, but that's how we use it in our projects, might to change in the future, as we introduce some cleaner APIs.


## Uploading resources to Amazon
For distributing the modified resources to your app instances in the wild - you obviously would need to upload the files to Amazon.  Although it is slightly out of scope of this library project - there is a recommended command line utility to use: s3cmd, and there is a script that wraps the command line utility s3sync.sh - allowing you to simply upload all changed files from the local directory to remote Amazon bucket.

