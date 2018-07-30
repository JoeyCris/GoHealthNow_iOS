//
//  ChooseInsulinContainerController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseInsulinContainerController.h"
#import "StyleManager.h"

@interface ChooseInsulinContainerController () <UINavigationBarDelegate, ChooseInsulinDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIView *continueViewTopDividerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewToDividerConstraint;

@end

@implementation ChooseInsulinContainerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    
    self.navBar.delegate = self;
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [StyleManager styleButton:self.continueButton];
    }
    else {
        self.continueButton.hidden = YES;
        self.continueViewTopDividerView.hidden = YES;
        
        [self.view removeConstraint:self.containerViewToDividerConstraint];
        self.containerViewToDividerConstraint = nil;
        
        // this produces UIViewAlertForUnsatisfiableConstraints error, which is fine
        // because some other constraints with continueButton also need to be broken
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView
                                                             attribute:NSLayoutAttributeBottom
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                               constant:0.0]];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (self.isUserSetupModeEnabled) {
        UITableViewController *tableVC = (UITableViewController *)self.childViewControllers.lastObject;
        // check to see whether the content is large enough that scrolling is required.
        // If it is required then we need to show the divider
        if (tableVC.tableView.frame.size.height > tableVC.tableView.contentSize.height) {
            self.continueViewTopDividerView.hidden = YES;
        }
        else {
            self.continueViewTopDividerView.hidden = NO;
        }
    }
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - ChooseInsulinDelegate

- (void)didUpdateUserProfileWithInsulin:(NSDictionary *)insulin sender:(id)sender {
    [self.delegate didUpdateUserProfileWithInsulin:insulin sender:self];
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapContinueButton:(id)sender {
    [self.delegate didUpdateUserProfileWithInsulin:nil sender:nil];
}

#pragma mark - Navigation

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString *segueId = segue.identifier;
    if ([segueId isEqualToString: @"chooseInsulinTableVCSegue"]) {
        ChooseInsulinController *destVC = (ChooseInsulinController *)[segue destinationViewController];
        destVC.delegate = self;
    }
}

@end
