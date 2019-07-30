//
//  FilmDetailViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@class FilmDetailViewModel;
@interface FilmDetailViewController : BaseViewController
@property (nonatomic,strong) FilmDetailViewModel *viewModel;
@end
