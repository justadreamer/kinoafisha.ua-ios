//
//  SkyResponseSerializer.m
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#import "SkyResponseSerializer.h"

@implementation SkyResponseSerializer

+ (instancetype)serializerWithXSLTransformation:(SkyXSLTransformation *)transformation params:(NSDictionary *)params modelAdapter:(NSObject<SkyModelAdapter> *)modelAdapter{
    SkyResponseSerializer *serializer = [[self alloc] init];
    serializer.transformation = transformation;
    serializer.params = params;
    serializer.modelAdapter = modelAdapter;
    
    return serializer;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return nil;
    }
    
    id JSONObject = nil;
    if ([data isKindOfClass:NSData.class]) {
        JSONObject = [self applyTransformationToData:data withError:error];
    } else if ([data isKindOfClass:NSDictionary.class] || [data isKindOfClass:NSArray.class]) {
        JSONObject = [self applyTransformationToJSONObject:data withError:error];
    }
    
    id responseObject = JSONObject;
    if (JSONObject && self.modelAdapter) {
        responseObject = [self.modelAdapter modelFromJSONObject:JSONObject error:error];
    }
    return responseObject;
}

//override in subclasses
- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error {
    return nil;
}

//override in subclasses
- (id) applyTransformationToJSONObject:(id)JSONObject withError:(NSError *__autoreleasing *)error {
    return nil;
}

#pragma mark - NSSecureCoding

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [super encodeWithCoder:coder];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SkyResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    
    return serializer;
}


@end
