//
//  City.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "City.h"
#import "NSValueTransformer+MTLPredefinedTransformerAdditions.h"

static City *gSelectedCity;

@implementation City

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"name":@"name",
             @"cinemaURL":@"link_cinema",
             @"filmURL":@"link_kinoafisha"
             };
}

+ (NSValueTransformer *)cinemaURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)filmURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (City *) selectedCity {
    return gSelectedCity;
}

+ (void) setSelectedCity:(City *)city {
    gSelectedCity = city;
}

@end
