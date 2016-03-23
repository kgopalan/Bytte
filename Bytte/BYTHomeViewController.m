//
//  ViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "BYTNavigationView.h"
#import "BYTDataSource.h"
#import "BYTBytte.h"
#import "BYTMyByttesHeaderCollectionReusableView.h"
#import "BYTHomeCollectionViewCell.h"
#import "BYTLocationViewController.h"
#import "BYTSettingsViewController.h"
#import "PXLActionSheet.h"
#import "PXLActionSheetTheme.h"
#import "BYTCreateMenuViewController.h"
#import "BYTSplashScreenViewController.h"
#import "BYTSelectAvatarViewController.h"
#import "BYTCommentsViewController.h"
#import "BYTFollowBytterViewController.h"
#import "BYTNotificationsViewController.h"

#define kMaxNumberAppCodeNameCharacters 13

@interface BYTHomeViewController () <BYTHomeCollectionViewCellDelegate, UICollectionViewDataSource, UICollectionViewDelegate, BYTNavigationViewDelegate, BYTMyByttesHeaderCollectionReusableViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIButton *addBytteButton;
@property (weak, nonatomic) IBOutlet BYTNavigationView *navigationView;
@property (nonatomic, assign) BOOL hasLaunchedBytterCreator;

@property (nonatomic, assign) BOOL isMyByttes;

@property (nonatomic, assign) BOOL shouldHideStatusBar;

@property (nonatomic, assign) CGPoint currentScrollPosition;
@property (nonatomic, assign) CGPoint lastScrollPosition;

@end

@implementation BYTHomeViewController

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _shouldHideStatusBar = YES;
        _hasLaunchedBytterCreator = NO;
    }
    
    return self;
}

- (void)dealloc {
    [[BYTDataSource sharedInstance] removeObserver:self forKeyPath:@"byttes"];
    [[BYTDataSource sharedInstance] removeObserver:self forKeyPath:@"notifications"];
    _collectionView.delegate = nil;
    _collectionView.dataSource = nil;
}

#pragma mark - Properties

- (BOOL)isMyByttes {
    return [self isMyByttesFilter:[BYTDataSource sharedInstance].currentFilter];
}

- (BOOL)isMyByttesFilter:(NSString *)filter {
    return [filter isEqualToString:@"my"];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObservers];
    [self addPullToRefresh];
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![[BYTDataSource sharedInstance] hasDeviceID] && !self.hasLaunchedBytterCreator) {
        BYTSplashScreenViewController *splashVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SplashScreen"];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:splashVC];
        self.hasLaunchedBytterCreator = YES;
        [self presentViewController:navigationController animated:NO completion:nil];
    } else {
        
    }
}

#pragma mark - Helpers

- (void)addObservers {
    [[BYTDataSource sharedInstance] addObserver:self forKeyPath:@"byttes" options:0 context:nil];
    [[BYTDataSource sharedInstance] addObserver:self forKeyPath:@"notifications" options:0 context:nil];
}

- (void)addPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor grayColor];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}

#pragma mark - Pull-to-Refresh

- (void)refreshControlDidFire:(UIRefreshControl *)sender {
    [[BYTDataSource sharedInstance] fetchNewByttesWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}

- (BOOL)isLastBytteForIndexPath:(NSIndexPath *)indexPath {
    NSInteger numberOfByttes = [BYTDataSource sharedInstance].byttes.count;
    
    if (indexPath.row == numberOfByttes - 1) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - UICollectionViewDataSource

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([self isMyByttes]) {
        BYTMyByttesHeaderCollectionReusableView *myByttesHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"MyByttesHeader" forIndexPath:indexPath];
        myByttesHeaderView.numberOfPosts = [BYTDataSource sharedInstance].byttes.count;
        myByttesHeaderView.delegate = self;
        NSString *photoID = [[BYTDataSource sharedInstance] avatarPhotoID];
        myByttesHeaderView.photoID = photoID;
        myByttesHeaderView.appCodeNameTextField.text = [[BYTDataSource sharedInstance] appCodeName];
        
        NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:@"Your bytter name" attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor]}];
        myByttesHeaderView.appCodeNameTextField.attributedPlaceholder = placeholderText;
        myByttesHeaderView.appCodeNameTextField.tintColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
        myByttesHeaderView.appCodeNameTextField.enablesReturnKeyAutomatically = YES;
        
        return myByttesHeaderView;
    } else {
        return nil;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [BYTDataSource sharedInstance].byttes.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BYTHomeCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BytteCell" forIndexPath:indexPath];
    cell.delegate = self;
    
    BYTBytte *bytte = [[BYTDataSource sharedInstance].byttes objectAtIndex:indexPath.row];
    
    cell.bytte = bytte;
    cell.isMyBytte = [self isMyByttes];
  
//    float speed = self.scrollSpeed.y;
//    
//    if (speed != 0.0f) { // Don't animate the initial state
//        cell.layer.opacity = 1.0f - fabs(speed);
//    }
//    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3];
//    
//    cell.layer.transform = CATransform3DIdentity;
//    cell.layer.opacity = 1.0f;
//    
//    [UIView commitAnimations];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    BYTHomeCollectionViewCell *homeCell = (BYTHomeCollectionViewCell *)cell;
    [homeCell collectionViewDidEndDisplayingCell];
}

