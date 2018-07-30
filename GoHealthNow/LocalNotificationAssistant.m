//
//  LocalNotificationAssistant.m
//  notificationAssistant
//
//  Created by John Wreford on 2015-09-08.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotificationAssistant.h"
#import <UserNotifications/UserNotifications.h>
#import "Constants.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@implementation LocalNotificationAssistant


@synthesize notificationCenter;

static LocalNotificationAssistant *singletonInstance;

+(LocalNotificationAssistant *)getInstance
{
    static dispatch_once_t once;
    static id singletonInstance;
    dispatch_once(&once, ^{
        singletonInstance = [[self alloc] init];
    });
    return singletonInstance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

-(void)askForNotificationPermission{
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
}

///Medication Category
-(void)registerMedicationCategory{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:@"snooze_action" title:[LocalizationManager getStringFromStrId:@"Snooze"] options:UNNotificationActionOptionNone];
                UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:@"take_action" title:[LocalizationManager getStringFromStrId:@"Take & Log"] options:UNNotificationActionOptionNone];
                
                UNNotificationCategory *medication10Category = [UNNotificationCategory categoryWithIdentifier:@"medication_category" actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
                
                [notificationCenter setNotificationCategories:[NSSet setWithObjects:medication10Category, nil]];
            }
        }];
        
        
    }else{
    
        UIMutableUserNotificationAction *snooze = [[UIMutableUserNotificationAction alloc]init];
        snooze.identifier = @"snooze_action";
        snooze.title = [LocalizationManager getStringFromStrId:@"Snooze"];
        snooze.destructive = NO;
        snooze.authenticationRequired = NO;
        snooze.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *take = [[UIMutableUserNotificationAction alloc]init];
        take.identifier = @"take_action";
        take.title = [LocalizationManager getStringFromStrId:@"Take & Log"];
        take.destructive = NO;
        take.authenticationRequired = NO;
        take.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationCategory *userNotificationCategory = UIMutableUserNotificationCategory.new;
        userNotificationCategory.identifier = @"medication_category";
        [userNotificationCategory setActions:@[] forContext:UIUserNotificationActionContextDefault]; //Center Screen Alert (Current nothing = Open / Close)
        [userNotificationCategory setActions:@[snooze, take] forContext:UIUserNotificationActionContextMinimal]; //Banner & Notifications
        
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categories:[NSSet setWithArray:@[userNotificationCategory]]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    }
    
    
}

//Medication LocalAlert
-(void)addLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)alertMessage repeatInterval:(NSCalendarUnit)calendarUnit andUserInfo:(NSDictionary *)userInfoDictionary withUuid:(NSString *)uuid
{
    [self registerMedicationCategory];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"GoHealthNow" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:alertMessage arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"medication_category";
        content.userInfo = userInfoDictionary;
        
        /// 4. update application icon badge number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        //content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone) fromDate:fireDate];
        
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        
       // UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuid content:content trigger:trigger];
     
        //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest Medication succeeded!");
            }
        }];
        
    }else{
    
        UILocalNotification *localNotification       = UILocalNotification.new;
        
        localNotification.fireDate                   = fireDate;  //[NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.timeZone                   = [NSTimeZone defaultTimeZone];
        localNotification.alertBody                  = alertMessage;
        localNotification.alertAction                = @"Open";
        localNotification.category                   = @"medication_category";
        localNotification.userInfo                   = userInfoDictionary;
        localNotification.soundName                  = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = 1;  Annoying Badges Have Been Disabled
        localNotification.repeatInterval             = calendarUnit;
        
        //NSCalendarUnitWeekday -Daily
        //NSCalendarUnitWeekOfYear -Weekly
        
        NSLog(@"Notif Med: %@", localNotification.description);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    


}

