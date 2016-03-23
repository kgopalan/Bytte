//
//  BYTCommentsViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 5/1/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTCommentsViewController.h"
#import "BYTDataSource.h"
#import "BYTComment.h"
#import "BYTCommentTableViewCell.h"

#define kMaxNumberCommentCharacters 120


@interface BYTCommentsViewController () <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldBottomConstraint;
@property (nonatomic, strong) NSArray *comments;
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@end

@implementation BYTCommentsViewController

#pragma mark - Init/Dealloc

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _isFollowingBytte = NO;
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsFetched:) name:@"CommentsUpdated" object:nil];
    
    self.comments = self.bytte.comments;

    self.shouldHideStatusBar = YES;


    NSString *photoID = [[BYTDataSource sharedInstance] avatarPhotoID];
    
    if (photoID) {
        NSString *backgroundImageName = [NSString stringWithFormat:@"avatar-%@.jpg", photoID];
        UIImage *image = [UIImage imageNamed:backgroundImageName];
        [self.backgroundImageView setImage:image];
    }
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 10.0f)];
    spacerView.backgroundColor = self.textField.backgroundColor;
    [self.textField setLeftViewMode:UITextFieldViewModeAlways];
    [self.textField setLeftView:spacerView];
    
    NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:@"Type something kind..." attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.textField.attributedPlaceholder = placeholderText;
    self.textField.tintColor = [UIColor colorWithRed:80.0f/255.0f green:227.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
    self.textField.enablesReturnKeyAutomatically = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:kCATransition];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView *view in self.view.subviews){
        if ([view isKindOfClass:[UITextField class]] && [view isFirstResponder]) {
            self.textField.text = nil;
            [view resignFirstResponder];
        }
    }
}

#pragma mark - Data 

- (void)commentsFetched:(NSNotification *)notification {
    if ([[notification name] isEqualToString:@"CommentsUpdated"]) {
        self.comments = (NSArray *)notification.object;
        [self.tableview reloadData];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.comments) {
        return self.comments.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYTCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];

    cell.comment = [self.comments objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYTComment *comment = [self.comments objectAtIndex:indexPath.row];
    
    return [BYTCommentTableViewCell heightForComment:comment.text inView:self.view];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (self.textFieldBottomConstraint.constant < 0) {
        [self repositionViewDidMoveUp:NO keyboardHeight:keyboardSize.height];
    } else {
        [self repositionViewDidMoveUp:YES keyboardHeight:keyboardSize.height];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    if (self.textFieldBottomConstraint.constant < 0) {
        [self repositionViewDidMoveUp:YES keyboardHeight:keyboardSize.height];
    } else {
        [self repositionViewDidMoveUp:NO keyboardHeight:keyboardSize.height];
    }
}

- (void)repositionViewDidMoveUp:(BOOL)movedUp keyboardHeight:(CGFloat)keyboardHeight {
    if (movedUp) {
        [UIView animateWithDuration:0.3 animations:^{
            self.textFieldBottomConstraint.constant += keyboardHeight;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.textFieldBottomConstraint.constant -= keyboardHeight;
        }];
    }
    [self.view layoutSubviews];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // First check to see if the "Done" button was pressed
    if ([string isEqualToString:@"\n"]) {
        [self doneButtonPressed];
        return NO;
    }
    
    if (textField.text.length < kMaxNumberCommentCharacters) {
        return YES;
    }
    
    if (textField.text.length == kMaxNumberCommentCharacters && string.length == 0) {
        return YES;
    }
    
    return NO;
}

#pragma mark - Actions

- (void)doneButtonPressed {
    NSString *comment = self.textField.text;
    [[BYTDataSource sharedInstance] postComment:comment forBytte:self.bytte completionHandler:^(NSError *error) {
        if (self.isFollowingBytte) {
            [[BYTDataSource sharedInstance] fetchCommentsForFollowingBytte:self.bytte completionHandler:^(NSError *error) {
                [self.tableview reloadData];
                self.textField.text = nil;
                [self.textField resignFirstResponder];
            }];
        } else {
            [[BYTDataSource sharedInstance] fetchCommentsForBytte:self.bytte completionHandler:^(NSError *error) {
                [self.tableview reloadData];
                self.textField.text = nil;
                [self.textField resignFirstResponder];
            }];
        }
    }];
}

- (IBAction)backButtonPressed:(id)sender {
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
