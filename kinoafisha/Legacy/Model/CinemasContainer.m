//
//  CinemasContainer.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "CinemasContainer.h"
#import "Cinema.h"

@implementation CinemasContainer
+ (NSDictionary *) JSONKeyPathsByPropertyKey {
    return @{
             @"cityName" : @"city_name",
             @"cinemas" : @"cinemas"
             };
}

+ (NSValueTransformer *) cinemasJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:[Cinema class]];
}

@end
