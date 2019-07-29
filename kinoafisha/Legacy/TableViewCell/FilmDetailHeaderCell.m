//
//  FilmDetailHeaderCell.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/12/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmDetailHeaderCell.h"
#import "Film.h"
#import <UIImageView+AFNetworking.h>

@interface FilmDetailHeaderCell()
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic,strong) IBOutlet UILabel *votesCountLabel;
@property (nonatomic,strong) IBOutlet UIImageView *thumbnailImageView;
@end
@implementation FilmDetailHeaderCell
- (void) setFilm:(Film *)film {
    _film = film;
    self.titleLabel.text = film.title;
    self.ratingLabel.text = film.rating;
    self.votesCountLabel.text = film.votesCount;
    [self.thumbnailImageView setImageWithURL:film.thumbnailURL];
}
@end
