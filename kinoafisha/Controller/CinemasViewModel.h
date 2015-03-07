//
//  CinemasViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 1/11/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>
@class City;
@class CinemasContainer;
@interface CinemasViewModel : NSObject
@property (nonatomic,strong) City *city;
@property (nonatomic,assign,readonly) BOOL isLoading;
@property (nonatomic,strong,readonly) NSString *title;
@property (nonatomic,assign,readonly) NSUInteger cinemasCount;
@property (nonatomic,strong,readonly) NSArray *cinema;

- (instancetype) initWithCity:(City *)city;
- (void) loadData;
@end
