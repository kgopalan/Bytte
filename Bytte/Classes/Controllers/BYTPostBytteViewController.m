//
//  BYTPostBytteViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTPostBytteViewController.h"
#import "BYTActionButton.h"
#import "PXLActionSheet.h"
#import "PXLActionSheetTheme.h"
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BYTAddLocationViewController.h"
#import "BYTDataSource.h"
#import "BYTAddTextToPhotoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BYTAddAudioViewController.h"
#import "BYTLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@interface BYTPostBytteViewController () <BYTAddLocationViewControllerDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet BYTActionButton *locationButton;
@property (weak, nonatomic) IBOutlet BYTActionButton *textButton;
@property (strong, nonatomic) BYTBytte *bytte;
@property (weak, nonatomic) IBOutlet UILabel *audioLengthLabel;
@property (weak, nonatomic) IBOutlet UIImageView *audioOverlayImageView;
@property (weak, nonatomic) IBOutlet BYTActionButton *audioPlayerButton;
@property (weak, nonatomic) IBOutlet UIButton *rerecordAudioButton;
@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation BYTPostBytteViewController

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _bytte = [[BYTBytte alloc] init];
        _enableAddText = NO;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationButton.disabledStateImageName = @"btn-location";
    self.locationButton.enabledStateImageName = @"btn-location-on";
    self.locationButton.actionButtonState = BYTActionButtonStateDisabled;
    
    self.textButton.disabledStateImageName = @"btn-txt";
    self.textButton.enabledStateImageName = @"btn-txt-cancel";
    
    if (self.lightBytte.bytteText && ![self.lightBytte.bytteText isEqualToString:@""]) {
        self.textButton.actionButtonState = BYTActionButtonStateEnabled;
    } else {
        self.textButton.actionButtonState = BYTActionButtonStateDisabled;
    }
    
    self.textLabel.text = self.lightBytte.bytteText;
    
    if (self.lightBytte.bytteImage) {
        self.imageView.image = self.lightBytte.bytteImage;
    }
    
    self.textButton.hidden = !self.enableAddText;
 
    if (self.lightBytte.audioLength) {
        self.audioLengthLabel.text = self.lightBytte.audioLength;
        self.audioLengthLabel.hidden = NO;
        self.audioOverlayImageView.hidden = NO;
        self.audioPlayerButton.hidden = NO;
        self.rerecordAudioButton.hidden = NO;
        
        self.audioPlayerButton.disabledStateImageName = @"btn-play";
        self.audioPlayerButton.enabledStateImageName = @"btn-pause";
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
    }
    
    if (self.lightBytte.videoURL) {
        [self playBackMovie];
    }
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (self.moviePlayer && self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer stop];
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)postButtonPressed:(id)sender {
    
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (self.moviePlayer && self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer stop];
    }
  
    [[BYTDataSource sharedInstance] postBytte:self.lightBytte completionHandler:nil];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)textButtonPressed:(id)sender {
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (self.moviePlayer && self.moviePlayer.playbackState == MPMoviePlaybackStatePlaying) {
        [self.moviePlayer stop];
    }
    
    BYTAddTextToPhotoViewController *addTextToPhotoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AddTextToPhoto"];
    addTextToPhotoVC.lightBytte = self.lightBytte;
    
    [self.navigationController pushViewController:addTextToPhotoVC animated:YES];
}

- (IBAction)audioPlayerButtonPressed:(id)sender {
    if (self.audioPlayerButton.actionButtonState == BYTActionButtonStateDisabled) {
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateEnabled;
        
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.lightBytte.audioURL error:nil];
        self.audioPlayer.volume = 1.0f;
        self.audioPlayer.delegate = self;
        
        [self.audioPlayer play];
        
    } else {
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
        [self.audioPlayer pause];
    }
}

- (IBAction)rerecordAudioButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)locationButtonPressed:(id)sender {
    PXLActionSheetTheme *actionSheetTheme = [PXLActionSheetTheme defaultTheme];
    actionSheetTheme.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    actionSheetTheme.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
    actionSheetTheme.animationSpeed = 0.8f;
    
    actionSheetTheme.normalButtonColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    actionSheetTheme.normalButtonHighlightColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:0.8f];
    actionSheetTheme.destructiveButtonColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    
    actionSheetTheme.normalButtonTextColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.9f blue:194.0f/255.0f alpha:0.8f];
    actionSheetTheme.destructiveButtonTextColor = [UIColor redColor];
    
    actionSheetTheme.buttonFont = [UIFont fontWithName:@"OpenSans-Semibold" size:13.0f];
    
    [PXLActionSheet showInView:self.view
                     withTheme:actionSheetTheme
                         title:nil
             cancelButtonTitle:[@"Cancel" uppercaseString]
        destructiveButtonTitle:nil
             otherButtonTitles:@[[@"ADD CURRENT LOCATION" uppercaseString], [@"DROP A PIN" uppercaseString]]
                      tapBlock:^(PXLActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                          switch (tappedButtonIndex) {
                              case 0:
                                  // Add Current Location
                                  [self addCurrentLocation];
                                  
                                  break;
                              case 1:
                                  // Drop Pin
                                  [self dropPinButtonPressed];
                                  break;
                              default:
                                  break;
                          }
                      }];
}

- (void)addCurrentLocation {
    CLLocation *currentLocation = [[BYTLocationManager sharedInstance] usersCurrentLocation];
    self.lightBytte.mapLatitude = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
    self.lightBytte.mapLongitude = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
    self.lightBytte.tagMap = YES;
    self.locationButton.actionButtonState = BYTActionButtonStateEnabled;
}

- (void)dropPinButtonPressed {
    BYTAddLocationViewController *addLocationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AddLocation"];
    addLocationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    addLocationViewController.delegate = self;
    
    [self presentViewController:addLocationViewController animated:YES completion:nil];
}

#pragma mark - BYTAddLocationViewControllerDelegate

- (void)addLocationViewControllerDidAddLocationCoordinate:(CLLocationCoordinate2D)coordinate {
    self.lightBytte.mapLatitude = [[NSNumber numberWithDouble:coordinate.latitude] stringValue];
    self.lightBytte.mapLongitude = [[NSNumber numberWithDouble:coordinate.longitude] stringValue];
    self.lightBytte.tagMap = YES;
    self.locationButton.actionButtonState = BYTActionButtonStateEnabled;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.audioPlayer stop];
    self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
}

#pragma mark - Video

- (void)playBackMovie {
    self.moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:self.lightBytte.videoURL];
    self.moviePlayer.controlStyle = MPMovieControlStyleNone;
    self.moviePlayer.shouldAutoplay = YES;
    self.moviePlayer.scalingMode = MPMovieScalingModeAspectFill;
    self.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    
    self.moviePlayer.view.frame = [self.view bounds];
    [self.view insertSubview:self.moviePlayer.view atIndex:0];
    
    self.moviePlayer.contentURL = self.lightBytte.videoURL;
    [self.moviePlayer prepareToPlay];
}

@end
