//
//  AppDelegate.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/5/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SkyS3Sync/SkyS3Sync.h>

#define AD ((AppDelegate *)[UIApplication sharedApplication].delegate)
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SkyS3SyncManager *s3SyncManager;

@end

