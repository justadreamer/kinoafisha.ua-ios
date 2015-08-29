//
//  CitiesViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseViewModel.h"

@class City;
@interface CitiesViewModel : BaseViewModel
@property (nonatomic,strong,readonly) NSArray *cities;
@property (nonatomic,strong,readonly) City *selectedCity;

- (void) setSelectedCityIndex:(NSUInteger)index;
- (NSString *) cityCaptionAtIndex:(NSUInteger)index;
- (BOOL) isCurrentCityAtIndex:(NSUInteger)index;
- (NSUInteger) indexForCurrentSelection;
@end
