//
//  Cinema.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Cinema : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSURL *detailURL;
@property (nonatomic,strong) NSURL *thumbnailURL;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *phone;
@property (nonatomic,strong) NSString *rating;
@property (nonatomic,strong) NSString *votesCount;
@end
