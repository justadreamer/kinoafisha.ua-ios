//
//  CinemasViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;
@class CinemasContainer;
@class ScheduleViewModel;
#import "BaseViewModel.h"

@interface CinemasViewModel : BaseViewModel
@property (nonatomic,strong) City *city;
@property (nonatomic,strong,readonly) NSString *title;
@property (nonatomic,strong,readonly) NSArray *cinemas;

- (instancetype) initWithCity:(City *)city;
- (ScheduleViewModel *) scheduleViewModelForCinemaAtIndex:(NSUInteger)idx;

@end
