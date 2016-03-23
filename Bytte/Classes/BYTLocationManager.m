//
//  BYTLocationManager.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/14/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTLocationManager.h"

@interface BYTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, assign) BOOL locationIsUpdating;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

@implementation BYTLocationManager

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Init

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationIsUpdating = NO;
        _currentLocation = nil;
        
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [_locationManager requestWhenInUseAuthorization];
            [_locationManager requestAlwaysAuthorization];
        } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
            [_locationManager startUpdatingLocation];
        }
        
    }
    
    return self;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        [self.locationManager startUpdatingLocation];
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(checkForLocationUpdateWithTimer:) userInfo:nil repeats:YES];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.locationIsUpdating = YES;
    self.currentLocation = newLocation;
}

#pragma mark - Location Updates

-(void)checkForLocationUpdateWithTimer:(NSTimer *)timer
{
    [self.locationManager startUpdatingLocation];
}

#pragma mark 

- (BOOL)isActive {
    return self.locationIsUpdating;
}

- (BOOL)hasLocation {
    return (self.currentLocation && self.currentLocation.coordinate.latitude && self.currentLocation.coordinate.latitude);
}

- (CLLocation *)usersCurrentLocation {
    return self.currentLocation;
}

@end
