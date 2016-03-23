//
//  BYTLocationViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/19/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "BYTLocationViewController.h"
#import "BYTPulsingAnnotationView.h"
#import "BYTAnnotation.h"

#define METERS_PER_MILE 1609.344

@interface BYTLocationViewController () <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *getThereButton;

@property (nonatomic, assign) BOOL shouldHideStatusBar;

@end

@implementation BYTLocationViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldHideStatusBar = YES;
    self.mapView.showsUserLocation = YES;
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[BYTAnnotation class]]) {
        BYTPulsingAnnotationView *pulsingAnnotationView = (id)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pulsingAnnotationView"];
        
        if (!pulsingAnnotationView) {
            pulsingAnnotationView = [[BYTPulsingAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pulsingAnnotationView"];
        }
        return pulsingAnnotationView;
    } else {
        return nil;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    CLLocationCoordinate2D bytteLocation;
    bytteLocation.latitude = self.bytte.mapLatitude;
    bytteLocation.longitude= self.bytte.mapLongitude;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(bytteLocation, 0.5*METERS_PER_MILE, 0.5*METERS_PER_MILE);
    
    [self.mapView setRegion:viewRegion animated:YES];
    
    BYTAnnotation *bytteLocationAnnotation = [[BYTAnnotation alloc] initWithCoordinate:bytteLocation];
    [self.mapView addAnnotation:bytteLocationAnnotation];
}

#pragma mark - Actions

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)getThereButtonPressed:(id)sender {
    NSString *nativeMapScheme = @"maps.apple.com";
    NSString *googleMapScheme = @"comgooglemapsurl://";
    
    NSString *appleMapsURLString = [NSString stringWithFormat:@"http://%@/maps?q=%f,%f", nativeMapScheme, self.bytte.mapLatitude, self.bytte.mapLongitude];
    NSString *googleMapsURLString = [NSString stringWithFormat:@"%@maps.google.com/?q=%f,%f", googleMapScheme, self.bytte.mapLatitude, self.bytte.mapLongitude];
    
    NSURL *url = [NSURL URLWithString:appleMapsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:googleMapScheme]]) {
        url = [NSURL URLWithString:googleMapsURLString];
    }
    
    [[UIApplication sharedApplication] openURL:url];
}

@end
