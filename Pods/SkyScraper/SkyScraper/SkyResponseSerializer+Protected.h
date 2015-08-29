//
//  SkyResponseSerializer+Protected.h
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#ifndef Pods_SkyResponseSerializer_Protected_h
#define Pods_SkyResponseSerializer_Protected_h
#import "SkyResponseSerializer.h"

@interface SkyResponseSerializer()
- (id) applyTransformationToData:(NSData *)data withError:(NSError *__autoreleasing *)error;
@end

#endif
