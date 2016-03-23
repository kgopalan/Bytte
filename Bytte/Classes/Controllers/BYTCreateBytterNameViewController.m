//
//  BYTCreateBytterNameViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTCreateBytterNameViewController.h"
#import "BYTSelectAvatarViewController.h"

#define kMaxNumberBytterNameCharacters 13

@interface BYTCreateBytterNameViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation BYTCreateBytterNameViewController

#pragma mark - Init/Dealloc

- (void)dealloc {
    self.textField.delegate = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:@"Your bytter name" attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.textField.attributedPlaceholder = placeholderText;
    self.textField.tintColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    self.textField.enablesReturnKeyAutomatically = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

#pragma mark - UITextFieldDelegate 

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // First check to see if the "Done" button was pressed
    if ([string isEqualToString:@"\n"]) {
        [self doneButtonPressed];
        return NO;
    }
    
    if (textField.text.length < kMaxNumberBytterNameCharacters) {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
    
    if (textField.text.length == kMaxNumberBytterNameCharacters && string.length == 0) {
        NSCharacterSet *blockedCharacters = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
        return ([string rangeOfCharacterFromSet:blockedCharacters].location == NSNotFound);
    }
    
    return NO;
}

#pragma mark - Actions

- (IBAction)skipButtonPressed:(id)sender {
    BYTSelectAvatarViewController *selectAvatarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAvatar"];
    [self.navigationController pushViewController:selectAvatarVC animated:YES];
}

- (void)doneButtonPressed {
    BYTSelectAvatarViewController *selectAvatarVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAvatar"];
    selectAvatarVC.appCodeName = self.textField.text;
    [self.navigationController pushViewController:selectAvatarVC animated:YES];
}

@end
