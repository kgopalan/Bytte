//
//  BYTDataSource.m
//  Bytte
//
//  Created by Krishnan Gopalan on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTDataSource.h"
#import <AFNetworking/AFNetworking.h>
#import "BYTBytteRequest.h"
#import "BYTLocationManager.h"
#import "Constants.h"
#import "BYTDeviceDetails.h"
#import "BYTComment.h"
#import "BYTNotification.h"

@interface BYTDataSource () {
    NSMutableArray *_byttes;
}

@property (nonatomic, strong) NSMutableArray *byttes;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, strong) AFHTTPRequestOperationManager *requestOperationManager;
@property (nonatomic, strong) BYTBytteRequest *bytteRequest;
@property (nonatomic, strong) BYTDeviceDetails *deviceDetails;
@property (nonatomic, strong) NSString *deviceID;
@property (nonatomic, strong) NSTimer *firstFetchTimer;
@property (nonatomic, strong) NSTimer *deviceIDTimer;
@property (nonatomic, strong) NSMutableArray *followingByttes;
@property (nonatomic, strong) NSString *followingByttesDeviceID;
@property (nonatomic, assign) BOOL isFollowingBytte;
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, strong) NSTimer *notificationTimer;

@end

@implementation BYTDataSource

#pragma mark - Class Methods

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Properties

- (NSString *)currentFilter {
    return self.bytteRequest.listingType;
}

- (NSString *)appCodeName {
    return self.deviceDetails.codeName;
}

- (NSString *)avatarPhotoID {
    return self.deviceDetails.avatarPhotoID;
}

#pragma mark - Init

-(instancetype)init {
    self = [super init];
    
    if (self) {
        _hasDeviceID = NO;
        _hasFetchedFirstByttes = NO;
        _isFollowingBytte = NO;
        _deviceDetails = [[BYTDeviceDetails alloc] init];
        _imageCache = [[NSCache alloc] init];
        _followingByttes = [[NSMutableArray alloc] init];
        _followingByttesDeviceID = nil;
        _notifications = [[NSMutableArray alloc] init];
        
//        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", @"http://23.239.23.224/Bytte/"]; // Prod Server
        NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@", @"http://23.239.7.218/Bytte/"]; // Dev Server
        NSURL *baseURL = [NSURL URLWithString:urlString];
        _requestOperationManager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status < AFNetworkReachabilityStatusReachableViaWWAN) {
                NSString *warning = @"Yikes, Bytte cannot connect to the Internet! Please check your WiFi or cellular data connection.";
                UIAlertView *errorView = [[UIAlertView alloc] initWithTitle:@"Bytte" message:warning delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorView show];
            }
        }];
        
        AFJSONResponseSerializer *jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        AFImageResponseSerializer *imageResponseSerializer = [AFImageResponseSerializer serializer];
        imageResponseSerializer.imageScale = 1.0;
        
        AFCompoundResponseSerializer *responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[jsonResponseSerializer, imageResponseSerializer]];
        _requestOperationManager.responseSerializer = responseSerializer;
        
        [self getUniqueIdentifier];
    }
    
    return self;
}

#pragma mark - Reachability

- (BOOL)checkReachability {
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

#pragma mark - Device Token

- (void)setBytteRequest:(BYTBytteRequest *)bytteRequest {
    if (!_bytteRequest) {
        _bytteRequest = bytteRequest;
        [self fetchNewByttesWithCompletionHandler:nil];
    }
}

- (void)getUniqueIdentifier
{
    NSString *uniqueIdentifier = [self uuidString];

#warning comment this back in
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"]) {
        self.deviceID = [[[NSUserDefaults standardUserDefaults] objectForKey:@"deviceToken"] stringValue];
        
        if (!self.deviceID || [self.deviceID isEqualToString:@""]) {
            [self deviceIDByDeviceToken:uniqueIdentifier];
        } else {
            self.hasDeviceID = YES;
            [self makeFirstBytteFetch];
            self.firstFetchTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(makeFirstBytteFetch) userInfo:nil repeats:YES];
        }
    } else {
        self.deviceIDTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(fetchDeviceID) userInfo:nil repeats:YES];
    }
}

