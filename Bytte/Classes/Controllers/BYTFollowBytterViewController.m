//
//  BYTFollowBytterViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/2/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTFollowBytterViewController.h"
#import "BYTFollowingCollectionViewCell.h"
#import "BYTDataSource.h"
#import "BYTCommentsViewController.h"
#import "BYTLocationViewController.h"
#import "PXLActionSheet.h"
#import "PXLActionSheetTheme.h"
#import "BYTActionButton.h"

@interface BYTFollowBytterViewController () <UICollectionViewDataSource, UICollectionViewDelegate, BYTFollowingCollectionViewCellDelegate>

@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *bytterNameLabel;
@property (nonatomic, strong) NSArray *followingUserByttes;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BYTActionButton *followButton;


@end

@implementation BYTFollowBytterViewController

#pragma mark - Init/Dealloc

- (void)dealloc {
   [[BYTDataSource sharedInstance] removeObserver:self forKeyPath:@"followingByttes"];
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldHideStatusBar = YES;
    
    self.followButton.disabledStateImageName = @"btn-follow";
    self.followButton.enabledStateImageName = @"btn-unfollow";
    self.followButton.actionButtonState = BYTActionButtonStateDisabled;
    
    self.followButton.layer.cornerRadius = self.followButton.frame.size.height/2;
    self.followButton.layer.masksToBounds = YES;
    
    self.bytterNameLabel.text = [self.bytterName uppercaseString];
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:kCATransition];
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

#pragma mark - Helpers

- (void)addObservers {
    [[BYTDataSource sharedInstance] addObserver:self forKeyPath:@"followingByttes" options:0 context:nil];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSInteger count = [[BYTDataSource sharedInstance] followingByttes].count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BYTFollowingCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FollowingCell" forIndexPath:indexPath];
    cell.delegate = self;

    BYTBytte *bytte = [[BYTDataSource sharedInstance].followingByttes objectAtIndex:indexPath.row];
    cell.bytte = bytte;
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    BYTFollowingCollectionViewCell *homeCell = (BYTFollowingCollectionViewCell *)cell;
    [homeCell collectionViewDidEndDisplayingCell];
}

#pragma mark - UICollectionViewLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    
    return CGSizeMake(width, height);
}

#pragma mark - Actions

- (IBAction)followButtonPressed:(id)sender {
    if (self.followButton.actionButtonState == BYTActionButtonStateEnabled) {
        [[BYTDataSource sharedInstance] unfollowUserWithDeviceID:self.userDeviceID completionHandler:^(NSError *error) {
            self.followButton.actionButtonState = BYTActionButtonStateDisabled;
        }];
    } else {
        [[BYTDataSource sharedInstance] followUserWithDeviceID:self.userDeviceID completionHandler:^(NSError *error) {
            self.followButton.actionButtonState = BYTActionButtonStateEnabled;
        }];
    }
}


- (IBAction)backButtonPressed:(id)sender {
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)flagBytte:(BYTBytte *)bytte {
    [[BYTDataSource sharedInstance] flagBytte:bytte];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BYTDataSource sharedInstance] && [keyPath isEqualToString:@"followingByttes"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.collectionView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            NSMutableArray *indexPathsChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPathsChanged addObject:newIndexPath];
            }];
            
            switch (kindOfChange) {
                case NSKeyValueChangeInsertion: {
                    [self.collectionView insertItemsAtIndexPaths:indexPathsChanged];
                }
                    break;
                case NSKeyValueChangeRemoval: {
                    [self.collectionView deleteItemsAtIndexPaths:indexPathsChanged];
                }
                    break;
                case NSKeyValueChangeReplacement: {
                    [self.collectionView reloadItemsAtIndexPaths:indexPathsChanged];
                }
                    break;
                default:
                    break;
            }
        }
        if ([[BYTDataSource sharedInstance] isFollowingBytte]) {
            self.followButton.actionButtonState = BYTActionButtonStateEnabled;
        }
    }
}

#pragma mark - BYTFollowingCollectionViewCellDelegate

- (void)cellDidPressLikeButton:(BYTFollowingCollectionViewCell *)cell {
    [[BYTDataSource sharedInstance] toggleLikeOnFollowingBytte:cell.bytte];
}

- (void)cellDidPressCommentButton:(BYTFollowingCollectionViewCell *)cell {
    BYTCommentsViewController *commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
    commentsVC.bytte = cell.bytte;
    commentsVC.isFollowingBytte = YES;
    
    [[BYTDataSource sharedInstance] fetchCommentsForFollowingBytte:cell.bytte completionHandler:nil];
    
    [self presentViewController:commentsVC animated:NO completion:nil];
}

- (void)cellDidPressLocationButton:(BYTFollowingCollectionViewCell *)cell {
    BYTBytte *bytte = cell.bytte;
    UIStoryboard *storyboard = self.storyboard;
    
    BYTLocationViewController *locationViewController = [storyboard instantiateViewControllerWithIdentifier:@"Location"];
    locationViewController.bytte = bytte;
    locationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:locationViewController animated:YES completion:nil];
}

- (void)cellDidTapMoreButton:(BYTFollowingCollectionViewCell *)cell {
    BYTBytte *bytte = cell.bytte;
    
    PXLActionSheetTheme *actionSheetTheme = [PXLActionSheetTheme defaultTheme];
    actionSheetTheme.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
    actionSheetTheme.borderColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
    actionSheetTheme.animationSpeed = 0.8f;
    
    actionSheetTheme.normalButtonColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    actionSheetTheme.normalButtonHighlightColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:0.8f];
    actionSheetTheme.destructiveButtonColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.8f];
    
    actionSheetTheme.normalButtonTextColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.8f];
    actionSheetTheme.destructiveButtonTextColor = [UIColor redColor];
    
    actionSheetTheme.buttonFont = [UIFont fontWithName:@"OpenSans-Semibold" size:13.0f];
    
    [PXLActionSheet showInView:self.view
                         withTheme:actionSheetTheme
                             title:nil
                 cancelButtonTitle:[@"Cancel" uppercaseString]
            destructiveButtonTitle:[@"Flag" uppercaseString]
                 otherButtonTitles:@[[@"Share" uppercaseString]]
                          tapBlock:^(PXLActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                              switch (tappedButtonIndex) {
                                  case 0:
                                      // Share
                                      break;
                                  case -2:
                                      [self flagBytte:bytte];
                                      break;
                                  default:
                                      break;
                              }
                          }];
}

- (void)cellDidToggleFullScreen:(BYTFollowingCollectionViewCell *)cell {
    BOOL isFullscreen = cell.isFullscreen;
    
    self.collectionView.scrollEnabled = isFullscreen ? NO : YES;
    self.followButton.hidden = isFullscreen ? YES : NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
