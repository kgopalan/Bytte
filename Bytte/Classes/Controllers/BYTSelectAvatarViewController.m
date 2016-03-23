//
//  BYTSelectAvatarViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTSelectAvatarViewController.h"
#import "BYTDataSource.h"
#import "BYTSelectAvatarCollectionViewCell.h"

@interface BYTSelectAvatarViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIImageView *currentAvatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *appCodeNameLabel;
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, strong) NSArray *avatars;
@end

@implementation BYTSelectAvatarViewController

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _shouldHideStatusBar = YES;
        _selectedItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self populateData];
    }
    
    return self;
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];

    NSString *avatarImageName;
    
    self.appCodeNameLabel.text = self.appCodeName;
    
    if (self.initialPhotoID) {
        NSString *photoID = self.initialPhotoID;
        avatarImageName = [NSString stringWithFormat:@"avatar-%@.jpg", photoID];
        
        NSInteger selectedItemRow = [self.initialPhotoID integerValue];
        if (selectedItemRow < [self.collectionView numberOfItemsInSection:0]) {
            self.selectedItemIndexPath = [NSIndexPath indexPathForRow:selectedItemRow-1 inSection:0];
        } else {
            self.selectedItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            avatarImageName = [NSString stringWithFormat:@"avatar-%@.jpg", @"1"];
        }
    } else {
        self.selectedItemIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        avatarImageName = [NSString stringWithFormat:@"avatar-%@.jpg", @"1"];
    }
    
    UIImage *avatarImage = [UIImage imageNamed:avatarImageName];
    [self.currentAvatarImageView setImage:avatarImage];
    self.currentAvatarImageView.layer.cornerRadius = self.currentAvatarImageView.frame.size.height/2;
    self.currentAvatarImageView.layer.masksToBounds = YES;
    self.currentAvatarImageView.layer.borderWidth = 0.0f;
}

- (void)populateData {
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (int index = 1; index <= 6; index++) {
        NSString *photoID = [NSString stringWithFormat:@"avatar-%i.jpg", index];
        [tempArray addObject:photoID];
    }
    self.avatars = [tempArray copy];
}

#pragma mark - Actions

- (IBAction)doneButtonPressed:(id)sender {
    if (!self.appCodeName) {
        self.appCodeName = @"";
    }
    
    NSString *photoID = [self photoIDForIndexPath:self.selectedItemIndexPath];
    
    [[BYTDataSource sharedInstance] updateProfileWithCodeName:self.appCodeName photoID:photoID completionHandler:nil];
    [[BYTDataSource sharedInstance] updateProfileWithCodeName:self.appCodeName photoID:photoID completionHandler:^(NSError *error) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.avatars.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BYTSelectAvatarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AvatarCell" forIndexPath:indexPath];
    
    NSString *imageName = [self.avatars objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:imageName];
    
    if (self.selectedItemIndexPath != nil && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
        cell.imageView.layer.borderColor = [[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] CGColor];
        cell.imageView.layer.borderWidth = 4.0;
    } else {
        cell.imageView.layer.borderColor = nil;
        cell.imageView.layer.borderWidth = 0.0;
    }
    
    return cell;
}

#pragma mark - UICollectionViewLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = floor((CGRectGetWidth(self.collectionView.frame) - 10)/3);
    
    return CGSizeMake(width, width);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (self.selectedItemIndexPath) {
        if ([indexPath compare:self.selectedItemIndexPath] != NSOrderedSame)
        {
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
        }
    }
    else {
        self.selectedItemIndexPath = indexPath;
    }
   
    NSString *photoID = [self photoIDForIndexPath:self.selectedItemIndexPath];
    NSString *imageName = [NSString stringWithFormat:@"avatar-%@.jpg", photoID];
    self.currentAvatarImageView.image = [UIImage imageNamed:imageName];
    [collectionView reloadItemsAtIndexPaths:indexPaths];
}

- (NSString *)photoIDForIndexPath:(NSIndexPath *)indexPath {
    NSString *photoID;
    
    switch (indexPath.row) {
        case 0: {
            photoID = @"1";
            break;
        }
        case 1: {
            photoID = @"2";
            break;
        }
        case 2: {
            photoID = @"3";
            break;
        }
        case 3: {
            photoID = @"4";
            break;
        }
        case 4: {
            photoID = @"5";
            break;
        }
        case 5: {
            photoID = @"6";
            break;
        }
        default: {
            photoID = @"1";
            break;
        }
    }
    
    return photoID;
}

@end
