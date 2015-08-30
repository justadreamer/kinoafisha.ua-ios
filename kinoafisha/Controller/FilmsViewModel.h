//
//  FilmsViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "BaseViewModel.h"
@class City;
@interface FilmsViewModel : BaseViewModel
@property (nonatomic,strong,readonly) NSArray *films;
- (instancetype) initWithCity:(City *)city;
@end
