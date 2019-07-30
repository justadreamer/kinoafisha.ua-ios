//
//  CinemasViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "CinemasViewModel.h"
#import "CinemasContainer.h"
#import "City.h"
#import "City.h"
#import "Cinema.h"
#import "CinemasContainer.h"
#import "ScheduleViewModel.h"
#import "BaseViewModel+Protected.h"
#import "Global.h"
#import "ReactiveCocoa.h"
#import "extobjc.h"
#import "Flurry.h"

@interface CinemasViewModel ()
@property (nonatomic,strong,readwrite) NSString *title;
@end

@implementation CinemasViewModel
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype) initWithCity:(City *)city {
    if (self = [super init]) {
        self.city = city;
        @weakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DidChangeCityNotification object:nil] subscribeNext:^(NSNotification *notification) {
            @strongify(self);
            self.city = notification.userInfo[CityKey];
            [self loadDataModel];
        }];
    }
    return self;
}

- (void) setCity:(City *)city {
    _city = city;
    if ([city.name length]) {
        self.title = [NSString stringWithFormat:@"Кинотеатры %@",city.name];
    } else {
        self.title = @"Кинотеатры";
    }
    self.dataModel = nil;
}

- (ScheduleViewModel *) scheduleViewModelForCinemaAtIndex:(NSUInteger)idx {
    Cinema *cinema = self.cinemas[idx];
    [Flurry logEvent:@"Schedule for cinema" withParameters:@{@"cinema":cinema.name?:@""}];
    return [[ScheduleViewModel alloc] initWithCinema:cinema];
}

- (NSArray *) cinemas {
    return self.dataModel;
}

#pragma mark - BaseViewModel overrides
- (NSString *)XSLTName {
    return @"cinemas";
}

- (NSURL *) URL {
    return self.city.cinemaURL;
}

- (Class) dataModelClass {
    return CinemasContainer.class;
}

- (id) processLoadedDataModel:(nullable CinemasContainer *)cinemasContainer {
    return cinemasContainer.cinemas;
}

@end
