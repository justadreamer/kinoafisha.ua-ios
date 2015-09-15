//
//  City.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "City.h"
#import "Global.h"
#import "Flurry.h"

static City *gSelectedCity;

@implementation City

+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"name":@"name",
             @"cinemaURL":@"link_cinema",
             @"filmURL":@"link_kinoafisha",
             @"isDefaultSelection":@"is_default_selection"
             };
}

+ (NSValueTransformer *)cinemaURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)filmURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)isDefaultSelectionJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLBooleanValueTransformerName];
}

+ (City *) selectedCity {
    return gSelectedCity;
}

+ (void) setSelectedCity:(City *)city {
    gSelectedCity = city;
    [Flurry logEvent:@"City selected" withParameters:@{@"city":city.name?:@""}];
    [[NSNotificationCenter defaultCenter] postNotificationName:DidChangeCityNotification object:nil userInfo:@{CityKey:city}];
}

@end
