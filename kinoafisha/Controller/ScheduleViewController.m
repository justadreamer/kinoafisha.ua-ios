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
#import <XHTransformation/XHAll.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ScheduleCinemaRoomCell.h"
#import "Cinema.h"
@interface ScheduleViewController ()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
    if (self.cinema) {
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
    
    NSURL *XSLURL = [[NSBundle mainBundle] URLForResource:@"single_cinema" withExtension:@"xsl"];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:XSLURL];
    XHMantleModelAdapter *adapter = [[XHMantleModelAdapter alloc] initWithModelClass:[ScheduleEntry class]];
    XHTransformationHTMLResponseSerializer *serializer = [XHTransformationHTMLResponseSerializer serializerWithXHTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.cinema.detailURL];
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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
}

@end
