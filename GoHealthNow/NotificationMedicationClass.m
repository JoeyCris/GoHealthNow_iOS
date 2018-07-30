//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "NotificationMedicationClass.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "DBHelper.h"
#import "User.h"
#import "LocalNotificationAssistant.h"
#import "MedicationRecord.h"
#import "GGUtils.h"
#import "NotificationRecord.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation NotificationMedicationClass

@synthesize arrayDrug, stringDosage, stringTime, database, results, stringNotificationIndex, tempMeasurement, uuidString;
@synthesize tempDose, tempID, tempName, tempCompliance, tempTotalCount, stringComingFromWhere, medicationType, tempMedicineID;


static NotificationMedicationClass *singletonInstance;

+(NotificationMedicationClass *)getInstance
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
        arrayDrug = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return self;
}

-(void)addReminderUuid:(NSString *)uuid{
    uuidString = uuid;
}

-(void)addReminderDrug:(NSString *)drug{
    arrayDrug = [[NSMutableArray alloc] initWithCapacity:1];
    [arrayDrug addObject:drug];
}

-(void)addReminderDosage:(NSString *)dosage{
    stringDosage = dosage;
}

-(void)addReminderTime:(NSString *)time{
     stringTime = time;
}

-(void)addNotificationIndex:(NSString *)notificationIndex{
    stringNotificationIndex = notificationIndex;
}

-(void)comingFromWhere:(NSString *)comingFromWhere{
    stringComingFromWhere = comingFromWhere;
}

-(NSString *)stringComingFromWhere{
    return stringComingFromWhere;
}

-(NSMutableArray *)arrayDrug {
    return arrayDrug;
}

-(NSString *)stringDosage {
    return stringDosage;
}

-(NSString *)stringTime {
    return stringTime;
}

-(NSString *)stringNotificationIndex {
    return stringNotificationIndex;
}

-(NSString *)uuidString {
    return uuidString;
}

#pragma mark - Database CRUD
-(void)openNotificationTable{

    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    [database open];
    
    [database executeUpdateWithFormat:@"create table if not exists NotificationMedicineRecord (indexId integer PRIMARY KEY AUTOINCREMENT NOT NULL, drugID char(6) NOT NULL, drugName char(60) NOT NULL, drugDose char(10) NOT NULL, notificationTime char(25) NOT NULL, notificationFrequency char(15) DEFAULT('Daily'), notificationCreationDate float(30), notificationUpdateDate float(10), uuid char(50), skipCount float(10) DEFAULT(0));"];
    
   // [database close];
}

-(NSArray *)getAllNotificationsFromDatabase{
    
    [self openNotificationTable];
    
    results = [database executeQueryWithFormat:@"SELECT indexID, drugID, drugName, drugDose, uuid, notificationTime FROM NotificationMedicineRecord"];
    
    
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];

    while([results next])
    {
        NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
        
        [returnDictionary setObject:[results stringForColumn:@"indexID"] forKey:@"indexID"];
        [returnDictionary setObject:[results stringForColumn:@"drugID"] forKey:@"drugID"];
        [returnDictionary setObject:[results stringForColumn:@"drugName"] forKey:@"drugName"];
        [returnDictionary setObject:[results stringForColumn:@"drugDose"] forKey:@"drugDose"];
        [returnDictionary setObject:[results stringForColumn:@"notificationTime"] forKey:@"notificationTime"];
        [returnDictionary setObject:[self addSortNotificationDate:[results stringForColumn:@"notificationTime"]] forKey:@"sortByTime"];
        [returnDictionary setObject:@"Medication" forKey:@"NotfiType"];
        [returnDictionary setObject:[results stringForColumn:@"uuid"] forKey:@"uuid"];
        
        [returnArray addObject:returnDictionary];
    }
    
    [database close];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"sortByTime" ascending:YES];
    NSArray *sortedArray = [returnArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

         return sortedArray;
}

