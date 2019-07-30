//
//  ViewModel.h
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/29/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ViewModel <NSObject>
//base class handles those
@property (nullable,nonatomic,strong) id dataModel;
@property (nonatomic,assign) BOOL isLoading;
@property (nullable,nonatomic,strong) NSError *error;
//this is a permanent property, set for a specific data model once, and should not be changed
//during its lifetime
@property (nonatomic,assign,readonly) BOOL loadable;
- (NSString * __nullable) loadingIndicatorMessage;
- (void) loadDataModel;

@end
