//
//  BYTPostBytteViewController.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTLightBytte.h"

@interface BYTPostBytteViewController : UIViewController

@property (nonatomic, strong) BYTLightBytte *lightBytte;
@property (nonatomic, assign) BOOL enableAddText;

@end
