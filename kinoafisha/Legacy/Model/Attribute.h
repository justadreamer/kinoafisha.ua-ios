//
//  Attribute.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/11/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Attribute : MTLModel<MTLJSONSerializing>
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *value;
@end
