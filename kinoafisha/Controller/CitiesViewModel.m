//
//  CitiesViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "Global.h"
#import "CitiesViewModel.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import <AFNetworking/AFNetworking.h>
#import <SkyScraper/SkyScraper.h>
#import <ReactiveCocoa/ReactiveCocoa.h>

#import "City.h"
#import "AppDelegate.h"

@interface CitiesViewModel ()
@property (nonatomic,strong) AFHTTPRequestOperation *operation;
@property (nonatomic,strong,readwrite) City *selectedCity;
@end

@implementation CitiesViewModel
- (void) dealloc {
    self.operation.completionBlock = nil;
    [self.operation cancel];
}

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
    
    @weakify(self);
    self.isLoading = YES;
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *cities = responseObject;
        cities = [cities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        if (cities.count && ![City selectedCity]) {
            City* defaultSelection = [cities find:^BOOL(City *city) {
                return city.isDefaultSelection;
            }];
            [City setSelectedCity:defaultSelection];
        }
        @strongify(self);
        self.cities = cities;
        self.isLoading = NO;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        self.isLoading = NO;
        NSLog(@"%@",error);
    }];

    [self.operation start];

}

- (void) setSelectedCityIndex:(NSUInteger)index {
    [City setSelectedCity:self.cities[index]];
    self.selectedCity = self.cities[index];
}

- (NSString *) cityCaptionAtIndex:(NSUInteger)index {
    City *city = self.cities[index];
    return city.name;
}

- (BOOL) isCurrentCityAtIndex:(NSUInteger)index {
    City *city = self.cities[index];
    return [[City selectedCity] isEqual:city];
}

- (NSUInteger) indexForCurrentSelection {
    return [self.cities indexOfObject:[City selectedCity]];
}

@end
