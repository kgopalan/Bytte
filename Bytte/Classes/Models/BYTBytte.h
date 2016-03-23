//
//  BYTBytte.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface BYTBytte : NSObject

@property (nonatomic, strong) NSString *bytteID;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *templateId;
@property (nonatomic, strong) NSString *photoThumbURL;
@property (nonatomic, strong) NSString *bytteContent;
@property (nonatomic, strong) NSString *videoThumbUrl;
@property (nonatomic, strong) NSString *created_at;
@property (nonatomic, strong) NSString *updated_at;
@property (nonatomic, strong) NSMutableArray *latlongArray;
@property (nonatomic, strong) NSString *tagmap;
@property (nonatomic, strong) NSString *isliked;
@property (nonatomic, strong) NSString *isSpamed;
@property (nonatomic, assign) CGFloat mapLatitude;
@property (nonatomic, assign) CGFloat mapLongitude;
@property (nonatomic, strong) NSString *totalLikes;
@property (nonatomic, strong) NSString *totalDisLikes;
@property (nonatomic, strong) NSString *appcodename;
@property (nonatomic, strong) NSString *lastUpdated;

//temp property
@property (nonatomic, strong) NSString *totalComments;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, assign) BYTActionButtonState likeState;
@property (nonatomic, assign) BYTActionButtonState commentState;
@property (nonatomic, assign) BOOL shouldShowMap;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, assign) CGFloat latitude;
@property (nonatomic, assign) CGFloat longitude;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (void)incrementTotalLikes;
- (void)decrementTotalLikes;

@end
