//
//  IntroContentViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroPageViewController.h"

@interface IntroContentViewController : UIViewController

@property (nonatomic) NSString *introTitle;
@property (nonatomic) NSString *introDescription;
@property (nonatomic) NSString *introImageName;
@property (nonatomic) BOOL showGetStartedButton;
@property (nonatomic) BOOL hidePreviousButton;
@property (nonatomic) BOOL showSkipButton;

@property (nonatomic) IntroPageViewController *delegate;

@end
