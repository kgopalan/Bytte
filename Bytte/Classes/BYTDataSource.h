//
//  BYTDataSource.h
//  Bytte
//
//  Created by Krishnan Gopalan on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BYTBytte.h"
#import "BYTLightBytte.h"

typedef void (^BYTNewBytteCompletionBlock)(NSError *error);

@interface BYTDataSource : NSObject

@property (nonatomic, strong, readonly) NSMutableArray *byttes;
@property (nonatomic, strong, readonly) NSCache *imageCache;
@property (nonatomic, strong, readonly) NSString *currentFilter;
@property (nonatomic, assign) BOOL hasDeviceID;
@property (nonatomic, assign) BOOL hasFetchedFirstByttes;
@property (nonatomic, strong, readonly) NSString *appCodeName;
@property (nonatomic, strong, readonly) NSString *avatarPhotoID;
@property (nonatomic, strong, readonly) NSMutableArray *followingByttes;
@property (nonatomic, strong, readonly) NSString *followingByttesDeviceID;
@property (nonatomic, assign, readonly) BOOL isFollowingBytte;
@property (nonatomic, strong, readonly) NSMutableArray *notifications;

+ (instancetype)sharedInstance;

- (void)fetchFollowingUserListWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchDeviceDetailsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchNewByttesWithFilter:(NSString *)filterType completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchNewByttesWithSearchRadius:(NSString *)searchRadius completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchNewByttesWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchCommentsForBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchNotificationsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)resetNotificationsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchCommentsForFollowingBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)fetchByttesForUserOfBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)deleteBytte:(BYTBytte *)bytte;
- (void)toggleLikeOnBytte:(BYTBytte *)bytte;
- (void)toggleLikeOnFollowingBytte:(BYTBytte *)bytte;
- (void)flagBytte:(BYTBytte *)bytte;
- (void)removeBytte:(BYTBytte *)bytte;
- (void)followUserWithDeviceID:(NSString *)deviceID completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)unfollowUserWithDeviceID:(NSString *)deviceID completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)postBytte:(BYTLightBytte *)lightBytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)postComment:(NSString *)comment forBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler;
- (void)updateProfileWithCodeName:(NSString *)appCodeName photoID:(NSString *)photoID completionHandler:(BYTNewBytteCompletionBlock)completionHandler;

@end
