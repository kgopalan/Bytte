//
//  BYTFollowingCollectionViewCell.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTBytte.h"

@protocol BYTFollowingCollectionViewCellDelegate;

@interface BYTFollowingCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) id <BYTFollowingCollectionViewCellDelegate> delegate;
@property (strong, nonatomic) BYTBytte *bytte;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (assign, nonatomic) BOOL isFullscreen;
@property (assign, nonatomic) BOOL isMyBytte;

- (void)collectionViewDidEndDisplayingCell;
- (void)playVideoIfNeeded;
- (void)pauseVideoIfNeeded;

@end

@protocol BYTFollowingCollectionViewCellDelegate <NSObject>

- (void)cellDidPressLikeButton:(BYTFollowingCollectionViewCell *)cell;
- (void)cellDidPressCommentButton:(BYTFollowingCollectionViewCell *)cell;
- (void)cellDidPressLocationButton:(BYTFollowingCollectionViewCell *)cell;
- (void)cellDidTapMoreButton:(BYTFollowingCollectionViewCell *)cell;
- (void)cellDidToggleFullScreen:(BYTFollowingCollectionViewCell *)cell;

@end