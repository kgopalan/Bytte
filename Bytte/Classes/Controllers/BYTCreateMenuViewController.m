//
//  BYTCreateMenuViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/30/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTCreateMenuViewController.h"
#import "BYTAddTextViewController.h"
#import "BYTAddPhotoViewController.h"
#import "BYTAddAudioViewController.h"
#import "BYTAddVideoViewController.h"

@interface BYTCreateMenuViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (assign, nonatomic) BOOL shouldHideStatusBar;

@end

@implementation BYTCreateMenuViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

#pragma mark - Actions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)photoButtonPressed:(id)sender {
    BYTAddPhotoViewController *addPhotoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddPhoto"];
    [self.navigationController pushViewController:addPhotoVC animated:YES];
}

- (IBAction)videoButtonPressed:(id)sender {
    BYTAddVideoViewController *addVideoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddVideo"];
    [self.navigationController pushViewController:addVideoVC animated:YES];
}

- (IBAction)textButtonPressed:(id)sender {
    BYTAddTextViewController *addTextVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddText"];
    [self.navigationController pushViewController:addTextVC animated:YES];
}

- (IBAction)audioButtonPressed:(id)sender {
    BYTAddAudioViewController *addAudioVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddAudio"];
    [self.navigationController pushViewController:addAudioVC animated:YES];
}

@end
