//
//  CitiesViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Global.h"
#import "CitiesViewController.h"
#import "XHAll.h"
#import "SVProgressHUD.h"
#import "City.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

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

    NSURL *citiesXSLURL = [[NSBundle mainBundle] URLForResource:@"cities" withExtension:@"xsl"];
    XHTransformation *transformation = [[XHTransformation alloc] initWithXSLTURL:citiesXSLURL];
    XHMantleModelAdapter *adapter = [[XHMantleModelAdapter alloc] initWithModelClass:[City class]];
    XHTransformationHTMLResponseSerializer *serializer = [XHTransformationHTMLResponseSerializer serializerWithXHTransformation:transformation params:@{@"baseURL":Q(KinoAfishaBaseURL)} modelAdapter:adapter];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[KinoAfishaBaseURL stringByAppendingString:@"/cinema"]]];
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.operation.responseSerializer = serializer;
    
    __typeof(self) __weak weakSelf = self;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        weakSelf.cities = responseObject;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
