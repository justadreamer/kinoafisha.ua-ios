// SkyS3AmazonS3Manager.h
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

#import <AFNetworking/AFHTTPSessionManager.h>
#import "SkyS3RequestSerializer.h"

/**
 SkyS3AmazonS3Manager` is an `AFHTTPRequestOperationManager` subclass for interacting with the Amazon S3 webservice API (http://aws.amazon.com/s3/).
 */
@interface SkyS3AmazonS3Manager : AFHTTPSessionManager <NSSecureCoding, NSCopying>

/**
 The base URL for the S3 manager.
 
 @discussion By default, the `baseURL` of `SkyS3AmazonS3Manager` is derived from the `bucket` and `region` values. If `baseURL` is set directly, it will override the default `baseURL` and disregard values set for the `bucket`, `region`, and `useSSL` properties.
 */
@property (readonly, nonatomic, strong) NSURL *baseURL;

/**
 Requests created by `SkyS3AmazonS3Manager` are serialized by a subclass of `SkyS3RequestSerializer`, which is responsible for encoding credentials, and any specified region and bucket.
 */
@property (nonatomic, strong) SkyS3RequestSerializer <AFURLRequestSerialization> * requestSerializer;

/**
 Initializes and returns a newly allocated Amazon S3 client with specified credentials.
 
 This is the designated initializer.
 
 @param accessKey The AWS access key.
 @param secret The AWS secret.
 */
- (id)initWithAccessKeyID:(NSString *)accessKey
                   secret:(NSString *)secret;


///------------------------
/// @name Bucket Operations
///------------------------

/**
 Lists information about the objects in a bucket for a user that has read access to the bucket.
 
 @param bucket The S3 bucket to get. Must not be `nil`.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the response object from the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the `NSError` object describing error that occurred.
 
 @return The operation that was enqueued on operationQueue
 */
- (NSURLSessionDataTask *)getBucket:(NSString *)bucket
                            success:(void (^)(id responseObject))success
                            failure:(void (^)(NSError *error))failure;


///------------------------
/// @name Bucket Operations
///------------------------

/**
 Gets an object for a user that has read access to the object.
 
 @param path The object path. Must not be `nil`.
 @param outputFileURL The destination file URL.
 @param success A block object to be executed when the request operation finishes successfully. This block has no return value and takes a single argument: the response object from the server.
 @param failure A block object to be executed when the request operation finishes unsuccessfully, or that finishes successfully, but encountered an error while parsing the response data. This block has no return value and takes a single argument: the `NSError` object describing error that occurred.
 
 @return The operation that was enqueued
 */
- (NSURLSessionDownloadTask *)getObjectWithPath:(NSString *)path
                                  outputFileURL:(NSURL *)outputFileURL
                                        success:(void (^)(id responseObject))success
                                        failure:(void (^)(NSError *error))failure;

@end

///----------------
/// @name Constants
///----------------

/**
 ## Error Domain
 
 `SkyS3AmazonS3ManagerErrorDomain`
 SkyS3AmazonS3Manager errors. Error codes for `SkyS3AmazonS3ManagerErrorDomain` correspond to codes in `NSURLErrorDomain`.
 */
extern NSString * const SkyS3AmazonS3ManagerErrorDomain;
