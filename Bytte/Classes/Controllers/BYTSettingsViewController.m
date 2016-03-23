//
//  BYTSettingsViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 3/19/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTSettingsViewController.h"
#import "BYTWebViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

typedef NS_ENUM(NSInteger, BYTSettingsRow) {
    BYTSettingsRowHowItWorks = 0,
    BYTSettingsRowFAQ = 1,
    BYTSettingsRowFeedback = 2,
    BYTSettingsRowReportAProblem = 3,
    BYTSettingsRowLoveBytte = 4,
    BYTSettingsRowShare = 5,
    BYTSettingsRowTermsAndConditions = 6,
    BYTSettingsRowPrivacyPolicy
};

@interface BYTSettingsViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (assign, nonatomic) BOOL firstAppearance;

@end

@implementation BYTSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.firstAppearance = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.firstAppearance) {
        CATransition *animation = [CATransition animation];
        [animation setDelegate:self];
        [animation setType:kCATransitionPush];
        [animation setSubtype:kCATransitionFromRight];
        [animation setDuration:0.5];
        [animation setTimingFunction:
         [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [self.view.layer addAnimation:animation forKey:kCATransition];
        
        self.firstAppearance = YES;
    }
    
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case BYTSettingsRowHowItWorks: {
            // launch app tutorial - NEED THESE SCREENS
        }
            break;
        case BYTSettingsRowFAQ: {
            // push FAQ webview - NEED THIS URL
            BYTWebViewController *faqViewController = [[BYTWebViewController alloc] initWithWebAddress:@"http://www.bytte.co/faq" title:@"FAQs"];
            [self.navigationController pushViewController:faqViewController animated:YES];
        }
            break;
        case BYTSettingsRowFeedback: {
            if ([MFMailComposeViewController canSendMail]) {
                MFMailComposeViewController* controller = [[MFMailComposeViewController alloc] init];
                controller.mailComposeDelegate = self;
                [controller setToRecipients:[NSArray arrayWithObjects:@"byttefeedback@gmail.com", nil]];
                [controller setSubject:@"Bytte Feedback"];
                [controller setMessageBody:@"Hi there - I would like to provide the following feedback: " isHTML:NO];
                if (controller)
                    [self presentViewController:controller animated:YES completion:nil];
            }
        }
            break;
        case BYTSettingsRowLoveBytte: {
            // ??? - LOVE BYTTE NOT IN V1 AND NEED THIS SPEC
        }
            break;
        case BYTSettingsRowShare: {
            // launch share sheet
            
            NSString *text;
#warning need iTunes URL
            NSString *iTunesURL;
            
            if (iTunesURL)
            {
                text = [NSString stringWithFormat:@"Hey, I encourage you to check out Bytte! It’s a hyperlocal and totally anonymous social sharing app that lets you see trending posts created around your location.  Here’s the link to get it for free %@", iTunesURL];
            }
            else
                text = @"Hey, I encourage you to check out Bytte! It’s a hyperlocal and totally anonymous social sharing app that lets you see trending posts created around your location.";
            
            NSArray *activityItems =  @[text];
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            [activityController setValue:@"Bytte App" forKey:@"subject"];
            
            NSArray *excludedActivities = @[
                                            UIActivityTypePostToWeibo,
                                            UIActivityTypePrint, UIActivityTypeCopyToPasteboard,
                                            UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                            UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr,
                                            UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
            activityController.excludedActivityTypes = excludedActivities;
            
            [self presentViewController:activityController animated:YES completion:nil];
        }
            break;
        case BYTSettingsRowTermsAndConditions: {
            // push terms and conditons webview
            BYTWebViewController *termsAndConditionsViewController = [[BYTWebViewController alloc] initWithWebAddress:@"http://www.bytte.co/terms" title:@"TERMS & CONDITIONS"];
            [self.navigationController pushViewController:termsAndConditionsViewController animated:YES];
        }
            break;
        case BYTSettingsRowPrivacyPolicy: {
            // push privacy policy webview
            BYTWebViewController *privacyPolicyViewController = [[BYTWebViewController alloc] initWithWebAddress:@"http://www.bytte.co/privacy" title:@"PRIVACY POLICY"];
            [self.navigationController pushViewController:privacyPolicyViewController animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultSent:
        {
            UIAlertView *mailAlert = [[UIAlertView alloc] initWithTitle: @""
                                                                message: @"Feedback sent successfully. Thanks!"
                                                               delegate: nil
                                                      cancelButtonTitle: @"Ok"
                                                      otherButtonTitles: nil];
            [mailAlert show];
        }
            break;
        default:
            break;
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Actions

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
