//
//  FilmDetailViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmDetailViewController.h"
#import "Film.h"
#import "FilmDetailHeaderCell.h"
#import "Attribute.h"
#import "AttributeCell.h"
#import "ScheduleViewController.h"
#import "AppDelegate.h"
#import "ScheduleViewModel.h"
#import "UIViewController+ViewModel.h"
#import "FilmDetailViewModel.h"

@interface FilmDetailViewController ()<ViewModelSupport>
@end

@implementation FilmDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.viewModel action:@selector(loadDataModel)];
    [self defineDefaultBindings];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel loadDataModel];
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRows];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row==0) {/*header*/
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailHeaderCell"];
        ((FilmDetailHeaderCell *)cell).film = self.viewModel.film;
    } else if (indexPath.row>0 && indexPath.row<=self.viewModel.film.attributes.count) {/*attributes*/
        Attribute *attribute = self.viewModel.film.attributes[indexPath.row-1];
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailAttributeCell"];
        ((AttributeCell *)cell).attribute = attribute;
    } else { /*description*/
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailDescriptionCell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = self.viewModel.film.descr;

    }
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
    [cell layoutIfNeeded];

    return cell;
}


#pragma mark - UITableViewDelegate


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ScheduleViewController *scheduleViewController = (ScheduleViewController *)segue.destinationViewController;
    ScheduleViewModel *scheduleViewModel = [[ScheduleViewModel alloc] initWithFilm:self.viewModel.film];
    scheduleViewController.viewModel = scheduleViewModel;
}

@end