- (void)makeFirstBytteFetch {
    BOOL check = [self checkReachability];
    if (check==YES) {
        if ([[BYTLocationManager sharedInstance] isActive] && [[BYTLocationManager sharedInstance] hasLocation]) {
            BYTBytteRequest *defaultRequest = [[BYTBytteRequest alloc] initWithDeviceID:self.deviceID];
            _bytteRequest = defaultRequest;
            [self.firstFetchTimer invalidate];
            [self fetchNewByttesWithCompletionHandler:nil];
            
            if (self.hasDeviceID) {
                [self fetchDeviceDetailsWithCompletionHandler:nil];
                [self fireNotificationsRefresh];
                self.notificationTimer = [NSTimer scheduledTimerWithTimeInterval:600.0f target:self selector:@selector(fireNotificationsRefresh) userInfo:nil repeats:YES]; // every 15 minutes
                [[NSRunLoop currentRunLoop] addTimer:self.notificationTimer forMode:NSRunLoopCommonModes];
            }
        }
    }
}

- (void)fireNotificationsRefresh {
     [self fetchNotificationsWithCompletionHandler:nil];
}

- (NSString *)uuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

- (void)fetchDeviceID {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        [self.deviceIDTimer invalidate];
        NSString *uniqueIdentifier = [self uuidString];
        [self deviceIDByDeviceToken:uniqueIdentifier];
    }
}

- (void)deviceIDByDeviceToken:(NSString *)deviceToken
{
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        __block NSString *deviceID;
        
#warning comment this back in and replace hardcode
        NSString *urlString = [NSString stringWithFormat:@"getdeviceid.php?devicetoken=%@", deviceToken];
//        NSString *urlString = @"getdeviceid.php?devicetoken=40373744";
        
        [self.requestOperationManager GET:urlString
                               parameters:nil
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          NSDictionary *resmsg = [responseDictionary objectForKey:@"resmsg"];
                                          deviceID = [resmsg objectForKey:@"DeviceId"];
                                          self.deviceID = deviceID;
                                          self.firstFetchTimer = [NSTimer scheduledTimerWithTimeInterval:0.005 target:self selector:@selector(makeFirstBytteFetch) userInfo:nil repeats:YES];                                      } else {
                                          deviceID = @"";
                                      }
                                      [[NSUserDefaults standardUserDefaults] setValue:deviceID forKey:@"deviceToken"];
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      deviceID = @"";
                                      [[NSUserDefaults standardUserDefaults] setValue:deviceID forKey:@"deviceToken"];
                                      // error
                                  }];
    }
}

#pragma mark - KVO for Byttes

- (NSUInteger)numberOfByttes {
    return self.byttes.count;
}

- (id)objectInByttesAtIndex:(NSUInteger)index {
    return [self.byttes objectAtIndex:index];
}

- (NSArray *)byttesAtIndexes:(NSIndexSet *)indexes {
    return [self.byttes objectsAtIndexes:indexes];
}

- (void)insertObject:(BYTBytte *)object inByttesAtIndex:(NSUInteger)index {
    [_byttes insertObject:object atIndex:index];
}

- (void)removeObjectFromByttesAtIndex:(NSUInteger)index {
    [_byttes removeObjectAtIndex:index];
}

- (void)replaceObjectInByttesAtIndex:(NSUInteger)index withObject:(id)object {
    [_byttes replaceObjectAtIndex:index withObject:object];
}

#pragma mark - KVO for Notifications

- (NSUInteger)numberOfNotifications {
    return self.notifications.count;
}

- (id)objectInNotificationsAtIndex:(NSUInteger)index {
    return [self.notifications objectAtIndex:index];
}

- (NSArray *)notificationsAtIndexes:(NSIndexSet *)indexes {
    return [self.notifications objectsAtIndexes:indexes];
}

- (void)insertObject:(BYTNotification *)object inNotificationsAtIndex:(NSUInteger)index {
    [_notifications insertObject:object atIndex:index];
}

- (void)removeObjectFromNotificationsAtIndex:(NSUInteger)index {
    [_notifications removeObjectAtIndex:index];
}

- (void)replaceObjectInNotificationsAtIndex:(NSUInteger)index withObject:(id)object {
    [_notifications replaceObjectAtIndex:index withObject:object];
}

#pragma mark - KVO for Following Byttes

- (NSUInteger)numberOfFollowingByttes {
    return self.followingByttes.count;
}

