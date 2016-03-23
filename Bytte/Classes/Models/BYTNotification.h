//
//  BYTNotification.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 6/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYTNotification : NSObject

@property (nonatomic, strong) NSString *deviceid;
@property (nonatomic, strong) NSString *postedAgo;
@property (nonatomic, strong) NSString *notificationType;
@property (nonatomic, strong) NSString *appCodeName;
@property (nonatomic, strong) NSString *photoID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
