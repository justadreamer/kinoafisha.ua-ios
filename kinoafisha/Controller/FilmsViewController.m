//
//  FilmsViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/13/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmsViewController.h"
#import "Film.h"
#import "City.h"
#import "FilmDetailViewController.h"
#import "FilmCell.h"
#import "AppDelegate.h"
#import "FilmDetailViewModel.h"
#import "FilmsViewModel.h"
#import "UIViewController+ViewModel.h"

@interface FilmsViewController ()<ViewModelSupport>
@end

@implementation FilmsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[FilmsViewModel alloc] initWithCity:[City selectedCity]];
    self.tableView.estimatedRowHeight = 44.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.viewModel action:@selector(loadDataModel)];
    [self defineDefaultBindings];
    [self.viewModel loadDataModel];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.viewModel.needsReload) {
        [self.viewModel loadDataModel];
    }
}

- (void) redisplayData {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.films.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilmCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilmCell"];
    Film *film = self.viewModel.films[indexPath.row];
    cell.film = film;

    cell.frame = CGRectMake(0, 0, tableView.frame.size.width, self.tableView.estimatedRowHeight);
    [cell layoutIfNeeded];

    return cell;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    FilmDetailViewController *controller = segue.destinationViewController;
    Film *film = self.viewModel.films[[self.tableView indexPathForSelectedRow].row];
    controller.viewModel = [[FilmDetailViewModel alloc] initWithFilmURL:film.detailURL];
    controller.title = film.title;
}


@end
