//
//  AppDelegate.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-10-23.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "AppDelegate.h"
#import "StyleManager.h"
#import "GlucoguideAPI.h"
#import "Constants.h"
#import "User.h"
#import "RecommendationRecord.h"
#import "UserSetupPageViewController.h"
#import "IntroPageViewController.h"
#import "GoalsDelegate.h"
#import "SWRevealViewController.h"
#import "LocalNotificationResponseAssistant.h"
#import "LocalNotificationAssistant.h"
#import "DBHelper.h"
#import "UIView+Extensions.h"
#import "AppDelegate.h"

#import "InputViewController.h"

#import <UserNotifications/UserNotifications.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface AppDelegate () <UITabBarControllerDelegate, SWRevealViewControllerDelegate, UIAlertViewDelegate, UNUserNotificationCenterDelegate>

@property (nonatomic) BOOL introShownWhileAppActive;

@end

@implementation AppDelegate

#pragma mark - App lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self setWindowRootWithAnimation:NO];
    
    // Let the device know we want to receive push notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [self syncHomeTabBadgeValueWithAppBadgeValue];
    
    // TODO: this is not ideal
    // adding this call to initialize the GoalsDelegate because the [GoalsDelegate init]
    // call found within this method is executed within a block. This means that we can't
    // expect to call sharedService and then immediately access its properties as the block
    // may execute at a later time. This means a situation may arise where we are accessing
    // GoalsDelegate's properties before it has been initialized
    [GoalsDelegate sharedService];
    
    if (launchOptions[UIApplicationLaunchOptionsLocalNotificationKey])
    {
        UILocalNotification *notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
        [self application:application didReceiveLocalNotification:notification];
    }
    
    if (SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0") ) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
    }
    
    return YES;
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    User* user = [User sharedModel];
    [user save];
    
    [[LocalNotificationAssistant getInstance] scheduleNagLocalNotification];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [[LocalNotificationAssistant getInstance] cancelNagLocalNotification];
 
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    User* user = [User sharedModel];
    [user save];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    dispatch_promise(^{
        User* user = [User sharedModel];
        [user resetNotificationToken:deviceToken];
    });
    
    NSLog(@"registered");
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

//App is running
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"got a notification in didReceiveRemoteNotification! %@ ", userInfo );
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TipsNotification" object:self];

    
    UITabBarController *mainTabBarController = [self mainTabBarController];
    if (userInfo[@"aps"][@"badge"]) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = mainTabBarController.selectedIndex == 0 ? 0 : [userInfo[@"aps"][@"badge"] integerValue];
    }
    
    [self syncHomeTabBadgeValueWithAppBadgeValue];
}


//////////
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    //NSLog(@"didRegisterUserNotificationSettings: %@", notificationSettings);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{    
    //FOREGROUND
    //NSLog(@"didReceiveLocalNotification: %@", notification);
    
    User* user = [User sharedModel];
    if (!user.isLoggedIn) {
        [[LocalNotificationResponseAssistant getInstance] saveNotificationForLogin:notification];
    }else{
        [[LocalNotificationResponseAssistant getInstance] localNotificationForegroundResponseWithNotification:notification];
    }
}

//PRE ios8 Devices
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification completionHandler:(void (^)())completionHandler
{
    [self application:application handleActionWithIdentifier:identifier forLocalNotification:notification withResponseInfo:[notification userInfo] completionHandler:completionHandler];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forLocalNotification:(UILocalNotification *)notification withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{    
    [self setWindowRootWithAnimation:NO];
    
    User* user = [User sharedModel];
    if (!user.isLoggedIn) {
        [[LocalNotificationResponseAssistant getInstance] saveNotificationForLogin:notification];
    }else{
        [[LocalNotificationResponseAssistant getInstance] localNotificationResponseWithUserInfoDictionary:[notification userInfo] withAction:identifier withNotification:notification];
    }
    
    
    if (completionHandler)
    {
        completionHandler();
    }
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler {
    
    [self setWindowRootWithAnimation:NO];
   
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *currentNavController = (UINavigationController *)viewController;
        
        UIViewController *rootController = [currentNavController.viewControllers firstObject];
        
        // a bit of a hack here as when it is the moreNavigationController,
        // the viewControllers are nil for some reason
        if (!rootController) {
            [tabBarController.moreNavigationController popToRootViewControllerAnimated:NO];
        }
        else if (rootController != currentNavController.topViewController) {
            [currentNavController popToRootViewControllerAnimated:NO];
        }
    }
}

#pragma mark - SWRevealViewControllerDelegate

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
}

