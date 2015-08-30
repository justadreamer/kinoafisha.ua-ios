//
//  ScheduleViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/10/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//
#import "Global.h"
#import "ScheduleViewController.h"
#import "ScheduleEntry.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "ScheduleCinemaRoomCell.h"
#import "Cinema.h"
#import "FilmDetailViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "ScheduleViewModel.h"
#import "UIViewController+ViewModel.h"
#import "FilmDetailViewModel.h"

@interface ScheduleViewController ()<ViewModelSupport>
@property (nonatomic,strong) UIView *emptyView;
@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    
    RAC(self,title) = RACObserve(self,viewModel.title);
    
    [self defineDefaultBindings];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewModel loadDataModel];
}

- (void) redisplayData {
    [self.tableView reloadData];
    if (!self.viewModel.scheduleEntries.count) {
        [self displayEmptyView];
    } else {
        [self removeEmptyView];
    }
}

- (UIView *)emptyView {
    if (!_emptyView) {
        UILabel *emptyView = [[UILabel alloc] initWithFrame:CGRectZero];
        emptyView.text = @"Нет расписания";
        [emptyView sizeToFit];
        emptyView.center = self.view.center;
        emptyView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.emptyView = emptyView;
    }
    return _emptyView;
}

- (void) displayEmptyView {
    [self.tableView addSubview:self.emptyView];
}

- (void) removeEmptyView {
    [self.emptyView removeFromSuperview];
}

- (void) refresh:(UIBarButtonItem *)barButtonItem {
    [self.viewModel loadDataModel];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.scheduleEntries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleEntry *scheduleEntry = self.viewModel.scheduleEntries[indexPath.row];
    NSString *identifier = @"ScheduleEntityCell";
    if (scheduleEntry.type==ScheduleEntryCinemaRoom) {
        identifier = @"ScheduleCinemaRoomCell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    if (scheduleEntry.type==ScheduleEntryCinemaRoom) {
        ScheduleCinemaRoomCell *scheduleCinemaRoomCell = (ScheduleCinemaRoomCell *)cell;
        scheduleCinemaRoomCell.entry = scheduleEntry;
    } else {
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
        cell.textLabel.text = scheduleEntry.title;
        if (scheduleEntry.type==ScheduleEntryFilm) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, self.tableView.estimatedRowHeight);
    [cell layoutIfNeeded];

    return cell;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ScheduleEntry *entry = self.viewModel.scheduleEntries[[self.tableView indexPathForSelectedRow].row];
    if (entry.URL) {
        FilmDetailViewController *controller = segue.destinationViewController;
        controller.title = entry.title;
        controller.viewModel = [[FilmDetailViewModel alloc] initWithFilmURL:entry.URL];
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    ScheduleEntry *entry = self.viewModel.scheduleEntries[[self.tableView indexPathForSelectedRow].row];
    return entry.type==ScheduleEntryFilm;
}

@end
