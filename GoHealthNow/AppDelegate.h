//
//  AppDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-10-23.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromiseKit/PromiseKit.h"
//#import <UserNotifications/UserNotifications.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BOOL notification;

- (void)setWindowRootWithAnimation:(BOOL)animation;
- (void)setWindowRootToUserSetupPageViewControllerWithAnimation:(BOOL)animation;
- (UITabBarController *)mainTabBarController;

- (void)syncHomeTabBadgeValueWithAppBadgeValue;

-(void)setWindowToExerciseSummary;
    
    


@end

