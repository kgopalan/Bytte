//
//  BYTComment.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTComment.h"

@implementation BYTComment

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _commendID = dictionary[@"commentid"];
        _deviceid = dictionary[@"deviceid"];
        _postedAgo = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"postedago"]]];
        _text = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"comment"]]];
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
