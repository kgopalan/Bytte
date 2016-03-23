//
//  BYTNavigationView.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/6/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTNavigationView.h"
#import "Constants.h"

static CGFloat kFilterItemHeight = 60.0f;
static CGFloat kNumberOfFilterItems = 4.0f;

@interface BYTNavigationView ()

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) UIView *backgroundTopView;
@property (nonatomic, strong) NSLayoutConstraint *backgroundTopViewHeightConstraint;

@property (nonatomic, strong) UIView *notificationContainerView;
@property (nonatomic, strong) UIView *notificationBackgroundImageView;

@property (nonatomic, strong) IBOutlet UIButton *filterButton;
@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) NSLayoutConstraint *settingsButtonWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *settingsButtonHeightConstraint;
@property (nonatomic, strong) NSString *currentFilter;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIButton *searchRadiusButton;
@property (nonatomic, strong) UIView *buttonContainerView;
@property (nonatomic, strong) UIButton *downArrowButton;
@property (nonatomic, strong) NSLayoutConstraint *downArrowImageViewHeightConstraint;
@property (nonatomic, strong) NSLayoutConstraint *downArrowImageViewWidthConstraint;
@property (nonatomic, strong) NSArray *buttonHorizontalConstraints;
@property (nonatomic, strong) NSLayoutConstraint *searchRadiusHorizontalAlignmentConstraint;
@property (nonatomic, strong) NSArray *searchRadiusHorizontalConstraints;
@property (nonatomic, strong) NSLayoutConstraint *filterButtonHorizontalAlignmentConstraint;
@property (nonatomic, strong) NSArray *filterButtonHorizontalConstraints;

@property (nonatomic, strong) UIView *dropBackgroundView;
@property (nonatomic, strong) UIButton *trendingFilterButton;
@property (nonatomic, strong) UIView *trendingFilterButtonTopSeparatorView;
@property (nonatomic, strong) UIButton *popularFilterButton;
@property (nonatomic, strong) UIView *popularFilterButtonTopSeparatorView;
@property (nonatomic, strong) UIButton *recentFilterButton;
@property (nonatomic, strong) UIView *recentFilterButtonTopSeparatorView;
@property (nonatomic, strong) UIButton *myByttesFilterButton;
@property (nonatomic, strong) UIView *myByttesFilterButtonTopSeparatorView;
@property (nonatomic, strong) UILabel *notificationLabel;
@property (nonatomic, strong) UIView *notificationsFlagView;
@property (nonatomic, strong) UIView *notificationBackgroundCircleView;

@property (nonatomic, strong) UISlider *searchRadiusSlider;

@property (nonatomic, assign) BOOL isFilterOpen;
@property (nonatomic, assign) BOOL isSearchRadiusOpen;

@end

