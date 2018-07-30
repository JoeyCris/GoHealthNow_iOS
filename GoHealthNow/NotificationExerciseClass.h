//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotificationExerciseClass : NSObject
{
    NSString *stringNotificationIndex;
    NSString *stringTime;
    NSString *stringComingFromWhere;
    NSString *stringGoingToExerciseType;
    NSString *uuidString;
}

@property (nonatomic) NSString *stringNotificationIndex;
@property (nonatomic) NSString *stringTime;
@property (nonatomic) NSString *stringComingFromWhere;
@property (nonatomic) NSString *stringGoingToExerciseType;
@property (nonatomic) NSString *uuidString;

@property (nonatomic) NSString *tempCompliance;
@property (nonatomic) NSString *tempTotalCount;

@property FMDatabase *database;
@property FMResultSet *results;

+(NotificationExerciseClass *)getInstance;

-(void)addReminderTime:(NSString *)time;

-(void)addNotificationToDatabase:(NotificationExerciseClass *)reminder;
-(void)deleteNotificationFromDatabase:(NSString *)stringID;
-(void)addOneToReminderCountSkipForExerciseCompliance:(int)reminderID;

-(void)comingFromWhere:(NSString *)comingFromWhere;
-(void)goingToExerciseType:(NSString *)goingToExerciseType;
-(NSString *)getNotificationExerciseComplianceRate;
-(NSString *)getNotificationExerciseCompliance;
-(NSString *)getNotificationExerciseTotalCount;
-(NSArray *)getAllExerciseNotificationsFromDatabase;
    
@end