-(NSString *)getLastMedication{
 
 /*/   [self openNotificationTable];
    
    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    [database open];
    
    if ([database tableExists:@"MedicationRecord"]) {
        results = [database executeQueryWithFormat:@"SELECT medicationId as drugID, dose, measurement, recordedTime FROM MedicationRecord WHERE rowid = (SELECT max(rowid) FROM MedicationRecord)"];

        while([results next])
        {
            tempID          = [results stringForColumn:@"drugId"];
            tempDose        = [results stringForColumn:@"dose"];
            tempMeasurement = [results stringForColumn:@"measurement"];
        }
    }
    
    [database close];
    
    for (NSDictionary *record in [MedicationRecord getAllMedications]) {
        NSString *medicationName = [record objectForKey:@"_ID"];
        if ([tempID isEqualToString:medicationName]) {
            tempName = [NSString stringWithFormat:@"%@ - %@ %@", [record objectForKey:@"_Name"], tempDose, tempMeasurement];
        }
    }
    
    if ([tempName length] < 1) {
        tempName = @"";
    }
    */
    return  nil;  //tempName;
    
}

-(NSDate *)addSortNotificationDate:(NSString *)stringNotificationTime{
    
    NSDate *currentDate          = [NSDate date];
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
    
    [components setMonth:9];
    [components setDay:29];
    [components setYear:2015];
    
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mma"];
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld %@", (long)[components day], (long)[components month], (long)[components year], stringNotificationTime];
    NSDate *sortDate = [formatter dateFromString:dateStr];

    return sortDate;
}

-(void)addNotificationToDatabase:(NotificationMedicationClass *)reminder withMeasurment:(NSString *)measurment andDosage:(NSString *)dosage{
    
    [self openNotificationTable];
    [database executeUpdateWithFormat:@"INSERT INTO NotificationMedicineRecord (drugID, drugName, drugDose, notificationTime, notificationCreationDate, notificationUpdateDate, uuid) VALUES (%@, %@, %@, %@, %@, %@, %@)", [reminder.arrayDrug objectAtIndex:0][@"_ID"], [reminder.arrayDrug objectAtIndex:0][@"_Name"], reminder.stringDosage, reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:0], reminder.uuidString];
    
    long long lastId = [database lastInsertRowId];
    [database close];
    
    [self scheduleLocalNotificationWithReminder:reminder andWithIndexID:lastId];
    
    /////////////////////UPLOAD TO SERVER BELOW///////////////////////////////////////////////////////
    
    if ([[[reminder.arrayDrug objectAtIndex:0][@"_ID"] substringToIndex:1] isEqualToString:@"c"]) {
        medicationType = [NSNumber numberWithInteger:0];
        tempMedicineID = @"";
    }else{
        medicationType = [NSNumber numberWithInteger:1];
        tempMedicineID = [reminder.arrayDrug objectAtIndex:0][@"_ID"];
    }
    
    
    
    NSString *tempDosage = reminder.stringDosage;
    tempDosage = [tempDosage stringByReplacingOccurrencesOfString:measurment withString:@""];
    tempDosage = [tempDosage stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self uploadReminderToServerWithReminderTime:reminder.stringTime uuid:reminder.uuidString medicineDose:tempDosage medicineUnit:measurment medicinID:tempMedicineID medicineName:[reminder.arrayDrug objectAtIndex:0][@"_Name"] medicineType:medicationType];
}

-(void)uploadReminderToServerWithReminderTime:(NSString *)reminderTime uuid:(NSString *)uuid medicineDose:(NSString *)medicineDose medicineUnit:(NSString *)medicineUnit medicinID:(NSString *)medicineID medicineName:(NSString *)medicineName medicineType:(NSNumber *)medicineType {
    
    dispatch_promise(^{
        NotificationRecord *record = [[NotificationRecord alloc] init];
        record.reminderType = [NSNumber numberWithInteger:0];
        record.reminderTime = reminderTime;
        record.repeatType = [NSNumber numberWithInteger:1];
        
        record.medicineDose = medicineDose;
        record.medicineUnit = medicineUnit;
        record.medicineID = medicineID;
        record.medicineName = medicineName;
        record.medicineType = medicineType;
        
        record.uuid = uuid;
        
        [record saveMedication];
    });
    
}

