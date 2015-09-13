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
- (NSString * __nullable) loadingIndicatorMessage;
- (void) loadDataModel;

@end
