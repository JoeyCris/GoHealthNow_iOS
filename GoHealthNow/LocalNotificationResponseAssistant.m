//
//  LocalNotificationAssistant.m
//  notificationAssistant
//
//  Created by John Wreford on 2015-09-29.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocalNotificationResponseAssistant.h"
#import "LocalNotificationAssistant.h"

#import "MedicationRecord.h"

#import "NotificationMedicationClass.h"
#import "NotificationBloodGlucoseClass.h"
#import "NotificationDietClass.h"
#import "NotificationExerciseClass.h"

#import "AppDelegate.h"

#import "AddGlucoseRecordViewController.h"
#import "DosageInputViewController.h"
#import "RecentMealsController.h"
#import "ChooseExerciseTypeViewController.h"
#import "AddExerciseRecordViewController.h"
#import "UIAlertController+Window.h"
#import "User.h"

@implementation LocalNotificationResponseAssistant 
@synthesize alert;

static LocalNotificationResponseAssistant *singletonInstance;

+(LocalNotificationResponseAssistant *)getInstance
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

-(void)saveNotificationForLogin:(UILocalNotification *)notification{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *arrayNotifications = [[NSMutableArray alloc]init];
        
        if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"notifications"]){
            
            arrayNotifications = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"notifications"]];
            [arrayNotifications addObject:notification];
            
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrayNotifications] forKey:@"notifications"];
            
        }else{
            [arrayNotifications addObject:notification];
            [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:arrayNotifications] forKey:@"notifications"];
        }

    //NSLog(@"test: %@",[NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"notifications"]]);

    alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                  message:[LocalizationManager getStringFromStrId:@"Login To Record The Information"]
                                           preferredStyle:UIAlertControllerStyleAlert];
            
    UIAlertAction *btnOK = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
            
            [alert addAction:btnOK];
            
            [self fireAlert];
}

#pragma mark - LocalNotification Return Action
-(void)localNotificationForegroundResponseWithNotification:(UILocalNotification *)notification{
    
       [alert dismissViewControllerAnimated:YES completion:nil];
  
        if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"BloodGlucose"]){
            [self bloodGlucose:notification];
        }else if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"Diet"]){
            [self diet:notification];
        }else if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"Medication"]){
            [self medication:notification];
        }else if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"BloodPressure"]){
            [self bloodPressure:notification];
        }else{
            [self exercise:notification];
        }
}