-(void)updateNotificationToDatabase:(NotificationMedicationClass *)reminder{
    
    [self deleteLocalNotificationWithIndexID:(long)[reminder.stringNotificationIndex integerValue]];

    [self openNotificationTable];
    
    [database executeUpdateWithFormat:@"UPDATE NotificationMedicineRecord SET drugID=%@, drugName=%@, drugDose=%@, notificationTime=%@, notificationUpdateDate=%@ WHERE indexId=%ld",  [reminder.arrayDrug objectAtIndex:0][@"_ID"], [reminder.arrayDrug objectAtIndex:0][@"_Name"], reminder.stringDosage, reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], (long)[reminder.stringNotificationIndex integerValue]];
    [database close];
    
    [self scheduleLocalNotificationWithReminder:reminder andWithIndexID:(long)[reminder.stringNotificationIndex integerValue]];
    [[LocalNotificationAssistant getInstance]logAllNotificationDescriptions];
}


-(void)deleteNotificationFromDatabase:(NSString *)stringID{
    
    [self openNotificationTable];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        results = [database executeQueryWithFormat:@"SELECT uuid FROM NotificationMedicineRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        
    
        while([results next])
        {
        
            NSArray *uuidToDeleteArray = [[NSArray alloc] initWithObjects:[results stringForColumn:@"uuid"], nil];
        
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeDeliveredNotificationsWithIdentifiers:uuidToDeleteArray];
            [center removePendingNotificationRequestsWithIdentifiers:uuidToDeleteArray];
        }
        
        [database executeUpdateWithFormat:@"DELETE FROM NotificationMedicineRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationMedicineRecord"];

        [database close];
        
    }else{
        [database executeUpdateWithFormat:@"DELETE FROM NotificationMedicineRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationMedicineRecord"];
        [database close];
        
        [self deleteLocalNotificationWithIndexID:(long)[stringID integerValue]];
    }

}


#pragma mark - LocalNotification CRUD
-(void)deleteLocalNotificationWithIndexID:(long long)indexID{
    
    UIApplication *app = [UIApplication sharedApplication];
    NSArray *eventArray = [app scheduledLocalNotifications];
    for (int i=0; i<[eventArray count]; i++)
    {
        UILocalNotification* oneEvent = [eventArray objectAtIndex:i];
        NSDictionary *userInfoCurrent = oneEvent.userInfo;
        NSString *uid=[NSString stringWithFormat:@"%@",[userInfoCurrent valueForKey:@"reminderID"]];
        if ([uid isEqualToString:[NSString stringWithFormat:@"%lld",indexID]])
        {
            [app cancelLocalNotification:oneEvent];
            break;
        }
    }
}


-(void)scheduleLocalNotificationWithReminder:(NotificationMedicationClass *)reminder andWithIndexID:(long long)indexID{
    
    LocalNotificationAssistant *localNotif = [LocalNotificationAssistant getInstance];
    [localNotif askForNotificationPermission];
    
    [localNotif addLocalNotificationWithFireDate:[self createDateReminder:reminder.stringTime]
                                    alertMessage:[self createAlertMessage:[reminder.arrayDrug objectAtIndex:0][@"_Name"] drugDose:reminder.stringDosage]
                                  repeatInterval:NSCalendarUnitDay
                                     andUserInfo:[self createDictionaryForReminder:[NSString stringWithFormat:@"%lld", indexID] drugID:[reminder.arrayDrug objectAtIndex:0][@"_ID"] dosage:reminder.stringDosage drugName:[reminder.arrayDrug objectAtIndex:0][@"_Name"] uuid:reminder.uuidString]                                        withUuid:reminder.uuidString];
    
}

-(NSString *)getNotificationMedicationCompliance{
    
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationMedicineRecord"]){
        results = [database executeQueryWithFormat:@"SELECT SUM(skipCount) AS compliance FROM NotificationMedicineRecord"];
    }else{
       return @"0";
    }
        
        
    while([results next])
    {
        tempCompliance = [results stringForColumn:@"compliance"];
    }
    
    [database close];
    
    if ([tempCompliance length] > 0) {
        tempCompliance = [NSString stringWithString:[tempCompliance substringToIndex:[tempCompliance rangeOfString:@"."].location]];
    }else{
        return @"0";
    }
    
    
    return tempCompliance;
}

