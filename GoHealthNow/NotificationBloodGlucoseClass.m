//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "NotificationBloodGlucoseClass.h"
#import "FMDatabase.h"
#import "FMResultSet.h"
#import "FMDatabaseAdditions.h"
#import "DBHelper.h"
#import "User.h"
#import "LocalNotificationAssistant.h"
#import "GGUtils.h"
#import "NotificationRecord.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation NotificationBloodGlucoseClass

@synthesize stringMeal, stringTime, database, results, stringNotificationIndex, tempCompliance, tempTotalCount, stringNotificationMealType, uuidString;


static NotificationBloodGlucoseClass *singletonInstance;

+(NotificationBloodGlucoseClass *)getInstance
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

-(void)addReminderMeal:(NSString *)meal{
    stringMeal = meal;
}

-(void)addNotificationIndex:(NSString *)notificationIndex{
    stringNotificationIndex = notificationIndex;
}

-(void)addNotificationMealType:(NSString *)notificationMealType{
    stringNotificationMealType = notificationMealType;
}

-(NSString *)stringNotificationMealType {
    return stringNotificationMealType;
}

-(NSString *)stringMeal {
    return stringMeal;
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
    
    if(![database open])
    {
        [database open];
    }
    
    [database executeUpdateWithFormat:@"create table if not exists NotificationBloodGlucoseRecord (indexID integer PRIMARY KEY AUTOINCREMENT NOT NULL, mealType char(30) NOT NULL, notificationFrequency char(15) DEFAULT('Daily'), notificationTime char(25) NOT NULL, notificationCreationDate float(30), notificationUpdateDate float(10), uuid char(50), skipCount float(10) DEFAULT(0));"];
}

-(NSArray *)getAllBloodGlucoseNotificationsFromDatabase{
    
    [self openNotificationTable];
    results = [database executeQueryWithFormat:@"SELECT indexID, mealType, notificationTime FROM NotificationBloodGlucoseRecord"];
    
    
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];

    while([results next])
    {
        NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
        
        [returnDictionary setObject:[results stringForColumn:@"indexID"] forKey:@"indexID"];
        [returnDictionary setObject:[results stringForColumn:@"mealType"] forKey:@"mealType"];
        [returnDictionary setObject:[results stringForColumn:@"notificationTime"] forKey:@"notificationTime"];
        [returnDictionary setObject:[self addSortNotificationDate:[results stringForColumn:@"notificationTime"]] forKey:@"sortByTime"];
        [returnDictionary setObject:@"BloodGlucose" forKey:@"NotfiType"];
         
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

-(void)addNotificationToDatabase:(NotificationBloodGlucoseClass *)reminder andIndexOfMealType:(int)indexOfMealType{
    
    [self openNotificationTable];
    [database executeUpdateWithFormat:@"INSERT INTO NotificationBloodGlucoseRecord (mealType, notificationTime, notificationCreationDate, notificationUpdateDate, uuid) VALUES (%@, %@, %@, %@, %@)",reminder.stringMeal, reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], [NSNumber numberWithInt:0], reminder.uuidString];
    long long lastId = [database lastInsertRowId];
    [database close];
    
    [self scheduleLocalNotificationWithReminder:reminder andWithIndexID:lastId];
    
    /////////////////////UPLOAD TO SERVER BELOW///////////////////////////////////////////////////////
    
    dispatch_promise(^{
        NotificationRecord *record = [[NotificationRecord alloc] init];
        record.reminderType = [NSNumber numberWithInteger:1];
        record.reminderTime = reminder.stringTime;
        record.repeatType = [NSNumber numberWithInteger:1];
        record.uuid = reminder.uuidString;
        record.glucoseType = [NSNumber numberWithInt:indexOfMealType];
        
        [record saveBG];
        
    });
    
}

-(void)updateNotificationToDatabase:(NotificationBloodGlucoseClass *)reminder{

    [self openNotificationTable];
    
    [database executeUpdateWithFormat:@"UPDATE NotificationBloodGlucoseRecord SET mealType=%@, notificationTime=%@, notificationUpdateDate=%@ WHERE indexId=%ld", reminder.stringMeal, reminder.stringTime, [NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]], (long)[reminder.stringNotificationIndex integerValue]];
    [database close];

}


