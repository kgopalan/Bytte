//
//  BYTLocationManager.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/14/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BYTLocationManager : NSObject

+ (instancetype)sharedInstance;

- (BOOL)isActive;
- (BOOL)hasLocation;
- (CLLocation *)usersCurrentLocation;

@end
