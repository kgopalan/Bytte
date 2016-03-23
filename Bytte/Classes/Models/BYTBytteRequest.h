//
//  BYTBytteRequest.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/18/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYTBytteRequest : NSObject

@property (nonatomic, strong) NSString *listingType; // type of filter
@property (nonatomic, strong) NSString *count;
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *referenceID;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSString *search;
@property (nonatomic, strong) NSString *distance;

- (instancetype)initWithDeviceID:(NSString *)deviceID;

@end