- (id)objectInFollowingByttesAtIndex:(NSUInteger)index {
    return [self.followingByttes objectAtIndex:index];
}

- (NSArray *)followingByttesAtIndexes:(NSIndexSet *)indexes {
    return [self.followingByttes objectsAtIndexes:indexes];
}

- (void)insertObject:(BYTBytte *)object inFollowingByttesAtIndex:(NSUInteger)index {
    [_followingByttes insertObject:object atIndex:index];
}

- (void)removeObjectFromFollowingByttesAtIndex:(NSUInteger)index {
    [_followingByttes removeObjectAtIndex:index];
}

- (void)replaceObjectInFollowingByttesAtIndex:(NSUInteger)index withObject:(id)object {
    [_followingByttes replaceObjectAtIndex:index withObject:object];
}

#pragma mark - Data Operations

- (void)deleteBytte:(BYTBytte *)bytte {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"byttes"];
    [mutableArrayWithKVO removeObject:bytte];
}

- (void)reloadBytte:(BYTBytte *)bytte {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"byttes"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:bytte];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:bytte];
}

- (void)deleteFollowingBytte:(BYTBytte *)bytte {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"followingByttes"];
    [mutableArrayWithKVO removeObject:bytte];
}

- (void)reloadFollowingBytte:(BYTBytte *)bytte {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"followingByttes"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:bytte];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:bytte];
}

- (void)deleteNotification:(BYTNotification *)notification {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"notifications"];
    [mutableArrayWithKVO removeObject:notification];
}

- (void)reloadNotification:(BYTNotification *)notification {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"notifications"];
    NSUInteger index = [mutableArrayWithKVO indexOfObject:notification];
    [mutableArrayWithKVO replaceObjectAtIndex:index withObject:notification];
}

#pragma mark - Data Fetching

- (void)fetchNewByttesWithFilter:(NSString *)filterType completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    self.bytteRequest.listingType = filterType;
    [self fetchNewByttesWithCompletionHandler:completionHandler];
}

- (void)fetchNewByttesWithSearchRadius:(NSString *)searchRadius completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    self.bytteRequest.distance = searchRadius;
    [self fetchNewByttesWithCompletionHandler:completionHandler];
}

- (void)fetchNewByttesWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    if (!self.isRefreshing) {
        self.isRefreshing = YES;
        
        NSDictionary *parameters = @{@"lat" : self.bytteRequest.latitude,
                                     @"lon" : self.bytteRequest.longitude,
                                     @"rcnt" : self.bytteRequest.count,
                                     @"datatype" : self.bytteRequest.dataType,
                                     @"referenceid" : self.bytteRequest.referenceID,
                                     @"deviceid" : self.bytteRequest.deviceID,
                                     @"search" : self.bytteRequest.search,
                                     @"distance" : self.bytteRequest.distance};

        
        [self populateDataWithParameters:parameters completionHandler:^(NSError *error) {
            self.isRefreshing = NO;
            
            if (completionHandler) {
                completionHandler(nil);
            }
        }];
    }
}

#pragma mark - Data Parsing

- (void)parseDataFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSDictionary *messageDictionary = [feedDictionary objectForKey:@"resmsg"];
    NSArray *byttes = [messageDictionary objectForKey:@"data"];
    
    NSMutableArray *tempByttes = [NSMutableArray array];
    
    for (NSDictionary *bytteDictionary in byttes) {
        BYTBytte *bytte = [[BYTBytte alloc] initWithDictionary:bytteDictionary];
        
        if (bytte) {
            [tempByttes addObject:bytte];
            [self downloadImageForBytte:bytte];
        }
    }
    
    [self willChangeValueForKey:@"byttes"];
    self.byttes = tempByttes;
    [self didChangeValueForKey:@"byttes"];
}

- (void)parseDeviceDetailsFromFeedDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    if ([feedDictionary objectForKey:@"AppCodeName"]) {
        self.deviceDetails.codeName = [NSString stringWithFormat:@"%@", [self checkForNull:feedDictionary[@"AppCodeName"]]];
    }
    
    if ([feedDictionary objectForKey:@"PhotoId"]) {
        self.deviceDetails.avatarPhotoID = [NSString stringWithFormat:@"%@", [self checkForNull:feedDictionary[@"PhotoId"]]];
    }
}

