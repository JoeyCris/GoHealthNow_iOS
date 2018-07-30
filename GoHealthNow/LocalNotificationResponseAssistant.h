//
//  LocalNotificationResponseAssistant.h
//  notificationAssistant
//
//  Created by John Wreford on 2015-09-29.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LocalNotificationResponseAssistant : NSObject

@property UIAlertController *alert;
@property BOOL showTakeLogAlert;

+(LocalNotificationResponseAssistant *)getInstance;

-(void)localNotificationResponseWithUserInfoDictionary:(NSDictionary *)responseUserInfoDictionary withAction:(NSString *)actionIdentifier withNotification:(UILocalNotification *)notification;
-(void)localNotificationForegroundResponseWithNotification:(UILocalNotification *)notification;

-(void)saveNotificationForLogin:(UILocalNotification *)notification;

@end