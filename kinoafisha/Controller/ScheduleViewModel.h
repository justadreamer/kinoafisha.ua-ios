//
//  ScheduleViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 3/7/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Cinema;
@class Film;
@interface ScheduleViewModel : NSObject
@property (nonatomic,strong) Cinema *cinema;
@property (nonatomic,strong) Film *film;
@property (nonatomic,strong) NSArray *scheduleEntries;
@property (nonatomic,strong) NSString *title;

@property (nonatomic,assign,readonly) BOOL isLoading;

- (instancetype) initWithCinema:(Cinema *)cinema;
- (instancetype) initWithFilm:(Film *)film;
- (void) loadData;
@end
