//
//  FilmsViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/13/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmsViewController.h"
#import "Film.h"
#import <SkyScraper/SkyScraper.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "Global.h"
#import "City.h"
#import "FilmDetailViewController.h"
#import "FilmCell.h"
#import "AppDelegate.h"

@interface FilmsViewController ()
@property (nonatomic,strong) NSArray *films;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,strong) City *city;
@end

@implementation FilmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.city isEqual:[City selectedCity]]) {
        self.city = [City selectedCity];
        self.films = nil;
        [self redisplayData];
        [self loadData];
    }
}

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];
    
    NSURL *XSLURL = [AD.s3SyncManager URLForResource:@"films" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:XSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[Film class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    City *city = [City selectedCity];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:city.filmURL];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.films = responseObject;
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
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.films.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilmCell"];
    Film *film = self.films[indexPath.row];
    cell.film = film;

    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, self.tableView.estimatedRowHeight);
    [cell layoutIfNeeded];

    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FilmDetailViewController *controller = segue.destinationViewController;
    Film *film = self.films[[self.tableView indexPathForSelectedRow].row];
    controller.filmURL = film.detailURL;
    controller.title = film.title;
}


@end