- (NSString *)checkForNull:(id)value {
    NSString *valueString = [NSString stringWithFormat:@"%@", value];
    
    if (![valueString isEqualToString:@"(null)"] && ![valueString isEqualToString:@"<null>"] && valueString.length != 0)
        return value;
    else
        return @"";
}

- (void)populateDataWithParameters:(NSDictionary *)parameters completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSMutableDictionary *mutableParameters = [[NSDictionary dictionaryWithDictionary:parameters] mutableCopy];
        
        NSString *urlString = [NSString stringWithFormat:@"getbyttelist.php?listingtype=%@", self.bytteRequest.listingType];
        
        [self.requestOperationManager GET:urlString
                               parameters:mutableParameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              [self parseDataFromFeedDictionary:responseDictionary fromRequestWithParameters:parameters];
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                      self.hasFetchedFirstByttes = YES;
                                      [[NSNotificationCenter defaultCenter] postNotificationName:@"kBYTFetchingFirstBytteNotification" object:nil];
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                      self.hasFetchedFirstByttes = YES;
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"kBYTFetchingFirstBytteNotification" object:nil];
                                  }];
    }
}

#pragma mark - Device Info

- (void)fetchDeviceDetailsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getdevicedetails.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              [self parseDeviceDetailsFromFeedDictionary:responseDictionary fromRequestWithParameters:parameters];
                                          }
                                          
                                          if (completionHandler) {
                                              completionHandler(nil);
                                          }
                                      }
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(nil);
                                      }
                                  }];
    }
}

#pragma mark - Images

- (void)downloadImageForBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        if (bytte.imageURL && !bytte.image) {
            [self.requestOperationManager GET:bytte.imageURL.absoluteString
                                   parameters:nil
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          if ([responseObject isKindOfClass:[UIImage class]]) {
                                              bytte.image = responseObject;
                                              [self.imageCache setObject:responseObject forKey:bytte.imageURL];
                                              NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"byttes"];
                                              NSUInteger index = [mutableArrayWithKVO indexOfObject:bytte];
                                              
                                              if (index != NSNotFound) {
                                                  [mutableArrayWithKVO replaceObjectAtIndex:index withObject:bytte];
                                              } else {
                                                  [mutableArrayWithKVO addObject:bytte];
                                              }
                                              
                                          }
                                      } failure:nil];
        }
    }
}

- (void)downloadImageForFollowingBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        if (bytte.imageURL && !bytte.image) {
            [self.requestOperationManager GET:bytte.imageURL.absoluteString
                                   parameters:nil
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          if ([responseObject isKindOfClass:[UIImage class]]) {
                                              bytte.image = responseObject;
                                              [self.imageCache setObject:responseObject forKey:bytte.imageURL];
                                              NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"followingByttes"];
                                              NSUInteger index = [mutableArrayWithKVO indexOfObject:bytte];
                                              
                                              if (index != NSNotFound) {
                                                  [mutableArrayWithKVO replaceObjectAtIndex:index withObject:bytte];
                                              } else {
                                                  [mutableArrayWithKVO addObject:bytte];
                                              }
                                              
                                          }
                                      } failure:nil];
        }
    }
}

#pragma mark - Posting

