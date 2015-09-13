//
//  UIViewController+ViewModel.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 8/30/15.
//  Copyright (c) 2015 justadreamer. All rights reserved.
//
#import "BaseViewController.h"
#import <objc/runtime.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "BaseViewModel.h"

@implementation BaseViewController

- (void)defineDefaultBindings {
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    @weakify(self)
    [RACObserve(self.viewModel,isLoading) subscribeNext:^(NSNumber *isLoading) {
        @strongify(self)
        if ([isLoading boolValue]) {
            [SVProgressHUD showWithStatus:self.viewModel.loadingIndicatorMessage];
        } else {
            [SVProgressHUD dismiss];
        }
    }];
    
    [RACObserve(self.viewModel, dataModel) subscribeNext:^(id dataModel) {
        @strongify(self)
        [self redisplayData];
    }];
    
    [RACObserve(self.viewModel, error) subscribeNext:^(NSError *error) {
        @strongify(self);
        [self redisplayData];
    }];

}

- (void) redisplayData {
    
}

- (id<ViewModel>) viewModel {
    return nil;
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Загрузка не удалась";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Проверьте подключение к Интернету и повторите загрузку.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f]};
    
    return [[NSAttributedString alloc] initWithString:@"Повторить" attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIColor whiteColor];
}

#pragma mark - DZNEmptyDataSetDelegate
- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return self.viewModel.error!=nil;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
    return NO;
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self.viewModel loadDataModel];
}

@end
