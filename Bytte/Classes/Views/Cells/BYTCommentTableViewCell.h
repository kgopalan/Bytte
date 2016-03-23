//
//  BYTCommentTableViewCell.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTComment.h"

@interface BYTCommentTableViewCell : UITableViewCell

@property (nonatomic, strong) BYTComment *comment;

+ (CGFloat)heightForComment:(NSString *)comment inView:(UIView *)containerView;

@end
