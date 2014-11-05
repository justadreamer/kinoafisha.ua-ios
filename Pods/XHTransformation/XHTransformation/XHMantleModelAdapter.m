#import "XHMantleModelAdapter.h"
#import "XHModelAdapter.h"
#import "MTLJSONAdapter.h"

@implementation XHMantleModelAdapter

- (instancetype) initWithModelClass:(Class)modelClass {
    if (self = [super init]) {
        self.modelClass = modelClass;
    }
    return self;
}

-(id) modelFromJSONObject:(NSDictionary *)JSONObject error:(NSError *__autoreleasing *)error {
    return [MTLJSONAdapter modelOfClass:self.modelClass fromJSONDictionary:JSONObject error:error];
}
@end
