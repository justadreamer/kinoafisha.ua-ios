// SkyS3OnoResponseSerializer.m
// 
// Copyright (c) 2014 AFNetworking (http://afnetworking.com)
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

#import "SkyS3OnoResponseSerializer.h"
#import "Ono.h"

@interface _SkyS3OnoXMLResponseSerializer : SkyS3OnoResponseSerializer
@end

@interface _SkyS3OnoHTMLResponseSerializer : SkyS3OnoResponseSerializer
@end

#pragma mark -

@implementation SkyS3OnoResponseSerializer

+ (_SkyS3OnoXMLResponseSerializer *)sharedXMLSerializer {
    static _SkyS3OnoXMLResponseSerializer *_sharedXMLSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedXMLSerializer = [self XMLResponseSerializer];
    });

    return _sharedXMLSerializer;
}

+ (_SkyS3OnoHTMLResponseSerializer *)sharedHTMLSerializer {
    static _SkyS3OnoHTMLResponseSerializer *_sharedHTMLSerializer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHTMLSerializer = [self HTMLResponseSerializer];
    });

    return _sharedHTMLSerializer;
}

+ (instancetype)XMLResponseSerializer {
    return [[_SkyS3OnoXMLResponseSerializer alloc] init];
}

+ (instancetype)HTMLResponseSerializer {
    return [[_SkyS3OnoHTMLResponseSerializer alloc] init];
}

+ (instancetype)serializer {
    return [[self alloc] init];
}

#pragma mark - AFURLResponserSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    id responseObject = nil;
    NSError *serializationError = nil;

    if (!responseObject) {
        responseObject = [[[self class] sharedXMLSerializer] responseObjectForResponse:response data:data error:&serializationError];
    }

    if (!responseObject) {
        responseObject = [[[self class] sharedHTMLSerializer] responseObjectForResponse:response data:data error:&serializationError];
    }

    if (error) {
        *error = serializationError;
    }

    return responseObject;
}

@end

#pragma mark -

@implementation _SkyS3OnoXMLResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"application/xml", nil];

    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return nil;
    }

    return [ONOXMLDocument XMLDocumentWithData:data error:error];
}

@end

#pragma mark -

@implementation _SkyS3OnoHTMLResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];

    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return nil;
    }

    return [ONOXMLDocument HTMLDocumentWithData:data error:error];
}

@end
