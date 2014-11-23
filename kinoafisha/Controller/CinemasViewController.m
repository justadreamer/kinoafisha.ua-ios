//
//  CinemasViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Global.h"
#import <SkyScraper/SkyScraper.h>
#import <AFNetworking/AFNetworking.h>
#import "CinemasViewController.h"
#import "City.h"
#import "Cinema.h"
#import "CinemasContainer.h"
#import "SVProgressHUD.h"
#import "CinemaCell.h"
#import "ScheduleViewController.h"

@interface CinemasViewController ()
@property (nonatomic,strong) City *city;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,strong) CinemasContainer *cinemasContainer;
@end

@implementation CinemasViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 120;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.city isEqual:[City selectedCity]]) {
        self.city = [City selectedCity];
        self.cinemasContainer = nil;
        [self redisplayData];
        [self loadData];
    }
}

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];

    NSURL *XSLURL = [[NSBundle mainBundle] URLForResource:@"cinemas" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[CinemasContainer class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.city.cinemaURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;

    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.cinemasContainer = responseObject;
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
    if ([self.cinemasContainer.cityName length]) {
        self.title = [NSString stringWithFormat:@"Кинотеатры %@",self.cinemasContainer.cityName];
    } else {
        self.title = @"Кинотеатры";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cinemasContainer.cinemas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CinemaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CinemaCell" forIndexPath:indexPath];
    Cinema *cinema = self.cinemasContainer.cinemas[indexPath.row];
    cell.cinema = cinema;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, 0);
    [cell layoutIfNeeded];

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
    ScheduleViewController *controller = segue.destinationViewController;
    Cinema *cinema = self.cinemasContainer.cinemas[[self.tableView indexPathForSelectedRow].row];
    controller.cinema = cinema;
    // Pass the selected object to the new view controller.
}


@end