#pragma mark - Methods
-(void)setWindowToExerciseSummary{
    
    UITabBarController *mainTabBarController = [self mainTabBarController];
    mainTabBarController.selectedIndex = 2;
    mainTabBarController.delegate = self;
    [self setupRevealControllerWithMainTabBar:mainTabBarController];
    self.notification = 1;
}

- (void)setWindowRootWithAnimation:(BOOL)animation {
    User* user = [User sharedModel];
    if (user.introShownCount < APP_MAX_INTRO_SHOWN_COUNT && !self.introShownWhileAppActive) {
        [self setWindowRootToIntroPageViewControllerWithAnimation:animation];
    }
    else {
        if ([user isLoggedIn]) {
            NSDictionary *upgradeMethodInfo = [DBHelper upgradeMethodInfo];
            // DB upgrade is only required when it isn't a fresh user and there are
            // upgrade methods that have not been executed previously
            if (!user.isFreshUser && [upgradeMethodInfo[@"upgradeMethodNames"] count])
            {
                self.window.rootViewController = [[UIViewController alloc] init];
                self.window.rootViewController.view.backgroundColor = [UIColor whiteColor];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.window.rootViewController.view showActivityIndicatorWithMessage:[LocalizationManager getStringFromStrId:MSG_UPGRADING_DB]];
                });
                
                dispatch_promise(^{
                    [DBHelper upgradeWithMethodNames:upgradeMethodInfo[@"upgradeMethodNames"]].then(^(BOOL success) {
                        // DB upgrade success
                        [self.window.rootViewController.view hideActivityIndicator];
                        [self setWindowRootToMainTabBarControllerWithAnimation:animation];
                    }).catch(^(NSError *error) {
                        // DB upgrade failed
                        [self.window.rootViewController.view hideActivityIndicator];
                        
                        UIAlertController *upgradeFailedAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:MSG_UPGRADING_DB_ERROR_ALERT_TITLE]
                                                                                                    message:[LocalizationManager getStringFromStrId:MSG_UPGRADING_DB_ERROR_ALERT_CONTENT]
                                                                                             preferredStyle:UIAlertControllerStyleAlert];
                        [self.window.rootViewController presentViewController:upgradeFailedAlert animated:YES completion:nil];
                    }).finally(^(){
                        [[GoalsDelegate sharedService] loadGoals];
                        [[GoalsDelegate sharedService] saveGoalsWithoutUploading];
                    });
                });
            }
            else {
                if (user.isFreshUser) {
                    int newDatabaseVersion = [upgradeMethodInfo[@"newDatabaseVersion"] intValue];
                    NSLog(@"Fresh install, database upgrade not needed. Setting database version to %d", newDatabaseVersion);
                    [DBHelper setDatabaseVersion:newDatabaseVersion];
                }
                else {
                    NSLog(@"Database was already upgraded, no upgrade required");
                }
                
                [[GoalsDelegate sharedService] loadGoals];
                [[GoalsDelegate sharedService] saveGoalsWithoutUploading];
                
                [self setWindowRootToMainTabBarControllerWithAnimation:animation];
            }
        }
        else {
            [[GoalsDelegate sharedService] loadGoals];
            [self setWindowRootToRegisterLoginViewControllerWithAnimation:animation];
        }
    }
    NSLog(@"Now=%lu\n",(unsigned long)user.introShownCount);
}

