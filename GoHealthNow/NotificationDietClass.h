//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotificationDietClass : NSObject
{
    NSString *stringNotificationIndex;
    NSString *stringTime;
    NSString *stringMeal;
    NSString *uuidString;
}

@property (nonatomic) NSString *stringNotificationIndex;
@property (nonatomic) NSString *stringTime;
@property (nonatomic) NSString *stringMeal;
@property (nonatomic) NSString *uuidString;

@property (nonatomic) NSString *tempCompliance;
@property (nonatomic) NSString *tempTotalCount;

@property (nonatomic) int tempMealType;

@property FMDatabase *database;
@property FMResultSet *results;

+(NotificationDietClass *)getInstance;

-(void)addReminderMeal:(NSString *)meal;
-(void)addReminderTime:(NSString *)time;

-(void)addNotificationToDatabase:(NotificationDietClass *)reminder;
-(void)deleteNotificationFromDatabase:(NSString *)stringID;
-(void)addOneToReminderCountSkipForDietCompliance:(int)reminderID;
-(NSString *)getNotificationDietCompliance;
-(NSString *)getNotificationDietComplianceRate;
-(NSString *)getNotificationDietTotalCount;
-(NSArray *)getAllDietNotificationsFromDatabase;
    
@end
