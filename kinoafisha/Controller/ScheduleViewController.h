//
//  ScheduleViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/10/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Cinema;
@interface ScheduleViewController : UITableViewController
@property (nonatomic,strong) Cinema *cinema;
@property (nonatomic,strong) NSArray *scheduleEntries;
@end
