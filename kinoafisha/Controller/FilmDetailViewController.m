//
//  FilmDetailViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmDetailViewController.h"
#import "Film.h"
#import "Global.h"
#import <AFNetworking/AFNetworking.h>
#import <SkyScraper/SkyScraper.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "FilmDetailHeaderCell.h"
#import "Attribute.h"
#import <ObjectiveSugar.h>
#import "AttributeCell.h"
#import "ScheduleViewController.h"
#import "AppDelegate.h"

@interface FilmDetailViewController ()
@property (nonatomic,strong) Film *film;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation FilmDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 180;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    if (self.filmURL) {
        [self loadData];
    }
}

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *XSLURL = [AD.s3SyncManager URLForResource:@"single_film" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[Film class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.filmURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.film = responseObject;
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
}


#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return self.film ? 1 : 0;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 1/*title*/+self.film.attributes.count/*number of attributes*/+1/*description*/;
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row==0) {/*header*/
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailHeaderCell"];
        ((FilmDetailHeaderCell *)cell).film = self.film;
    } else if (indexPath.row>0 && indexPath.row<=self.film.attributes.count) {/*attributes*/
        Attribute *attribute = self.film.attributes[indexPath.row-1];
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailAttributeCell"];
        ((AttributeCell *)cell).attribute = attribute;
    } else { /*description*/
        cell = [tableView dequeueReusableCellWithIdentifier:@"FilmDetailDescriptionCell"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.text = self.film.descr;

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
    scheduleViewController.title = self.film.title;
    scheduleViewController.scheduleEntries = self.film.scheduleEntries;
}

@end
