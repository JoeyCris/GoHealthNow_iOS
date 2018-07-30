//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotificationBloodPressureClass : NSObject
{
    NSString *stringNotificationIndex;
    NSString *stringTime;
    NSString *stringComingFromWhere;
    NSString *stringGoingToBloodPressureType;
    NSString *uuidString;
}

@property (nonatomic) NSString *stringNotificationIndex;
@property (nonatomic) NSString *stringTime;
@property (nonatomic) NSString *stringComingFromWhere;
@property (nonatomic) NSString *stringGoingToBloodPressureType;
@property (nonatomic) NSString *uuidString;

@property (nonatomic) NSString *tempCompliance;
@property (nonatomic) NSString *tempTotalCount;

@property FMDatabase *database;
@property FMResultSet *results;

+(NotificationBloodPressureClass *)getInstance;

-(void)addReminderTime:(NSString *)time;

-(void)addNotificationToDatabase:(NotificationBloodPressureClass *)reminder;
-(void)deleteNotificationFromDatabase:(NSString *)stringID;
-(void)addOneToReminderCountSkipForBloodPressureCompliance:(int)reminderID;

-(void)comingFromWhere:(NSString *)comingFromWhere;
-(void)goingToBloodPressureType:(NSString *)goingToExerciseType;
-(NSString *)getNotificationBloodPressureComplianceRate;
-(NSString *)getNotificationBloodPressureCompliance;
-(NSString *)getNotificationBloodPressureTotalCount;
-(NSArray *)getAllBloodPressureNotificationsFromDatabase;
    
@end
