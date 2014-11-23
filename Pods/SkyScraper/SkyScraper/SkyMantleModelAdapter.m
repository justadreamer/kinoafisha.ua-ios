#import "SkyXSLTransformation.h"
#import "SkyMantleModelAdapter.h"
#import "SkyModelAdapter.h"
#import "MTLJSONAdapter.h"

@implementation SkyMantleModelAdapter

- (instancetype) initWithModelClass:(Class)modelClass {
    if (self = [super init]) {
        self.modelClass = modelClass;
    }
    return self;
}

-(id) modelFromJSONObject:(id)JSONObject error:(NSError *__autoreleasing *)error {
    id model = nil;
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        model = [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:JSONObject error:error];
    } else if ([JSONObject isKindOfClass:[NSArray class]]) {
        model = [MTLJSONAdapter modelsOfClass:self.modelClass fromJSONArray:JSONObject error:error                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             ];
    } else {
        *error = [NSError errorWithDomain:SkyScraperErrorDomain code:101 userInfo:@{NSLocalizedDescriptionKey:@"JSONObject of the unsupported type"}];
    }
    return model;
}
@end
