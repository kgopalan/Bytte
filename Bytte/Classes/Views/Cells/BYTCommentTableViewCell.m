//
//  BYTCommentTableViewCell.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTCommentTableViewCell.h"

@interface BYTCommentTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *commentTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *postedAgoTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *appCodeNameTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end

@implementation BYTCommentTableViewCell

+ (CGFloat)heightForComment:(NSString *)comment inView:(UIView *)containerView {
    CGFloat baseHeight = 80.0f;
    
    CGFloat dynamicHeight = 80.0f;
    CGSize containerSize = CGSizeMake(containerView.frame.size.width - 150.0f, CGFLOAT_MAX);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    
    NSDictionary *attributes = @{[UIFont fontWithName:@"OpenSans-Light" size:18.0f] : NSFontAttributeName,
                                 paragraphStyle : NSParagraphStyleAttributeName};
    NSMutableAttributedString *attrComment = [[NSMutableAttributedString alloc] initWithString:comment attributes:attributes];
    
    CGRect requiredRect = [attrComment boundingRectWithSize:containerSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil];
    
    dynamicHeight += ceil(requiredRect.size.height);
    
    if (dynamicHeight > baseHeight) {
        baseHeight = dynamicHeight;
    }
    
    return baseHeight;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.commentTextLabel.text = self.comment.text;
    self.postedAgoTextLabel.text = self.comment.postedAgo;
    self.appCodeNameTextLabel.text = [self.comment.appCodeName uppercaseString];
    
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.height/2;
    self.avatarImageView.layer.masksToBounds = YES;
    self.avatarImageView.layer.borderWidth = 0.0f;
    
    NSString *imageName = [NSString stringWithFormat:@"avatar-%@.jpg", self.comment.photoID];
    UIImage *image = [UIImage imageNamed:imageName];
    
    self.avatarImageView.image = image;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.commentTextLabel.text = nil;
    self.postedAgoTextLabel.text = nil;
    self.appCodeNameTextLabel.text = nil;
    self.avatarImageView.image = nil;
}

@end
