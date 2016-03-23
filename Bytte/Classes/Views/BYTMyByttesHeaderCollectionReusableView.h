//
//  BYTMyByttesHeaderCollectionReusableView.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/23/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BYTMyByttesHeaderCollectionReusableViewDelegate;

@interface BYTMyByttesHeaderCollectionReusableView : UICollectionReusableView

@property (nonatomic, assign) NSInteger numberOfPosts;
@property (nonatomic, weak) id<BYTMyByttesHeaderCollectionReusableViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITextField *appCodeNameTextField;
@property (nonatomic, strong) NSString *photoID;

@end

@protocol BYTMyByttesHeaderCollectionReusableViewDelegate <NSObject>

- (void)didSelectMyByttesHeaderCollectionReusableView:(BYTMyByttesHeaderCollectionReusableView *)headerView;

@end