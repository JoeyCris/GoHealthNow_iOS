//
//  Exercise.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "ExerciseRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "DBHelper.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"

NSString* const EXERCISERECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Exercise_Records>  %@ </Exercise_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

@interface ExerciseRecord()

@property (nonatomic, retain)           NSString* uploadingVersion;

@end

@implementation ExerciseRecord

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(ExerciseRecord *record in records) {
        [DBHelper insertToDB: record];
        [xmlRecords appendString:[record toXML]];
    }
    
    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:
            [NSString stringWithFormat:EXERCISERECORD_UPLOADING,
             user.userId,
             xmlRecords,
             [GGUtils stringFromDate:[NSDate date]]
             ]];
}

-(id)init {
    
    if (self = [super init]){
        self.uploadingVersion = @"0";
    }
    
    return self;
}

- (PMKPromise *)save {
    
    [DBHelper insertToDB: self];
    
    User* user = [User sharedModel];

    [user updatePointsByAction: [[self class] description]];
    
    NSString* xmlRecord = [NSString stringWithFormat:EXERCISERECORD_UPLOADING,
                           user.userId,
                           [self toXML],
                           [GGUtils stringFromDate:[NSDate date]]];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

- (PMKPromise *)saveToServer {
    
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:EXERCISERECORD_UPLOADING,
                           user.userId,
                           [self toXML],
                           [GGUtils stringFromDate:[NSDate date]]];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}


-(NSString*)toXML {
    
    if ([self.note length] < 1) {
        self.note = @"";
    }
    
    return [NSString stringWithFormat:@"<Exercise_Record> \
            <Minutes>%@</Minutes> \
            <Type>%@</Type> \
            <ExerciseRecordType>%@</ExerciseRecordType>\
            <StepCount>%@</StepCount>\
            <Interval>0</Interval> \
            <ExerciseStartingTime>%@</ExerciseStartingTime> \
            <RecordedTime>%@</RecordedTime> \
            <Calories>%@</Calories> \
            <UploadingVersion>%@</UploadingVersion> \
            <Uuid>%@</Uuid>\
            <Note>%@</Note>\
            </Exercise_Record> ",
            self.minutes,
            [ExerciseRecord getTypeDescription:self.type],
            self.entryType, self.steps,[GGUtils stringFromDate:self.recordedTime],
            [GGUtils stringFromDate:self.recordedTime],
            self.calories, self.uploadingVersion, self.uuid, self.note];
    
}

+(NSString*)getTypeDescription: (ExerciseType) type {
    switch (type) {
        case ExerciseTypeLight:
            return @"Light";//[LocalizationManager getStringFromStrId:@"Light"];
            break;
        case ExerciseTypeModerate:
            return @"Moderate";//[LocalizationManager getStringFromStrId:@"Moderate"];
            break;
        case ExerciseTypeVigorous:
            return @"Vigorous";//[LocalizationManager getStringFromStrId:@"Vigorous"];
            break;
        default:
            return @"Light";//[LocalizationManager getStringFromStrId:@"Light"];
            break;
    }
}

+ (PMKPromise *)calculateTodayCalories {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSString* query = [NSString stringWithFormat:@"select type, sum(calories) from ExerciseRecord where recordedTime >= %f group by type;", [[GGUtils dateOfMidNight] timeIntervalSince1970]];
        
        NSArray* results = [ExerciseRecord querySumData:query];
        
        fulfill(results);

    }];
}

