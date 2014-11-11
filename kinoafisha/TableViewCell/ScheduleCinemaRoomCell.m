//
//  ScheduleCinemaRoomCell.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "ScheduleCinemaRoomCell.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
@interface ScheduleCinemaRoomCell()
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *scheduleLabel;
@end

@implementation ScheduleCinemaRoomCell
- (void) setEntry:(ScheduleEntry *)entry {
    _entry = entry;
    self.titleLabel.text = self.entry.title;
    self.scheduleLabel.text = [self.entry.showTimes join:@" "];
}

@end
