//
//  BYTAddVideoViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAddVideoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BYTActionButton.h"
#import "BYTPostBytteViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface BYTAddVideoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVCaptureFileOutputRecordingDelegate>

@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *videoView;
@property (weak, nonatomic) IBOutlet BYTActionButton *captureButton;
@property (weak, nonatomic) IBOutlet BYTActionButton *cameraDirectionButton;
@property (weak, nonatomic) IBOutlet UIButton *videoGalleryButton;
@property (weak, nonatomic) IBOutlet UILabel *actionButtonTitle;
@property (weak, nonatomic) IBOutlet UILabel *recordingLengthLabel;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDevice *audioDevice;
@property (strong, nonatomic) AVCaptureDevice *backCaptureDevice;
@property (strong, nonatomic) AVCaptureDevice *frontCaptureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioDeviceInput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieOutput;
@property (assign, nonatomic) NSInteger currentRecordingLengthInSeconds;
@property (assign, nonatomic) NSInteger maxRecordingTime;
@property (strong, nonatomic) NSTimer *recordingTimer;

@end

@implementation BYTAddVideoViewController

#pragma mark - Properties

- (BYTLightBytte *)lightBytte {
    if (!_lightBytte) {
        _lightBytte = [[BYTLightBytte alloc] init];
    }
    
    return _lightBytte;
}

- (NSURL *)videoOutputFileURL
{
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],@"output.mp4", nil];
    NSURL *outputURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    return outputURL;
}

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _shouldHideStatusBar = YES;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self openCamera];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.captureButton.disabledStateImageName = @"btn-bg-red";
    self.captureButton.enabledStateImageName = @"btn-bg-green";
    
    self.cameraDirectionButton.disabledStateImageName = @"btn-reverse";
    self.cameraDirectionButton.enabledStateImageName = @"btn-reverse-on";
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)captureButtonPressed:(id)sender {
    if (self.captureButton.actionButtonState == BYTActionButtonStateDisabled) {
        [self startRecording];
    } else if (self.captureButton.actionButtonState == BYTActionButtonStateEnabling) {
        [self stopRecording];
    } else { // BYTActionButtonStateEnabled
        [self postBytte];
    }
}

- (IBAction)cameraDirectionButtonPressed:(id)sender {
    if (self.captureSession) {
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.videoDeviceInput];
        
        if (self.cameraDirectionButton.actionButtonState == BYTActionButtonStateEnabled) {
            self.cameraDirectionButton.actionButtonState = BYTActionButtonStateDisabled;
            self.captureDevice = self.backCaptureDevice;
        } else {
            self.cameraDirectionButton.actionButtonState = BYTActionButtonStateEnabled;
            self.captureDevice = self.frontCaptureDevice;
        }
        
        if (self.captureDevice)
        {
            NSError *error;
            self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
            if (!error)
            {
                if ([self.captureSession canAddInput:self.videoDeviceInput])
                {
                    [self.captureSession addInput:self.videoDeviceInput];
                }
            }
        }
        
        [self.captureSession commitConfiguration];
    }
}

- (IBAction)videoGalleryButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.videoMaximumDuration = 10.0f;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:(NSString *)kUTTypeMovie, nil];
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - Video

- (void)postBytte {
    NSString *timeString = [NSString stringWithFormat:@":%02d", (int)self.currentRecordingLengthInSeconds];
    
    BYTPostBytteViewController *postBytteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBytte"];
    self.lightBytte.videoLength = timeString;
    self.lightBytte.videoURL = [self videoOutputFileURL];
    self.lightBytte.bytteImage = [self thumbnailImageForVideoURL:[self videoOutputFileURL]];
    postBytteVC.lightBytte = self.lightBytte;
    postBytteVC.enableAddText = YES;
    
    [self.navigationController pushViewController:postBytteVC animated:NO];
}

