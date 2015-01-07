
#SkyS3SyncManager


A simple resource manager that allows to remotely update app's resources via Amazon S3.  Basically the manager hosts a local mirror of the Amazon S3 bucket.

##Cocoapod
It is planned to publish the spec to the main Specs repo in the near future, however for now please use:

```
pod 'SkyS3Sync', :git => "git@github.com:justadreamer/SkyS3Sync.git"
```

##Integration

SkyS3SyncManager class is not a singleton (to allow f.e. for syncing several S3 buckets each with its own separate manager).  Thus it is best to create a 'sticky' instance belonging to an object which has a significantly long life-time.  For the simplest use case it can be your application delegate object.  Below is a suggested integration snippet (taken from the Example project):

AppDelegate.h:

```objective-c
	
	#import <SkyS3Sync/SkyS3Sync.h>
	
	#define AD ((AppDelegate *)[[UIApplication sharedApplication] delegate])

	@interface AppDelegate : UIResponder <UIApplicationDelegate>
	@property (nonatomic,readonly) SkyS3SyncManager *s3SyncManager;
	@property (strong, nonatomic) UIWindow *window;
	@end

```

AppDelegate.m:

```objective-c

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

```objective-c

	#include "AppDelegate.h"
	
	//...
	NSURL *URL = [AD.s3SyncManager URLForResourceWithFileName:@"<#filename#>"];
	//or:
	NSURL *URL = [AD.s3Sync URLForResource:@"<#filename#>" withExtension:@"<#extension#>"];
```

##Directories
By default SkyS3SyncManager creates SkyS3Sync directory under app's Documents directory.  However you can specify a different directory (f.e. if syncing several different buckets and they appear to have files with the same names) using the property of SkyS3SyncManager:

```objective-c

	@property (nonatomic,strong) NSString *syncDirectoryName;
```

##Syncing strategy
The local file under sync directory is updated (fetched from Amazon or overwritten by a newer version provided under app's resource bundle) only in case the remote file is:
a) newer than the local version (by file's modification time)
b) md5 of the remote file is different than of the local file (i.e. the remote file has a different content)

In this case the newer version is downloaded and the local older version is overwritten.

There is no delete strategy currently implemented.  That is a TODO.  

If the local version of the file does not exist under sync directory, and there is a remote version - it is downloaded and saved under the sync directory.


##Uploading resources to Amazon
For distributing the modified resources to your app instances in the wild - you obviously would need to upload the files to Amazon.  Although it is slightly out of scope of this library project - there is a recommended command line utility to use: s3cmd, and there is a script that wraps the command line utility s3sync.sh - allowing you to simply upload all changed files from the local directory to remote Amazon bucket.

