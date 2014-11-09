//
//  City.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "MTLModel.h"
#import "MTLJSONAdapter.h"

@interface City : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *cinemaURL;
@property (nonatomic,strong) NSURL *filmURL;

+ (City *) selectedCity;
+ (void) setSelectedCity:(City *)city;
@end
