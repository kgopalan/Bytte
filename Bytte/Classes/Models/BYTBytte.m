//
//  BYTBytte.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 2/11/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTBytte.h"

@implementation BYTBytte

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        _bytteID = dictionary[@"bytteid"];
        _deviceID = dictionary[@"deviceid"];
        
        NSArray *location = dictionary[@"location"];
        _longitude = [[location firstObject] floatValue];
        _latitude = [[location lastObject] floatValue];
        
        // Photo
        NSString *imageURLString = dictionary[@"imageurl"];
        NSURL *imageURL = [NSURL URLWithString:imageURLString];
        
        if (imageURL) {
            _imageURL = imageURL;
        }
       
        // Audio
        NSString *audioURLString = dictionary[@"audiourl"];
        NSURL *audioURL = [NSURL URLWithString:audioURLString];
        
        if (audioURL) {
            _audioURL = audioURL;
        }
        
        // Video
        NSString *videoURLString = dictionary[@"videourl"];
        NSURL *videoURL = [NSURL URLWithString:videoURLString];
        
        if (videoURL) {
            _videoURL = videoURL;
        }
        
        // Text
        _bytteContent = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"byttecontent"]]];
        
        // Map
        _tagmap = dictionary[@"tagmp"];
        
        // Location
        _mapLatitude = [dictionary[@"maplat"] floatValue];
        _mapLongitude = [dictionary[@"maplong"] floatValue];
        
        // Likes
        _isliked = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"liked"]]];

        BOOL userHasLiked = [_isliked boolValue];
        _likeState = userHasLiked ? BYTActionButtonStateEnabled : BYTActionButtonStateDisabled;
        
        _totalLikes = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"totlikes"]]];
        
        // Comments
        _commentState = BYTActionButtonStateDisabled;
        _totalComments = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"commentcnt"]]];
        
        // App Code Name
        _appcodename = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"appcodename"]]];
        
        // Last Updated
        _lastUpdated = [NSString stringWithFormat:@"%@", [self checkForNull:dictionary[@"updatedago"]]];
    }
    
    return self;
}

- (BOOL)shouldShowMap {
    if ([self.tagmap isEqualToString:@"1"]) {
        return YES;
    } else {
        return NO;
    }
}
                    
- (NSString *)checkForNull:(id)value {
    NSString *valueString = [NSString stringWithFormat:@"%@", value];
    
    if (![valueString isEqualToString:@"(null)"] && ![valueString isEqualToString:@"<null>"] && valueString.length != 0)
        return value;
    else
        return @"";
}

- (void)incrementTotalLikes {
    NSInteger totalLikes = [self.totalLikes integerValue];
    totalLikes++;
    
    self.totalLikes = [NSString stringWithFormat:@"%ld", (long)totalLikes];
}

- (void)decrementTotalLikes {
    NSInteger totalLikes = [self.totalLikes integerValue];
    totalLikes--;
    
    self.totalLikes = totalLikes > 0 ? [NSString stringWithFormat:@"%ld", (long)totalLikes] : @"0";
}

@end
