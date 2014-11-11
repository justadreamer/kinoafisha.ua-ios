//
//  ScheduleEntry.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>
typedef NS_ENUM(NSUInteger,ScheduleEntryType) {
    ScheduleEntryFilm = 0,
    ScheduleEntryCinema,
    ScheduleEntryCinemaRoom
};

@interface ScheduleEntry : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) ScheduleEntryType type;
@property (nonatomic,strong) NSURL *URL;
@property (nonatomic,strong) NSArray *showTimes;
@end
