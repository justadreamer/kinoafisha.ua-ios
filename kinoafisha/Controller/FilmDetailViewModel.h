//
//  FilmDetailViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "BaseViewModel.h"
#import "Film.h"

@interface FilmDetailViewModel : BaseViewModel
@property (nonatomic,strong,readonly) Film *film;
- (instancetype)initWithFilmURL:(NSURL *)URL;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRows;
@end