- (void)setWindowRootToIntroPageViewControllerWithAnimation:(BOOL)animation {
    IntroPageViewController *introPageVC = [[IntroPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                              navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                            options:nil];
    if (animation) {
        [UIView transitionFromView:self.window.rootViewController.view
                            toView:introPageVC.view
                          duration:0.65
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            self.introShownWhileAppActive = YES;
                            self.window.rootViewController = introPageVC;
                        }
         ];
    }
    else {
        self.introShownWhileAppActive = YES;
        self.window.rootViewController = introPageVC;
    }
}

- (void)setWindowRootToUserSetupPageViewControllerWithAnimation:(BOOL)animation {
    UserSetupPageViewController *userSetupPageVC = [[UserSetupPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                                                        options:nil];
    if (animation) {
        [UIView transitionFromView:self.window.rootViewController.view
                            toView:userSetupPageVC.view
                          duration:0.65
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            self.window.rootViewController = userSetupPageVC;
                        }
         ];
    }
    else {
        self.window.rootViewController = userSetupPageVC;
    }
}

- (void)setWindowRootToRegisterLoginViewControllerWithAnimation:(BOOL)animation {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
    UIViewController *loginOrRegisterVC = [storyBoard instantiateViewControllerWithIdentifier:APP_DELEGATE_REGISTER_LOGIN_VIEW_CONTROLLER_ID];
    
    if (animation) {
        [UIView transitionFromView:self.window.rootViewController.view
                            toView:loginOrRegisterVC.view
                          duration:0.65
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            self.window.rootViewController = loginOrRegisterVC;
                        }
         ];
    }
    else {
        self.window.rootViewController = loginOrRegisterVC;
    }
}

- (void)setWindowRootToMainTabBarControllerWithAnimation:(BOOL)animation
{
    UITabBarController *mainTabBarController = [self mainTabBarController];
    mainTabBarController.delegate = self;
    
    if (self.window.rootViewController != mainTabBarController) {
        if (animation) {
            [UIView transitionFromView:self.window.rootViewController.view
                                toView:mainTabBarController.view
                              duration:0.65
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL finished) {
                                [self setupRevealControllerWithMainTabBar:mainTabBarController];
                            }
             ];
        }
        else {
            [self setupRevealControllerWithMainTabBar:mainTabBarController];
        }
    }
    else {
        // the root view controller is the GG Tab Bar from the start so now we
        // need to setup the reveal controller
        [self setupRevealControllerWithMainTabBar:mainTabBarController];
    }
}

- (void)setupRevealControllerWithMainTabBar:(UITabBarController *)mainTabBarController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
    UIViewController *settingsNavigationController = [storyBoard instantiateViewControllerWithIdentifier:APP_DELEGATE_SETTINGS_NAV_CONTROLLER_ID];
    
    SWRevealViewController *revealController = [[SWRevealViewController alloc] initWithRearViewController:settingsNavigationController
                                                                                      frontViewController:mainTabBarController];
    revealController.delegate = self;
    self.window.rootViewController = revealController;
}

- (UITabBarController *)mainTabBarController
{
    UITabBarController *mainTabBarController = nil;
    
    if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
        mainTabBarController = (UITabBarController *)self.window.rootViewController;
    }
    else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
        mainTabBarController = [storyBoard instantiateViewControllerWithIdentifier:APP_DELEGATE_MAIN_TAB_BAR_CONTROLLER_ID];
    }
    
    return mainTabBarController;
}

- (void)syncHomeTabBadgeValueWithAppBadgeValue {
    User* user = [User sharedModel];
    
    if (user.isLoggedIn) {
        UITabBarController *mainTabBarController = [self mainTabBarController];
        NSInteger appBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
        [[mainTabBarController.viewControllers objectAtIndex:0] tabBarItem].badgeValue = appBadgeNumber != 0 ? [@(appBadgeNumber) stringValue] : nil;
    }
}

@end
