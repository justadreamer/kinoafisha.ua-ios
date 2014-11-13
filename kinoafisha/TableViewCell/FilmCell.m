//
//  FilmCell.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/13/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "FilmCell.h"
#import <UIImageView+AFNetworking.h>
#import "Film.h"
@interface FilmCell()
@property (nonatomic,strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *subtitleLabel;
@property (nonatomic,strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic,strong) IBOutlet UILabel *votesCountLabel;
@end

@implementation FilmCell
- (void) setFilm:(Film *)film {
    _film = film;
    [self.thumbnailImageView setImageWithURL:film.thumbnailURL];
    self.titleLabel.text = film.title;
    self.subtitleLabel.text = film.subtitle;
    self.ratingLabel.text = film.rating;
    self.votesCountLabel.text = film.votesCount;
}
@end
