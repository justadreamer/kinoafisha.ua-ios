//
//  FilmsViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "FilmsViewModel.h"
#import "BaseViewModel+Protected.h"
#import "City.h"
#import "Film.h"

@interface FilmsViewModel()
@property (nonatomic,strong) City *city;
@end

@implementation FilmsViewModel

- (instancetype) initWithCity:(City *)city {
    if (self = [super init]) {
        self.city = city;
    }
    return self;
}

- (NSArray *)films {
    return self.dataModel;
}

#pragma mark - BaseViewModel overrides

- (NSString *)XSLTName {
    return @"films_v2";
}

- (NSURL *)URL {
    return self.city.filmURL;
}

- (Class)dataModelClass {
    return Film.class;
}
@end