@implementation BYTNavigationView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _backgroundTopView = [[UIView alloc] init];
        _backgroundTopView.translatesAutoresizingMaskIntoConstraints = NO;
        _backgroundTopView.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f];
        _backgroundTopView.alpha = 0.0f;
        [self addSubview:_backgroundTopView];
        
        _buttonContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _buttonContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_buttonContainerView];
        
        _notificationContainerView = [[UIView alloc] initWithFrame:CGRectZero];
        _notificationContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        _notificationContainerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_notificationContainerView];
        
        _notificationBackgroundImageView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
        _notificationBackgroundImageView.backgroundColor = [UIColor clearColor];
        _notificationBackgroundImageView.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationContainerView addSubview:_notificationBackgroundImageView];
        
        _notificationBackgroundCircleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 36.0f, 36.0f)];
        _notificationBackgroundCircleView.backgroundColor = [UIColor colorWithRed:42.0f/255.0f green:51.0f/255.0f blue:58.0f/255.0f alpha:0.8f];
        _notificationBackgroundCircleView.layer.cornerRadius = _notificationBackgroundImageView.frame.size.height/2;
        _notificationBackgroundCircleView.layer.masksToBounds = YES;
        _notificationBackgroundCircleView.translatesAutoresizingMaskIntoConstraints = NO;
        [_notificationBackgroundImageView addSubview:_notificationBackgroundCircleView];
        
        _numberOfNotifications = @"0";
        _notificationLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(_notificationBackgroundImageView.frame)/2 - 3, 0.0f, CGRectGetWidth(_notificationBackgroundImageView.frame)/2, _notificationBackgroundImageView.frame.size.height)];
        _notificationLabel.textColor = [UIColor whiteColor];
        _notificationLabel.font = [UIFont fontWithName:@"OpenSans-Semibold" size:11.0f];
        _notificationLabel.text = _numberOfNotifications;
        [_notificationBackgroundImageView addSubview:_notificationLabel];
        
        _notificationsFlagView = [[UIView alloc] initWithFrame:CGRectMake(30.0f, 5.0f, 10.0f, 10.0f)];
        _notificationsFlagView.backgroundColor = [UIColor colorWithRed:255.0f/255.0f green:7.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
        _notificationsFlagView.layer.cornerRadius = _notificationsFlagView.frame.size.height/2;
        _notificationsFlagView.layer.masksToBounds = YES;
        _notificationsFlagView.hidden = YES;
        [_notificationBackgroundImageView addSubview:_notificationsFlagView];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(notificationsTapped:)];
        [_notificationBackgroundImageView addGestureRecognizer:tapRecognizer];
        
        _settingsButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _settingsButton.translatesAutoresizingMaskIntoConstraints = NO;
        _settingsButton.alpha = 0.0f;
        UIImage *settingsImage = [UIImage imageNamed:@"ic-settings"];
        [_settingsButton setImage:settingsImage forState:UIControlStateNormal];
        [_settingsButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_settingsButton];
        
        _currentFilter = @"trending";
        _filterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _filterButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_filterButton setTitle:[_currentFilter uppercaseString] forState:UIControlStateNormal];
        [_filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_filterButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_filterButton addTarget:self action:@selector(filterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonContainerView addSubview:_filterButton];
        
        _searchRadiusButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _searchRadiusButton.translatesAutoresizingMaskIntoConstraints = NO;
        NSString *searchRadiusTitle = [self titleForSearchRadius:kDefaultSearchRadius];
        [_searchRadiusButton setTitle:searchRadiusTitle forState:UIControlStateNormal];
        [_searchRadiusButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_searchRadiusButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_searchRadiusButton addTarget:self action:@selector(searchRadiusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonContainerView addSubview:_searchRadiusButton];
        
        _separatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _separatorView.alpha = 1.0f;
        _separatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _separatorView.backgroundColor = [UIColor whiteColor];
        [_buttonContainerView addSubview:_separatorView];
        
        UIImage *downArrowImage = [UIImage imageNamed:@"ic-arrow-down"];
        _downArrowButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _downArrowButton.translatesAutoresizingMaskIntoConstraints = NO;
        _downArrowButton.hidden = YES;
        _downArrowButton.alpha = 0.0f;
        [_downArrowButton setImage:downArrowImage forState:UIControlStateNormal];
        [_downArrowButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_downArrowButton];
        
        _searchRadiusSlider = [[UISlider alloc] init];
        _searchRadiusSlider.alpha = 0.0f;
        _searchRadiusSlider.translatesAutoresizingMaskIntoConstraints = NO;
        _searchRadiusSlider.minimumTrackTintColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
        _searchRadiusSlider.maximumTrackTintColor = [UIColor whiteColor];
        UIImage *thumbImage = [UIImage imageNamed:@"btn-radius-handle"];
        [_searchRadiusSlider setThumbImage:thumbImage forState:UIControlStateNormal];
        _searchRadiusSlider.minimumValue = 1.0f;
        _searchRadiusSlider.maximumValue = 50.0f;
        _searchRadiusSlider.value = kDefaultSearchRadius;
        [_searchRadiusSlider addTarget:self action:@selector(searchRadiusValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_searchRadiusSlider];
        
        _trendingFilterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _trendingFilterButton.alpha = 0.0f;
        _trendingFilterButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_trendingFilterButton setTitle:[@"Trending" uppercaseString] forState:UIControlStateNormal];
        [_trendingFilterButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_trendingFilterButton setTitleColor:[UIColor colorWithRed:123.0f/255.0f green:139.0f/255.0f blue:151.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_trendingFilterButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [_trendingFilterButton addTarget:self action:@selector(trendingFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_trendingFilterButton];
        
        _trendingFilterButtonTopSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _trendingFilterButtonTopSeparatorView.alpha = 0.0f;
        _trendingFilterButtonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _trendingFilterButtonTopSeparatorView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
        [self addSubview:_trendingFilterButtonTopSeparatorView];
        
        _popularFilterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _popularFilterButton.alpha = 0.0f;
        _popularFilterButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_popularFilterButton setTitle:[@"Popular" uppercaseString] forState:UIControlStateNormal];
        [_popularFilterButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_popularFilterButton setTitleColor:[UIColor colorWithRed:123.0f/255.0f green:139.0f/255.0f blue:151.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_popularFilterButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [_popularFilterButton addTarget:self action:@selector(popularFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_popularFilterButton];
        
        _popularFilterButtonTopSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _popularFilterButtonTopSeparatorView.alpha = 0.0f;
        _popularFilterButtonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _popularFilterButtonTopSeparatorView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
        [self addSubview:_popularFilterButtonTopSeparatorView];
        
        _recentFilterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _recentFilterButton.alpha = 0.0f;
        _recentFilterButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_recentFilterButton setTitle:[@"Recent" uppercaseString] forState:UIControlStateNormal];
        [_recentFilterButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_recentFilterButton setTitleColor:[UIColor colorWithRed:123.0f/255.0f green:139.0f/255.0f blue:151.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_recentFilterButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [_recentFilterButton addTarget:self action:@selector(recentFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_recentFilterButton];
        
        _recentFilterButtonTopSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _recentFilterButtonTopSeparatorView.alpha = 0.0f;
        _recentFilterButtonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _recentFilterButtonTopSeparatorView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
        [self addSubview:_recentFilterButtonTopSeparatorView];
        
        _myByttesFilterButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _myByttesFilterButton.alpha = 0.0f;
        _myByttesFilterButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_myByttesFilterButton setTitle:[@"Me" uppercaseString] forState:UIControlStateNormal];
        [_myByttesFilterButton.titleLabel setFont:[UIFont fontWithName:@"OpenSans-Semibold" size:13.0f]];
        [_myByttesFilterButton setTitleColor:[UIColor colorWithRed:123.0f/255.0f green:139.0f/255.0f blue:151.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [_myByttesFilterButton setTitleColor:[UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f] forState:UIControlStateHighlighted];
        [_myByttesFilterButton addTarget:self action:@selector(myByttesFilterButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_myByttesFilterButton];
        
        _myByttesFilterButtonTopSeparatorView = [[UIView alloc] initWithFrame:CGRectZero];
        _myByttesFilterButtonTopSeparatorView.alpha = 0.0f;
        _myByttesFilterButtonTopSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
        _myByttesFilterButtonTopSeparatorView.backgroundColor = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:0.22f];
        [self addSubview:_myByttesFilterButtonTopSeparatorView];
        
        
        _isFilterOpen = NO;
        _isSearchRadiusOpen = NO;
        
        [self setupConstraints];
    }
    
    return self;
}

- (void)setNumberOfNotifications:(NSString *)numberOfNotifications {
    _numberOfNotifications = numberOfNotifications;
    self.notificationLabel.text = numberOfNotifications;
    
    if ([numberOfNotifications isEqualToString:@"0"]) {
        self.notificationsFlagView.hidden = YES;
    } else {
        self.notificationsFlagView.hidden = NO;
    }
}

- (void)setupConstraints {
    NSDictionary *views = @{@"backgroundTopView" : self.backgroundTopView,
                            @"settingsButton" : self.settingsButton,
                            @"notificationContainerView" : self.notificationContainerView,
                            @"buttonContainerView" : self.buttonContainerView,
                            @"filterButton" : self.filterButton,
                            @"searchRadiusButton" : self.searchRadiusButton,
                            @"trendingFilterButton" : self.trendingFilterButton,
                            @"popularFilterButton" : self.popularFilterButton,
                            @"recentFilterButton" : self.recentFilterButton,
                            @"myByttesFilterButton" : self.myByttesFilterButton,
                            @"searchRadiusSlider" : self.searchRadiusSlider,
                            @"downArrow" : self.downArrowButton,
                            @"trendingFilterButtonTopSeparatorView" : self.trendingFilterButtonTopSeparatorView,
                            @"popularFilterButtonTopSeparatorView" : self.popularFilterButtonTopSeparatorView,
                            @"recentFilterButtonTopSeparatorView" : self.recentFilterButtonTopSeparatorView,
                            @"myByttesFilterButtonTopSeparatorView" : self.myByttesFilterButtonTopSeparatorView,
                            @"separatorView" : self.separatorView};
    
    NSArray *backgroundTopViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[backgroundTopView]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *backgroundTopViewTopConstraint = [NSLayoutConstraint constraintWithItem:_backgroundTopView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:-33.0f];
    _backgroundTopViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_backgroundTopView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:69.0f];
    [self addConstraints:backgroundTopViewHorizontalConstraints];
    [self addConstraints:@[backgroundTopViewTopConstraint, _backgroundTopViewHeightConstraint]];
    
    // Settings Button
    NSLayoutConstraint *settingsButtonWidthConstraint = [NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
    NSLayoutConstraint *settingsButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
    NSLayoutConstraint *settingsButtonTrailingConstraint = [NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-10.0f];
    NSLayoutConstraint *settingsButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_settingsButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:-4.0f];
    
    [self addConstraints:@[settingsButtonWidthConstraint, settingsButtonHeightConstraint, settingsButtonTrailingConstraint, settingsButtonTopConstraint]];
    
    // Notifications Constraints
    NSLayoutConstraint *notificationContainerViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_notificationContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    NSLayoutConstraint *notificationContainerViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_notificationContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40.0f];
    NSLayoutConstraint *notificationContainerViewLeadingConstraint = [NSLayoutConstraint constraintWithItem:_notificationContainerView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:10.0f];
    NSLayoutConstraint *notificationContainerViewTopConstraint = [NSLayoutConstraint constraintWithItem:_notificationContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0.0f];
    
    [self addConstraints:@[notificationContainerViewWidthConstraint, notificationContainerViewHeightConstraint, notificationContainerViewLeadingConstraint, notificationContainerViewTopConstraint]];
    
    NSLayoutConstraint *notificationBackgroundImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_notificationBackgroundImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
    NSLayoutConstraint *notificationBackgroundImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_notificationBackgroundImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
    NSLayoutConstraint *notificationBackgroundImageViewCenterXConstraint = [NSLayoutConstraint constraintWithItem:_notificationBackgroundImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_notificationContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *notificationBackgroundImageViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:_notificationBackgroundImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_notificationContainerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:-10.0f];
    
    [self.notificationContainerView addConstraints:@[notificationBackgroundImageViewWidthConstraint, notificationBackgroundImageViewHeightConstraint, notificationBackgroundImageViewCenterXConstraint, notificationBackgroundImageViewCenterYConstraint]];
    
    // Filter and Search Radius Button Constraints
    NSLayoutConstraint *buttonContainterViewHorizontalConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *buttonContainterViewTopConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:-10.0f];
    NSLayoutConstraint *buttonContainterViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_buttonContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:36.0f];
    
    [self addConstraints:@[buttonContainterViewHorizontalConstraint, buttonContainterViewTopConstraint, buttonContainterViewHeightConstraint]];
    
    _buttonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[filterButton]-[separatorView]-[searchRadiusButton]|" options:0 metrics:nil views:views];
    _filterButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[filterButton]|" options:0 metrics:nil views:views];
    _filterButtonHorizontalAlignmentConstraint = [NSLayoutConstraint constraintWithItem:_filterButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_buttonContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    _searchRadiusHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[searchRadiusButton]|" options:0 metrics:nil views:views];
    _searchRadiusHorizontalAlignmentConstraint = [NSLayoutConstraint constraintWithItem:_searchRadiusButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_buttonContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSArray *filterButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[filterButton]|" options:0 metrics:nil views:views];
    NSArray *searchRadiusButtonVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchRadiusButton]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *separatorViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_separatorView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
    NSLayoutConstraint *separatorViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_separatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:10.0f];
    NSLayoutConstraint *separatorViewVerticalConstraint = [NSLayoutConstraint constraintWithItem:_separatorView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_buttonContainerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    
    [self.buttonContainerView addConstraints:_buttonHorizontalConstraints];
    [self.buttonContainerView addConstraints:filterButtonVerticalConstraints];
    [self.buttonContainerView addConstraints:searchRadiusButtonVerticalConstraints];
    [self.buttonContainerView addConstraints:@[separatorViewHeightConstraint, separatorViewWidthConstraint, separatorViewVerticalConstraint]];
    
    // Down Arrow Image Constraints
    NSLayoutConstraint *downArrowImageViewHorizontalConstraints = [NSLayoutConstraint constraintWithItem:_downArrowButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_buttonContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *downArrowImageViewTopConstraint = [NSLayoutConstraint constraintWithItem:_downArrowButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_buttonContainerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:10.0f];
    _downArrowImageViewWidthConstraint = [NSLayoutConstraint constraintWithItem:_downArrowButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:5.0f];
    _downArrowImageViewHeightConstraint = [NSLayoutConstraint constraintWithItem:_downArrowButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:8.0f];
    
    [self addConstraints:@[downArrowImageViewHorizontalConstraints, downArrowImageViewTopConstraint, _downArrowImageViewHeightConstraint, _downArrowImageViewWidthConstraint]];
    
    // Search Radius Slider Constraints
    NSArray *searchRadiusSliderHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|-[searchRadiusSlider]-|" options:0 metrics:nil views:views];
    NSLayoutConstraint *searchRadiusSliderTopConstraint = [NSLayoutConstraint constraintWithItem:_searchRadiusSlider attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_searchRadiusButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:10.0f];
    NSLayoutConstraint *searchRadiusSliderHeightConstraint = [NSLayoutConstraint constraintWithItem:_searchRadiusSlider attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kFilterItemHeight];
    
    [self addConstraints:searchRadiusSliderHorizontalConstraints];
    [self addConstraints:@[searchRadiusSliderTopConstraint, searchRadiusSliderHeightConstraint]];
    
    // Filter Option Button Constraints
    NSArray *trendingFilterButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[trendingFilterButton]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *trendingFilterButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_trendingFilterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *trendingFilterButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_trendingFilterButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kFilterItemHeight];
    
    NSArray *trendingFilterButtonSeparatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[trendingFilterButtonTopSeparatorView]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *trendingFilterButtonSeparatorTopConstraint = [NSLayoutConstraint constraintWithItem:_trendingFilterButtonTopSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_filterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *trendingFilterButtonSeparatorHeightConstraint = [NSLayoutConstraint constraintWithItem:_trendingFilterButtonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
    
    NSArray *popularFilterButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[popularFilterButton]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *popularFilterButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_popularFilterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_trendingFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *popularFilterButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_popularFilterButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kFilterItemHeight];
    
    NSArray *popularFilterButtonSeparatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[popularFilterButtonTopSeparatorView]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *popularFilterButtonSeparatorTopConstraint = [NSLayoutConstraint constraintWithItem:_popularFilterButtonTopSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_trendingFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *popularFilterButtonSeparatorHeightConstraint = [NSLayoutConstraint constraintWithItem:_popularFilterButtonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
    
    NSArray *recentFilterButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[recentFilterButton]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *recentFilterButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_recentFilterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_popularFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *recentFilterButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_recentFilterButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kFilterItemHeight];
    
    NSArray *recentFilterButtonSeparatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[recentFilterButtonTopSeparatorView]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *recentFilterButtonSeparatorTopConstraint = [NSLayoutConstraint constraintWithItem:_recentFilterButtonTopSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_popularFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *recentFilterButtonSeparatorHeightConstraint = [NSLayoutConstraint constraintWithItem:_recentFilterButtonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
    
    
    NSArray *myByttesFilterButtonHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[myByttesFilterButton]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *myByttesFilterButtonTopConstraint = [NSLayoutConstraint constraintWithItem:_myByttesFilterButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_recentFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *myByttesFilterButtonHeightConstraint = [NSLayoutConstraint constraintWithItem:_myByttesFilterButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:kFilterItemHeight];
    
    NSArray *myByttesFilterButtonSeparatorHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"|[myByttesFilterButtonTopSeparatorView]|" options:0 metrics:nil views:views];
    NSLayoutConstraint *myByttesFilterButtonSeparatorTopConstraint = [NSLayoutConstraint constraintWithItem:_myByttesFilterButtonTopSeparatorView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_recentFilterButton attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0.0f];
    NSLayoutConstraint *myByttesFilterButtonSeparatorHeightConstraint = [NSLayoutConstraint constraintWithItem:_myByttesFilterButtonTopSeparatorView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:1.0f];
    
    
    [self addConstraints:trendingFilterButtonHorizontalConstraints];
    [self addConstraints:trendingFilterButtonSeparatorHorizontalConstraints];
    [self addConstraints:popularFilterButtonHorizontalConstraints];
    [self addConstraints:popularFilterButtonSeparatorHorizontalConstraints];
    [self addConstraints:recentFilterButtonHorizontalConstraints];
    [self addConstraints:recentFilterButtonSeparatorHorizontalConstraints];
    [self addConstraints:myByttesFilterButtonHorizontalConstraints];
    [self addConstraints:myByttesFilterButtonSeparatorHorizontalConstraints];
    [self addConstraints:@[trendingFilterButtonTopConstraint, trendingFilterButtonHeightConstraint,
                           trendingFilterButtonSeparatorTopConstraint, trendingFilterButtonSeparatorHeightConstraint,
                           popularFilterButtonTopConstraint, popularFilterButtonHeightConstraint,
                           popularFilterButtonSeparatorTopConstraint, popularFilterButtonSeparatorHeightConstraint,
                           recentFilterButtonTopConstraint, recentFilterButtonHeightConstraint,
                           recentFilterButtonSeparatorTopConstraint, recentFilterButtonSeparatorHeightConstraint,
                           myByttesFilterButtonTopConstraint, myByttesFilterButtonHeightConstraint,
                           myByttesFilterButtonSeparatorTopConstraint, myByttesFilterButtonSeparatorHeightConstraint]];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL pointInside = NO;
    
    if (CGRectContainsPoint(self.buttonContainerView.frame, point) || self.isFilterOpen || self.isSearchRadiusOpen || CGRectContainsPoint(self.notificationBackgroundImageView.frame, point)
         || ([self.currentFilter isEqualToString:@"my"] && CGRectContainsPoint(self.settingsButton.frame, point))) {
        pointInside = YES;
    }
    
    return pointInside;
}

#pragma mark - Actions

- (void)notificationsTapped:(UITapGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(navigationViewDidSelectNotifications:)]) {
        [self.delegate navigationViewDidSelectNotifications:self];
    }
}

- (IBAction)filterButtonPressed:(id)sender {
    CGFloat navigationDropDownHeight = [self heightForFilterDropDown];
    
    if (self.isFilterOpen) {
        [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
            self.backgroundTopViewHeightConstraint.constant -= navigationDropDownHeight;
            self.trendingFilterButton.alpha = 0.0f;
            self.trendingFilterButtonTopSeparatorView.alpha = 0.0f;
            self.popularFilterButton.alpha = 0.0f;
            self.popularFilterButtonTopSeparatorView.alpha = 0.0f;
            self.recentFilterButton.alpha = 0.0f;
            self.recentFilterButtonTopSeparatorView.alpha = 0.0f;
            self.myByttesFilterButton.alpha = 0.0f;
            self.myByttesFilterButtonTopSeparatorView.alpha = 0.0f;
            self.downArrowButton.alpha = 0.0f;
            [self.buttonContainerView removeConstraints:self.filterButtonHorizontalConstraints];
            [self.buttonContainerView removeConstraint:self.filterButtonHorizontalAlignmentConstraint];
            [self.buttonContainerView addConstraints:self.buttonHorizontalConstraints];
            if ([self.currentFilter isEqualToString:@"my"]) {
                self.settingsButton.hidden = NO;
            }
            self.notificationBackgroundImageView.hidden = NO;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                self.backgroundTopView.alpha = 0.0f;
                self.buttonContainerView.hidden = NO;
                self.searchRadiusButton.hidden = NO;
                self.separatorView.hidden = NO;
                self.buttonContainerView.alpha = 1.0f;
                self.downArrowButton.hidden = YES;
                self.notificationBackgroundImageView.alpha = 1.0f;
                
                if ([self.currentFilter isEqualToString:@"my"]) {
                    self.settingsButton.alpha = 1.0f;
                }
            } completion:^(BOOL finished) {
                self.isFilterOpen = NO;
                if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
                    [self.delegate navigationViewWillEndClosing:self];
                }
            }];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
            [self.delegate navigationViewWillBeginOpening:self];
        }
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundTopView.alpha = 1.0f;
            self.downArrowButton.hidden = NO;
            self.searchRadiusButton.hidden = YES;
            self.separatorView.hidden = YES;
            self.settingsButton.alpha = 0.0f;
            self.notificationBackgroundImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
                self.trendingFilterButton.alpha = 1.0f;
                self.trendingFilterButtonTopSeparatorView.alpha = 1.0f;
                self.popularFilterButton.alpha = 1.0f;
                self.popularFilterButtonTopSeparatorView.alpha = 1.0f;
                self.recentFilterButton.alpha = 1.0f;
                self.recentFilterButtonTopSeparatorView.alpha = 1.0f;
                self.myByttesFilterButton.alpha = 1.0f;
                self.myByttesFilterButtonTopSeparatorView.alpha = 1.0f;
                self.backgroundTopViewHeightConstraint.constant += navigationDropDownHeight;
                [self.buttonContainerView removeConstraints:self.buttonHorizontalConstraints];
                [self.buttonContainerView addConstraints:self.filterButtonHorizontalConstraints];
                [self.buttonContainerView addConstraint:self.filterButtonHorizontalAlignmentConstraint];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isFilterOpen = YES;
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.downArrowButton.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    self.buttonContainerView.hidden = YES;
                    self.settingsButton.hidden = YES;
                    self.notificationBackgroundImageView.hidden = YES;
                }];
            }];
        }];
    }
}

