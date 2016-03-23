//
//  BYTSplashScreenViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTSplashScreenViewController.h"
#import "BYTDataSource.h"
#import "BYTCreateBytterNameViewController.h"

@interface BYTSplashScreenViewController ()

@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end

@implementation BYTSplashScreenViewController

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _shouldHideStatusBar = YES;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchedFirstByttes) name:@"kBYTFetchingFirstBytteNotification" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
 
    if ([[BYTDataSource sharedInstance] hasDeviceID] && [[BYTDataSource sharedInstance] hasFetchedFirstByttes]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[BYTDataSource sharedInstance] fetchDeviceDetailsWithCompletionHandler:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if ([[BYTDataSource sharedInstance] hasFetchedFirstByttes]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self presentAnonymousProfileCreator];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchedFirstByttes {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([[BYTDataSource sharedInstance] hasDeviceID] && [[BYTDataSource sharedInstance] hasFetchedFirstByttes]) {
        [[BYTDataSource sharedInstance] fetchDeviceDetailsWithCompletionHandler:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else {
        [self presentAnonymousProfileCreator];
    }
}

- (void)presentAnonymousProfileCreator {
    BYTCreateBytterNameViewController *createBytterNameVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateBytterName"];
    [self.navigationController pushViewController:createBytterNameVC animated:YES];
}

@end
