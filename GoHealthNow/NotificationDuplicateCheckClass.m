//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "NotificationDuplicateCheckClass.h"

#import "NotificationBloodGlucoseClass.h"
#import "NotificationExerciseClass.h"
#import "NotificationDietClass.h"
#import "NotificationMedicationClass.h"
#import "NotificationBloodPressureClass.h"

#import "UIAlertController+Window.h"
#import "Constants.h"

@implementation NotificationDuplicateCheckClass
@synthesize isDuplicate, alert;
static NotificationDuplicateCheckClass *singletonInstance;

+(NotificationDuplicateCheckClass *)getInstance
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

#pragma mark - Check For duplicate time notification
-(BOOL)isDuplicateNotificationTimeUsingNotificationTimeString:(NSString *)timeString{

    NSMutableArray *arrayMedicationNotification = [NSMutableArray arrayWithArray:[[NotificationMedicationClass getInstance] getAllNotificationsFromDatabase]];
    NSMutableArray *arrayBloodGlucoseNotification = [NSMutableArray arrayWithArray:[[NotificationBloodGlucoseClass getInstance] getAllBloodGlucoseNotificationsFromDatabase]];
    NSMutableArray *arrayDietNotification = [NSMutableArray arrayWithArray:[[NotificationDietClass getInstance] getAllDietNotificationsFromDatabase]];
    NSMutableArray *arrayExerciseNotification = [NSMutableArray arrayWithArray:[[NotificationExerciseClass getInstance] getAllExerciseNotificationsFromDatabase]];
    NSMutableArray *arrayBloodPressureNotification = [NSMutableArray arrayWithArray:[[NotificationBloodPressureClass getInstance] getAllBloodPressureNotificationsFromDatabase]];
    
    NSMutableArray *arrayMergeNotifications = [[NSMutableArray alloc]initWithCapacity:4];
    [arrayMergeNotifications addObjectsFromArray:arrayMedicationNotification];
    [arrayMergeNotifications addObjectsFromArray:arrayBloodGlucoseNotification];
    [arrayMergeNotifications addObjectsFromArray:arrayDietNotification];
    [arrayMergeNotifications addObjectsFromArray:arrayExerciseNotification];
    [arrayMergeNotifications addObjectsFromArray:arrayBloodPressureNotification];
    
    if ([arrayMergeNotifications count] == 0) {
        arrayMedicationNotification = nil;
        arrayBloodGlucoseNotification = nil;;
        arrayDietNotification = nil;
        arrayExerciseNotification = nil;
        arrayBloodPressureNotification = nil;
        
        return isDuplicate = NO;
    }else{
    
        for (int i = 0; i < [arrayMergeNotifications count]; ++i) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
            [formatter setLocale:locale];
            [formatter setDateFormat:@"hh:mm a"];
            
            NSDate *possibleBadTimeDate = [formatter dateFromString:[[arrayMergeNotifications objectAtIndex:i] valueForKey:@"notificationTime"]];
            NSDate *timeStringDate = [formatter dateFromString:timeString];
            
            int tempNumber = [timeStringDate timeIntervalSinceDate:possibleBadTimeDate];
            
            if (abs(tempNumber) <= 120) {
                isDuplicate = YES;
                break;
            }else{
                isDuplicate = NO;
            }
            
        }
    
        arrayMedicationNotification = nil;
        arrayBloodGlucoseNotification = nil;;
        arrayDietNotification = nil;
        arrayExerciseNotification = nil;
        arrayBloodPressureNotification = nil;
    }

    return isDuplicate;
}

-(void)showDuplicateAlert{
    
    alert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Duplicate Notification Times"]
                                                message:[LocalizationManager getStringFromStrId:@"You have another notification set within 2 minutes of this one.\n\nSpace out notifications by 3 or more minutes, to give yourself time to address each notification."]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    [alert addAction:cancelAction];
    
    [alert show];
}



@end
