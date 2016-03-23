//
//  BYTWebViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/20/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTWebViewController.h"

@interface BYTWebViewController ()

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIWebView *webview;

@end

@implementation BYTWebViewController

- (instancetype)init {
    NSAssert(NO, @"Must initialize with a web address");
    return nil;
}

- (instancetype)initWithWebAddress:(NSString *)webAddress title:(NSString *)title {
    self = [super init];
    
    if (self) {
        _url = [[NSURL alloc] initWithString:webAddress];
        self.title = title;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _webview = [[UIWebView alloc] initWithFrame:CGRectZero];
    _webview.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [_webview loadRequest:request];
    
    [self.view addSubview:_webview];
    
    [self setupConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//}

#pragma mark - Autolayout

- (void)setupConstraints {
    NSDictionary *views = @{@"webview" : self.webview};
    
    NSArray *webviewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[webview]|" options:0 metrics:nil views:views];
    NSArray *webviewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webview]|" options:0 metrics:nil views:views];
    
    [self.view addConstraints:webviewHorizontalConstraints];
    [self.view addConstraints:webviewVerticalConstraints];
}

@end
