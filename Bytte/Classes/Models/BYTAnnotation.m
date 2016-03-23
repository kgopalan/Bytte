//
//  BYTAnnotation.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/20/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAnnotation.h"

@implementation BYTAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    self = [super init];
    
    if (self) {
        _coordinate = coordinate;
    }
    
    return self;
}

@end
