#import "SkyHTMLResponseSerializer.h"
#import "SkyXSLTransformation.h"
#import "SkyResponseSerializer+Protected.h"

@implementation SkyHTMLResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    return self;
}

- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error {
    return [self.transformation JSONObjectFromHTMLData:data withParams:self.params error:error];
}

@end
