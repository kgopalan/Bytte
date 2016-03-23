//
//  BYTHomeCollectionViewCell.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTHomeCollectionViewCell.h"
#import "BYTActionButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "BYTDataSource.h"

@interface BYTHomeCollectionViewCell () <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;

@property (weak, nonatomic) IBOutlet BYTActionButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfLikesLabel;

@property (weak, nonatomic) IBOutlet BYTActionButton *commentsButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfCommentsLabel;

@property (weak, nonatomic) IBOutlet BYTActionButton *locationButton;

@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedLabel;

@property (weak, nonatomic) IBOutlet UIView *moreContainerView;

@property (strong, nonatomic) AVPlayer *videoPlayer;
@property (strong, nonatomic) AVPlayerLayer *videoPlayerLayer;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet BYTActionButton *audioPlayerButton;
@property (weak, nonatomic) IBOutlet UIImageView *audioOverlayImageView;

@end

@implementation BYTHomeCollectionViewCell

#pragma mark - Init/Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Properties

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.isFullscreen = NO;
    
    self.likeButton.disabledStateImageName = @"ic-like";
    self.likeButton.enabledStateImageName = @"ic-like-on";
    
    self.likeButton.actionButtonState = self.bytte.likeState;
    [self.numberOfLikesLabel setText:self.bytte.totalLikes];
    
    self.commentsButton.disabledStateImageName = @"ic-comments";
    self.commentsButton.enabledStateImageName = @"ic-comments-on";
    
    self.commentsButton.actionButtonState = self.bytte.commentState;
    [self.numberOfCommentsLabel setText:self.bytte.totalComments];
    
    self.locationButton.disabledStateImageName = @"ic-maps";
    self.locationButton.enabledStateImageName = @"ic-maps";
    
    self.locationButton.actionButtonState = BYTActionButtonStateDisabled;
    self.locationButton.hidden = !self.bytte.shouldShowMap;
    
    NSString *audioString = [NSString stringWithContentsOfURL:self.bytte.audioURL encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    if (![audioString isEqualToString:@""] && audioString) {
        self.audioPlayerButton.hidden = NO;
        self.audioOverlayImageView.hidden = NO;
    } else {
        self.audioPlayerButton.hidden = YES;
        self.audioOverlayImageView.hidden = YES;
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreButtonTapped:)];
    [self.moreContainerView addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *fullscreenTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fullscreenToggled:)];
    [self addGestureRecognizer:fullscreenTapGestureRecognizer];
}

#pragma mark - Properties

- (void)setBytte:(BYTBytte *)bytte {
    _bytte = bytte;
    
    if ([[BYTDataSource sharedInstance].imageCache objectForKey:bytte.imageURL]) {
        self.imageView.image = [[BYTDataSource sharedInstance].imageCache objectForKey:bytte.imageURL];
    } else {
        self.imageView.image = bytte.image;
    }
    
#warning commented out for now until data is provided via server
//    [self.followButton setTitle:bytte.appcodename forState:UIControlStateNormal];
    self.lastUpdatedLabel.text = [bytte.lastUpdated uppercaseString];
    self.contentTextLabel.text = bytte.bytteContent;
    
    if (bytte.audioURL) {
        self.audioPlayerButton.hidden = NO;
        self.audioOverlayImageView.hidden = NO;
        
        self.audioPlayerButton.disabledStateImageName = @"btn-play";
        self.audioPlayerButton.enabledStateImageName = @"btn-pause";
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
    }
    
    if (bytte.videoURL) {
        [self playMovie];
    }
    
    [self layoutSubviews];
}

- (void)setIsFullscreen:(BOOL)isFullscreen {
    _isFullscreen = isFullscreen;
    
    self.overlayView.hidden = isFullscreen ? YES : NO;
    self.likeButton.hidden = (isFullscreen || self.isMyBytte) ? YES : NO;
    self.numberOfLikesLabel.hidden = (isFullscreen || self.isMyBytte) ? YES : NO;
    self.commentsButton.hidden = isFullscreen ? YES : NO;
    self.numberOfCommentsLabel.hidden = isFullscreen ? YES : NO;
    self.locationButton.hidden = isFullscreen ? YES : NO;
    self.followButton.hidden = isFullscreen ? YES : NO;
    self.lastUpdatedLabel.hidden = isFullscreen ? YES : NO;
    self.moreContainerView.hidden = isFullscreen ? YES : NO;
    self.videoPlayer.muted = isFullscreen ? NO : YES;
}

