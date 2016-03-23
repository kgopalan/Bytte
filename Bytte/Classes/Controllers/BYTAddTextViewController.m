//
//  BYTAddTextViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 4/5/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTAddTextViewController.h"
#import "BYTPostBytteViewController.h"

#define kMaxNumberOfLines 5

@interface BYTAddTextViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation BYTAddTextViewController

#pragma mark - Properties

- (BYTLightBytte *)lightBytte {
    if (!_lightBytte) {
        _lightBytte = [[BYTLightBytte alloc] init];
    }
    
    return _lightBytte;
}

#pragma mark - Init/Dealloc

- (void)dealloc {
    self.textView.delegate = nil;
    [self.textView removeObserver:self forKeyPath:@"contentSize"];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.textView addObserver:self forKeyPath:@"contentSize" options:(NSKeyValueObservingOptionNew) context:NULL];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)replacementText
{
    // First check to see if the "Done" button was pressed
    if ([replacementText isEqualToString:@"\n"]) {
        [self doneButtonPressed];
        return NO;
    }
    
    
    NSMutableString *text = [NSMutableString stringWithString:textView.text];
    [text replaceCharactersInRange:range withString:replacementText];
    
    // Next check for standard '\n' (newline) type characters.
    NSUInteger numberOfLines = 0;
    for (NSUInteger index = 0; index < text.length; index++) {
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember: [text characterAtIndex:index]]) {
            numberOfLines++;
        }
    }
    
    if (numberOfLines >= kMaxNumberOfLines)
        return NO;
    
    // Now check for word wrapping onto newline.
    NSAttributedString *wordWrappedText = [[NSAttributedString alloc]
                              initWithString:[NSMutableString stringWithString:text] attributes:@{NSFontAttributeName:textView.font}];
    
    __block NSInteger lineCount = 0;
    
    CGFloat maxWidth   = textView.frame.size.width;
    
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    NSTextStorage   *textStorage = [[NSTextStorage alloc] initWithAttributedString:wordWrappedText];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];
    [layoutManager enumerateLineFragmentsForGlyphRange:NSMakeRange(0,layoutManager.numberOfGlyphs)
                                 usingBlock:^(CGRect rect,
                                              CGRect usedRect,
                                              NSTextContainer *textContainer,
                                              NSRange glyphRange,
                                              BOOL *stop)
     {
         lineCount++;
     }];
    
    return (lineCount <= kMaxNumberOfLines);
}

#pragma mark - Actions

- (IBAction)cancelButtonPressed:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)doneButtonPressed {
    BYTPostBytteViewController *postBytteVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PostBytte"];
    
    self.lightBytte.bytteText = self.textView.text;
    postBytteVC.lightBytte = self.lightBytte;
    
    [self.navigationController pushViewController:postBytteVC animated:YES];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    UITextView *textView = object;
    CGFloat topCorrect = ([textView bounds].size.height - [textView contentSize].height * [textView zoomScale])/2.0;
    topCorrect = (topCorrect < 0.0 ? 0.0 : topCorrect );
    textView.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

@end
