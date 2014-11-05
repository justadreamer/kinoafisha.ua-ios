#import <Foundation/Foundation.h>
#import "XHModelAdapter.h"

@interface XHMantleModelAdapter : NSObject<XHModelAdapter>
/**
 *  a subclass of MTLModel class, instance of which will be returned by modelFromJSONObject:error: method
 */
@property (nonatomic,weak) Class modelClass;

/**
 *  A designated initializer of the XHMantleModelAdapter
 *
 *  @param modelClass a subclass of MTLModel class, instance of which will be returned by modelFromJSONObject:error: method
 *
 *  @return instance of XHMantleModelAdapter
 */
- (instancetype) initWithModelClass:(Class)modelClass NS_DESIGNATED_INITIALIZER;

@end