- (void)filterButtonPressedWithFilter:(NSString *)filter {
    CGFloat navigationDropDownHeight = [self heightForFilterDropDown];
    
    if (self.isFilterOpen) {
        [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
            self.backgroundTopViewHeightConstraint.constant -= navigationDropDownHeight;
            self.trendingFilterButton.alpha = 0.0f;
            self.trendingFilterButtonTopSeparatorView.alpha = 0.0f;
            self.popularFilterButton.alpha = 0.0f;
            self.popularFilterButtonTopSeparatorView.alpha = 0.0f;
            self.recentFilterButton.alpha = 0.0f;
            self.recentFilterButtonTopSeparatorView.alpha = 0.0f;
            self.myByttesFilterButton.alpha = 0.0f;
            self.myByttesFilterButtonTopSeparatorView.alpha = 0.0f;
            self.downArrowButton.alpha = 0.0f;
            [self.buttonContainerView removeConstraints:self.filterButtonHorizontalConstraints];
            [self.buttonContainerView removeConstraint:self.filterButtonHorizontalAlignmentConstraint];
            [self.buttonContainerView addConstraints:self.buttonHorizontalConstraints];
            if ([self.currentFilter isEqualToString:@"my"]) {
                self.settingsButton.hidden = NO;
            }
            self.notificationBackgroundImageView.hidden = NO;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                self.backgroundTopView.alpha = 0.0f;
                self.buttonContainerView.alpha = 1.0f;
                self.buttonContainerView.hidden = NO;
                self.searchRadiusButton.hidden = NO;
                self.separatorView.hidden = NO;
                self.downArrowButton.hidden = YES;
                self.notificationBackgroundImageView.alpha = 1.0f;
                
                if ([self.currentFilter isEqualToString:@"my"]) {
                    self.settingsButton.alpha = 1.0f;
                }
            } completion:^(BOOL finished) {
                self.isFilterOpen = NO;
                
                if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
                    [self.delegate navigationViewWillEndClosing:self];
                }
                
                if ([self.delegate respondsToSelector:@selector(navigationView:didChangeFilter:)]) {
                    [self.delegate navigationView:self didChangeFilter:filter];
                }
            }];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
            [self.delegate navigationViewWillBeginOpening:self];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundTopView.alpha = 1.0f;
            self.buttonContainerView.alpha = 0.0f;
            self.downArrowButton.hidden = NO;
            self.searchRadiusButton.hidden = YES;
            self.separatorView.hidden = YES;
            self.settingsButton.alpha = 0.0f;
            self.notificationBackgroundImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
                self.trendingFilterButton.alpha = 1.0f;
                self.trendingFilterButtonTopSeparatorView.alpha = 1.0f;
                self.popularFilterButton.alpha = 1.0f;
                self.popularFilterButtonTopSeparatorView.alpha = 1.0f;
                self.recentFilterButton.alpha = 1.0f;
                self.recentFilterButtonTopSeparatorView.alpha = 1.0f;
                self.myByttesFilterButton.alpha = 1.0f;
                self.myByttesFilterButtonTopSeparatorView.alpha = 1.0f;
                self.backgroundTopViewHeightConstraint.constant += navigationDropDownHeight;
                [self.buttonContainerView removeConstraints:self.buttonHorizontalConstraints];
                [self.buttonContainerView addConstraints:self.filterButtonHorizontalConstraints];
                [self.buttonContainerView addConstraint:self.filterButtonHorizontalAlignmentConstraint];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isFilterOpen = YES;
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.downArrowButton.alpha = 1.0f;
                } completion:^(BOOL finished) {
                    self.buttonContainerView.hidden = YES;
                    self.settingsButton.hidden = YES;
                    self.notificationBackgroundImageView.hidden = YES;
                }];
            }];
        }];
    }
}

