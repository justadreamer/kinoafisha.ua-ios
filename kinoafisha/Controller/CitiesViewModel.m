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
#import "BaseViewModel+Protected.h"
#import "City.h"
#import "Flurry.h"

@interface CitiesViewModel ()
@property (nonatomic,strong,readwrite) City *selectedCity;
@end

@implementation CitiesViewModel

- (void) setSelectedCityIndex:(NSUInteger)index {
    [self setSelectedCity:self.cities[index]];
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

- (NSArray *)cities {
    return self.dataModel;
}

#pragma mark - BaseViewModel overrides
- (NSString *)XSLTName {
    return @"cities";
}

- (NSURL *) URL {
    return [NSURL URLWithString:[KinoAfishaBaseURL stringByAppendingString:@"/cinema"]];
}

- (Class) dataModelClass {
    return City.class;
}

- (nullable id) processLoadedDataModel:(nullable NSArray*)cities {
    cities = [cities sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
    if (cities.count && ![City selectedCity]) {
        City* defaultSelection = [cities find:^BOOL(City *city) {
            return city.isDefaultSelection;
        }];
        [self setSelectedCity:defaultSelection];
    }
    return cities;
}

- (void) setSelectedCity:(City *)city {
    [City setSelectedCity:city];
    [Flurry logEvent:@"City selected" withParameters:@{@"city":city.name?:@""}];
}
@end