- (void)postBytte:(BYTLightBytte *)lightBytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        __block NSData *pngData;
        __block NSData *audioData;
        __block NSData *videoData;
        
        NSString *refID = [NSString stringWithFormat:@"%@ %@", self.bytteRequest.deviceID, [self getDateAndTime]];
        
        NSMutableDictionary *mutableParameters = [[NSMutableDictionary alloc] init];
        
        if (self.bytteRequest.deviceID) {
            [mutableParameters setObject:self.bytteRequest.deviceID forKey:@"deviceid"];
        } else {
            [mutableParameters setObject:@"" forKey:@"deviceid"];
        }

        if (refID) {
            [mutableParameters setObject:refID forKey:@"refid"];
        } else {
            [mutableParameters setObject:@"" forKey:@"refid"];
        }
        
        if (lightBytte.bytteText) {
            [mutableParameters setObject:lightBytte.bytteText forKey:@"content"];
        } else {
            [mutableParameters setObject:@"" forKey:@"content"];
        }
        
        [mutableParameters setValue:@"0" forKey:@"ispromoted"];
        [mutableParameters setValue:@"" forKey:@"cityname"];
        [mutableParameters setValue:@"" forKey:@"countryname"];
        
        if (lightBytte.mapLatitude && lightBytte.mapLongitude) {
            [mutableParameters setObject:lightBytte.mapLatitude forKey:@"latitude"];
            [mutableParameters setObject:lightBytte.mapLongitude forKey:@"longitude"];
        } else {
            CLLocation *currentLocation = [[BYTLocationManager sharedInstance] usersCurrentLocation];
            NSString *latitude = [[NSNumber numberWithDouble:currentLocation.coordinate.latitude] stringValue];
            NSString *longitude = [[NSNumber numberWithDouble:currentLocation.coordinate.longitude] stringValue];
            
            [mutableParameters setObject:latitude forKey:@"latitude"];
            [mutableParameters setObject:longitude forKey:@"longitude"];
        }
        
        [mutableParameters setObject:@"2" forKey:@"templateid"];

        if (lightBytte.mapLatitude && lightBytte.mapLongitude && lightBytte.tagMap) {
            [mutableParameters setValue:@"1" forKey:@"tagmap"];
        } else {
            [mutableParameters setValue:@"0" forKey:@"tagmap"];
        }
        
        if (lightBytte.mapLatitude) {
            [mutableParameters setObject:lightBytte.mapLatitude forKey:@"maplatitude"];
        } else {
            [mutableParameters setObject:@"" forKey:@"maplatitude"];
        }
        
        if (lightBytte.mapLongitude) {
            [mutableParameters setObject:lightBytte.mapLongitude forKey:@"maplongitude"];
        } else {
            [mutableParameters setObject:@"" forKey:@"maplongitude"];
        }
        
        [mutableParameters setObject:@"" forKey:@"img"];
        [mutableParameters setObject:@"" forKey:@"aud"];
        [mutableParameters setObject:@"" forKey:@"vid"];
        [mutableParameters setObject:@"" forKey:@"vidimg"];
        [mutableParameters setObject:@"" forKey:@"imgtmb"];
        
        if (lightBytte.bytteText) {
            [mutableParameters setObject:lightBytte.bytteText forKey:@"contentview"];
        } else {
            [mutableParameters setObject:@"" forKey:@"contentview"];
        }
        
        if (lightBytte.bytteImage) {
            pngData = UIImagePNGRepresentation(lightBytte.bytteImage);
        }
        
        if (lightBytte.audioURL) {
            audioData = [[NSData alloc] initWithContentsOfURL:lightBytte.audioURL];
        }
        
        if (lightBytte.videoURL) {
            videoData = [[NSData alloc] initWithContentsOfURL:lightBytte.videoURL];
        }

        NSString *urlString = @"getcreatebytte.php";
        
        NSDictionary *parameters = [mutableParameters copy];

        AFHTTPRequestOperation *operation = [self.requestOperationManager POST:urlString
                                parameters:parameters
                 constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                         if (pngData) {
                                             [formData appendPartWithFileData:pngData name:@"img" fileName:@"photoImage.png" mimeType:@"image/png"];
                                         }
                     
                                         if (audioData) {
                                             [formData appendPartWithFileData:audioData name:@"aud" fileName:@"audioFile.wav" mimeType:@"audio/wav"];
                                         }
                     
                                         if (videoData) {
                                             [formData appendPartWithFileData:videoData name:@"vid" fileName:@"videoFile.mp4" mimeType:@"video/mp4"];
                                         }
                                   }
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       // successful post
                                       
                                       NSString *alertMessage = @"Yay, your Bytte has been posted successfully!";
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bytte" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       [alertView show];
                                       
                                       if (completionHandler) {
                                           completionHandler(nil);
                                       }
                                   }
                                   failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       // failed to post
                                       
                                       NSString *alertMessage = @"Uh oh, unable to post your Bytte!";
                                       UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bytte" message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                       [alertView show];
                                       
                                       if (completionHandler) {
                                           completionHandler(error);
                                       }
                                   }];

        [operation start];
    }
}

#pragma mark - Social 