-(void)exercise:(UILocalNotification *)notification{
    
    if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"Exercise"])
    {
        
        alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
        
       
        /*
        UIAlertAction *btnLog = [UIAlertAction actionWithTitle:@"Log"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                     [NotificationExerciseClass getInstance].stringComingFromWhere = @"logFromNotification";
                                     [NotificationExerciseClass getInstance].stringNotificationIndex = [[notification userInfo] objectForKey:@"reminderID"];
                                     
                                         UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                         AddExerciseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"NewExerciseRecord"];
                                         UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
                                         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
                                         
                                         //ChooseExerciseTypeViewController
                                         //exerciseViewController
                                         //InputViewController
                                     
                                         [topRootViewController presentViewController:navigationController animated:YES completion:nil];
                                 }];
         */
        UIAlertAction *btnOK = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Will Do"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        
        
        UIAlertAction *btnSnooze = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Snooze"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [self rescheduleExerciseLocalNotifcationAndFire:notification withTime:900];
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        UIAlertAction *btnSkip = [UIAlertAction
                                  actionWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
                                      [[NotificationExerciseClass getInstance] addOneToReminderCountSkipForExerciseCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
        
        //[alert addAction:btnLog];
        [alert addAction:btnOK];
        [alert addAction:btnSnooze];
        [alert addAction:btnSkip];
        
        [self fireAlert];
    }
}

-(void)medication:(UILocalNotification *)notification{

        alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                                        message:nil
                                                                 preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnTake = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Take & Log"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                        {
                                            self.showTakeLogAlert = 1;
                                            [self logMedicationFromDictionary:[notification userInfo]];
                                            [alert dismissViewControllerAnimated:YES completion:nil];
                                        
                                        }];
        
        UIAlertAction *btnModify = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Modify Once"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        
                                            UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                            DosageInputViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"DosageInputViewController"];
                                            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
                                            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
                                        
                                            myViewController.notification = notification;
                                        
                                            [NotificationMedicationClass getInstance].stringComingFromWhere = @"modifyFromNotification";
                                        
                                            [topRootViewController presentViewController:navigationController animated:YES completion:nil];
                                        
                                    }];
           
        
        UIAlertAction *btnSnooze = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Snooze"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                   {
                                       [self rescheduleLocalNotifcationAndFire:notification withTime:900];
   
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                   }];
        
        UIAlertAction *btnSkip = [UIAlertAction
                                  actionWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                   style:UIAlertActionStyleDestructive
                                   handler:^(UIAlertAction * action)
                                   {
                                        [[NotificationMedicationClass getInstance] addOneToReminderCountSkipForMedicationCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];

                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
        
        [alert addAction:btnTake];
        [alert addAction:btnModify];
        [alert addAction:btnSnooze];
        [alert addAction:btnSkip];

        [self fireAlert];
    
}

-(void)bloodGlucose:(UILocalNotification *)notification{
    
    if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"BloodGlucose"])
    {
    
        alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnLog = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Log"]
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction * action)
                                  {
                                      [NotificationBloodGlucoseClass getInstance].stringNotificationMealType = [[notification userInfo] objectForKey:@"mealType"];

                                          UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                          AddGlucoseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"AddGlucoseRecordViewController"];
                                          UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
                                          UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];

                                          [topRootViewController presentViewController:navigationController
                                                                          animated:YES
                                                                        completion:nil];
                                      
                                  }];
        
        
        UIAlertAction *btnSnooze = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Snooze"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [self rescheduleBloodGlucoseLocalNotifcationAndFire:notification withTime:900];
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        UIAlertAction *btnSkip = [UIAlertAction
                                  actionWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
                                      [[NotificationBloodGlucoseClass getInstance] addOneToReminderCountSkipForBloodGlucoseCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
        
        [alert addAction:btnLog];
        [alert addAction:btnSnooze];
        [alert addAction:btnSkip];
        
        [self fireAlert];
    }
}

-(void)bloodPressure:(UILocalNotification *)notification{
    
    if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"BloodPressure"])
    {
        
        alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnLog = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Log"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                                     
                                     UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                     AddGlucoseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"AddBloodPressureViewController"];
                                     UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
                                     UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
                                     
                                     [topRootViewController presentViewController:navigationController
                                                                         animated:YES
                                                                       completion:nil];
                                     
                                 }];
        
        
        UIAlertAction *btnSnooze = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Snooze"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [self rescheduleBloodGlucoseLocalNotifcationAndFire:notification withTime:900];
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        UIAlertAction *btnSkip = [UIAlertAction
                                  actionWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
                                      [[NotificationBloodGlucoseClass getInstance] addOneToReminderCountSkipForBloodGlucoseCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
        
        [alert addAction:btnLog];
        [alert addAction:btnSnooze];
        [alert addAction:btnSkip];
        
        [self fireAlert];
    }
}

//
-(void)diet:(UILocalNotification *)notification{
    
    if ([[[notification userInfo]objectForKey:@"reminderType"] isEqualToString:@"Diet"])
    {
        
        alert =   [UIAlertController alertControllerWithTitle:notification.alertBody
                                                      message:nil
                                               preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *btnLog = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Log"]
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action)
                                 {
                        
                                         UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                                         RecentMealsController *myViewController      = [storyboard  instantiateViewControllerWithIdentifier:@"RecentMealsController"];
                                         UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
                                         UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
                                     
                                     
                                         [topRootViewController presentViewController:navigationController
                                                                             animated:YES
                                                                           completion:nil];
                                     
                                 }];
        
        
        UIAlertAction *btnSnooze = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Snooze"]
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action)
                                    {
                                        [self rescheduleDietLocalNotifcationAndFire:notification withTime:900];
                                        [alert dismissViewControllerAnimated:YES completion:nil];
                                    }];
        
        UIAlertAction *btnSkip = [UIAlertAction
                                  actionWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                  style:UIAlertActionStyleDestructive
                                  handler:^(UIAlertAction * action)
                                  {
                                      [[NotificationDietClass getInstance] addOneToReminderCountSkipForDietCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];
                                      [alert dismissViewControllerAnimated:YES completion:nil];
                                      
                                  }];
        
        [alert addAction:btnLog];
        [alert addAction:btnSnooze];
        [alert addAction:btnSkip];
        
        [self fireAlert];
    }
}


