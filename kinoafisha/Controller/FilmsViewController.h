//
//  FilmsViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/13/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class FilmsViewModel;

@interface FilmsViewController : BaseViewController
@property (nonatomic,strong) FilmsViewModel *viewModel;
@end