#pragma mark - UICollectionViewLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if ([self isMyByttes]) {
        CGFloat height = CGRectGetHeight(self.collectionView.frame);
        CGFloat width = CGRectGetWidth(self.collectionView.frame);
        
        return CGSizeMake(width, height);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    
    return CGSizeMake(width, height);
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BYTDataSource sharedInstance] && [keyPath isEqualToString:@"byttes"]) {
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
        [self.collectionView setContentOffset:CGPointZero];
    } else if (object == [BYTDataSource sharedInstance] && [keyPath isEqualToString:@"notifications"]) {
        self.navigationView.numberOfNotifications = [NSString stringWithFormat:@"%li", [[BYTDataSource sharedInstance] notifications].count];
    }
}

#pragma mark - BYTHomeCollectionViewCellDelegate 

- (void)cellDidPressFollowButton:(BYTHomeCollectionViewCell *)cell {
    BYTFollowBytterViewController *followVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FollowBytter"];
#warning temp name for now until app code name added to server response - test comment
//    followVC.bytterName = cell.bytte.appcodename;
    followVC.bytterName = @"APPCODENAME";
    followVC.userDeviceID = cell.bytte.deviceID;
    
    [[BYTDataSource sharedInstance] fetchFollowingUserListWithCompletionHandler:nil];
    [[BYTDataSource sharedInstance] fetchByttesForUserOfBytte:cell.bytte completionHandler:nil];
    
    [self presentViewController:followVC animated:NO completion:nil];
}

- (void)cellDidPressLikeButton:(BYTHomeCollectionViewCell *)cell {
    [[BYTDataSource sharedInstance] toggleLikeOnBytte:cell.bytte];
}

- (void)cellDidPressCommentButton:(BYTHomeCollectionViewCell *)cell {
    BYTCommentsViewController *commentsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Comments"];
    commentsVC.bytte = cell.bytte;
    
    [[BYTDataSource sharedInstance] fetchCommentsForBytte:cell.bytte completionHandler:nil];
    
    [self presentViewController:commentsVC animated:NO completion:nil];
}

- (void)cellDidPressLocationButton:(BYTHomeCollectionViewCell *)cell {
    BYTBytte *bytte = cell.bytte;
    UIStoryboard *storyboard = self.storyboard;
    
    BYTLocationViewController *locationViewController = [storyboard instantiateViewControllerWithIdentifier:@"Location"];
    locationViewController.bytte = bytte;
    locationViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:locationViewController animated:YES completion:nil];
}

- (void)cellDidTapMoreButton:(BYTHomeCollectionViewCell *)cell {
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
    
    if (self.isMyByttes) {
        [PXLActionSheet showInView:self.view
                         withTheme:actionSheetTheme
                             title:nil
                 cancelButtonTitle:[@"Cancel" uppercaseString]
            destructiveButtonTitle:[@"Delete" uppercaseString]
                 otherButtonTitles:@[[@"Share" uppercaseString]]
                          tapBlock:^(PXLActionSheet *actionSheet, NSInteger tappedButtonIndex) {
                              switch (tappedButtonIndex) {
                                  case 0:
                                      // Share
                                      break;
                                  case -2:
                                      [self deleteBytte:bytte];
                                      break;
                                  default:
                                      break;
                              }
                          }];
    } else {
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
}

- (void)cellDidToggleFullScreen:(BYTHomeCollectionViewCell *)cell {
    BOOL isFullscreen = cell.isFullscreen;
    
    self.collectionView.scrollEnabled = isFullscreen ? NO : YES;
    self.addBytteButton.hidden = (isFullscreen || self.isMyByttes) ? YES : NO;
    self.navigationView.hidden = isFullscreen ? YES : NO;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Collection View Transition Animation Helpers

- (CGPoint)scrollSpeed {
    return CGPointMake(self.lastScrollPosition.x - self.currentScrollPosition.x,
                       self.lastScrollPosition.y - self.currentScrollPosition.y);
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastScrollPosition = self.currentScrollPosition;
    self.currentScrollPosition = [scrollView contentOffset];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self scrollingFinished];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollingFinished];
}

