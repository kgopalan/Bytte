//
//  BYTActionButton.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/16/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTActionButton.h"

@implementation BYTActionButton

#pragma mark - Init

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentEdgeInsets =UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        _actionButtonState = BYTActionButtonStateDisabled;
    }
    
    return self;
}

#pragma mark - Properties

- (void)setActionButtonState:(BYTActionButtonState)actionButtonState {
    _actionButtonState = actionButtonState;
    
    NSString *imageName;
    
    switch (_actionButtonState) {
        case BYTActionButtonStateEnabled:
        case BYTActionButtonStateDisabling: {
            imageName = self.enabledStateImageName;
        }
            break;
        case BYTActionButtonStateDisabled:
        case BYTActionButtonStateEnabling: {
            imageName = self.disabledStateImageName;
        }
            break;
    }
    
    UIImage *image = [UIImage imageNamed:imageName];
    [self setImage:image forState:UIControlStateNormal];
}

@end