- (void)searchRadiusButtonPressed:(id)sender {
    CGFloat navigationDropDownHeight = [self heightForSearchRadiusDropDown];
    
    if (self.isSearchRadiusOpen) {
        [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
            self.backgroundTopViewHeightConstraint.constant -= navigationDropDownHeight;
            self.searchRadiusSlider.alpha = 0.0f;
            [self.buttonContainerView removeConstraint:self.searchRadiusHorizontalAlignmentConstraint];
            [self.buttonContainerView removeConstraints:self.searchRadiusHorizontalConstraints];
            [self.buttonContainerView addConstraints:self.buttonHorizontalConstraints];
            if ([self.currentFilter isEqualToString:@"my"]) {
                self.settingsButton.hidden = NO;
            }
            self.notificationBackgroundImageView.hidden = NO;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.3 animations:^{
                self.backgroundTopView.alpha = 0.0f;
                self.filterButton.hidden = NO;
                self.separatorView.hidden = NO;
                self.filterButton.alpha = 1.0f;
                self.separatorView.alpha = 1.0f;
                self.notificationBackgroundImageView.alpha = 1.0f;
                if ([self.currentFilter isEqualToString:@"my"]) {
                    self.settingsButton.alpha = 1.0f;
                }
            } completion:^(BOOL finished) {
                self.isSearchRadiusOpen = NO;
                
                if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
                    [self.delegate navigationViewWillEndClosing:self];
                }
                
                if ([self.delegate respondsToSelector:@selector(navigationView:didChangeRadius:)]) {
                    CGFloat roundedRadius = roundf(self.searchRadiusSlider.value);
                    NSString *searchRadius = [NSString stringWithFormat:@"%f", roundedRadius];
                    [self.delegate navigationView:self didChangeRadius:searchRadius];
                }
            }];
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(navigationViewWillEndClosing:)]) {
            [self.delegate navigationViewWillBeginOpening:self];
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.backgroundTopView.alpha = 1.0f;
            self.filterButton.alpha = 0.0f;
            self.separatorView.alpha = 0.0f;
            self.settingsButton.alpha = 0.0f;
            self.notificationBackgroundImageView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.55 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.3 options:kNilOptions animations:^{
                self.searchRadiusSlider.alpha = 1.0f;
                self.backgroundTopViewHeightConstraint.constant += navigationDropDownHeight;
                [self.buttonContainerView removeConstraints:self.buttonHorizontalConstraints];
                [self.buttonContainerView addConstraint:self.searchRadiusHorizontalAlignmentConstraint];
                [self.buttonContainerView addConstraints:self.searchRadiusHorizontalConstraints];
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                self.isSearchRadiusOpen = YES;
                self.filterButton.hidden = YES;
                self.separatorView.hidden = YES;
                self.settingsButton.hidden = YES;
                self.notificationBackgroundImageView.hidden = YES;
            }];
        }];
    }
}