-(void)fireAlert{
    
    [alert show];
}

-(void)localNotificationResponseWithUserInfoDictionary:(NSDictionary *)responseUserInfoDictionary withAction:(NSString *)actionIdentifier withNotification:(UILocalNotification *)notification{
    
    ///Medication
    if ([[responseUserInfoDictionary objectForKey:@"reminderType"] isEqualToString:@"Medication"]) {
    
        if ([actionIdentifier isEqualToString:@"take_action"]){
            [self logMedicationFromDictionary:responseUserInfoDictionary];
        }else{
           [self rescheduleLocalNotifcationAndFire:notification withTime:900];
        }

    }
    
    ///Diet
    if ([[responseUserInfoDictionary objectForKey:@"reminderType"] isEqualToString:@"Diet"]) {
        if ([actionIdentifier isEqualToString:@"open_action"]){
            
            UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            RecentMealsController *myViewController      = [storyboard  instantiateViewControllerWithIdentifier:@"RecentMealsController"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
            
            
        }else{
            [self rescheduleDietLocalNotifcationAndFire:notification withTime:900];
        }
    
    }
    
    //BloodGlucose
    if ([[responseUserInfoDictionary objectForKey:@"reminderType"] isEqualToString:@"BloodGlucose"]) {
        if ([actionIdentifier isEqualToString:@"open_action"]){
            
            [NotificationExerciseClass getInstance].stringNotificationIndex = [responseUserInfoDictionary objectForKey:@"reminderID"];
            
            UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            AddGlucoseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"AddGlucoseRecordViewController"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
        }else{
            [self rescheduleBloodGlucoseLocalNotifcationAndFire:notification withTime:900];
        }
        
    }
    
    //Exercise
    if ([[responseUserInfoDictionary objectForKey:@"reminderType"] isEqualToString:@"Exercise"]) {
        if ([actionIdentifier isEqualToString:@"open_action"]){
            
            [NotificationExerciseClass getInstance].stringComingFromWhere = @"logFromNotification";
            [NotificationExerciseClass getInstance].stringNotificationIndex = [responseUserInfoDictionary objectForKey:@"reminderID"];
            
            UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            AddExerciseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"NewExerciseRecord"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
       
        }else if ([actionIdentifier isEqualToString:@"dismiss_action"]){
            
        }else{
            [self rescheduleExerciseLocalNotifcationAndFire:notification withTime:900];
        }
        
    }
    
    //BloodPressure
    if ([[responseUserInfoDictionary objectForKey:@"reminderType"] isEqualToString:@"BloodPressure"]) {
        if ([actionIdentifier isEqualToString:@"open_action"]){
            
            [NotificationExerciseClass getInstance].stringComingFromWhere = @"logFromNotification";
            [NotificationExerciseClass getInstance].stringNotificationIndex = [responseUserInfoDictionary objectForKey:@"reminderID"];
            
            UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            AddExerciseRecordViewController *myViewController  = [storyboard  instantiateViewControllerWithIdentifier:@"AddBloodPressureViewController"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
            
        }else if ([actionIdentifier isEqualToString:@"dismiss_action"]){
            
        }else{
            [self rescheduleExerciseLocalNotifcationAndFire:notification withTime:900];
        }
        
    }
    

    
}


#pragma mark - LocalNotification Reschedule
-(void)rescheduleLocalNotifcationAndFire:(UILocalNotification *)notification withTime:(NSInteger)timeInterval{
    
    [[LocalNotificationAssistant getInstance]addLocalNotificationWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]
                                                                alertMessage:notification.alertBody
                                                              repeatInterval:0
                                                                andUserInfo:[notification userInfo]
                                                                     withUuid:[[notification userInfo] objectForKey:@"uuid"]];
    
}

-(void)rescheduleBloodGlucoseLocalNotifcationAndFire:(UILocalNotification *)notification withTime:(NSInteger)timeInterval{
    
    [[LocalNotificationAssistant getInstance]addBloodGlucoseLocalNotificationWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]
                                                                 alertMessage:notification.alertBody
                                                               repeatInterval:0
                                                                  andUserInfo:[notification userInfo]
                                                                     withUuid:[[notification userInfo] objectForKey:@"uuid"]];
    
}

