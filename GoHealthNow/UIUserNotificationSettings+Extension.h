//
//  LocalNotificationAssistant.h
//  notificationAssistant
//
//  Created by John Wreford on 2015-09-08.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef UIUserNotificationTypeAll
#define UIUserNotificationTypeAll (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) //Annoying Badges Have Been Disabled In LocalNotificationAssistant. 
#endif

@interface UIUserNotificationSettings (Extension)

+ (instancetype)settingsForTypes:(UIUserNotificationType)types categoriesArray:(NSArray *)categories;

@end

@interface UIUserNotificationCategory (Extension)

+ (instancetype)categoryWithIdentifier:(NSString *)identifier defaultActions:(NSArray *)defaultActions;
+ (instancetype)categoryWithIdentifier:(NSString *)identifier minimalActions:(NSArray *)minimalActions;
+ (instancetype)categoryWithIdentifier:(NSString *)identifier defaultActions:(NSArray *)defaultActions minimalActions:(NSArray *)minimalActions;

@end

@interface UIUserNotificationAction (Extension)

//textInput Only Works In Banner Notifications and IOS9 ONLY

+ (instancetype)foregroundActionWithIdentifier:(NSString *)identifier title:(NSString *)title;
+ (instancetype)foregroundActionWithIdentifier:(NSString *)identifier title:(NSString *)title textInput:(BOOL)textInput; //IOS9 ONLY

+ (instancetype)foregroundDestructiveActionWithIdentifier:(NSString *)identifier title:(NSString *)title;
+ (instancetype)foregroundDestructiveActionWithIdentifier:(NSString *)identifier title:(NSString *)title textInput:(BOOL)textInput; //IOS9 ONLY

+ (instancetype)backgroundActionWithIdentifier:(NSString *)identifier title:(NSString *)title authenticationRequired:(BOOL)authenticationRequired;

+ (instancetype)backgroundActionWithIdentifier:(NSString *)identifier title:(NSString *)title authenticationRequired:(BOOL)authenticationRequired textInput:(BOOL)textInput; //IOS9 ONLY

+ (instancetype)backgroundDestructiveActionWithIdentifier:(NSString *)identifier title:(NSString *)title authenticationRequired:(BOOL)authenticationRequired;
+ (instancetype)backgroundDestructiveActionWithIdentifier:(NSString *)identifier title:(NSString *)title authenticationRequired:(BOOL)authenticationRequired textInput:(BOOL)textInput; //IOS9 ONLY

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title activationMode:(UIUserNotificationActivationMode)activationMode authenticationRequired:(BOOL)authenticationRequired destructive:(BOOL)destructive;

+ (instancetype)actionWithIdentifier:(NSString *)identifier title:(NSString *)title activationMode:(UIUserNotificationActivationMode)activationMode authenticationRequired:(BOOL)authenticationRequired destructive:(BOOL)destructive textInput:(BOOL)textInput; //IOS9 ONLY

/*Notes For Learning

 authenticationRequired: This property is a bool value also. When it becomes true, the user must necessarily authenticate himself to the device before the action is performed. It’s extremely useful in cases where the action is critical enough, and any unauthorised access can damage the application’s data.
 
 activationMode: This is an enum property, and defines whether the app should run in the foreground or in the background when the action is performed. The possible values specifying each mode are two: (a) UIUserNotificationActivationModeForeground, and (b) UIUserNotificationActivationModeBackground. In background, the app is given just a few seconds to perform the action.
 
*/

@end
