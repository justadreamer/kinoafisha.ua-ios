//
//  Film.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Film.h"
#import "Attribute.h"
#import "ScheduleEntry.h"

@implementation Film
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
        @"title":@"title",
        @"thumbnailURL":@"thumbnail",
        @"rating":@"rating",
        @"votesCount":@"votes_count",
        @"attributes":@"attributes",
        @"descr":@"description",
        @"scheduleEntries":@"schedule"
        };
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)attributesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:Attribute.class];
}

+ (NSValueTransformer *)scheduleEntriesJSONTransformer {
    return [NSValueTransformer mtl_JSONArrayTransformerWithModelClass:ScheduleEntry.class];
}
@end
