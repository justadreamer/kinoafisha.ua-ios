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
#import "UIViewController+ViewModel.h"

@interface CitiesViewController ()<ViewModelSupport>
@property (nonatomic,strong) CitiesViewModel *viewModel;
@end

@implementation CitiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Киноафиша города";
    self.viewModel = [CitiesViewModel new];

    [self defineDefaultBindings];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.viewModel.cities) {
        [self.viewModel loadDataModel];
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
    [self.tabBarController setSelectedIndex:1];
}

#pragma mark -

- (NSIndexPath *) indexPathForCurrentSelection {
    NSUInteger idx = [self.viewModel indexForCurrentSelection];
    NSIndexPath *indexPath = nil;
    if (idx<self.viewModel.cities.count) {
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
