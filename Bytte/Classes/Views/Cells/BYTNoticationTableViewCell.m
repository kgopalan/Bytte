//
//  BYTNoticationTableViewCell.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 6/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTNoticationTableViewCell.h"

@interface BYTNoticationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedAgoTextLabel;

@end

@implementation BYTNoticationTableViewCell

+ (CGFloat)heightForNoticiation:(BYTNotification *)comment inView:(UIView *)containerView {
    CGFloat baseHeight = 80.0f;
    
    CGFloat dynamicHeight = 80.0f;
    CGSize containerSize = CGSizeMake(containerView.frame.size.width - 150.0f, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = @{[UIFont fontWithName:@"OpenSans-Light" size:18.0f] : NSFontAttributeName,
                                 paragraphStyle : NSParagraphStyleAttributeName};
    NSMutableAttributedString *attrComment = [[NSMutableAttributedString alloc] initWithString:@"Temp Text" attributes:attributes]; // change this line
    
    CGRect requiredRect = [attrComment boundingRectWithSize:containerSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    dynamicHeight += ceil(requiredRect.size.height);
    
    if (dynamicHeight > baseHeight) {
        baseHeight = dynamicHeight;
    }
    
    return baseHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.notificationTextLabel.attributedText = [self attributedNotificationText];
    self.postedAgoTextLabel.text = self.notification.postedAgo;
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height/2;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.backgroundColor = [UIColor lightGrayColor];
    
    NSString *imageName = [NSString stringWithFormat:@"avatar-%@.jpg", self.notification.photoID];
    UIImage *image = [UIImage imageNamed:imageName];
    self.avatarImageView.image = image;
}

- (NSAttributedString *)attributedNotificationText {
    NSMutableAttributedString *tempText;
    NSString *textCopy;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    UIColor *greenColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    NSDictionary *attributes = @{[UIFont fontWithName:@"OpenSans-Light" size:18.0f] : NSFontAttributeName,
                                   paragraphStyle : NSParagraphStyleAttributeName};
    
    switch ([self.notification.notificationType integerValue]) {
        case 1:
            textCopy = @"You have 1 new like on your bytte post";
            tempText = [[NSMutableAttributedString alloc] initWithString:textCopy attributes:attributes];
            [tempText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textCopy.length)];
            break;
        case 2:
            if (self.notification.appCodeName) {
                textCopy = [NSString stringWithFormat:@"%@%@ commented on your post", @"@", self.notification.appCodeName];
                tempText = [[NSMutableAttributedString alloc] initWithString:textCopy attributes:attributes];
                [tempText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(self.notification.appCodeName.length - 1, textCopy.length - self.notification.appCodeName.length)];
                [tempText addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(0, self.notification.appCodeName.length + 1)];
            } else {
                textCopy = @"You have a new comment on your bytte post";
                tempText = [[NSMutableAttributedString alloc] initWithString:textCopy attributes:attributes];
                [tempText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textCopy.length)];
            }
            break;
        case 3:
            if (self.notification.appCodeName) {
                textCopy = [NSString stringWithFormat:@"%@%@ started following you", @"@", self.notification.appCodeName];
                tempText = [[NSMutableAttributedString alloc] initWithString:textCopy attributes:attributes];
                [tempText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(self.notification.appCodeName.length - 1, textCopy.length - self.notification.appCodeName.length)];
                [tempText addAttribute:NSForegroundColorAttributeName value:greenColor range:NSMakeRange(0, self.notification.appCodeName.length + 1)];
            } else {
                textCopy = @"You have 1 new follower";
                tempText = [[NSMutableAttributedString alloc] initWithString:textCopy attributes:attributes];
                [tempText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textCopy.length)];
            }
            break;
        default:
            break;
    }
    
    return [tempText copy];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    self.notificationTextLabel.text = nil;
    self.postedAgoTextLabel.text = nil;
    self.avatarImageView.image = nil;
}

@end