//BloodGlucose Category
-(void)registerBGCategory{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:@"snooze_action" title:[LocalizationManager getStringFromStrId:@"Snooze"] options:UNNotificationActionOptionNone];
                UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:@"open_action" title:[LocalizationManager getStringFromStrId:@"Log"] options:UNNotificationActionOptionForeground];
                
                UNNotificationCategory *BloodGlucose10Category = [UNNotificationCategory categoryWithIdentifier:@"bloodglucose_category" actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
                
                [notificationCenter setNotificationCategories:[NSSet setWithObjects:BloodGlucose10Category, nil]];
            }
        }];
        
    }else{
    
        UIMutableUserNotificationAction *snooze = [[UIMutableUserNotificationAction alloc]init];
        snooze.identifier = @"snooze_action";
        snooze.title = [LocalizationManager getStringFromStrId:@"Snooze"];
        snooze.destructive = NO;
        snooze.authenticationRequired = NO;
        snooze.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *open = [[UIMutableUserNotificationAction alloc]init];
        open.identifier = @"open_action";
        open.title = [LocalizationManager getStringFromStrId:@"Log"];
        open.destructive = NO;
        open.authenticationRequired = NO;
        open.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationCategory *userNotificationCategory = UIMutableUserNotificationCategory.new;
        userNotificationCategory.identifier = @"bloodglucose_category";
        [userNotificationCategory setActions:@[] forContext:UIUserNotificationActionContextDefault]; //Center Screen Alert (Current nothing = Open / Close)
        [userNotificationCategory setActions:@[snooze, open] forContext:UIUserNotificationActionContextMinimal]; //Banner & Notifications
        
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categories:[NSSet setWithArray:@[userNotificationCategory]]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    }
}

//BloodGlucose Local Alert
-(void)addBloodGlucoseLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)alertMessage repeatInterval:(NSCalendarUnit)calendarUnit andUserInfo:(NSDictionary *)userInfoDictionary  withUuid:(NSString *)uuid
{
    [self registerBGCategory];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"GoHealthNow" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:alertMessage arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"bloodglucose_category";
        content.userInfo = userInfoDictionary;
        
        /// 4. update application icon badge number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        //content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone) fromDate:fireDate];
        
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        
        // UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuid content:content trigger:trigger];
        
        //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest Blood Glucose succeeded!");
            }
        }];
        
    }else{
    
        UILocalNotification *localNotification       = UILocalNotification.new;
        
        localNotification.fireDate                   = fireDate; //[NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.timeZone                   = [NSTimeZone defaultTimeZone];
        localNotification.alertBody                  = alertMessage;
        localNotification.alertAction                = [LocalizationManager getStringFromStrId:@"Open"];
        localNotification.category                   = @"bloodglucose_category";
        localNotification.userInfo                   = userInfoDictionary;
        localNotification.soundName                  = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = 1;  Annoying Badges Have Been Disabled
        localNotification.repeatInterval             = calendarUnit;
        
        //NSCalendarUnitWeekday -Daily
        //NSCalendarUnitWeekOfYear -Weekly
        
        NSLog(@"Notif BG: %@", localNotification.description);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

-(void)registerDietCategory{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:@"snooze_action" title:[LocalizationManager getStringFromStrId:@"Snooze"] options:UNNotificationActionOptionNone];
                UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:@"open_action" title:[LocalizationManager getStringFromStrId:@"Log"] options:UNNotificationActionOptionForeground];
                
                UNNotificationCategory *diet10Category = [UNNotificationCategory categoryWithIdentifier:@"diet_category" actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
                
                [notificationCenter setNotificationCategories:[NSSet setWithObjects:diet10Category, nil]];
            }
        }];
        
    }else{
    
        UIMutableUserNotificationAction *snooze = [[UIMutableUserNotificationAction alloc]init];
        snooze.identifier = @"snooze_action";
        snooze.title = [LocalizationManager getStringFromStrId:@"Snooze"];
        snooze.destructive = NO;
        snooze.authenticationRequired = NO;
        snooze.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *open = [[UIMutableUserNotificationAction alloc]init];
        open.identifier = @"open_action";
        open.title = [LocalizationManager getStringFromStrId:@"Log"];
        open.destructive = NO;
        open.authenticationRequired = NO;
        open.activationMode = UIUserNotificationActivationModeForeground;
        
        UIMutableUserNotificationCategory *userNotificationCategory = UIMutableUserNotificationCategory.new;
        userNotificationCategory.identifier = @"diet_category";
        [userNotificationCategory setActions:@[] forContext:UIUserNotificationActionContextDefault]; //Center Screen Alert (Current nothing = Open / Close)
        [userNotificationCategory setActions:@[snooze, open] forContext:UIUserNotificationActionContextMinimal]; //Banner & Notifications
        
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categories:[NSSet setWithArray:@[userNotificationCategory]]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    }
}

