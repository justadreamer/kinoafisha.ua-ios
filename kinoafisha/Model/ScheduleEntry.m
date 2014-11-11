//
//  ScheduleEntry.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "ScheduleEntry.h"

@implementation ScheduleEntry
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"title":@"title",
             @"type":@"type",
             @"URL":@"link",
             @"showTimes":@"show_times"
             };
}

+ (NSValueTransformer *)typeJSONTransformer {
    return [NSValueTransformer mtl_valueMappingTransformerWithDictionary:@{
                                                                           @"cinema":@(ScheduleEntryCinema),
                                                                           @"film":@(ScheduleEntryFilm),
                                                                           @"cinema_room":@(ScheduleEntryCinemaRoom)
                                                                           }];
}

+ (NSValueTransformer *)URLJSONTransformer {
    return [NSValueTransformer valueTransformerForName:MTLURLValueTransformerName];
}

@end
