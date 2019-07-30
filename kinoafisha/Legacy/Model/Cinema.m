//
//  Cinema.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Cinema.h"

@implementation Cinema
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"name":@"name",
        @"detailURL":@"link",
        @"thumbnailURL":@"thumbnail",
        @"address":@"address",
        @"phone":@"phone",
        @"rating":@"rating",
        @"votesCount":@"votes_count"
    };
}

+ (NSValueTransformer *)detailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
