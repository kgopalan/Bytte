//
//  BYTComment.h
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BYTComment : NSObject

@property (nonatomic, strong) NSString *commendID;
@property (nonatomic, strong) NSString *deviceid;
@property (nonatomic, strong) NSString *postedAgo;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *appCodeName;
@property (nonatomic, strong) NSString *photoID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
