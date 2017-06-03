//
//  SkyS3ResourceURLProvider.h
//  Pods
//
//  Created by Eugene Dorfman on 1/18/16.
//
//

#import <Foundation/Foundation.h>

@protocol SkyS3ResourceURLProvider <NSObject>
- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext;
@end
