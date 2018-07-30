//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "NotificationBloodPressureClass.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "DBHelper.h"
#import "User.h"
#import "LocalNotificationAssistant.h"
#import "GGUtils.h"
#import "NotificationRecord.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation NotificationBloodPressureClass

@synthesize stringTime, database, results, stringNotificationIndex, tempCompliance, stringComingFromWhere, stringGoingToBloodPressureType, tempTotalCount, uuidString;


static NotificationBloodPressureClass *singletonInstance;

+(NotificationBloodPressureClass *)getInstance
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

-(void)addReminderUuid:(NSString *)uuid{
    uuidString = uuid;
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

-(void)goingToBloodPressureType:(NSString *)goingToBloodPressureType{
    stringGoingToBloodPressureType = goingToBloodPressureType;
}

-(NSString *)stringGoingToBloodPressureType{
    return stringGoingToBloodPressureType;
}

-(NSString *)uuidString {
    return uuidString;
}


//////

-(NSString *)stringTime {
    return stringTime;
}

-(NSString *)stringNotificationIndex {
    return stringNotificationIndex;
}

#pragma mark - Database CRUD
-(void)openNotificationTable{
    
    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    [database executeUpdateWithFormat:@"create table if not exists NotificationBloodPressureRecord (indexID integer PRIMARY KEY AUTOINCREMENT NOT NULL,  notificationTime char(25) NOT NULL, notificationFrequency char(15) DEFAULT('Daily'), notificationCreationDate float(30), notificationUpdateDate float(10), uuid char(50), skipCount float(10) DEFAULT(0));"];
}

-(NSArray *)getAllBloodPressureNotificationsFromDatabase{
    
    [self openNotificationTable];
    results = [database executeQueryWithFormat:@"SELECT indexID, notificationTime FROM NotificationBloodPressureRecord"];
    
    
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];

    while([results next])
    {
        NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
        
        [returnDictionary setObject:[results stringForColumn:@"indexID"] forKey:@"indexID"];
        [returnDictionary setObject:[results stringForColumn:@"notificationTime"] forKey:@"notificationTime"];
        [returnDictionary setObject:[self addSortNotificationDate:[results stringForColumn:@"notificationTime"]] forKey:@"sortByTime"];
        [returnDictionary setObject:@"BloodPressure" forKey:@"NotfiType"];
         
        [returnArray addObject:returnDictionary];
    }
    
    [database close];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"sortByTime" ascending:YES];
    NSArray *sortedArray = [returnArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];

         return sortedArray;
}

-(NSDate *)addSortNotificationDate:(NSString *)stringNotificationTime{
    
    NSDate *currentDate          = [NSDate date];
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
    
    [components setMonth:9];
    [components setDay:29];
    [components setYear:2015];
    
    NSDateFormatter * formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mma"];
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld %@", (long)[components day], (long)[components month], (long)[components year], stringNotificationTime];
    NSDate *sortDate = [formatter dateFromString:dateStr];

    return sortDate;
}

-(void)addNotificationToDatabase:(NotificationBloodPressureClass *)reminder{
    
    [self openNotificationTable];
    [database executeUpdateWithFormat:@"INSERT INTO NotificationBloodPressureRecord (notificationTime, notificationCreationDate, notificationUpdateDate, uuid) VALUES (%@, %@, %@, %@)", reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:0], reminder.uuidString];
    
    long long lastId = [database lastInsertRowId];
    [database close];
    
    [self scheduleLocalNotificationWithReminder:reminder andWithIndexID:lastId];
    
    dispatch_promise(^{
        NotificationRecord *record = [[NotificationRecord alloc] init];
        record.reminderType = [NSNumber numberWithInteger:4];
        record.reminderTime = reminder.stringTime;
        record.repeatType = [NSNumber numberWithInteger:1];
        record.uuid = reminder.uuidString;
        
        [record saveBloodPressure];
        
    });
}

