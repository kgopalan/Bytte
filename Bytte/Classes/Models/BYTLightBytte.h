//
//  BYTLightBytte.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/8/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BYTLightBytte : NSObject

@property (nonatomic, strong) NSString *bytteText;
@property (nonatomic, strong) UIImage *bytteImage;
@property (nonatomic, assign) BOOL enableAddText;
@property (nonatomic, strong) NSString *audioLength;
@property (nonatomic, strong) NSURL *audioURL;
@property (nonatomic, strong) NSString *videoLength;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) NSString *mapLatitude;
@property (nonatomic, strong) NSString *mapLongitude;
@property (nonatomic, assign) BOOL tagMap;

@end
