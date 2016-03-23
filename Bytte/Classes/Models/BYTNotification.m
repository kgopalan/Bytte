//
//  BYTNotification.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 6/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTNotification.h"

@implementation BYTNotification

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _deviceid = dictionary[@"f_deviceid"];
        _postedAgo = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"actionago"]]];
        _notificationType = dictionary[@"notificationtype"];
    }
    
    return self;
}

- (NSString *)checkForNull:(id)value {
    NSString *valueString = [NSString stringWithFormat:@"%@", value];
    
    if (![valueString isEqualToString:@"(null)"] && ![valueString isEqualToString:@"<null>"] && valueString.length != 0)
        return value;
    else
        return @"";
}

@end
