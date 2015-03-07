//
//  CitiesViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Global.h"
#import "CitiesViewController.h"
#import "CitiesViewModel.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface CitiesViewController ()
@property (nonatomic,strong) CitiesViewModel *viewModel;
@end

@implementation CitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Киноафиша города";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(loadData)];
    self.viewModel = [CitiesViewModel new];

    [RACObserve(self.viewModel,isLoading) subscribeNext:^(NSNumber *isLoading) {
        if ([isLoading boolValue]) {
            [SVProgressHUD showWithStatus:@"Загрузка..."];
        } else {
            [SVProgressHUD dismiss];
        }
    }];

    [RACObserve(self.viewModel, self.cities) subscribeNext:^(NSArray *cities) {
        if (cities) {
            [self redisplayData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewModel.cities) {
        [self.viewModel loadData];
    }
}

#pragma mark -

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
    return self.viewModel.cities.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CityCell" forIndexPath:indexPath];
    cell.textLabel.text = [self.viewModel cityCaptionAtIndex:indexPath.row];
    cell.accessoryType = [self.viewModel isCurrentCityAtIndex:indexPath.row] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell;
}

#pragma mark - Table view delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self cellForCurrentSelection].accessoryType = UITableViewCellAccessoryNone;
    [self.viewModel setSelectedCityIndex:indexPath.row];
    [self cellForCurrentSelection].accessoryType = UITableViewCellAccessoryCheckmark;
    [self.tabBarController.viewControllers each:^(UIViewController *controller) {
        if ([controller isKindOfClass:[UINavigationController class]]) {
            UINavigationController *navController = (UINavigationController *)controller;
            [navController popToRootViewControllerAnimated:NO];
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidChangeCityNotification object:nil userInfo:@{CityKey:self.viewModel.selectedCity}];
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark -

- (NSIndexPath *) indexPathForCurrentSelection {
    NSUInteger idx = [self.viewModel indexForCurrentSelection];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
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
