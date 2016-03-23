//
//  BYTAddLocationViewController.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BYTBytte.h"

@protocol BYTAddLocationViewControllerDelegate;

@interface BYTAddLocationViewController : UIViewController

@property (nonatomic, weak) id<BYTAddLocationViewControllerDelegate> delegate;

@end

@protocol BYTAddLocationViewControllerDelegate <NSObject>

- (void)addLocationViewControllerDidAddLocationCoordinate:(CLLocationCoordinate2D)coordinate;

@end
