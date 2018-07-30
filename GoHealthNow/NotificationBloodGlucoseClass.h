//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotificationBloodGlucoseClass : NSObject
{
    NSString *stringNotificationIndex;
    NSString *stringTime;
    NSString *stringMeal;
    NSString *stringNotificationMealType;
    NSString *uuidString;
}

@property (nonatomic) NSString *stringNotificationIndex;
@property (nonatomic) NSString *stringTime;
@property (nonatomic) NSString *stringMeal;
@property (nonatomic) NSString *stringNotificationMealType;
@property (nonatomic) NSString *uuidString;

@property (nonatomic) NSString *tempCompliance;
@property (nonatomic) NSString *tempTotalCount;

@property FMDatabase *database;
@property FMResultSet *results;

+(NotificationBloodGlucoseClass *)getInstance;

-(void)addReminderMeal:(NSString *)meal;
-(void)addReminderTime:(NSString *)time;
-(void)addReminderUuid:(NSString *)uuid;

-(void)addNotificationToDatabase:(NotificationBloodGlucoseClass *)reminder andIndexOfMealType:(int)indexOfMealType;
-(NSString *)getNotificationBloodGlucoseComplianceRate;
-(void)deleteNotificationFromDatabase:(NSString *)stringID;
-(void)addOneToReminderCountSkipForBloodGlucoseCompliance:(int)reminderID;
-(NSString *)getNotificationBloodGlucoseCompliance;
-(NSString *)getNotificationBloodGlucoseTotalCount;
-(NSArray *)getAllBloodGlucoseNotificationsFromDatabase;
    
@end
