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
        @"subtitle":@"subtitle",
        @"thumbnailURL":@"thumbnail",
        @"rating":@"rating",
        @"votesCount":@"votes_count",
        @"attributes":@"attributes",
        @"descr":@"description",
        @"scheduleEntries":@"schedule",
        @"detailURL":@"detail_url"
        };
}

+ (NSValueTransformer *)thumbnailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

+ (NSValueTransformer *)attributesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:Attribute.class];
}

+ (NSValueTransformer *)scheduleEntriesJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:ScheduleEntry.class];
}

+ (NSValueTransformer *)detailURLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