- (void)setIsMyBytte:(BOOL)isMyBytte {
    _isMyBytte = isMyBytte;
}

#pragma mark - Actions

- (void)collectionViewDidEndDisplayingCell {
    if (self.audioPlayer.playing) {
        [self.audioPlayer stop];
    }
    
    if (self.videoPlayer) {
        [self.videoPlayer pause];
    }
}

- (IBAction)likeButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidPressLikeButton:)]) {
        [self.delegate cellDidPressLikeButton:self];
    }
}

- (IBAction)commentButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidPressCommentButton:)]) {
        [self.delegate cellDidPressCommentButton:self];
    }
}

- (IBAction)locationButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidPressLocationButton:)]) {
        [self.delegate cellDidPressLocationButton:self];
    }
}

- (IBAction)followButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidPressFollowButton:)]) {
        [self.delegate cellDidPressFollowButton:self];
    }
}

- (void)moreButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(cellDidTapMoreButton:)]) {
        [self.delegate cellDidTapMoreButton:self];
    }
}

- (void)fullscreenToggled:(id)sender {
    self.isFullscreen = !self.isFullscreen;
    if ([self.delegate respondsToSelector:@selector(cellDidToggleFullScreen:)]) {
        [self.delegate cellDidToggleFullScreen:self];
    }
}

- (IBAction)audioPlayerButtonPressed:(id)sender {
    if (self.audioPlayerButton.actionButtonState == BYTActionButtonStateDisabled) {
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateEnabled;
        
        NSData *audioData = [NSData dataWithContentsOfURL:self.bytte.audioURL];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithData:audioData error:nil];
        self.audioPlayer.volume = 1.0f;
        self.audioPlayer.delegate = self;
        
        [self.audioPlayer play];
        
    } else {
        self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
        [self.audioPlayer pause];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    [self.audioPlayer stop];
    self.audioPlayerButton.actionButtonState = BYTActionButtonStateDisabled;
}

#pragma mark - Video

- (void)playVideoIfNeeded {
    if (self.bytte.videoURL && self.videoPlayer) {
        [self.videoPlayer play];
    }
}

- (void)pauseVideoIfNeeded {
    if (self.bytte.videoURL && self.videoPlayer) {
        [self.videoPlayer pause];
    }
}

- (void)playMovie {
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:self.bytte.videoURL options:nil];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:avAsset];
    
    if (!self.videoPlayer) {
        self.videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        self.videoPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
        self.videoPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        self.videoPlayerLayer.frame = self.bounds;
        self.videoPlayerLayer.backgroundColor = [[UIColor clearColor] CGColor];
        [self.imageView.layer addSublayer:self.videoPlayerLayer];
        
        // muting and infinite video looping
        self.videoPlayer.muted = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restartMovie) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        
        [self.videoPlayer play];
    } else {
        [self.videoPlayer replaceCurrentItemWithPlayerItem:playerItem];
    }
}

- (void)restartMovie {
    CMTime seekTime = CMTimeMake(0, 1);
    [self.videoPlayer seekToTime:seekTime];
    [self.videoPlayer play];
}

#pragma mark - Reuse

- (void)prepareForReuse {
    self.bytte = nil;
    self.imageView.image = nil;
#warning don't nil out yet
//    [self.followButton setTitle:nil forState:UIControlStateNormal];
    self.lastUpdatedLabel.text = nil;
    self.isFullscreen = NO;
    
    self.audioPlayerButton.hidden = YES;
    self.audioOverlayImageView.hidden = YES;
    
    self.likeButton.actionButtonState = BYTActionButtonStateDisabled;
    [self.numberOfLikesLabel setText:@"0"];
    
    self.commentsButton.actionButtonState = BYTActionButtonStateDisabled;
    [self.numberOfCommentsLabel setText:@"0"];
    
    self.locationButton.actionButtonState = BYTActionButtonStateDisabled;
    self.locationButton.hidden = YES;
}

@end
