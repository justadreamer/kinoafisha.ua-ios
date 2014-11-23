#import "SkyHTMLResponseSerializer.h"
#import "SkyXSLTransformation.h"

@interface SkyHTMLResponseSerializer()

@end

@implementation SkyHTMLResponseSerializer

+ (instancetype)serializerWithXSLTransformation:(SkyXSLTransformation *)transformation params:(NSDictionary *)params modelAdapter:(NSObject<SkyModelAdapter> *)modelAdapter{
    SkyHTMLResponseSerializer *serializer = [[self alloc] init];
    serializer.transformation = transformation;
    serializer.params = params;
    serializer.modelAdapter = modelAdapter;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error) {
            return nil;
        }
    }

    id JSONObject = [self.transformation JSONObjectFromHTMLData:data withParams:self.params error:error];
    id responseObject = JSONObject;
    if (JSONObject && self.modelAdapter) {
        responseObject = [self.modelAdapter modelFromJSONObject:JSONObject error:error];
    }
    return responseObject;
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
    SkyHTMLResponseSerializer *serializer = [[[self class] allocWithZone:zone] init];
    
    return serializer;
}

@end
