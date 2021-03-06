//
//  BYTNoticationTableViewCell.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 6/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTNotification.h"

@interface BYTNoticationTableViewCell : UITableViewCell

@property (nonatomic, strong) BYTNotification *notification;

+ (CGFloat)heightForNoticiation:(BYTNotification *)comment inView:(UIView *)containerView;

@end
