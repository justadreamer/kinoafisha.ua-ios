//
//  CinemaCell.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "CinemaCell.h"
#import "Cinema.h"
#import <UIImageView+AFNetworking.h>

@interface CinemaCell()
@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic,strong) IBOutlet UIImageView *ratingImageView;
@property (nonatomic,strong) IBOutlet UILabel *ratingLabel;
@property (nonatomic,strong) IBOutlet UILabel *votesCountLabel;
@property (nonatomic,strong) IBOutlet UILabel *addressLabel;
@property (nonatomic,strong) IBOutlet UILabel *phoneLabel;
@end

@implementation CinemaCell

- (void) setCinema:(Cinema *)cinema {
    _cinema = cinema;
    self.titleLabel.text = cinema.name;
    [self.thumbnailImageView setImageWithURL:self.cinema.thumbnailURL];
    self.addressLabel.text = self.cinema.address;
    self.phoneLabel.text = self.cinema.phone;
}


@end
