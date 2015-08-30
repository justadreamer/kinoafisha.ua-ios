//
//  FilmDetailViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "FilmDetailViewModel.h"
#import "BaseViewModel+Protected.h"
@interface FilmDetailViewModel()
@property (nonatomic,strong) NSURL *filmURL;
@end

@implementation FilmDetailViewModel

- (instancetype)initWithFilmURL:(NSURL *)URL {
    if (self = [super init]) {
        self.filmURL = URL;
    }
    return self;
}

- (Film *) film {
    return self.dataModel;
}

- (NSInteger)numberOfSections {
    return self.film ? 1 : 0;
}

- (NSInteger)numberOfRows {
    NSInteger rows = 1/*title*/+self.film.attributes.count/*number of attributes*/+1/*description*/;
    return rows;
}

#pragma mark - BaseViewModel overrides
- (NSString *)XSLTName {
    return @"single_film";
}

- (NSURL *)URL {
    return self.filmURL;
}

- (Class) dataModelClass {
    return Film.class;
}

@end
