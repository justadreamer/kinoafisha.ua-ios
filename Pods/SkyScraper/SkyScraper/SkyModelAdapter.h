@protocol SkyModelAdapter <NSObject>

/**
 *  implementations should provide deserialization code according in this method to the application logic 
 *  most commonly an NSDictionary corresponds to a model object
 *  an NSArray of NSDictionaries corresponds to an NSArray of model objects
 *  these cases are not enforced, implementations are capable to define this logic as needed
 *
 *  @param JSONObject can be either NSArray, NSDictionary, all other classes should be handled gracefully with according errors returned
 *  @param error      in case an error occurred return it via this output parameter
 *
 *  @return an appropriate model object - completely implementation-dependant
 */
- (id)modelFromJSONObject:(id)JSONObject error:(NSError *__autoreleasing *)error;
@end