@protocol XHModelAdapter <NSObject>
- (id)modelFromJSONObject:(NSDictionary *)JSONObject error:(NSError *__autoreleasing *)error;
@end