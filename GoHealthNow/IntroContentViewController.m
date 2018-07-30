//
//  IntroContentViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "IntroContentViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "AppDelegate.h"
#import "User.h"

@interface IntroContentViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *prevNextNavBar;
@property (weak, nonatomic) IBOutlet UIView *prevNextNavBarTopBorder;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;

@property (weak, nonatomic) IBOutlet UILabel *splashTitle;
@property (weak, nonatomic) IBOutlet UIImageView *splashImage;
@property (weak, nonatomic) IBOutlet UILabel *labelWelcome;
@property (weak, nonatomic) IBOutlet UILabel *splashDescription;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *splashImageHeightConstraint;

@end

@implementation IntroContentViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    
    self.prevNextNavBarTopBorder.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
    self.prevNextNavBar.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
    
    self.previousButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.previousButton.titleLabel.font.pointSize];
    self.nextButton.titleLabel.font = [UIFont boldSystemFontOfSize:self.nextButton.titleLabel.font.pointSize];
    
    if (self.showSkipButton) {
        [self.previousButton setTitle:[LocalizationManager getStringFromStrId:MSG_SKIP] forState:UIControlStateNormal];
    }
    else {
        [self.previousButton setTitle:[LocalizationManager getStringFromStrId:@"Previous"] forState:UIControlStateNormal];
    }
    
    self.splashTitle.font = [UIFont boldSystemFontOfSize:24.0];
    self.splashTitle.textColor = [UIColor darkGrayColor];
    [self.splashTitle sizeToFit];
    
    self.splashDescription.font = [UIFont systemFontOfSize:22]; //19.5
    self.splashDescription.textColor = [UIColor darkGrayColor];
    self.splashDescription.lineBreakMode = NSLineBreakByWordWrapping;
    self.splashDescription.numberOfLines = 0;
    
    self.splashImage.layer.borderColor = self.prevNextNavBarTopBorder.backgroundColor.CGColor;
    //self.splashImage.layer.borderWidth = 1.0;
    [self.splashImage setContentMode:UIViewContentModeScaleAspectFit];
    
    if (IS_IPHONE_4_OR_LESS) {
        self.splashDescription.font = [UIFont systemFontOfSize:15.0];
        self.splashImageHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width - 80.0;
    }
    else if (IS_IPHONE) {
        if (IS_IPHONE_5) {
            self.splashDescription.font = [UIFont systemFontOfSize:18.0]; //18
        }
        self.splashImageHeightConstraint.constant = [UIScreen mainScreen].bounds.size.width - 16.0;
    }
    else if (IS_IPAD) {
        [self setupOrientationSpecificViews];
    }

    if (self.introTitle && self.splashDescription) { // && self.introImageName
        self.splashTitle.text = self.introTitle;
        self.splashDescription.text = self.introDescription;
        if (self.introImageName)
            [self.splashImage setImage:[UIImage imageNamed:self.introImageName]];
    }
    else {
        [StyleManager stylelabel:self.labelWelcome];
        self.labelWelcome.hidden = NO;
     
        self.prevNextNavBar.hidden = YES;
        self.splashTitle.hidden = YES;
        self.splashDescription.hidden = YES;
        self.splashImage.hidden = YES;
    }
    
    if (self.showGetStartedButton) {
        [self.nextButton setTitle:[LocalizationManager getStringFromStrId:@"Get Started"] forState:UIControlStateNormal];
    }
    if (self.hidePreviousButton) {
        self.previousButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.labelWelcome.isHidden)
    {
        [NSTimer scheduledTimerWithTimeInterval:0.25
                                         target:self
                                       selector:@selector(launchApp:)
                                       userInfo:nil
                                        repeats:NO];
    }
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setupOrientationSpecificViews];
     } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

#pragma mark - Even Handlers

- (void)launchApp:(NSTimer*)theTimer {
    User* user = [User sharedModel];
    user.introShownCount++;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setWindowRootWithAnimation:YES];
}

- (IBAction)didTapPreviousButton:(id)sender {
    if (self.showSkipButton) {
        [self launchApp:nil];
    }
    else {
        [self.delegate flipBack:self];
    }
}

- (IBAction)didTapNextButton:(id)sender {
    [self.delegate flipForward:self];
}

#pragma mark - Methods

- (void)setupOrientationSpecificViews {
    if (IS_IPAD_PRO) {
        self.splashTitle.font = [UIFont boldSystemFontOfSize:36.0];
        self.splashDescription.font = [UIFont systemFontOfSize:31.5];
        //self.splashImageHeightConstraint.constant = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 620.0 : 900.0;
    }
    else {
        self.splashTitle.font = [UIFont boldSystemFontOfSize:30.0];
        self.splashDescription.font = [UIFont systemFontOfSize:25.5];
        //self.splashImageHeightConstraint.constant = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) ? 420.0 : 700.0;
    }
}

@end
