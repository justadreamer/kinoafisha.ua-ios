//
//  CinemasViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CinemasViewModel;

@interface CinemasViewController : UITableViewController
@property (nonatomic,strong) CinemasViewModel *viewModel;
@end
