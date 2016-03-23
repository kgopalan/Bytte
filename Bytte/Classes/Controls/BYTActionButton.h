//
//  BYTActionButton.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/16/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface BYTActionButton : UIButton

@property (nonatomic, assign) BYTActionButtonState actionButtonState;
@property (nonatomic, strong) NSString *enabledStateImageName;
@property (nonatomic, strong) NSString *disabledStateImageName;

@end
