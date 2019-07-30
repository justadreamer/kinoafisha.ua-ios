//
//  CreditsViewController.m
//  kinoafisha
//
//  Created by Eugene Dorfman on 11/14/14.
//  Copyright (c) 2014 justadreamer. All rights reserved.
//

#import "CreditsViewController.h"
#import "Flurry.h"

@interface CreditsViewController ()<UIWebViewDelegate>
@property (nonatomic,strong) IBOutlet UIWebView *webView;
@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"credits" ofType:@"html"];
    NSError *error = nil;
    NSString *html = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:&error];
    NSString *version = [NSString stringWithFormat:@" %@ (build %@)",[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],[NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey]];
    html = [html stringByReplacingOccurrencesOfString:@"%%V%%" withString:version];
    self.webView.delegate = self;
    [self.webView loadHTMLString:html baseURL:nil];
    
    [Flurry logEvent:@"viewed credits"];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType==UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
}

@end
