//
//  FilmDetailViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilmDetailViewModel;
@interface FilmDetailViewController : UITableViewController
@property (nonatomic,strong) FilmDetailViewModel *viewModel;
@end
