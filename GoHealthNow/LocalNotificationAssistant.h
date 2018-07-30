//
//  LocalNotificationAssistant.h
//  notificationAssistant
//
//  Created by John Wreford on 2015-09-08.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#ifndef UIUserNotificationTypeAll
#define UIUserNotificationTypeAll (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)
#endif

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

@interface LocalNotificationAssistant : NSObject <UNUserNotificationCenterDelegate>

@property UNUserNotificationCenter *notificationCenter;

+(LocalNotificationAssistant *)getInstance;

-(void)askForNotificationPermission;

-(void)addLocalNotificationWithFireDate:(NSDate *)fireDate
                           alertMessage:(NSString *)alertMessage
                         repeatInterval:(NSCalendarUnit)calendarUnit
                            andUserInfo:(NSDictionary *)userInfoDictionary
                               withUuid:(NSString *)uuid;

-(void)addBloodGlucoseLocalNotificationWithFireDate:(NSDate *)fireDate
                                       alertMessage:(NSString *)alertMessage
                                     repeatInterval:(NSCalendarUnit)calendarUnit
                                        andUserInfo:(NSDictionary *)userInfoDictionary
                                           withUuid:(NSString *)uuid;

-(void)addDietLocalNotificationWithFireDate:(NSDate *)fireDate
                                       alertMessage:(NSString *)alertMessage
                                     repeatInterval:(NSCalendarUnit)calendarUnit
                                        andUserInfo:(NSDictionary *)userInfoDictionary
                                            withUuid:(NSString *)uuid;

-(void)addExerciseLocalNotificationWithFireDate:(NSDate *)fireDate
                               alertMessage:(NSString *)alertMessage
                             repeatInterval:(NSCalendarUnit)calendarUnit
                                andUserInfo:(NSDictionary *)userInfoDictionary
                                   withUuid:(NSString *)uuid;

-(void)addBloodPressureLocalNotificationWithFireDate:(NSDate *)fireDate
                                   alertMessage:(NSString *)alertMessage
                                 repeatInterval:(NSCalendarUnit)calendarUnit
                                    andUserInfo:(NSDictionary *)userInfoDictionary
                                       withUuid:(NSString *)uuid;

-(void)scheduleNagLocalNotification;
-(void)cancelNagLocalNotification;


-(void)cancelNotification:(UILocalNotification *)notification;
-(void)cancelAllNotifications;
-(void)logNotificationCount;
-(void)logAllNotificationDescriptions;



@end
