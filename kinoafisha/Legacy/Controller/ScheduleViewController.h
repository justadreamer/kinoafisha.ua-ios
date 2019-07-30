//
//  ScheduleViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/10/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class Cinema;
@class ScheduleViewModel;
@interface ScheduleViewController : BaseViewController
@property (nonatomic,strong) ScheduleViewModel *viewModel;
@end
