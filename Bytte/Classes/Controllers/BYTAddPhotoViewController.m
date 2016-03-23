//
//  BYTAddPhotoViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAddPhotoViewController.h"
#import "BYTPostBytteViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BYTActionButton.h"

@interface BYTAddPhotoViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (strong, nonatomic) UIImage *capturedImage;
@property (weak, nonatomic) IBOutlet UIButton *photoGalleryButton;
@property (weak, nonatomic) IBOutlet BYTActionButton *cameraDirectionButton;

@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;
@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDevice *backCaptureDevice;
@property (strong, nonatomic) AVCaptureDevice *frontCaptureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation BYTAddPhotoViewController

#pragma mark - Properties

- (BYTLightBytte *)lightBytte {
    if (!_lightBytte) {
        _lightBytte = [[BYTLightBytte alloc] init];
    }
    
    return _lightBytte;
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

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self openCamera];
    
    self.cameraDirectionButton.disabledStateImageName = @"btn-reverse";
    self.cameraDirectionButton.enabledStateImageName = @"btn-reverse-on";
}

#pragma mark - Actions

- (void)postBytte {
    BYTPostBytteViewController *postBytteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBytte"];
    self.lightBytte.bytteImage = self.capturedImage;
    postBytteVC.lightBytte = self.lightBytte;
    postBytteVC.enableAddText = YES;
    
    [self.navigationController pushViewController:postBytteVC animated:NO];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)photoGalleryButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self presentViewController:imagePicker animated:YES completion:nil];
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

- (IBAction)captureButtonPressed:(id)sender {
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
    [videoConnection setVideoScaleAndCropFactor:1.0];
    
    [self.stillImageOutput
     captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         if (imageSampleBuffer != NULL) {
             NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
             UIImage *rawImage = [UIImage imageWithData:imageData];
             
             CGRect outputRect = [self.previewLayer metadataOutputRectOfInterestForRect:self.previewLayer.bounds];
             CGImageRef rawCGImage = rawImage.CGImage;
             size_t width = CGImageGetWidth(rawCGImage);
             size_t height = CGImageGetHeight(rawCGImage);
             CGRect cropRect = CGRectMake(outputRect.origin.x * width, outputRect.origin.y * height, outputRect.size.width * width, outputRect.size.height * height);
             cropRect = CGRectIntegral(cropRect);
             CGImageRef cropCGImage = CGImageCreateWithImageInRect(rawCGImage, cropRect);
             
             self.capturedImage = [UIImage imageWithCGImage:cropCGImage scale:1 orientation:rawImage.imageOrientation];
             CGImageRelease(cropCGImage);
             
             [self postBytte];
         }
     }];
}

- (void)openCamera {
    self.captureSession = [[AVCaptureSession alloc] init];
    self.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    self.previewLayer.frame = self.view.bounds;
    [self.cameraView.layer addSublayer:self.previewLayer];
  
    UIView *view = self.cameraView;
    CALayer *viewLayer = [view layer];
    [viewLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[self.view bounds]];
    [viewLayer addSublayer:self.previewLayer];
    
    CGRect bounds = [view bounds];
    [self.previewLayer setFrame:bounds];
  
    NSArray *captureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    for (AVCaptureDevice *device in captureDevices) {
        if (device.position == AVCaptureDevicePositionBack) {
            self.backCaptureDevice = device;
        } else if (device.position == AVCaptureDevicePositionFront) {
            self.frontCaptureDevice = device;
        }
    }
    
    self.captureDevice = self.backCaptureDevice;
    
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
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys: AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [self.captureSession addOutput:self.stillImageOutput];
    [self.captureSession startRunning];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *imageFromPicker = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.capturedImage = [self imageWithImage:imageFromPicker scaledToSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self postBytte];
}

- (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