- (UIImage *)thumbnailImageForVideoURL:(NSURL *)videoURL {
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime time = [asset duration];
    time.value = 0;
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)startRecording {
    self.captureButton.actionButtonState = BYTActionButtonStateEnabling;
    self.actionButtonTitle.text = @"STOP";
    
    self.videoGalleryButton.hidden = YES;
    self.cameraDirectionButton.hidden = YES;
    self.recordingLengthLabel.hidden = NO;
    
    if (!self.movieOutput.isRecording) {
         self.maxRecordingTime = 10;
        [self.movieOutput startRecordingToOutputFileURL:[self videoOutputFileURL] recordingDelegate:self];
        self.currentRecordingLengthInSeconds = 0;
        self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                               target:self selector:@selector(updateTimeDisplay:) userInfo:nil repeats:YES];
    }
}

- (void)stopRecording {
    [self.recordingTimer invalidate];
    [self.movieOutput stopRecording];
    
    self.captureButton.actionButtonState = BYTActionButtonStateEnabled;
    self.actionButtonTitle.text = @"DONE";
    
    [self postBytte];
}

- (void)openCamera {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.backCaptureDevice = device;
        } else if (device.position == AVCaptureDevicePositionFront) {
            self.frontCaptureDevice = device;
        }
    }
    
    self.captureDevice = self.backCaptureDevice;
    self.audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    if (self.captureDevice)
    {
        NSError *error;
        self.videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
        if (!error)
        {
            if ([self.captureSession canAddInput:self.videoDeviceInput])
            {
                [self.captureSession addInput:self.videoDeviceInput];
            }
        }
    }
    
    self.movieOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    captureVideoPreviewLayer.frame = self.videoView.bounds;
    [self.videoView.layer addSublayer:captureVideoPreviewLayer];
    
    UIView *view = self.videoView;
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    [captureVideoPreviewLayer setFrame:[viewLayer bounds]];
    [viewLayer addSublayer:captureVideoPreviewLayer];
    
    CGRect bounds = [view bounds];
    [captureVideoPreviewLayer setFrame:bounds];
    
    if (self.audioDevice) {
        self.audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.audioDevice error:nil];
    }
    
    Float64 totalSeconds = 10;			//Total seconds
    int32_t preferredTimeScale = 10;	//Frames per second
    CMTime maxDuration = CMTimeMakeWithSeconds(totalSeconds, preferredTimeScale);	//<<SET MAX DURATION
    self.movieOutput.maxRecordedDuration = maxDuration;
    
    [self.captureSession addInput:self.audioDeviceInput];
    [self.captureSession addOutput:self.movieOutput];
    
    // Set orientation of capture connections to portrait
    NSArray *array = [[self.captureSession.outputs objectAtIndex:0] connections];
    for (AVCaptureConnection *connection in array)
    {
        connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    
    [self.captureSession startRunning];
}

- (void)updateTimeDisplay:(NSTimer *)timer {
    if (self.currentRecordingLengthInSeconds < self.maxRecordingTime) {
        self.currentRecordingLengthInSeconds++;
        self.recordingLengthLabel.text = [NSString stringWithFormat:@"0:%02d", (int)self.currentRecordingLengthInSeconds];
    } else {
        [self stopRecording];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    BYTPostBytteViewController *postBytteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBytte"];
//    self.lightBytte.videoLength = timeString;
    self.lightBytte.videoURL = (NSURL *)[info objectForKey:UIImagePickerControllerMediaURL];
    UIImage *imageFromVideoPicker = [self thumbnailImageForVideoURL:self.lightBytte.videoURL];
    self.lightBytte.bytteImage = [self imageWithImage:imageFromVideoPicker scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    
    postBytteVC.lightBytte = self.lightBytte;
    postBytteVC.enableAddText = YES;
    
    [self.navigationController pushViewController:postBytteVC animated:NO];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureFileOutputRecordingDelegate

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    
}

@end
