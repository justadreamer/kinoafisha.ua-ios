#import <Foundation/Foundation.h>
#import "SkyModelAdapter.h"

@interface SkyMantleModelAdapter : NSObject<SkyModelAdapter>
/**
 *  a subclass of MTLModel class, instance of which will be returned by modelFromJSONObject:error: method
 */
@property (nonatomic,weak) Class modelClass;

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Designated initializer
 *
 *  @param modelClass a subclass of MTLModel class, instance of which will be returned by modelFromJSONObject:error: method
 *
 *  @return instance of SkyMantleModelAdapter
 */
- (instancetype) initWithModelClass:(Class)modelClass NS_DESIGNATED_INITIALIZER;

@end