+(NSDictionary *)totalMinsWeek{
   
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:2];
    NSDictionary *currentWeekDateRange = [GGUtils weekDateRangeWithDate:[NSDate date]];

    NSDate *weekStartDate = currentWeekDateRange[WEEK_START_DATE_KEY];
    NSDate *weekEndDate = currentWeekDateRange[WEEK_END_DATE_KEY];
    
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    if ([database tableExists:@"ExerciseRecord"]){
    
        NSString* query = [NSString stringWithFormat:@"select type, sum(minutes) AS MINS from ExerciseRecord where recordedTime >= %f and recordedTime <= %f group by type;", [weekStartDate     timeIntervalSince1970], [weekEndDate timeIntervalSince1970]];
            
            FMResultSet *resultSet = [database executeQuery:query];
        
        
        while([resultSet next])
        {
            int type = [resultSet intForColumn:@"type"];
            
            switch (type) {
                case 0:
                    [tempDict setObject:@([resultSet intForColumn:@"MINS"])  forKey:@"0"];
                    break;
                case 1:
                    [tempDict setObject:@([resultSet intForColumn:@"MINS"]) forKey:@"1"];
                    break;
                case 2:
                    [tempDict setObject:@([resultSet intForColumn:@"MINS"]) forKey:@"2"];
                    break;
            }
        }
        
        [database close];
    }
    
    return tempDict;
}

+ (PMKPromise *)calculateTotalMinutesFrom:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        User *user = [User sharedModel];
        FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
        
        if(![database open])
        {
            [database open];
        }
        
        if ([database tableExists:@"ExerciseRecord"]){
        
            NSString* query = [NSString stringWithFormat:@"select type, sum(minutes) from ExerciseRecord where recordedTime >= %f and recordedTime <= %f group by type;", [fromDate timeIntervalSince1970], [toDate timeIntervalSince1970]];
            
            NSArray* results = [ExerciseRecord querySumData:query];
            
            fulfill(results);
        }
        
        [database close];
        
    }];
}

+ (PMKPromise *)searchSummaryMinutes:(SummaryPeroidType) peroid fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate {
    NSMutableArray* results = [[NSMutableArray alloc] init];

    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
    
        dispatch_promise(^{
        //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
        NSString* query = [NSString stringWithFormat:@"select sum(minutes), %@ from ExerciseRecord  where type != 0 and recordedTime >= %f and recordedTime <= %f group by %@",
                           [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid],
                           [fromDate timeIntervalSince1970],
                           [toDate timeIntervalSince1970],
                           [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid]];
        
        
        sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
        
        if(stmt != NULL) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                NSNumber* minutes = [NSNumber numberWithFloat:
                                     sqlite3_column_int(stmt, 0)];
                
                NSString* dayStr = [NSString stringWithUTF8String:
                                    (const char*)sqlite3_column_text(stmt,1) ];
                
                NSDate* recordedDay = [GGUtils dateOfDay: dayStr];
                
                [results addObject:@{@"minutes": minutes, @"recordedDay": recordedDay}];
            }
            
            sqlite3_finalize(stmt);
        }
        
        fulfill(results);
        
    });

    }];
}


+ (PMKPromise *)searchDailyMinutes:(NSDate*)fromDate toDate:(NSDate*)toDate {
    
    //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            
            NSString* query = [NSString stringWithFormat:@"select sum(minutes), datetime(recordedTime, 'unixepoch') from ExerciseRecord  where type != 0 and recordedTime >= %f and recordedTime <= %f group by datetime(recordedTime, 'unixepoch')",
                               [fromDate timeIntervalSince1970], [toDate timeIntervalSince1970]];
            
            NSMutableArray* results = [[NSMutableArray alloc] init];
            sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
            
            if(stmt != NULL) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    
                    NSNumber* minutes = [NSNumber numberWithFloat:
                                         sqlite3_column_int(stmt, 0)];
                    
                    NSString* dayStr = [NSString stringWithUTF8String:
                                        (const char*)sqlite3_column_text(stmt,1) ];
                    
                    NSDate* recordedDay = [GGUtils dateFromSQLString: dayStr];
                    
                    if ([results count]!=0) {
                        if ([GGUtils isSameDayOfDate:recordedDay andDate2:[results[[results count]-1] objectForKey:@"recordedDay"]]) {
                            minutes = [NSNumber numberWithDouble:[[results[[results count]-1] objectForKey:@"minutes"] doubleValue] + [minutes doubleValue]];
                            [results removeObjectAtIndex:[results count]-1];
                        }
                    }
                    
                    [results addObject:@{@"minutes": minutes, @"recordedDay": recordedDay}];
                }
                
                sqlite3_finalize(stmt);
            }
            
            fulfill(results);
        });
    }];
    
}

