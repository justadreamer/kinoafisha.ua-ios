//
//  SkyS3Directory.h
//  Pods
//
//  Created by Eugene Dorfman on 1/18/16.
//
//

#import <Foundation/Foundation.h>
#import <SkyS3Sync/SkyS3ResourceURLProvider.h>

/**
 *  A special object, which manages a specified directory and provides
 *  resource URLs within it - if resources pointed at exist.
 */
@interface SkyS3Directory : NSObject<SkyS3ResourceURLProvider>
@property (nonnull, nonatomic, strong) NSURL *directoryURL;
- (nonnull instancetype) initWithDirectoryURL:(nonnull NSURL *)directoryURL;
- (nonnull instancetype) init NS_UNAVAILABLE;
- (nullable NSURL *) URLForResourceWithFileName:(nonnull NSString *)fileName;
@end
