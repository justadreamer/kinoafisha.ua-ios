//
//  UIViewController+ViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModel.h"
#import "UIScrollView+EmptyDataSet.h"

@interface BaseViewController : UITableViewController<DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
//call in viewDidLoad
- (void)defineDefaultBindings;

/**
 *  override to return a specific viewModel
 */
- (id<ViewModel>)viewModel;

/**
 *  override with appropriate logic for refreshing the dataset
 */
- (void)redisplayData;

@end
