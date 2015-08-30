//
//  ScheduleViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 3/7/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"
@class Cinema;
@class Film;
@interface ScheduleViewModel : BaseViewModel
@property (nonatomic,strong) Cinema *cinema;
@property (nonatomic,strong) Film *film;
@property (nonatomic,strong,readonly) NSArray *scheduleEntries;
@property (nonatomic,strong) NSString *title;

- (instancetype) initWithCinema:(Cinema *)cinema;
- (instancetype) initWithFilm:(Film *)film;
@end