- (void)scrollingFinished {
    NSArray *visibleCellsIndexPaths = [self.collectionView indexPathsForVisibleItems];
    
    for (NSIndexPath *indexPath in visibleCellsIndexPaths) {
        CGRect cellRect = [[self.collectionView layoutAttributesForItemAtIndexPath:indexPath] frame];
        BYTHomeCollectionViewCell *cell = (BYTHomeCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
        
        if (CGRectContainsRect(visibleRect, cellRect)) {
            [cell playVideoIfNeeded];
        } else {
            [cell pauseVideoIfNeeded];
        }
    }
}

#pragma mark - Actions

- (IBAction)addBytteButtonPressed:(id)sender {
    BYTCreateMenuViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateMenu"];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void)flagBytte:(BYTBytte *)bytte {
    [[BYTDataSource sharedInstance] flagBytte:bytte];
}

- (void)deleteBytte:(BYTBytte *)bytte {
    [[BYTDataSource sharedInstance] removeBytte:bytte];
}

#pragma mark - BYTNavigationViewDelegate

- (void)navigationViewDidSelectNotifications:(BYTNavigationView *)navigationView {
    BYTNotificationsViewController *notificationsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Notifications"];
    
    [self presentViewController:notificationsVC animated:NO completion:nil];
}

- (void)navigationView:(BYTNavigationView *)navigationView didChangeFilter:(NSString *)filter {
    if ([self isMyByttesFilter:filter]) {
        self.addBytteButton.hidden = YES;
    } else {
        self.addBytteButton.hidden = NO;
    }
    
    [[BYTDataSource sharedInstance] fetchNewByttesWithFilter:filter completionHandler:nil];
}

- (void)navigationView:(BYTNavigationView *)navigationView didChangeRadius:(NSString *)radius {
    [[BYTDataSource sharedInstance] fetchNewByttesWithSearchRadius:radius completionHandler:nil];
}

- (void)navigationViewDidPressSettingsButton:(BYTNavigationView *)navigationView {
    BYTSettingsViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    [self presentViewController:nav animated:NO completion:nil];
}

- (void)navigationViewWillBeginOpening:(BYTNavigationView *)navigationView {
    NSArray *visibleCells = [self.collectionView visibleCells];
    
    for (BYTHomeCollectionViewCell *cell in visibleCells) {
        cell.isFullscreen = YES;
    }
}

- (void)navigationViewWillEndClosing:(BYTNavigationView *)navigationView {
    NSArray *visibleCells = [self.collectionView visibleCells];
    
    for (BYTHomeCollectionViewCell *cell in visibleCells) {
        cell.isFullscreen = NO;
    }
}

#pragma mark - BYTMyByttesHeaderCollectionReusableViewDelegate

- (void)didSelectMyByttesHeaderCollectionReusableView:(BYTMyByttesHeaderCollectionReusableView *)headerView {
    BYTSelectAvatarViewController *selectAvatarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAvatar"];
    selectAvatarVC.appCodeName = [[BYTDataSource sharedInstance] appCodeName];
    selectAvatarVC.initialPhotoID = [[BYTDataSource sharedInstance] avatarPhotoID];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:selectAvatarVC];
    
    [self presentViewController:navigationController animated:YES completion:^{
        [self.collectionView reloadData];
    }];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // First check to see if the "Done" button was pressed
    if ([string isEqualToString:@"\n"]) {
        NSString *photoID;
        
        if ([[BYTDataSource sharedInstance] avatarPhotoID]) {
            photoID = [[BYTDataSource sharedInstance] avatarPhotoID];
        } else {
            photoID = @"1";
        }
        
        [[BYTDataSource sharedInstance] updateProfileWithCodeName:textField.text photoID:photoID completionHandler:nil];
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
        return NO;
    }
    
    if (textField.text.length < kMaxNumberAppCodeNameCharacters) {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
    
    if (textField.text.length == kMaxNumberAppCodeNameCharacters && string.length == 0) {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
    
    return NO;
}

@end