-(void)rescheduleDietLocalNotifcationAndFire:(UILocalNotification *)notification withTime:(NSInteger)timeInterval{
    
    [[LocalNotificationAssistant getInstance]addDietLocalNotificationWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]
                                                                             alertMessage:notification.alertBody
                                                                           repeatInterval:0
                                                                              andUserInfo:[notification userInfo]
                                                                                 withUuid:[[notification userInfo] objectForKey:@"uuid"]];
    
    
}

-(void)rescheduleExerciseLocalNotifcationAndFire:(UILocalNotification *)notification withTime:(NSInteger)timeInterval{

            [[LocalNotificationAssistant getInstance]addExerciseLocalNotificationWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]
                                                                                 alertMessage:notification.alertBody
                                                                               repeatInterval:0
                                                                                  andUserInfo:[notification userInfo]
                                                                                     withUuid:[[notification userInfo] objectForKey:@"uuid"]];
}

-(void)rescheduleBloodPressureLocalNotifcationAndFire:(UILocalNotification *)notification withTime:(NSInteger)timeInterval{
    
    [[LocalNotificationAssistant getInstance]addBloodPressureLocalNotificationWithFireDate:[NSDate dateWithTimeIntervalSinceNow:timeInterval]
                                                                         alertMessage:notification.alertBody
                                                                       repeatInterval:0
                                                                          andUserInfo:[notification userInfo]
                                                                             withUuid:[[notification userInfo] objectForKey:@"uuid"]];
}

#pragma mark - Log Medication
-(void)logMedicationFromDictionary:(NSDictionary *)responseUserInfoDictionary{
    
        dispatch_promise(^{
            
            MedicationRecord *record = [[MedicationRecord alloc] init];
            record.dose = [[responseUserInfoDictionary objectForKey:@"dosage"] integerValue];
            record.measurement = [responseUserInfoDictionary objectForKey:@"measurement"];
            record.medicationId = [responseUserInfoDictionary objectForKey:@"drugID"];
            record.recordedTime = [NSDate date];
            
            User *user = [User sharedModel];
            NSString *lastMedication = [NSString stringWithFormat:@"%@ - %@ %@", [responseUserInfoDictionary objectForKey:@"drugName"], [responseUserInfoDictionary objectForKey:@"dosage"],[responseUserInfoDictionary objectForKey:@"measurement"]];
            
            
            NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
            NSMutableDictionary *userLastMedication = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userLastMedication"]];
            
            [userLastMedication setObject:lastMedication forKey:user.userId];
            [prefs setObject:userLastMedication forKey:@"userLastMedication"];
            [prefs synchronize];

            
            [record save].then(^(BOOL success) {
                NSLog(@"Saved Medication Record - Take & Log");
                if (self.showTakeLogAlert) {
                    
                    alert =   [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:ADD_RECORD_SUCESS_MSG]
                                                                  message:nil
                                                           preferredStyle:UIAlertControllerStyleAlert];

                    
                    [self fireAlert];
                    
                    [NSTimer scheduledTimerWithTimeInterval:1.0
                                                     target:self
                                                   selector:@selector(dismissRecordPromptAlert)
                                                   userInfo:nil
                                                    repeats:NO];
                }
                
            }).catch(^(BOOL success) {
                
                alert =   [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:ADD_RECORD_FAILURE_MSG]
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
                
                
                [self fireAlert];
                
                [NSTimer scheduledTimerWithTimeInterval:1.0
                                                 target:self
                                               selector:@selector(dismissRecordPromptAlert)
                                               userInfo:nil
                                                repeats:NO];
        });
    });

}

- (void)dismissRecordPromptAlert{

    [alert dismissViewControllerAnimated:NO completion:nil];
}

@end
