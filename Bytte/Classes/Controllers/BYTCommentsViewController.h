//
//  BYTCommentsViewController.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTBytte.h"

@interface BYTCommentsViewController : UIViewController

@property (nonatomic, strong) BYTBytte *bytte;
@property (nonatomic, assign) BOOL isFollowingBytte;

@end