-(void)addDietLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)alertMessage repeatInterval:(NSCalendarUnit)calendarUnit andUserInfo:(NSDictionary *)userInfoDictionary withUuid:(NSString *)uuid
{
    [self registerDietCategory];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"GoHealthNow" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:alertMessage arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"diet_category";
        content.userInfo = userInfoDictionary;
        
        /// 4. update application icon badge number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        //content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone) fromDate:fireDate];
        
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        
        // UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuid content:content trigger:trigger];
        
        //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest Diet succeeded!");
            }
        }];
        
    }else{
    
        UILocalNotification *localNotification       = UILocalNotification.new;
        
        localNotification.fireDate                   = fireDate; //NSDate dateWithTimeIntervalSinceNow:5];
        localNotification.timeZone                   = [NSTimeZone defaultTimeZone];
        localNotification.alertBody                  = alertMessage;
        localNotification.alertAction                = [LocalizationManager getStringFromStrId:@"Open"];
        localNotification.category                   = @"diet_category";
        localNotification.userInfo                   = userInfoDictionary;
        localNotification.soundName                  = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = 1;  Annoying Badges Have Been Disabled
        localNotification.repeatInterval             = calendarUnit;
        
        //NSCalendarUnitWeekday -Daily
        //NSCalendarUnitWeekOfYear -Weekly
        
        NSLog(@"Notif Diet: %@", localNotification.description);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

////Exercise
-(void)registerExerciseCategory{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:@"snooze_action" title:[LocalizationManager getStringFromStrId:@"Snooze"] options:UNNotificationActionOptionNone];
                UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:@"open_action" title:[LocalizationManager getStringFromStrId:@"Log"] options:UNNotificationActionOptionForeground];
                
                UNNotificationCategory *exercise10Category = [UNNotificationCategory categoryWithIdentifier:@"exercise_category" actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
                
                [notificationCenter setNotificationCategories:[NSSet setWithObjects:exercise10Category, nil]];
            }
        }];
        
    }else{
    
        UIMutableUserNotificationAction *snooze = [[UIMutableUserNotificationAction alloc]init];
        snooze.identifier = @"snooze_action";
        snooze.title = [LocalizationManager getStringFromStrId:@"Snooze"];
        snooze.destructive = NO;
        snooze.authenticationRequired = NO;
        snooze.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *WillDo = [[UIMutableUserNotificationAction alloc]init];
        WillDo.identifier = @"dismiss_action"; //WAS open_action
        WillDo.title = [LocalizationManager getStringFromStrId:@"Will Do"];
        WillDo.destructive = NO;
        WillDo.authenticationRequired = NO;
        WillDo.activationMode = UIUserNotificationActivationModeBackground;  //WAS UIUserNotificationActivationModeForeground
        
        UIMutableUserNotificationCategory *userNotificationCategory = UIMutableUserNotificationCategory.new;
        userNotificationCategory.identifier = @"exercise_category";
        [userNotificationCategory setActions:@[] forContext:UIUserNotificationActionContextDefault]; //Center Screen Alert (Current nothing = Open / Close)
        [userNotificationCategory setActions:@[snooze, WillDo] forContext:UIUserNotificationActionContextMinimal]; //Banner & Notifications
        
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categories:[NSSet setWithArray:@[userNotificationCategory]]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    }
}

