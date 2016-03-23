//
//  BYTAddLocationViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAddLocationViewController.h"
#import "BYTLocationManager.h"
#import <CoreLocation/CoreLocation.h>

#define METERS_PER_MILE 1609.344

@interface BYTAddLocationViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) UIImageView *locationMarkerImageView;

@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end

@implementation BYTAddLocationViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldHideStatusBar = YES;
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CLLocation *currentLocation = [[BYTLocationManager sharedInstance] usersCurrentLocation];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];
    
    UIImage *locationMarker = [UIImage imageNamed:@"btn-choose"];
    self.locationMarkerImageView = [[UIImageView alloc] initWithImage:locationMarker];
    self.locationMarkerImageView.center = self.view.center;
    [self.view addSubview:self.locationMarkerImageView];
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)addLocationButtonPressed:(id)sender {
    if ([self.delegate respondsToSelector:@selector(addLocationViewControllerDidAddLocationCoordinate:)]) {
        CLLocationCoordinate2D coordinate = [self.mapView centerCoordinate];
        [self.delegate addLocationViewControllerDidAddLocationCoordinate:coordinate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
