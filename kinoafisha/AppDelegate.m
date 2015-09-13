//
//  AppDelegate.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/5/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "AppDelegate.h"
#import <HockeySDK/HockeySDK.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#include "S3Secrets.h"
    NSURL *resourcesURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"XSLT"];
    self.s3SyncManager = [[SkyS3SyncManager alloc] initWithS3AccessKey:S3AccessKey secretKey:S3SecretKey bucketName:S3BucketName originalResourcesDirectory:resourcesURL];
#ifdef DEBUG
    self.s3SyncManager.remoteSyncEnabled = NO;
#else 
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"c357110cbce64ba11cc73faa41591897"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.s3SyncManager sync];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
