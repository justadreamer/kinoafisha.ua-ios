//
//  CitiesViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Global.h"
#import "CitiesViewController.h"
#import <SkyScraper/SkyScraper.h>
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFNetworking/AFNetworking.h>
#import "SVProgressHUD.h"
#import "City.h"
#import "AppDelegate.h"

@interface CitiesViewController ()
@property (nonatomic,strong) NSArray *cities;
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@end

@implementation CitiesViewController

- (void) dealloc {
    self.operation.completionBlock = nil;
    [self.operation cancel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Киноафиша города";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.cities) {
        [self loadData];
    }
}

#pragma mark -

- (void) loadData {
    self.operation.completionBlock = nil;
    [self.operation cancel];

    NSURL *citiesXSLURL = [AD.s3SyncManager URLForResource:@"cities" withExtension:@"xsl"];
    SkyXSLTransformation *transformation = [[SkyXSLTransformation alloc] initWithXSLTURL:citiesXSLURL];
    SkyMantleModelAdapter *adapter = [[SkyMantleModelAdapter alloc] initWithModelClass:[City class]];
    SkyHTMLResponseSerializer *serializer = [SkyHTMLResponseSerializer serializerWithXSLTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[KinoAfishaBaseURL stringByAppendingString:@"/cinema"]]];
    [request setValue:UA forHTTPHeaderField:@"User-Agent"];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSArray *cities = responseObject;
        cities = [cities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        weakSelf.cities = cities;
        if (weakSelf.cities.count && ![City selectedCity]) {
            City* defaultSelection = [weakSelf.cities find:^BOOL(City *city) {
                return city.isDefaultSelection;
            }];
            [City setSelectedCity:defaultSelection];
        }
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
    NSIndexPath *indexPath = [self indexPathForCurrentSelection];
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    City *city = self.cities[indexPath.row];
    cell.textLabel.text = city.name;
    cell.accessoryType = [[City selectedCity] isEqual:city] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self cellForCurrentSelection].accessoryType = UITableViewCellAccessoryNone;
    [City setSelectedCity:self.cities[indexPath.row]];
    [self cellForCurrentSelection].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tabBarController.viewControllers each:^(UIViewController *controller) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)controller;
            [navController popToRootViewControllerAnimated:NO];
        }
    }];
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark -

- (NSIndexPath *) indexPathForCurrentSelection {
    NSIndexPath *indexPath = nil;
    if ([City selectedCity]) {
        NSUInteger idx = [self.cities indexOfObject:[City selectedCity]];
        indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
    }
    return indexPath;
}

- (UITableViewCell *) cellForCurrentSelection {
    UITableViewCell *cell = nil;
    NSIndexPath *indexPath = [self indexPathForCurrentSelection];
    if (indexPath) {
        cell = [self.tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}

@end
