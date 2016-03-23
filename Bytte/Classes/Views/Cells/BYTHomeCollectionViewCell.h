//
//  BYTHomeCollectionViewCell.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTBytte.h"

@protocol BYTHomeCollectionViewCellDelegate;

@interface BYTHomeCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <BYTHomeCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) BYTBytte *bytte;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) BOOL isFullscreen;
@property (assign, nonatomic) BOOL isMyBytte;

- (void)collectionViewDidEndDisplayingCell;
- (void)playVideoIfNeeded;
- (void)pauseVideoIfNeeded;

@end

@protocol BYTHomeCollectionViewCellDelegate <NSObject>

- (void)cellDidPressLikeButton:(BYTHomeCollectionViewCell *)cell;
- (void)cellDidPressCommentButton:(BYTHomeCollectionViewCell *)cell;
- (void)cellDidPressLocationButton:(BYTHomeCollectionViewCell *)cell;
- (void)cellDidTapMoreButton:(BYTHomeCollectionViewCell *)cell;
- (void)cellDidToggleFullScreen:(BYTHomeCollectionViewCell *)cell;
- (void)cellDidPressFollowButton:(BYTHomeCollectionViewCell *)cell;

@end