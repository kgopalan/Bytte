//
//  BYTNotificationsViewController.m
//  Bytte
//
//  Created by Lauren Randa Hasson on 6/29/15.
//  Copyright (c) 2015 Bytte, Inc. All rights reserved.
//

#import "BYTNotificationsViewController.h"
#import "BYTNoticationTableViewCell.h"
#import "BYTNotification.h"
#import "BYTDataSource.h"

@interface BYTNotificationsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) BOOL shouldHideStatusBar;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *notications;

@end

@implementation BYTNotificationsViewController

#pragma mark - Init/Dealloc

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldHideStatusBar = YES;
    
    [self addObservers];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.layer addAnimation:animation forKey:kCATransition];
}

- (BOOL)prefersStatusBarHidden {
    return self.shouldHideStatusBar;
}


#pragma mark - Helpers

- (void)addObservers {
    [[BYTDataSource sharedInstance] addObserver:self forKeyPath:@"notifications" options:0 context:nil];
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = [[BYTDataSource sharedInstance] notifications].count;
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYTNoticationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NoticationCell" forIndexPath:indexPath];
    
    BYTNotification *notification = [[BYTDataSource sharedInstance].notifications objectAtIndex:indexPath.row];
    cell.notification = notification;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BYTNotification *notification = [self.notications objectAtIndex:indexPath.row];
    
    return [BYTNoticationTableViewCell heightForNoticiation:notification inView:self.view];
}

#pragma mark - Actions

- (IBAction)backButtonPressed:(id)sender {
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromRight];
    [animation setDuration:0.5];
    [animation setTimingFunction:
     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.view.window.layer addAnimation:animation forKey:kCATransition];
    
    [[BYTDataSource sharedInstance] resetNotificationsWithCompletionHandler:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [BYTDataSource sharedInstance] && [keyPath isEqualToString:@"notifications"]) {
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self.tableView reloadData];
        } else if (kindOfChange == NSKeyValueChangeInsertion || kindOfChange == NSKeyValueChangeRemoval || kindOfChange == NSKeyValueChangeReplacement) {
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            NSMutableArray *indexPathsChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
                [indexPathsChanged addObject:newIndexPath];
            }];
            
            switch (kindOfChange) {
                case NSKeyValueChangeInsertion: {
                    [self.tableView insertRowsAtIndexPaths:indexPathsChanged withRowAnimation:UITableViewRowAnimationNone];
                }
                    break;
                case NSKeyValueChangeRemoval: {
                    [self.tableView deleteRowsAtIndexPaths:indexPathsChanged withRowAnimation:UITableViewRowAnimationNone];
                }
                    break;
                case NSKeyValueChangeReplacement: {
                    [self.tableView reloadRowsAtIndexPaths:indexPathsChanged withRowAnimation:UITableViewRowAnimationNone];
                }
                    break;
                default:
                    break;
            }
        }
    }
}

@end
