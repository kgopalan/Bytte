//
//  BYTPulsingAnnotationView.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/20/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTPulsingAnnotationView.h"
#import "MultiplePulsingHaloLayer.h"

@implementation BYTPulsingAnnotationView

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    
    if (self) {
        MultiplePulsingHaloLayer *halosLayer = [[MultiplePulsingHaloLayer alloc] initWithHaloLayerNum:3 andStartInterval:1];
        halosLayer.position = self.center;
        halosLayer.radius = 120.0f;
        UIColor *haloColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:0.9f];
        [halosLayer setHaloLayerColor:haloColor.CGColor];
        [halosLayer buildSublayers];
        [self.layer addSublayer:halosLayer];
    }
    
    return self;
}

@end
