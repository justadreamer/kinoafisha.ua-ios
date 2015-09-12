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
#import "ReactiveCocoa.h"
#import "Global.h"
#import "extobjc.h"

@interface FilmsViewModel()
@property (nonatomic,strong) City *city;
@end

@implementation FilmsViewModel
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype) initWithCity:(City *)city {
    if (self = [super init]) {
        self.city = city;
        @weakify(self);
        [[[NSNotificationCenter defaultCenter] rac_addObserverForName:DidChangeCityNotification object:nil] subscribeNext:^(NSNotification *notification) {
            @strongify(self);
            self.city = notification.userInfo[CityKey];
            self.needsReload = YES;
        }];
    }
    return self;
}

- (NSArray *)films {
    return self.dataModel;
}

- (void) loadDataModel {
    [super loadDataModel];
    self.needsReload = NO;
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
