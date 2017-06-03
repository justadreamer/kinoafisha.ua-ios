//
//  SkyResponseSerializer.h
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFURLResponseSerialization.h>
#import "SkyModelAdapter.h"
#import "SkyXSLTransformation.h"

@interface SkyResponseSerializer : AFHTTPResponseSerializer
/**
 *  Transformation object used to convert HTML into JSON dictionary
 */
@property (nonatomic,strong) SkyXSLTransformation *transformation;

/**
 *  A params dictionary passed to XSLTransformation
 */
@property (nonatomic,strong) NSDictionary *params;

/**
 *  If set, will be used to convert a JSON dictionary into model object
 */
@property (nonatomic,strong) NSObject<SkyModelAdapter> *modelAdapter;

/**
 *  A factory method for instantiating a serializer object
 *
 *  @param transformation an XSLTransformation instance used to conver HTML into JSON dictionary
 *  @param params         optional params dictionary passed to XSLTransformation to convert HTML into JSON dictionary
 *  @param modelAdapter   an option model adapter object used to convert JSON dictionary into model object
 *
 *  @return an instance of the serializer
 */
+ (instancetype)serializerWithXSLTransformation:(SkyXSLTransformation *)transformation params:(NSDictionary *)params modelAdapter:(NSObject<SkyModelAdapter> *)modelAdapter;
@end