- (void)trendingFilterButtonPressed:(id)sender {
    self.currentFilter = @"trending";
    [self.filterButton setTitle:[@"trending" uppercaseString] forState:UIControlStateNormal];
    [self filterButtonPressedWithFilter:self.currentFilter];
}

- (void)popularFilterButtonPressed:(id)sender {
    self.currentFilter = @"popular";
    [self.filterButton setTitle:[@"popular" uppercaseString] forState:UIControlStateNormal];
    [self filterButtonPressedWithFilter:self.currentFilter];
}

- (void)recentFilterButtonPressed:(id)sender {
    self.currentFilter = @"recent";
    [self.filterButton setTitle:[@"recent" uppercaseString] forState:UIControlStateNormal];
    [self filterButtonPressedWithFilter:self.currentFilter];
}

- (void)myByttesFilterButtonPressed:(id)sender {
    self.currentFilter = @"my";
    [self.filterButton setTitle:[@"me" uppercaseString] forState:UIControlStateNormal];
    [self filterButtonPressedWithFilter:self.currentFilter];
}

- (void)closeButtonPressed:(id)sender {
    if (self.isFilterOpen) {
        [self filterButtonPressed:nil];
    } else {
        [self searchRadiusButtonPressed:nil];
    }
}

- (void)settingsButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(navigationViewDidPressSettingsButton:)]) {
        [self.delegate navigationViewDidPressSettingsButton:self];
    }
}

- (void)searchRadiusValueChanged:(id)sender {
    NSString *searchRadiusTitle = [self titleForSearchRadius:self.searchRadiusSlider.value];
    [_searchRadiusButton setTitle:searchRadiusTitle forState:UIControlStateNormal];
}

#pragma mark - Helper Methods

- (CGFloat)heightForFilterDropDown {
    return kNumberOfFilterItems*kFilterItemHeight;
}

- (CGFloat)heightForSearchRadiusDropDown {
    return kFilterItemHeight*1.5;
}

- (NSString *)titleForSearchRadius:(CGFloat)searchRadius {
    CGFloat roundedRadius = roundf(searchRadius);
    
    if (roundedRadius > 1) {
        return [NSString stringWithFormat:@"%1.0f MILES", roundedRadius];
    } else {
        return [NSString stringWithFormat:@"%1.0f MILE", roundedRadius];
    }
}


@end
