// AFAmazonS3RequestSerializer.h
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

#import <AFNetworking/AFURLRequestSerialization.h>

/**
 `AFAmazonS3RequestSerializer` is an `AFHTTPRequestSerializer` subclass with convenience methods for creating requests for the Amazon S3 webservice, including creating an authorization header and building an endpoint URL for a given bucket, region, and TLS preferences.
 
 @discussion Due to aggressive cache policies from the Foundation URL Loading System cause the unsupported `If-Modified-Since` header to be sent for certain requests, the default `cachePolicy` is `NSURLRequestReloadIgnoringCacheData`.
 */
@interface SkyS3RequestSerializer : AFHTTPRequestSerializer

/**
 The S3 bucket for the client. `nil` by default.
 
 @see `SkyS3AmazonS3Manager -baseURL`
 */
@property (nonatomic, copy) NSString *bucket;

/**
 The AWS region for the client. `SkyS3AmazonS3USStandardRegion` by default. Must not be `nil`. See "AWS Regions" for defined constant values.
 
 @see `SkyS3AmazonS3Manager -baseURL`
 */
@property (nonatomic, copy) NSString *region;

/**
 The AWS STS session token. `nil` by default.
 */
@property (nonatomic, copy) NSString *sessionToken;

/**
 Whether to connect over HTTPS. `YES` by default.
 
 @see `SkyS3AmazonS3Manager -baseURL`
 */
@property (nonatomic, assign) BOOL useSSL;

/**
 A readonly endpoint URL created for the specified bucket, region, and TLS preference. `SkyS3AmazonS3Manager` uses this as a `baseURL` unless one is manually specified.
 */
@property (readonly, nonatomic, copy) NSURL *endpointURL;

/**
 Sets the access key ID and secret, used to generate authorization headers.
 
 @param accessKey The Amazon S3 Access Key ID.
 @param secret The Amazon S3 Secret.
 
 @discussion These values can be found on the AWS control panel: http://aws-portal.amazon.com/gp/aws/developer/account/index.html?action=access-key
 */
- (void)setAccessKeyID:(NSString *)accessKey
                secret:(NSString *)secret;

/**
 Returns a request with the necessary AWS authorization HTTP header fields from the specified request using the provided credentials.
 
 @param request The request.
 @param error The error that occured while constructing the request.
 
 @return The request with necessary `Authorization` and `Date` HTTP header fields.
 */
- (NSURLRequest *)requestBySettingAuthorizationHeadersForRequest:(NSURLRequest *)request
                                                           error:(NSError * __autoreleasing *)error;

@end

///----------------
/// @name Constants
///----------------

/**
 ## AWS Regions
 
 The following AWS regions are defined:
 
 `SkyS3AmazonS3USStandardRegion`: US Standard (s3.amazonaws.com);
 
 For a full list of available regions, see http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region
 */
extern NSString * const SkyS3AmazonS3USStandardRegion;
