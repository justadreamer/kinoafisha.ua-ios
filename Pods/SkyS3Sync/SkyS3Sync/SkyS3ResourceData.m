//
//  SkyS3ManifestData.m
//  TestS3
//
//  Created by Eugene Dorfman on 12/7/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "SkyS3ResourceData.h"

@implementation SkyS3ResourceData
- (instancetype) initWithName:(NSString *)name etag:(NSString *)etag lastModifiedDate:(NSDate *)lastModifiedDate {
    if (self = [super init]) {
        self.name = name;
        self.etag = etag;
        self.lastModifiedDate = lastModifiedDate;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ %@ Etag:%@ localURL:%@",self.name,self.lastModifiedDate,self.etag,self.localURL];
}
@end
