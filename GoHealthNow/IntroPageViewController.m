//
//  IntroPageViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "IntroPageViewController.h"
#import "IntroContentViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "User.h"

@interface IntroPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic) NSMutableArray *contentViewControllers;

@end

@implementation IntroPageViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = self;
    
    [StyleManager styleMainView:self.view];
    
    self.contentViewControllers = [[NSMutableArray alloc] initWithCapacity:6];
    
    UIStoryboard *appStoryBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
    
    IntroContentViewController *firstContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
    firstContentViewController.introTitle = [LocalizationManager getStringFromStrId:@"Welcome to GoHealthNow"];
    firstContentViewController.introDescription = [LocalizationManager getStringFromStrId:@"Not another tracker!\n\nGoHealthNow is your personal guide. \n\n Lose weight, gain health NOW! \n\nMay help you reduce medications. (read Eula)"];
    firstContentViewController.introImageName = @"splashIntroOne";
    firstContentViewController.hidePreviousButton = NO;
    firstContentViewController.showSkipButton = YES;
    firstContentViewController.delegate = self;
    [self.contentViewControllers addObject:firstContentViewController];
    
    IntroContentViewController *secondContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
    secondContentViewController.introTitle = [LocalizationManager getStringFromStrId:@"Get instructions"];
    secondContentViewController.introDescription = [LocalizationManager getStringFromStrId:@"To learn more ? \n\n   Go to Menu->How to..."];
    secondContentViewController.introImageName = @"splashIntroTwo";
    secondContentViewController.showSkipButton = NO;
    secondContentViewController.delegate = self;
    [self.contentViewControllers addObject:secondContentViewController];

//    IntroContentViewController *thirdContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
//    thirdContentViewController.introTitle = [LocalizationManager getStringFromStrId:@"Online Logbook"];
//    thirdContentViewController.introDescription = [LocalizationManager getStringFromStrId:@"View trends, alerts, charts in your private and secure Online Logbook.  Print one out before seeing your healthcare providers."];
//    thirdContentViewController.introImageName = @"splashIntroThree";
//    thirdContentViewController.delegate = self;
//    [self.contentViewControllers addObject:thirdContentViewController];
//    
//    IntroContentViewController *fourthContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
//    fourthContentViewController.introTitle = [LocalizationManager getStringFromStrId:@"Clinical Trial"];
//    fourthContentViewController.introDescription = [LocalizationManager getStringFromStrId:@"Using GlucoGuide may help you improve your diabetes, as shown in a clinical trial at Western University."];
//    fourthContentViewController.introImageName = @"splashIntroFour";
//    fourthContentViewController.delegate = self;
//    [self.contentViewControllers addObject:fourthContentViewController];
//    
//    IntroContentViewController *fifthContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
//    fifthContentViewController.introTitle = [LocalizationManager getStringFromStrId:@"Get Started Today!"];
//    fifthContentViewController.introImageName = @"splashIntroFive";
//    fifthContentViewController.showGetStartedButton = YES;
//    fifthContentViewController.delegate = self;
//    [self.contentViewControllers addObject:fifthContentViewController];
    
    IntroContentViewController *launchAppViewController = [appStoryBoard instantiateViewControllerWithIdentifier:@"introContentViewController"];
    launchAppViewController.delegate = self;
    [self.contentViewControllers addObject:launchAppViewController];
    
    NSArray *viewControllers = @[firstContentViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [self.contentViewControllers indexOfObject:viewController];
    if (currentIndex == 0) {
        return nil;
    }
    else {
        return self.contentViewControllers[--currentIndex];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger currentIndex = [self.contentViewControllers indexOfObject:viewController];
    if (currentIndex == [self.contentViewControllers count] - 1) {
        return nil;
    }
    else {
        return self.contentViewControllers[++currentIndex];
    }
}

#pragma mark - Methods

- (void)flipForward:(id)sender {
    NSUInteger currentIndex = [self.contentViewControllers indexOfObject:sender];
    
    if (currentIndex < [self.contentViewControllers count]) {
        [self setViewControllers:@[self.contentViewControllers[++currentIndex]]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:YES
                      completion:nil];
    }
}

- (void)flipBack:(id)sender {
    NSUInteger currentIndex = [self.contentViewControllers indexOfObject:sender];
    
    if (currentIndex > 0) {
        [self setViewControllers:@[self.contentViewControllers[--currentIndex]]
                       direction:UIPageViewControllerNavigationDirectionReverse
                        animated:YES
                      completion:nil];
    }
}

@end