- (void)toggleLikeOnBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID};
        NSString *responseType = bytte.likeState == BYTActionButtonStateEnabled ? @"0" : @"1";
        NSString *urlString = [NSString stringWithFormat:@"getresponsebytte.php?responsetype=%@", responseType];
        
        if (bytte.likeState == BYTActionButtonStateDisabled) {
            bytte.likeState = BYTActionButtonStateEnabling;
            
            [self.requestOperationManager GET:urlString
                                   parameters:[parameters mutableCopy]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSError *jsonError;
                                          
                                          if (responseObject) {
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                              
                                              if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                  bytte.likeState = BYTActionButtonStateEnabled;
                                                  bytte.isliked = @"1";
                                                  [bytte incrementTotalLikes];
                                                  [self reloadBytte:bytte];
                                              }
                                          } else {
                                              bytte.likeState = BYTActionButtonStateDisabled;
                                              [self reloadBytte:bytte];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          bytte.likeState = BYTActionButtonStateDisabled;
                                          [self reloadBytte:bytte];
                                      }];
        } else if (bytte.likeState == BYTActionButtonStateEnabled) {
            bytte.likeState = BYTActionButtonStateDisabling;
            
            [self.requestOperationManager GET:urlString
                                   parameters:[parameters mutableCopy]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSError *jsonError;
                                          
                                          if (responseObject) {
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                              
                                              if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                  bytte.likeState = BYTActionButtonStateDisabled;
                                                  bytte.isliked = @"0";
                                                  [bytte decrementTotalLikes];
                                                  [self reloadBytte:bytte];
                                              }
                                          } else {
                                              bytte.likeState = BYTActionButtonStateEnabled;
                                              [self reloadBytte:bytte];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          bytte.likeState = BYTActionButtonStateEnabled;
                                          [self reloadBytte:bytte];
                                      }];
        }
        
        [self reloadBytte:bytte];
    }
}

- (void)toggleLikeOnFollowingBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID};
        NSString *responseType = bytte.likeState == BYTActionButtonStateEnabled ? @"0" : @"1";
        NSString *urlString = [NSString stringWithFormat:@"getresponsebytte.php?responsetype=%@", responseType];
        
        if (bytte.likeState == BYTActionButtonStateDisabled) {
            bytte.likeState = BYTActionButtonStateEnabling;
            
            [self.requestOperationManager GET:urlString
                                   parameters:[parameters mutableCopy]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSError *jsonError;
                                          
                                          if (responseObject) {
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                              
                                              if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                  bytte.likeState = BYTActionButtonStateEnabled;
                                                  bytte.isliked = @"1";
                                                  [bytte incrementTotalLikes];
                                                  [self reloadFollowingBytte:bytte];
                                              }
                                          } else {
                                              bytte.likeState = BYTActionButtonStateDisabled;
                                              [self reloadFollowingBytte:bytte];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          bytte.likeState = BYTActionButtonStateDisabled;
                                          [self reloadFollowingBytte:bytte];
                                      }];
        } else if (bytte.likeState == BYTActionButtonStateEnabled) {
            bytte.likeState = BYTActionButtonStateDisabling;
            
            [self.requestOperationManager GET:urlString
                                   parameters:[parameters mutableCopy]
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          NSError *jsonError;
                                          
                                          if (responseObject) {
                                              NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                              
                                              if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                                  bytte.likeState = BYTActionButtonStateDisabled;
                                                  bytte.isliked = @"0";
                                                  [bytte decrementTotalLikes];
                                                  [self reloadFollowingBytte:bytte];
                                              }
                                          } else {
                                              bytte.likeState = BYTActionButtonStateEnabled;
                                              [self reloadFollowingBytte:bytte];
                                          }
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          bytte.likeState = BYTActionButtonStateEnabled;
                                          [self reloadFollowingBytte:bytte];
                                      }];
        }
        
        [self reloadFollowingBytte:bytte];
    }
}

#pragma mark - Removing 

- (void)removeBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getdeletebytte.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      [self fetchNewByttesWithCompletionHandler:nil];
                                  }
                                  failure:nil];
    }
}

#pragma mark - Following 