-(void)addExerciseLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)alertMessage repeatInterval:(NSCalendarUnit)calendarUnit andUserInfo:(NSDictionary *)userInfoDictionary withUuid:(NSString *)uuid
{
    [self registerExerciseCategory];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"GoHealthNow" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:alertMessage arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"exercise_category";
        content.userInfo = userInfoDictionary;
        
        /// 4. update application icon badge number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        //content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone) fromDate:fireDate];
        
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        
        // UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuid content:content trigger:trigger];
        
        //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest Exercise succeeded!");
            }
        }];
        
    }else{
    
        UILocalNotification *localNotification       = UILocalNotification.new;
        
        localNotification.fireDate                   = fireDate;  //[NSDate dateWithTimeIntervalSinceNow:5];  //fireDate;
        localNotification.timeZone                   = [NSTimeZone defaultTimeZone];
        localNotification.alertBody                  = alertMessage;
        localNotification.alertAction                = [LocalizationManager getStringFromStrId:@"Open"];
        localNotification.category                   = @"exercise_category";
        localNotification.userInfo                   = userInfoDictionary;
        localNotification.soundName                  = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = 1;  Annoying Badges Have Been Disabled
        localNotification.repeatInterval             = calendarUnit;
        
        //NSCalendarUnitWeekday -Daily
        //NSCalendarUnitWeekOfYear -Weekly
        
        NSLog(@"Notif Exercise: %@", localNotification.description);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}

///Blood Pressure
////
-(void)registerBloodPressureCategory{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        notificationCenter.delegate = self;
        [notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted)
            {
                UNNotificationAction *actOne = [UNNotificationAction actionWithIdentifier:@"snooze_action" title:[LocalizationManager getStringFromStrId:@"Snooze"] options:UNNotificationActionOptionNone];
                UNNotificationAction *actTwo = [UNNotificationAction actionWithIdentifier:@"open_action" title:[LocalizationManager getStringFromStrId:@"Log"] options:UNNotificationActionOptionForeground];
                
                UNNotificationCategory *bloodPressure10Category = [UNNotificationCategory categoryWithIdentifier:@"bloodPressure_category" actions:@[actOne,actTwo] intentIdentifiers:@[] options:UNNotificationCategoryOptionNone];
                
                [notificationCenter setNotificationCategories:[NSSet setWithObjects:bloodPressure10Category, nil]];
            }
        }];
        
    }else{
        
        UIMutableUserNotificationAction *snooze = [[UIMutableUserNotificationAction alloc]init];
        snooze.identifier = @"snooze_action";
        snooze.title = [LocalizationManager getStringFromStrId:@"Snooze"];
        snooze.destructive = NO;
        snooze.authenticationRequired = NO;
        snooze.activationMode = UIUserNotificationActivationModeBackground;
        
        UIMutableUserNotificationAction *WillDo = [[UIMutableUserNotificationAction alloc]init];
        WillDo.identifier = @"dismiss_action"; //WAS open_action
        WillDo.title = [LocalizationManager getStringFromStrId:@"Log"];
        WillDo.destructive = NO;
        WillDo.authenticationRequired = NO;
        WillDo.activationMode = UIUserNotificationActivationModeBackground;  //WAS UIUserNotificationActivationModeForeground
        
        UIMutableUserNotificationCategory *userNotificationCategory = UIMutableUserNotificationCategory.new;
        userNotificationCategory.identifier = @"bloodPressure_category";
        [userNotificationCategory setActions:@[] forContext:UIUserNotificationActionContextDefault]; //Center Screen Alert (Current nothing = Open / Close)
        [userNotificationCategory setActions:@[snooze, WillDo] forContext:UIUserNotificationActionContextMinimal]; //Banner & Notifications
        
        UIUserNotificationSettings *userNotificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAll categories:[NSSet setWithArray:@[userNotificationCategory]]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:userNotificationSettings];
    }
}

