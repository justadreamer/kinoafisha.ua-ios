//
//  BaseViewModel+Protected.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/29/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import "BaseViewModel.h"

@interface BaseViewModel ()
//subclasses must handle those
@property (nonnull,nonatomic,readonly,strong) NSString *XSLTName;
@property (nonnull,nonatomic,readonly,strong) NSURL *URL;
@property (nonnull,nonatomic,readonly,assign) Class dataModelClass;
- (nullable id)processLoadedDataModel:(nullable id)dataModel;

@end
