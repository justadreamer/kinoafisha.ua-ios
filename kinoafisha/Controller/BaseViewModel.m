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

@interface BaseViewModel()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation BaseViewModel
@synthesize isLoading = _isLoading;
@synthesize dataModel = _dataModel;
@synthesize error = _error;

- (void) dealloc {
    self.operation.completionBlock = nil;
    [self.operation cancel];
}

- (void) loadDataModel {
    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *citiesXSLURL = [AD.s3SyncManager URLForResource:self.XSLTName withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:citiesXSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:self.dataModelClass];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.URL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    @weakify(self);
    self.isLoading = YES;
    self.error = nil;

    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        self.dataModel = [self processLoadedDataModel:responseObject];
        self.isLoading = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        self.error = error;
        NSLog(@"%@",error);
    }];
    
    [self.operation start];
    
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