-(void)updateNotificationToDatabase:(NotificationBloodPressureClass *)reminder{

    [self openNotificationTable];
    
    [database executeUpdateWithFormat:@"UPDATE NotificationBloodPressureRecord SET notificationTime=%@, notificationUpdateDate=%@ WHERE indexId=%ld", reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], (long)[reminder.stringNotificationIndex integerValue]];
    [database close];
}

-(void)deleteNotificationFromDatabase:(NSString *)stringID{
    
    [self openNotificationTable];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        results = [database executeQueryWithFormat:@"SELECT uuid FROM NotificationBloodPressureRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        
        
        while([results next])
        {
            
            NSArray *uuidToDeleteArray = [[NSArray alloc] initWithObjects:[results stringForColumn:@"uuid"], nil];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeDeliveredNotificationsWithIdentifiers:uuidToDeleteArray];
            [center removePendingNotificationRequestsWithIdentifiers:uuidToDeleteArray];
        }
        
        [database executeUpdateWithFormat:@"DELETE FROM NotificationBloodPressureRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationBloodPressureRecord"];
        
        [database close];
        
    }else{
    
        [database executeUpdateWithFormat:@"DELETE FROM NotificationBloodPressureRecord WHERE indexID=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationBloodPressureRecord"];
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

-(void)scheduleLocalNotificationWithReminder:(NotificationBloodPressureClass *)reminder andWithIndexID:(long long)indexID{
    
    LocalNotificationAssistant *localNotif = [LocalNotificationAssistant getInstance];
    [localNotif askForNotificationPermission];
    
    [localNotif addBloodPressureLocalNotificationWithFireDate:[self createDateReminder:reminder.stringTime]
                                        alertMessage:[LocalizationManager getStringFromStrId:@"Blood Pressure Reminder"]
                                      repeatInterval:NSCalendarUnitDay
                                             andUserInfo:[self createDictionaryForReminder:[NSString stringWithFormat:@"%lld", indexID] uuid:reminder.uuidString]
                                                withUuid:reminder.uuidString];
}


-(NSString *)getNotificationBloodPressureCompliance{
    
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationBloodPressureRecord"]){
        results = [database executeQueryWithFormat:@"SELECT SUM(skipCount) AS compliance FROM NotificationBloodPressureRecord"];
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

-(NSString *)getNotificationBloodPressureComplianceRate {
    NSString *skipNumStr = [self getNotificationBloodPressureCompliance];
    NSString *rt = @"100";
    int skipNum = [skipNumStr intValue];
    int totalNum = 0;
    if (skipNum == 0)
        return rt;
    
    [self openNotificationTable];
    results = [database executeQueryWithFormat:@"SELECT datetime(notificationCreationDate, 'unixepoch'), notificationTime FROM NotificationBloodPressureRecord"];
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

-(NSString *)getNotificationBloodPressureTotalCount {
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationBloodPressureRecord"]){
        results = [database executeQueryWithFormat:@"SELECT COUNT(notificationTime) AS count FROM NotificationBloodPressureRecord"];
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


-(void)addOneToReminderCountSkipForBloodPressureCompliance:(int)reminderID{
    [self openNotificationTable];
        [database executeUpdateWithFormat:@"UPDATE NotificationBloodPressureRecord SET skipCount = skipCount + 1 WHERE indexId = %d", reminderID];
    [database close];
};


-(NSMutableDictionary *)createDictionaryForReminder:(NSString *)reminderID uuid:(NSString *)uuid{

    NSMutableDictionary *reminderDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
    [reminderDictionary setObject:@"BloodPressure" forKey:@"reminderType"];
    [reminderDictionary setObject:reminderID forKey:@"reminderID"];
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


-(NSString *)createAlertMessage:(NSString *)mealTypeName{
    
    NSString *alertMessageString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Blood Pressure Reminder: %@"], mealTypeName];
    
    return alertMessageString;
}

@end
