//
//  SkyJSONResponseSerializer.m
//  Pods
//
//  Created by Oleg Kovtun on 13.04.15.
//
//

#import "SkyJSONResponseSerializer.h"

@implementation SkyJSONResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", nil];
    
    return self;
}

- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error {
    NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    data = [NSPropertyListSerialization dataWithPropertyList:jsonDict format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
    return [self.transformation JSONObjectFromXMLData:data withParams:self.params error:error];
}

@end