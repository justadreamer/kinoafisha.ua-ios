//
//  SkyS3ManifestData.h
//  TestS3
//
//  Created by Eugene Dorfman on 12/7/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface SkyS3ResourceData : NSObject
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *etag;
@property (nonatomic,strong) NSDate *lastModifiedDate;
@property (nonatomic,strong) NSURL *localURL;

- (instancetype) initWithName:(NSString *)name etag:(NSString *)etag lastModifiedDate:(NSDate *)lastModifiedDate;

@end
