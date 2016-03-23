//
//  BYTBytteRequest.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/18/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTBytteRequest.h"
#import "BYTLocationManager.h"
#import <CoreLocation/CoreLocation.h>

@implementation BYTBytteRequest

- (instancetype)init {
    return [self initWithDeviceID:@""];
}

- (instancetype)initWithDeviceID:(NSString *)deviceID {
    self = [super init];
    
    if (self) {
        CLLocation *currentLocation = [[BYTLocationManager sharedInstance] usersCurrentLocation];
        
        _listingType = @"trending";
        _count = @"30";
        _dataType = @"";
        _referenceID = @"";
        _deviceID = deviceID;
        _latitude = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
        _longitude = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
        _search = @"";
        _distance = @"5";
    }
    
    return self;
}

@end