- (void)followUserWithDeviceID:(NSString *)deviceID completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"type" : @"1",
                                     @"followdeviceid" : deviceID,
                                     @"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getfollowuser.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (void)unfollowUserWithDeviceID:(NSString *)deviceID completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"type" : @"0",
                                     @"followdeviceid" : deviceID,
                                     @"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getfollowuser.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (void)fetchFollowingUserListWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"deviceid" : self.bytteRequest.deviceID,
                                     @"rcnt" : @"30",
                                     @"batchno" : @"1"};
        NSString *urlString = @"getfollowinguserlist.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {

                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (void)fetchByttesForUserOfBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    if (self.followingByttes && self.followingByttes.count > 0) {
        [self.followingByttes removeAllObjects];
    }
    
    if (self.isFollowingBytte) {
            self.isFollowingBytte = NO;
    }
    
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"listingtype" : @"userbytte",
                                     @"deviceid" : bytte.deviceID};
        NSString *urlString = @"getbyttelist.php";
        self.followingByttesDeviceID = nil;
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              [self parseDataFromUserByttesDictionary:responseDictionary fromRequestWithParameters:parameters];
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                          self.followingByttesDeviceID = bytte.deviceID;
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (void)parseDataFromFollowingUserListDictionary:(NSDictionary *)feedDictionary romRequestWithParameters:(NSDictionary *)parameters {
    
}

- (void)parseDataFromUserByttesDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSDictionary *messageDictionary = [feedDictionary objectForKey:@"resmsg"];
    NSArray *byttes = [messageDictionary objectForKey:@"data"];
    CGFloat isFollowingUserFloat = [[messageDictionary objectForKey:@"isfollowing"] floatValue];
    NSNumber *isFollowingUserNumber = [NSNumber numberWithFloat:isFollowingUserFloat];
    self.isFollowingBytte = [isFollowingUserNumber boolValue];
    
    NSMutableArray *tempByttes = [NSMutableArray array];
    
    for (NSDictionary *bytteDictionary in byttes) {
        BYTBytte *bytte = [[BYTBytte alloc] initWithDictionary:bytteDictionary];
        
        if (bytte) {
            [tempByttes addObject:bytte];
            [self downloadImageForFollowingBytte:bytte];
        }
    }

    [self willChangeValueForKey:@"followingByttes"];
    self.followingByttes = tempByttes;
    [self didChangeValueForKey:@"followingByttes"];
}

#pragma mark - Notifications

- (void)resetNotificationsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        if (self.notifications && self.notifications.count > 0) {
            [self willChangeValueForKey:@"notifications"];
            self.notifications = [NSMutableArray array];
            [self didChangeValueForKey:@"notifications"];
        }
        
        NSDictionary *parameters = @{@"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getresetnotificationlist.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:nil
                                  failure:nil];
    }
}

- (void)parseDataFromNotificationsDictionary:(NSDictionary *)feedDictionary fromRequestParameters:(NSDictionary *)parameters {
    NSDictionary *messageDictionary = [feedDictionary objectForKey:@"resmsg"];
    NSArray *notificationsArray = [messageDictionary objectForKey:@"data"];
    id dict = [messageDictionary objectForKey:@"devicedet"];
    NSDictionary *usersDictionary = (NSDictionary *)dict;
    
    NSMutableArray *tempNotifications = [NSMutableArray array];
    
    for (NSDictionary *notificationDictionary in notificationsArray) {
        BYTNotification *notification = [[BYTNotification alloc] initWithDictionary:notificationDictionary];
        NSString *deviceID = [NSString stringWithFormat:@"%@", notification.deviceid];
        NSDictionary *deviceDetails = [usersDictionary objectForKey:deviceID];
        
        if (deviceDetails) {
            notification.appCodeName = [deviceDetails objectForKey:@"appcodename"];
            notification.photoID = [deviceDetails objectForKey:@"photoid"];
        }
        
        if (notification) {
            [tempNotifications addObject:notification];
        }
    }
    
    [self willChangeValueForKey:@"notifications"];
    self.notifications = tempNotifications;
    [self didChangeValueForKey:@"notifications"];
}

- (void)fetchNotificationsWithCompletionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"deviceid" : self.bytteRequest.deviceID};
        NSString *urlString = @"getnotificationlist.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              [self parseDataFromNotificationsDictionary:responseDictionary fromRequestParameters:parameters];
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

#pragma mark - Comments

