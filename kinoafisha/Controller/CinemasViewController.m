//
//  CinemasViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//
#import "Global.h"
#import "CinemasViewController.h"
#import "CinemaCell.h"
#import "ScheduleViewController.h"
#import "SVProgressHUD.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CinemasViewModel.h"
#import "City.h"
#import <libextobjc/extobjc.h>

@interface CinemasViewController ()
@end

@implementation CinemasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.viewModel action:@selector(loadDataModel)];

    self.viewModel = [[CinemasViewModel alloc] initWithCity:[City  selectedCity]];

    RAC(self,title) = RACObserve(self, viewModel.title);
    
    [self defineDefaultBindings];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel loadDataModel];
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cinemas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CinemaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CinemaCell" forIndexPath:indexPath];
    Cinema *cinema = self.viewModel.cinemas[indexPath.row];
    cell.cinema = cinema;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
    [cell layoutIfNeeded];

    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ScheduleViewController *controller = segue.destinationViewController;
    NSUInteger idx = [self.tableView indexPathForSelectedRow].row;
    ScheduleViewModel *scheduleViewModel = [self.viewModel scheduleViewModelForCinemaAtIndex:idx];
    controller.viewModel = scheduleViewModel;
}


@end