-(NSString *)getNotificationMedicationComplianceRate {
    NSString *skipNumStr = [self getNotificationMedicationCompliance];
    NSString *rt = @"100";
    int skipNum = [skipNumStr intValue];
    int totalNum = 0;
    if (skipNum == 0)
        return rt;
    
    [self openNotificationTable];
    results = [database executeQueryWithFormat:@"SELECT datetime(notificationCreationDate, 'unixepoch'), notificationTime FROM NotificationMedicineRecord"];
    while([results next])
    {
        NSString *alarmTimeStr = [results stringForColumn:@"notificationTime"];
        NSString *creationDateStr = [results stringForColumn:@"datetime(notificationCreationDate, 'unixepoch')"];
        NSDate *creationDate = [GGUtils dateFromSQLString:creationDateStr];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        NSDateComponents *d1 = [cal components:unitFlags fromDate:creationDate];
        
        NSDate *alarmTime = [self createDateReminder:alarmTimeStr];
        
        unsigned int unitFlagsForAlarm = NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *d2 = [cal components:unitFlagsForAlarm fromDate:alarmTime];
        
        if ([d1 hour] < [d2 hour]) {
            totalNum++;
        }
        else if ([d1 hour] == [d2 hour]) {
            if ([d1 minute] < [d2 minute]) {
                totalNum++;
            }
        }
        
        [d1 setHour:[d2 hour]];
        [d1 setMinute:[d2 minute]];
        
        totalNum += [[GGUtils daysBetweenTwoDate:[cal dateFromComponents:d1] andDate2:[NSDate date]] intValue];
    }
    
    [database close];
    
    //NSLog(@"total notifi num: %d\n skip: %d\n", totalNum, skipNum);
    
    rt = [NSString stringWithFormat:@"%.0f", 100.0*(totalNum - skipNum) / totalNum];
    
    if (totalNum-skipNum < 0)
        rt = @"0";
    
    return rt;
}

-(NSString *)getNotificationMedicationTotalCount {
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationMedicineRecord"]){
        results = [database executeQueryWithFormat:@"SELECT COUNT(drugID) AS count FROM NotificationMedicineRecord"];
    }else{
        return @"0";
    }
    
    
    while([results next])
    {
        tempTotalCount = [results stringForColumn:@"count"];
    }
    
    [database close];
    
    if ([tempTotalCount length] <= 0) {
        return @"0";
    }
    
    return tempTotalCount;
}

-(void)addOneToReminderCountSkipForMedicationCompliance:(int)reminderID{
    [self openNotificationTable];
        [database executeUpdateWithFormat:@"UPDATE NotificationMedicineRecord SET skipCount = skipCount + 1 WHERE indexId = %d", reminderID];
    [database close];
};


-(NSMutableDictionary *)createDictionaryForReminder:(NSString *)reminderID drugID:(NSString *)drugID dosage:(NSString *)dosage drugName:(NSString *)drugName uuid:(NSString *)uuid{
    
    NSArray *substrings = [dosage componentsSeparatedByString:@" "];
    NSString *correctDosage = [substrings objectAtIndex:0];
    NSString *correctMeasurement = [substrings objectAtIndex:1];
    
    NSMutableDictionary *reminderDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
    [reminderDictionary setObject:@"Medication" forKey:@"reminderType"];
    [reminderDictionary setObject:reminderID forKey:@"reminderID"];
    [reminderDictionary setObject:drugID forKey:@"drugID"];
    [reminderDictionary setObject:correctDosage  forKey:@"dosage"];
    [reminderDictionary setObject:correctMeasurement forKey:@"measurement"];
    [reminderDictionary setObject:drugName forKey:@"drugName"];
    [reminderDictionary setObject:[[User sharedModel] userId] forKey:@"userID"];
    [reminderDictionary setObject:uuid forKey:@"uuid"];
    
    return reminderDictionary;
}

-(NSDate *)createDateReminder:(NSString *)notificationTime{
    
    NSDate *currentDate          = [NSDate date];
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
   
    [components month];
    [components day];
    [components year];
    
    NSDateFormatter * formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mma"];
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld %@", (long)[components day], (long)[components month], (long)[components year], notificationTime];

    NSDate *fireDate = [formatter dateFromString:dateStr];
    
    return fireDate;
}


-(NSString *)createAlertMessage:(NSString *)drugName drugDose:(NSString *)drugDose{
    
    NSString *alertMessageString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Medication Reminder: %@ - %@"], drugName, drugDose];
    
    return alertMessageString;
}

@end
