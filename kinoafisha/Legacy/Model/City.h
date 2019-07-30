//
//  City.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface City : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *cinemaURL;
@property (nonatomic,strong) NSURL *filmURL;
@property (nonatomic,assign) BOOL isDefaultSelection;

+ (City *) selectedCity;
+ (void) setSelectedCity:(City *)city;
@end
