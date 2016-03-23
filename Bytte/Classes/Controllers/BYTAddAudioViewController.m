//
//  BYTAddAudioViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/8/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAddAudioViewController.h"
#import "BYTActionButton.h"
#import "BYTPostBytteViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kTimeIntervalIncrement 0.1

@interface BYTAddAudioViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (assign, nonatomic) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightHandleLeadingConstraint;
@property (weak, nonatomic) IBOutlet UIView *audioIntervalBand;
@property (weak, nonatomic) IBOutlet BYTActionButton *actionButton;
@property (weak, nonatomic) IBOutlet UILabel *actionButtonTitle;
@property (weak, nonatomic) IBOutlet UIButton *playbackButton;
@property (weak, nonatomic) IBOutlet UIButton *redoButton;
@property (weak, nonatomic) IBOutlet UILabel *recordingLengthLabel;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) int startingTime;
@property (nonatomic, assign) int endingTime;
@property (nonatomic, strong) NSTimer *audioTimer;

@end

@implementation BYTAddAudioViewController

#pragma mark - Properties

- (BYTLightBytte *)lightBytte {
    if (!_lightBytte) {
        _lightBytte = [[BYTLightBytte alloc] init];
    }
    
    return _lightBytte;
}

#pragma mark - Init/Dealloc

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _shouldHideStatusBar = YES;
        _startingTime = 0;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupAudioRecorder];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.actionButton.disabledStateImageName = @"btn-bg-red";
    self.actionButton.enabledStateImageName = @"btn-bg-green";
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)actionButtonPressed:(id)sender {
    if (self.actionButton.actionButtonState == BYTActionButtonStateDisabled) {
        [self startRecording];
    } else if (self.actionButton.actionButtonState == BYTActionButtonStateEnabling) {
        [self stopRecording];
    } else { // BYTActionButtonStateEnabled
        [self postBytte];
    }
}

- (void)startRecording {
    self.actionButton.actionButtonState = BYTActionButtonStateEnabling;
    self.actionButtonTitle.text = @"STOP";
    self.playbackButton.hidden = YES;
    self.playbackButton.hidden = YES;
    
    if (!self.audioRecorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:NULL];
        
        NSError *error;
        [session overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        [session setActive:YES error:nil];
        
        [self.audioRecorder record];
         self.endingTime = 10;
        
        if (self.audioTimer) {
            [self.audioTimer invalidate];
            self.audioTimer = nil;
        }
        
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateAudioIntervalBand:) userInfo:nil repeats:YES];
    }
}

- (void)stopRecording {
    [self.audioTimer invalidate];
    [self.audioRecorder stop];
    
    self.actionButton.actionButtonState = BYTActionButtonStateEnabled;
    self.actionButtonTitle.text = @"DONE";
    self.audioIntervalBand.backgroundColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    self.playbackButton.hidden = NO;
    self.redoButton.hidden = NO;
}

- (void)postBytte {
   
    if (!self.audioRecorder.recording && !self.audioPlayer.playing) {
        NSString *timeString = [NSString stringWithFormat:@":%02d", self.startingTime];
        
        BYTPostBytteViewController *postBytteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBytte"];
        self.lightBytte.audioLength = timeString;
        self.lightBytte.audioURL = self.audioRecorder.url;
        postBytteVC.lightBytte = self.lightBytte;
        
        postBytteVC.enableAddText = YES;
        
        [self.navigationController pushViewController:postBytteVC animated:NO];
    }
}

- (IBAction)playbackButtonPressed:(id)sender {
    if (!self.audioRecorder.recording) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.audioRecorder.url error:nil];
        self.audioPlayer.volume = 1.0f;
        self.audioPlayer.delegate = self;
        
        [self.audioPlayer play];
        
        self.endingTime = [self.audioPlayer duration];
        if (self.audioTimer) {
            [self.audioTimer invalidate];
            self.audioTimer = nil;
        }
        
        self.startingTime = 0;
        [UIView animateWithDuration:0.01 animations:^{
            self.rightHandleLeadingConstraint.constant = -21;
            [self.view layoutSubviews];
        } completion:nil];
        
        self.audioTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(playAudioIntervalBand:) userInfo:nil repeats:YES];
        self.playbackButton.alpha = 0.5f;
    }
}

- (IBAction)redoButtonPressed:(id)sender {
    self.actionButton.actionButtonState = BYTActionButtonStateDisabled;
    self.actionButtonTitle.text = @"REC";
    self.audioIntervalBand.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:7.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
    self.playbackButton.hidden = YES;
    self.playbackButton.hidden = YES;
    self.startingTime = 0;
    
    NSString *timeString = [NSString stringWithFormat:@":%02d", self.startingTime];
    self.recordingLengthLabel.text = timeString;
    
    [UIView animateWithDuration:0.01 animations:^{
        self.rightHandleLeadingConstraint.constant = -21;
        [self.view layoutSubviews];
    } completion:nil];
    
    if (self.audioTimer) {
        [self.audioTimer invalidate];
        self.audioTimer = nil;
    }
}

- (void)updateAudioIntervalBand:(NSTimer *)timer {
    if (self.startingTime < self.endingTime) {
        [self.audioRecorder updateMeters];
        
        self.startingTime++;
        
        NSString *timeString = [NSString stringWithFormat:@":%02d", self.startingTime];
        self.recordingLengthLabel.text = timeString;
        
        [UIView animateWithDuration:0.01 animations:^{
            self.rightHandleLeadingConstraint.constant = 26*self.startingTime;
            [self.view layoutSubviews];
        } completion:nil];
    } else {
        [self stopRecording];
    }
}

- (void)playAudioIntervalBand:(NSTimer *)timer {
    if (self.startingTime < self.endingTime) {
        [self.audioRecorder updateMeters];
        
        self.startingTime++;
        
        NSString *timeString = [NSString stringWithFormat:@":%02d", self.startingTime];
        self.recordingLengthLabel.text = timeString;
        
        [UIView animateWithDuration:0.01 animations:^{
            self.rightHandleLeadingConstraint.constant = 26*self.startingTime;
            [self.view layoutSubviews];
        } completion:nil];
    } else {
        self.playbackButton.alpha = 1.0f;
    }
}

#pragma mark - Audio Player

- (void)setupAudioRecorder {
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"MyAudioMemo.m4a", nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
    
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    self.audioRecorder.delegate = self;
    self.audioRecorder.meteringEnabled = YES;
}

@end
