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
#import "BaseViewModel+Protected.h"

@interface ScheduleViewModel()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
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
    self.dataModel = film.scheduleEntries;
}

- (NSArray *)scheduleEntries {
    return self.dataModel;
}

#pragma mark - BaseViewModel overrides

- (NSString *)XSLTName {
    return @"single_cinema";
}

- (NSURL *)URL {
    return self.cinema.detailURL;
}

- (Class)dataModelClass {
    return ScheduleEntry.class;
}

@end
