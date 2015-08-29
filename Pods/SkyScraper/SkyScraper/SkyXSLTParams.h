//
//  SkyXSLTParams.h
//  Pods
//
//  Created by Eugene Dorfman on 3/30/15.
//
//

#import <Foundation/Foundation.h>

@interface SkyXSLTParams : NSObject {

}
@property (nonatomic,assign,readonly) char **paramsBuf;
@property (nonatomic,strong) NSDictionary *params;
- (instancetype) initWithParams:(NSDictionary *)params;
@end