- (void)fetchCommentsForBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID,
                                     @"rcnt" : @"50"};
        NSString *urlString = @"getbyttecommentlist.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              bytte.comments = [self parseDataFromCommentsDictionary:responseDictionary fromRequestWithParameters:parameters];
                                              [self reloadBytte:bytte];
                                    
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentsUpdated" object:bytte.comments];
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (void)fetchCommentsForFollowingBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID,
                                     @"rcnt" : @"50"};
        NSString *urlString = @"getbyttecommentlist.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      NSError *webError;
                                      NSError *jsonError;
                                      
                                      if (responseObject) {
                                          NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&jsonError];
                                          
                                          if ([responseDictionary isKindOfClass:[NSDictionary class]]) {
                                              bytte.comments = [self parseDataFromCommentsDictionary:responseDictionary fromRequestWithParameters:parameters];
                                              [self reloadFollowingBytte:bytte];
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:@"CommentsUpdated" object:bytte.comments];
                                              
                                              if (completionHandler) {
                                                  completionHandler(nil);
                                              }
                                          } else if (completionHandler) {
                                              completionHandler(jsonError);
                                          }
                                      } else if (completionHandler) {
                                          completionHandler(webError);
                                      }
                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(error);
                                      }
                                  }];
    }
}

- (NSArray *)parseDataFromCommentsDictionary:(NSDictionary *)feedDictionary fromRequestWithParameters:(NSDictionary *)parameters {
    NSArray *commentsArray = [feedDictionary objectForKey:@"data"];
    id dict = [feedDictionary objectForKey:@"devicedet"];
    NSDictionary *commentUsersDictionary = (NSDictionary *)dict;
    NSMutableArray *tempComments = [NSMutableArray array];
    
    for (NSDictionary *commentDictionary in commentsArray) {
        BYTComment *comment = [[BYTComment alloc] initWithDictionary:commentDictionary];
        NSString *deviceID = [NSString stringWithFormat:@"%@", comment.deviceid];
        NSDictionary *deviceDetails = [commentUsersDictionary objectForKey:deviceID];
        
        if (deviceDetails) {
            comment.appCodeName = [deviceDetails objectForKey:@"appcodename"];
            comment.photoID = [deviceDetails objectForKey:@"photoid"];
        }
        
        if (comment) {
            [tempComments addObject:comment];
        }
    }
    
    return [tempComments copy];
}

- (void)postComment:(NSString *)comment forBytte:(BYTBytte *)bytte completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSString *refID = [NSString stringWithFormat:@"%@ %@", self.bytteRequest.deviceID, [self getDateAndTime]];
        NSString *latitude = [[NSNumber numberWithDouble:bytte.latitude] stringValue];
        NSString *longitude = [[NSNumber numberWithDouble:bytte.longitude] stringValue];
        
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID,
                                     @"refid" : refID,
                                     @"content" : comment,
                                     @"lat" : latitude,
                                     @"lon" : longitude};
        NSString *urlString = @"getpostbyttecomment.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                      if (completionHandler) {
                                          completionHandler(nil);
                                      }
                                  }
                                  failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                      if (completionHandler) {
                                          completionHandler(nil);
                                      }
                                  }];
    }
}

#pragma mark - Flagging

- (void)flagBytte:(BYTBytte *)bytte {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"bytteid" : bytte.bytteID,
                                     @"deviceid" : self.bytteRequest.deviceID,
                                     @"spamtype" : @"1"};
        NSString *urlString = @"getspambytte.php";
        
        [self.requestOperationManager GET:urlString
                               parameters:parameters
                                  success:nil
                                  failure:nil];
    }
}

#pragma mark - Profiles

- (void)updateProfileWithCodeName:(NSString *)appCodeName photoID:(NSString *)photoID completionHandler:(BYTNewBytteCompletionBlock)completionHandler {
    BOOL check = [self checkReachability];
    if (check==YES)
    {
        NSDictionary *parameters = @{@"deviceid" : self.bytteRequest.deviceID,
                                     @"photoid" : photoID,
                                     @"appcodename" : appCodeName};
        NSString *urlString = @"getupdateprofile.php";
        
        [self.requestOperationManager GET:urlString parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self fetchDeviceDetailsWithCompletionHandler:completionHandler];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (completionHandler) {
                completionHandler(nil);
            }
        }];
    }
}

#pragma mark - Helpers

-(NSString *)getDateAndTime
{
    NSDate *currentDateInLocal = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSString *currentLocalDateAsStr = [dateFormatter stringFromDate:currentDateInLocal];
    return currentLocalDateAsStr;
}

@end
