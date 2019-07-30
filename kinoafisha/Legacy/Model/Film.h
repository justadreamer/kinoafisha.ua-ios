//
//  Film.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Film : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *subtitle;
@property (nonatomic,strong) NSURL *thumbnailURL;
@property (nonatomic,strong) NSURL *detailURL;
@property (nonatomic,strong) NSString *rating;
@property (nonatomic,strong) NSString *votesCount;
@property (nonatomic,strong) NSArray *attributes;
@property (nonatomic,strong) NSString *descr;
@property (nonatomic,strong) NSArray *scheduleEntries;
@end
