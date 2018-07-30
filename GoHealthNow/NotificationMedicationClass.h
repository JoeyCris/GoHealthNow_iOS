//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface NotificationMedicationClass : NSObject
{
    NSMutableArray *arrayDrug;
    NSString *stringDosage;
    NSString *stringTime;
    NSString *stringNotificationIndex;
    NSString *stringComingFromWhere;
    NSString *uuidString;
    
}

@property (nonatomic) NSMutableArray *arrayDrug;
@property (nonatomic) NSString *stringDosage;
@property (nonatomic) NSString *stringTime;
@property (nonatomic) NSString *stringNotificationIndex;
@property (nonatomic) NSString *uuidString;

@property (nonatomic) NSString *tempID;
@property (nonatomic) NSString *tempName;
@property (nonatomic) NSString *tempDose;
@property (nonatomic) NSString *tempMeasurement;

@property (nonatomic) NSString *tempCompliance;
@property (nonatomic) NSString *tempTotalCount;
@property (nonatomic) NSString *stringComingFromWhere;

@property NSNumber *medicationType;
@property NSString *tempMedicineID;

@property (strong) FMDatabase *database;
@property (strong) FMResultSet *results;

+(NotificationMedicationClass *)getInstance;

-(void)addReminderDrug:(NSMutableArray *)drug;
-(void)addReminderDosage:(NSString *)dosage;
-(void)addReminderTime:(NSString *)time;
-(void)comingFromWhere:(NSString *)comingFromWhere;
-(void)addNotificationIndex:(NSString *)notificationIndex;
-(void)addOneToReminderCountSkipForMedicationCompliance:(int)reminderID;
-(void)addReminderUuid:(NSString *)uuid;

-(void)openNotificationTable;
-(NSArray *)getAllNotificationsFromDatabase;
-(void)addNotificationToDatabase:(NotificationMedicationClass *)reminder withMeasurment:(NSString *)measurment andDosage:(NSString *)dosage;
-(void)updateNotificationToDatabase:(NotificationMedicationClass *)reminder;
-(void)deleteNotificationFromDatabase:(NSString *)stringID;

-(NSArray *)getLastMedication;

-(NSString *)getNotificationMedicationCompliance;
-(NSString *)getNotificationMedicationComplianceRate;
-(NSString *)getNotificationMedicationTotalCount;
-(NSDate *)createDateReminder:(NSString *)notificationTime;
-(NSString *)createAlertMessage:(NSString *)drugName drugDose:(NSString *)drugDose;
    
@end
