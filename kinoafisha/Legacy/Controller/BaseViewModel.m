//
//  BaseViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/29/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "BaseViewModel+Protected.h"
#import "Global.h"
#import "AppDelegate.h"
#import <libextobjc/extobjc.h>
#import <AFNetworking/AFNetworking.h>
#import <SkyScraper/SkyScraper.h>
#import <SkyScraper/SkyHTMLResponseSerializer.h>
#import <SkyScraper/SkyMantleModelAdapter.h>
#import "Flurry.h"

@interface BaseViewModel()
+ (NSURLSession *) session;
@property (nonatomic,strong) NSURLSessionDataTask *task;
@end

@implementation BaseViewModel
@synthesize isLoading = _isLoading;
@synthesize dataModel = _dataModel;
@synthesize error = _error;
@synthesize loadable = _needsLoading;

- (void) dealloc {
    [self.task cancel];
}

+ (NSURLSession *)session {
    static dispatch_once_t onceToken;
    static NSURLSession *_session;
    dispatch_once(&onceToken, ^{
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    });
    return _session;
}

- (BOOL) loadable {
    return YES;
}

- (void) loadDataModel {
    if (!self.loadable) {
        return;
    }

    [self.task cancel];
    
    NSURL *citiesXSLURL = [AD.s3SyncManager URLForResource:self.XSLTName withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:citiesXSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:self.dataModelClass];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];

    
    self.isLoading = YES;
    self.error = nil;

    @weakify(self)
    self.task = [BaseViewModel.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        @strongify(self)
        if (data && !error) {
            NSError *serializationError;
            id responseObject = [serializer responseObjectForResponse:response data:data error:&serializationError];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.dataModel = [self processLoadedDataModel:responseObject];
                self.isLoading = NO;
                [Flurry logEvent:@"data did load" withParameters:@{@"view_model":NSStringFromClass([self class])}];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.isLoading = NO;
                self.error = error;
                [Flurry logEvent:@"data did fail to load" withParameters:@{@"view_model":NSStringFromClass([self class])}];
                [Flurry logError:@"data did fail to load" message:@"" error:error];
                NSLog(@"%@",error);
            });
        }
    }];
    
    [self.task resume];
    
}

#pragma mark - default implementations of overridables
- (NSString *)XSLTName {
    return @"";
}

- (NSURL *)URL {
    return [NSURL URLWithString:KinoAfishaBaseURL];
}

- (Class) dataModelClass {
    return NSObject.class;
}

- (nullable id)processLoadedDataModel:(nullable id)dataModel {
    return dataModel;
}

- (NSString *)loadingIndicatorMessage {
    return @"Загрузка...";
}

@end
