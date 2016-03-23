//
//  BYTNavigationView.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/6/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BYTNavigationViewState) {
    BYTNavigationViewStateClosed,
    BYTNavigationViewStateFilterOpen,
    BYTNavigationViewStateRadiusOpen
};

@protocol BYTNavigationViewDelegate;

@interface BYTNavigationView : UIView

@property (nonatomic, weak) IBOutlet id<BYTNavigationViewDelegate> delegate;
@property (nonatomic, assign) BYTNavigationViewState navigationState;
@property (nonatomic, strong) NSString *numberOfNotifications;

@end

@protocol BYTNavigationViewDelegate <NSObject>

- (void)navigationViewDidSelectNotifications:(BYTNavigationView *)navigationView;
- (void)navigationView:(BYTNavigationView *)navigationView didChangeFilter:(NSString *)filter;
- (void)navigationView:(BYTNavigationView *)navigationView didChangeRadius:(NSString *)radius;
- (void)navigationViewDidPressSettingsButton:(BYTNavigationView *)navigationView;
- (void)navigationViewWillBeginOpening:(BYTNavigationView *)navigationView;
- (void)navigationViewWillEndClosing:(BYTNavigationView *)navigationView;

@end