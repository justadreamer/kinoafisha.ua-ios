// SkyS3AmazonS3Manager.m
//
// Copyright (c) 2011–2015 AFNetworking (http://afnetworking.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SkyS3AmazonS3Manager.h"
#import "SkyS3ResponseSerializer.h"
#import "SkyS3RequestSerializer.h"

NSString * const SkyS3AmazonS3ManagerErrorDomain = @"com.alamofire.networking.skys3.error";

@interface SkyS3AmazonS3Manager ()
@property (readwrite, nonatomic, strong) NSURL *baseURL;
@end

@implementation SkyS3AmazonS3Manager
@synthesize baseURL = _s3_baseURL;
@synthesize requestSerializer = _requestSerializer;

- (instancetype)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [SkyS3RequestSerializer serializer];
    self.responseSerializer = [SkyS3ResponseSerializer serializer];
    
    return self;
}

- (id)initWithAccessKeyID:(NSString *)accessKey
                   secret:(NSString *)secret
{
    self = [self initWithBaseURL:nil];
    if (!self) {
        return nil;
    }
    
    [self.requestSerializer setAccessKeyID:accessKey secret:secret];
    
    return self;
}

- (NSURL *)baseURL {
    if (!_s3_baseURL) {
        return self.requestSerializer.endpointURL;
    }
    
    return _s3_baseURL;
}

#pragma mark Bucket Operations

- (NSURLSessionDataTask *)getBucket:(NSString *)bucket
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(bucket);
    
    NSURLSessionDataTask *task = [self GET:bucket parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionTask *task, NSError *error) {
        if (failure) {
            failure([SkyS3AmazonS3Manager augmentedErrorWith:error forTask:task]);
        }
    }];
    
    return task;
}

#pragma mark Object Operations

- (NSURLSessionDownloadTask *)getObjectWithPath:(NSString *)path
                                  outputFileURL:(NSURL *)outputFileURL
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSError *error))failure
{
    NSParameterAssert(path);
    
    path = [path stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString] parameters:nil error:&serializationError];
    if (serializationError) {
        if (failure) {
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
        }
        
        return nil;
    }
    
    __block NSURLSessionDownloadTask *task = [self downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        return outputFileURL;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            if (failure) {
                failure([SkyS3AmazonS3Manager augmentedErrorWith:error forTask:task]);
            }
        } else {
            if (success) {
                // unfortunately new API doesn't update NSFileModificationDate attribute for the downloaded file, so we should do it manually
                NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
                [attributes addEntriesFromDictionary:[[NSFileManager defaultManager] attributesOfItemAtPath:filePath.path error:nil] ?: @{}];
                attributes[NSFileModificationDate] = [NSDate date];
                [[NSFileManager defaultManager] setAttributes:attributes ofItemAtPath:filePath.path error:nil];
                success(filePath);
            }
        }
    }];
    
    [task resume];
    return task;
}

#pragma mark - Accessors

+ (NSError *) augmentedErrorWith:(NSError *)error forTask:(NSURLSessionTask *)task {
    if (error.userInfo.count==0) {
        NSURL *URL = task.originalRequest.URL;
        return [NSError errorWithDomain:error.domain
                                   code:error.code
                               userInfo:@{NSURLErrorFailingURLStringErrorKey:URL.absoluteString ?: @"", NSURLErrorFailingURLErrorKey:URL ?: NSURL.new}];
    }
    return error;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    SkyS3AmazonS3Manager *manager = [[[self class] allocWithZone:zone] initWithBaseURL:_s3_baseURL];
    
    manager.requestSerializer = [self.requestSerializer copyWithZone:zone];
    manager.responseSerializer = [self.responseSerializer copyWithZone:zone];
    
    return manager;
}

@end
