//
//  UIViewController+ViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewModel.h"

@protocol ViewModelSupport<NSObject>
- (id<ViewModel>) viewModel;
- (void)redisplayData;
@end

@interface UIViewController (ViewModel)
//call in viewDidLoad
- (void)defineDefaultBindings;

@end
