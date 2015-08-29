//
//  SkyXMLResponseSerializer.m
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#import "SkyXMLResponseSerializer.h"
#import "SkyResponseSerializer+Protected.h"
#import "SkyXSLTransformation.h"

@implementation SkyXMLResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"text/xml",@"application/rss+xml", nil];
    
    return self;
}

- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error {
    return [self.transformation JSONObjectFromXMLData:data withParams:self.params error:error];
}

@end
