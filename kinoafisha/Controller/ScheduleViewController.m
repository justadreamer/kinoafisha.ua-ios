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
#import <AFNetworking/AFNetworking.h>
#import <SkyScraper/SkyScraper.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ScheduleCinemaRoomCell.h"
#import "Cinema.h"
#import "FilmDetailViewController.h"
#import "AppDelegate.h"

@interface ScheduleViewController ()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    if (self.cinema) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
        self.title = self.cinema.name;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.cinema.detailURL && !self.scheduleEntries) {
        [self loadData];
    } else if (!self.scheduleEntries.count) {
        [self displayEmptyView];
    }
}

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *XSLURL = [AD.s3SyncManager URLForResource:@"single_cinema" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[ScheduleEntry class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.cinema.detailURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.scheduleEntries = responseObject;
        [weakSelf redisplayData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"%@",error);
    }];
    
    [SVProgressHUD showWithStatus:@"Загрузка..."];
    [self.operation start];
}

- (void) redisplayData {
    [self.tableView reloadData];
    if (!self.scheduleEntries.count) {
        [self displayEmptyView];
    }
}

- (void) displayEmptyView {
    UILabel *emptyView = [[UILabel alloc] initWithFrame:CGRectZero];
    emptyView.text = @"Нет расписания";
    [emptyView sizeToFit];
    emptyView.center = self.view.center;
    emptyView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.tableView addSubview:emptyView];
}

- (void) refresh:(UIBarButtonItem *)barButtonItem {
    [self loadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.scheduleEntries.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleEntry *scheduleEntry = self.scheduleEntries[indexPath.row];
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
    ScheduleEntry *entry = self.scheduleEntries[[self.tableView indexPathForSelectedRow].row];
    if (entry.URL) {
        FilmDetailViewController *controller = segue.destinationViewController;
        controller.title = entry.title;
        controller.filmURL = entry.URL;
    }
}

- (BOOL) shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    ScheduleEntry *entry = self.scheduleEntries[[self.tableView indexPathForSelectedRow].row];
    return entry.type==ScheduleEntryFilm;
}

@end
