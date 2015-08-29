//
//  ScheduleViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 3/7/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "ScheduleViewModel.h"
#import "Cinema.h"
#import <AFNetworking/AFNetworking.h>
#import <SkyScraper/SkyScraper.h>
#import "AppDelegate.h"
#import <libextobjc/extobjc.h>
#import "Global.h"
#import "ScheduleEntry.h"
#import "Film.h"

@interface ScheduleViewModel()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,assign,readwrite) BOOL isLoading;
@end

@implementation ScheduleViewModel
- (instancetype) initWithCinema:(Cinema *)cinema {
    if (self = [super init]) {
        self.cinema = cinema;
    }
    return self;
}

- (instancetype) initWithFilm:(Film *)film {
    if (self = [super init]) {
        self.film = film;
    }
    return self;
}

- (void) setCinema:(Cinema *)cinema {
    _cinema = cinema;
    self.title = cinema.name;
}

- (void) setFilm:(Film *)film {
    _film = film;
    self.title = film.title;
    self.scheduleEntries = film.scheduleEntries;
}

- (void) loadData {
    if (self.film) {
        return; //we've got data if we are a schedule view model for film
    }

    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *XSLURL = [AD.s3SyncManager URLForResource:@"single_cinema" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[ScheduleEntry class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.cinema.detailURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    self.isLoading = YES;
    @weakify(self);
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        self.isLoading = NO;
        self.scheduleEntries = responseObject;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        NSLog(@"%@",error);
    }];

    [self.operation start];
}

@end
