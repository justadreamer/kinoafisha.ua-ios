//
//  CinemasContainer.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/9/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface CinemasContainer : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *cityName;
@property (nonatomic,strong) NSArray *cinemas;
@end
