//
//  CitiesViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class City;
@interface CitiesViewModel : NSObject
@property (nonatomic,strong) NSArray *cities;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,strong,readonly) City *selectedCity;

- (void) loadData;
- (void) setSelectedCityIndex:(NSUInteger)index;
- (NSString *) cityCaptionAtIndex:(NSUInteger)index;
- (BOOL) isCurrentCityAtIndex:(NSUInteger)index;
- (NSUInteger) indexForCurrentSelection;
@end
