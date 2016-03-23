//
//  BYTMyByttesHeaderCollectionReusableView.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/23/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTMyByttesHeaderCollectionReusableView.h"

@interface BYTMyByttesHeaderCollectionReusableView ()

@property (nonatomic, weak) IBOutlet UILabel *numberOfPostsLabel;
@property (weak, nonatomic) IBOutlet UIButton *avatarImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *avatarBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *blurredAvatarBackgroundImageView;

@end

@implementation BYTMyByttesHeaderCollectionReusableView

- (void)layoutSubviews {
    
    if (self.photoID) {
        NSString *imageName = [NSString stringWithFormat:@"avatar-%@.jpg", self.photoID];
        [self.avatarImageButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [self.avatarBackgroundImageView setImage:[UIImage imageNamed:imageName]];
        [self.blurredAvatarBackgroundImageView setImage:[self blurAvatarImage]];
    }
    
    self.avatarImageButton.layer.cornerRadius = self.avatarImageButton.frame.size.height/2;
    self.avatarImageButton.layer.masksToBounds = YES;
    self.avatarImageButton.layer.borderWidth = 0.0f;
}

- (UIImage *)blurAvatarImage {
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:[self.avatarBackgroundImageView.image CGImage]] forKey:@"inputImage"];
    [gaussianBlurFilter setValue:@10 forKey:@"inputRadius"];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGRect rect = [outputImage extent];
    
    rect.origin.x += (rect.size.width  - self.avatarBackgroundImageView.image.size.width ) / 2;
    rect.origin.y += (rect.size.height - self.avatarBackgroundImageView.image.size.height) / 2;
    rect.size = self.avatarBackgroundImageView.image.size;
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:rect];
    UIImage *image = [UIImage imageWithCGImage:cgimg];
    CGImageRelease(cgimg);
    
    return image;
}

- (void)dealloc {
    self.appCodeNameTextField.delegate = nil;
}

- (void)setNumberOfPosts:(NSInteger)numberOfPosts {
    if (_numberOfPosts != numberOfPosts) {
        _numberOfPosts = numberOfPosts;
        
        NSString *labelText;
        
        if (numberOfPosts > 1) {
            labelText = [NSString stringWithFormat:@"%li POSTS", (long)self.numberOfPosts];
        } else {
            labelText = [NSString stringWithFormat:@"%li POST", (long)self.numberOfPosts];
        }
        
        [self.numberOfPostsLabel setText:labelText];
    }
}

- (void)setPhotoID:(NSString *)photoID {
    if (_photoID != photoID) {
        _photoID = photoID;
        
        NSString *imageName = [NSString stringWithFormat:@"avatar-%@.jpg", photoID];
        UIImage *image = [UIImage imageNamed:imageName];
        [self.avatarImageButton setBackgroundImage:image forState:UIControlStateNormal];
        [self layoutIfNeeded];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView *view in self.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            self.appCodeNameTextField.text = nil;
            [view resignFirstResponder];
        }
    }
}

#pragma mark - Actions

- (IBAction)avatarImageButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectMyByttesHeaderCollectionReusableView:)]) {
        [self.delegate didSelectMyByttesHeaderCollectionReusableView:self];
    }
}


@end
