//
//  FilmsViewController.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/13/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FilmsViewModel;
@interface FilmsViewController : UITableViewController
@property (nonatomic,strong) FilmsViewModel *viewModel;
@end
