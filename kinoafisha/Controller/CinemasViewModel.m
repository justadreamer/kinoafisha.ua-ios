//
//  CinemasViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "CinemasViewModel.h"
#import "Global.h"
#import "CinemasContainer.h"
#import "City.h"
#import <SkyScraper/SkyScraper.h>
#import <AFNetworking/AFNetworking.h>
#import "City.h"
#import "Cinema.h"
#import "CinemasContainer.h"
#import "AppDelegate.h"
#import <libextobjc/extobjc.h>

@interface CinemasViewModel ()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,assign,readwrite) BOOL isLoading;
@property (nonatomic,strong,readwrite) NSString *title;
@property (nonatomic,assign,readwrite) NSUInteger cinemasCount;
@property (nonatomic,strong,readwrite) NSArray *cinema;
@property (nonatomic,strong) CinemasContainer *cinemasContainer;
@end

@implementation CinemasViewModel

- (instancetype) initWithCity:(City *)city {
    if (self = [super init]) {
        self.city = city;
    }
    return self;
}

- (void) setCity:(City *)city {
    _city = city;
    [self loadData];
}

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *XSLURL = [AD.s3SyncManager URLForResource:@"cinemas" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[CinemasContainer class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.city.cinemaURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;

    self.isLoading = YES;
    @weakify(self);
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        self.isLoading = NO;
        self.cinemasContainer = responseObject;
        if ([self.cinemasContainer.cityName length]) {
            self.title = [NSString stringWithFormat:@"Кинотеатры %@",self.cinemasContainer.cityName];
        } else {
            self.title = @"Кинотеатры";
        }
        self.cinemasCount = self.cinemasContainer.cinemas.count;
        self.cinema = self.cinemasContainer.cinemas;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        NSLog(@"%@",error);
    }];
    
    [self.operation start];
}

@end