/*
 
 */
+ (PMKPromise *)searchRecentExerciseWithFilter:(NSString *)filter {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            NSMutableArray *results = [[NSMutableArray alloc] init];
            NSString *query = [self sqlForQuery:filter];
            
            sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE MMM dd, yyyy"];
            
            NSString* today = [dateFormatter stringFromDate:[NSDate date]];
            
            if (stmt != NULL) {
                NSMutableDictionary *nameKeys = [[NSMutableDictionary alloc] init];
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    ExerciseRecord *record = [self createWithDBBuffer:stmt];
                    
                    NSString *category = [dateFormatter stringFromDate:record.recordedTime];
                    if ([category isEqualToString:today]) {
                        category = TIME_TODAY;
                    }
                    
                    NSNumber *index = [nameKeys objectForKey:category];
                    
                    NSMutableArray *records = nil;
                    
                    if (index == nil) {
                        records = [[NSMutableArray alloc] init];
                        [results addObject:@{
                                             MACRO_EXERCISE_CATEGORY_ATTR: category,
                                             MACRO_EXERCISE_ROWS_ATTR: records
                                             }];
                        [nameKeys setObject:[NSNumber numberWithUnsignedInteger:(results.count - 1)] forKey:category];
                    }
                    else {
                        records = [results objectAtIndex:[index unsignedIntegerValue]][MACRO_EXERCISE_ROWS_ATTR];
                    }
                    
                    [records addObject:record];
                    
                }
                
                sqlite3_finalize(stmt);
            }
            
            fulfill(results);
        });
    }];
}


+(NSArray*) querySumData:(NSString*) sql {
    NSMutableArray* results = [[NSMutableArray alloc] init];
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[sql UTF8String]];
    
    
    if(stmt != NULL) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            NSNumber* type = [NSNumber numberWithInteger: sqlite3_column_int(stmt, 0)];
            NSNumber* sum = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 1)];
            
            [results addObject:@{type: sum}];
            
            
        }
        
        sqlite3_finalize(stmt);
    }
    
    return results;
    
}
+ (PMKPromise *)calculateTodayMinutes {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
            
            NSString* query = [NSString stringWithFormat:@"select type, sum(minutes) from ExerciseRecord where recordedTime >= %f group by type;", [[GGUtils dateOfMidNight] timeIntervalSince1970]];
        
        NSArray* results = [ExerciseRecord querySumData:query];
        
        fulfill(results);
        
    }];
}


//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (minutes, calories, type, recordedTime, entryType, recordEntryTime, steps, uuid, note) values (%@, %@, %lu, %f, %@, %f, %@, %@, %@)",
                     [self class],
                     self.minutes,
                     self.calories,
                     (unsigned long)self.type,
                     [self.recordedTime timeIntervalSince1970],
                     self.entryType,
                     [self.recordEntryTime timeIntervalSince1970],
                     self.steps,
                     [GGUtils toSQLString:self.uuid],
                     [GGUtils toSQLString:self.note]];
    
    return sql;
}


+(instancetype) createWithDBBuffer:(void*) source {
    ExerciseRecord* record = [ExerciseRecord alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.minutes = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 0)];
    record.calories = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 1)];
    record.type = sqlite3_column_int(stmt, 2);
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    record.recordEntryTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,4)];
    record.entryType = [NSNumber numberWithInt: sqlite3_column_int(stmt, 5)];
    record.steps = [NSNumber numberWithInt: sqlite3_column_int(stmt, 6)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 7)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 8)];
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (minutes double, calories double, type integer, recordedTime double UNIQUE, recordEntryTime double, entryType integer, steps int, note text, uuid text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select minutes, calories, type, recordedTime, recordEntryTime, entryType, steps, uuid, note from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}


@end
