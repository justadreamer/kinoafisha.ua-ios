//
//  Attribute.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "Attribute.h"

@implementation Attribute
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"name":@"name",
             @"value":@"value"
             };
}
@end