-(void)addBloodPressureLocalNotificationWithFireDate:(NSDate *)fireDate alertMessage:(NSString *)alertMessage repeatInterval:(NSCalendarUnit)calendarUnit andUserInfo:(NSDictionary *)userInfoDictionary withUuid:(NSString *)uuid
{
    [self registerBloodPressureCategory];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = [NSString localizedUserNotificationStringForKey:@"GoHealthNow" arguments:nil];
        content.body = [NSString localizedUserNotificationStringForKey:alertMessage arguments:nil];
        content.sound = [UNNotificationSound defaultSound];
        content.categoryIdentifier = @"bloodPressure_category";
        content.userInfo = userInfoDictionary;
        
        /// 4. update application icon badge number
        //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);
        //content.launchImageName = @"any string is ok,such as 微博@iOS程序犭袁";
        // Deliver the notification in five seconds.
        //*** Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'time interval must be at least 60 if repeating'
        
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitTimeZone) fromDate:fireDate];
        
        UNCalendarNotificationTrigger* trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:YES];
        
        
        // UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5.0f repeats:YES];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuid content:content trigger:trigger];
        
        //UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        /// 3. schedule localNotification,The delegate must be set before the application returns from applicationDidFinishLaunching:.
        // center.delegate = self;
        [notificationCenter addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (!error) {
                NSLog(@"add NotificationRequest BloodPressure succeeded!");
            }
        }];
        
    }else{
        
        UILocalNotification *localNotification       = UILocalNotification.new;
        
        localNotification.fireDate                   = fireDate;  //[NSDate dateWithTimeIntervalSinceNow:5];  //fireDate;
        localNotification.timeZone                   = [NSTimeZone defaultTimeZone];
        localNotification.alertBody                  = alertMessage;
        localNotification.alertAction                = [LocalizationManager getStringFromStrId:@"Open"];
        localNotification.category                   = @"bloodPressure_category";
        localNotification.userInfo                   = userInfoDictionary;
        localNotification.soundName                  = UILocalNotificationDefaultSoundName;
        //localNotification.applicationIconBadgeNumber = 1;  Annoying Badges Have Been Disabled
        localNotification.repeatInterval             = calendarUnit;
        
        //NSCalendarUnitWeekday -Daily
        //NSCalendarUnitWeekOfYear -Weekly
        
        NSLog(@"Notif BloodPressure: %@", localNotification.description);
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
}
////
-(void)scheduleNagLocalNotification{
    
    UILocalNotification *notificationNag = [[UILocalNotification alloc] init];
    notificationNag.fireDate = [NSDate dateWithTimeIntervalSinceNow:432000];
    notificationNag.alertBody = [LocalizationManager getStringFromStrId:@"We haven't see you in awhile. Please log your health information."];
    notificationNag.timeZone = [NSTimeZone defaultTimeZone];
    notificationNag.soundName = UILocalNotificationDefaultSoundName;
    notificationNag.repeatInterval = 0;
    [[UIApplication sharedApplication] scheduleLocalNotification:notificationNag];
    
}

-(void)cancelNagLocalNotification{
    
    NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *notification in notificationArray){
        if ([notification.alertBody isEqualToString:[LocalizationManager getStringFromStrId:@"We haven't see you in awhile. Please log your health information."]]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}



/////

- (void)cancelNotification:(UILocalNotification *)notification{
    
   if ([[UIApplication sharedApplication].scheduledLocalNotifications containsObject:notification]) {
       [[UIApplication sharedApplication] cancelLocalNotification:notification];
    }
}

-(void)cancelAllNotifications{
   
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
}

-(void)logNotificationCount{
   NSLog(@"Notification Count: %lu", (unsigned long)[[[UIApplication sharedApplication] scheduledLocalNotifications] count]);
}

-(void)logAllNotificationDescriptions{
    NSLog(@"Notifications Scheduled: %@", [[UIApplication sharedApplication] scheduledLocalNotifications].description);
}

@end