-(void)deleteNotificationFromDatabase:(NSString *)stringID{
    
    [self openNotificationTable];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
        
        results = [database executeQueryWithFormat:@"SELECT uuid FROM NotificationBloodGlucoseRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        
        
        while([results next])
        {
            
            NSArray *uuidToDeleteArray = [[NSArray alloc] initWithObjects:[results stringForColumn:@"uuid"], nil];
            
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeDeliveredNotificationsWithIdentifiers:uuidToDeleteArray];
            [center removePendingNotificationRequestsWithIdentifiers:uuidToDeleteArray];
        }
        
        [database executeUpdateWithFormat:@"DELETE FROM NotificationBloodGlucoseRecord WHERE indexId=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationBloodGlucoseRecord"];
        
        [database close];
        
    }else{
    
        [database executeUpdateWithFormat:@"DELETE FROM NotificationBloodGlucoseRecord WHERE indexID=%ld", (long)[stringID integerValue]];
        [database executeQuery:@"VACUUM NotificationBloodGlucoseRecord"];
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

-(void)scheduleLocalNotificationWithReminder:(NotificationBloodGlucoseClass *)reminder andWithIndexID:(long long)indexID{
    
    LocalNotificationAssistant *localNotif = [LocalNotificationAssistant getInstance];
    [localNotif askForNotificationPermission];
    
    [localNotif addBloodGlucoseLocalNotificationWithFireDate:[self createDateReminder:reminder.stringTime]
                                                alertMessage:[self createAlertMessage:reminder.stringMeal]
                                              repeatInterval:NSCalendarUnitDay
                                                 andUserInfo:[self createDictionaryForReminder:[NSString stringWithFormat:@"%lld", indexID] mealType:reminder.stringMeal uuid:reminder.uuidString]
                                                    withUuid:reminder.uuidString];
    
}


-(NSString *)getNotificationBloodGlucoseCompliance{
    
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationBloodGlucoseRecord"]){
        results = [database executeQueryWithFormat:@"SELECT SUM(skipCount) AS compliance FROM NotificationBloodGlucoseRecord"];
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

-(NSString *)getNotificationBloodGlucoseTotalCount {
    [self openNotificationTable];
    
    if ([database tableExists:@"NotificationBloodGlucoseRecord"]){
        results = [database executeQueryWithFormat:@"SELECT COUNT(mealType) AS count FROM NotificationBloodGlucoseRecord"];
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

-(NSString *)getNotificationBloodGlucoseComplianceRate {
    NSString *skipNumStr = [self getNotificationBloodGlucoseCompliance];
    NSString *rt = @"100";
    int skipNum = [skipNumStr intValue];
    int totalNum = 0;
    if (skipNum == 0)
        return rt;
    
    [self openNotificationTable];
    results = [database executeQueryWithFormat:@"SELECT datetime(notificationCreationDate, 'unixepoch'), notificationTime FROM NotificationBloodGlucoseRecord"];
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

-(void)addOneToReminderCountSkipForBloodGlucoseCompliance:(int)reminderID{
    [self openNotificationTable];
        [database executeUpdateWithFormat:@"UPDATE NotificationBloodGlucoseRecord SET skipCount = skipCount + 1 WHERE indexId = %d", reminderID];
    [database close];
};


-(NSMutableDictionary *)createDictionaryForReminder:(NSString *)reminderID mealType:(NSString *)mealType uuid:(NSString *)uuid{

    NSMutableDictionary *reminderDictionary = [[NSMutableDictionary alloc]initWithCapacity:2];
    [reminderDictionary setObject:@"BloodGlucose" forKey:@"reminderType"];
    [reminderDictionary setObject:reminderID forKey:@"reminderID"];
    [reminderDictionary setObject:mealType forKey:@"mealType"];
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
    
    NSString *alertMessageString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Blood Glucose Reminder: %@"], mealTypeName];
    
    return alertMessageString;
}

@end
