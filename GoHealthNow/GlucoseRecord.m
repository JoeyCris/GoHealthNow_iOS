//
//  Glucose.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-30.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "GlucoseRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "FMDatabase.h"

NSString* const GLUCOSRECORD_UPLOADING = @"\
  <User_Record> \
  <UserID>%@</UserID> \
  <Glucoses_Records>  %@ </Glucoses_Records> \
  <Created_Time>%@</Created_Time> \
  </User_Record>";


@interface BGValue ()

@property (nonatomic) float value_;


@end

@implementation BGValue

-(instancetype) initWithMMOL:(float) value {
    if (self = [super init]){
        self.value_ = value;
    }
    
    return self;
    
}

-(instancetype) initWithMG:(float) value {
    if (self = [super init]){
        self.value_ = value / 18;
    }
    
    return self;
}

-(BOOL) setValueWithMMOL:(float) value {
    self.value_ = value;
    
    return YES;
}
-(BOOL) setValueWithMG:(float) value {
    self.value_ = value / 18;
    
    return YES;
}


-(float) valueWithMMOL{
    return self.value_;
}
-(float) valueWithMG {
    return self.value_ * 18;
}


@end


@interface GlucoseRecord()

@property (nonatomic, copy)     NSString* uploadingVersion;

@end

@implementation GlucoseRecord

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(GlucoseRecord *record in records) {
        [xmlRecords appendString:[record toXML]];
        [DBHelper insertToDB: record];
    }

    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService] saveRecordWithXML:
            [NSString stringWithFormat:GLUCOSRECORD_UPLOADING,
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

+(NSArray*) getBGTypeOptions {
    return @[[LocalizationManager getStringFromStrId:@"Before Breakfast"],
             [LocalizationManager getStringFromStrId:@"After Breakfast"],
             [LocalizationManager getStringFromStrId:@"Before Lunch"],
             [LocalizationManager getStringFromStrId:@"After Lunch"],
             [LocalizationManager getStringFromStrId:@"Before Dinner"],
             [LocalizationManager getStringFromStrId:@"After Dinner"],
             [LocalizationManager getStringFromStrId:@"Bedtime"],
             [LocalizationManager getStringFromStrId:@"Other"]];
}

- (PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        User* user = [User sharedModel];
        
        [user updatePointsByAction: [[self class] description]];
        
        NSString* xmlRecord = [NSString stringWithFormat:GLUCOSRECORD_UPLOADING,
                               user.userId,
                               [self toXML],
                               [GGUtils stringFromDate:[NSDate date]]];
        
        [DBHelper insertToDB: self];
            
        [[GlucoguideAPI sharedService] saveRecordWithXML:xmlRecord].then(^(id res){
                 fulfill(res);
                 
            }).catch(^(id res) {
                    reject(res);
            });
    
    }];
}
//

//static NSString * const MACRO_FASTBG_NAME_ATTR = @"fastBG";
//static NSString * const MACRO_FASTBG_RECORDEDDAY_ATTR = @"recordedDay";
//return type NSArrary<f@{@"fastBG": BGValue*, @"recordedDay": NSDate* }>
+ (PMKPromise *)searchDailyFastBG:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            
            if((fromDate == nil) || (toDate == nil)) {
                fulfill(nil);
            } else {
                NSString* query = [NSString stringWithFormat:@"select level, datetime(recordedTime, 'unixepoch') from %@  where type = 0 and recordedTime >= %f and recordedTime <= %f group by datetime(recordedTime, 'unixepoch')", self,
                                   [fromDate timeIntervalSince1970],
                                   [toDate timeIntervalSince1970]];
                
                NSMutableArray* results = [[NSMutableArray alloc] init];
                sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
                
                if(stmt != NULL) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                        BGValue* fastBG = [[BGValue alloc] initWithMMOL:sqlite3_column_double(stmt,0)];
                        
                        
                        
                        NSString* dayStr = stringWithCString(
                                            (const char*)sqlite3_column_text(stmt,1));
                        
                        NSDate* recordedDay  = [GGUtils dateFromSQLString: dayStr];
                        
                        if ([results count]!=0) {
                            if ([GGUtils isSameDayOfDate:recordedDay andDate2:[results[[results count]-1] objectForKey:MACRO_FASTBG_RECORDEDDAY_ATTR]]) {
                                [results removeObjectAtIndex:[results count]-1];
                            }
                        }
                        
                        [results addObject:@{
                                             MACRO_FASTBG_NAME_ATTR:fastBG,
                                             MACRO_FASTBG_RECORDEDDAY_ATTR:recordedDay}];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
}

//static NSString * const MACRO_BG_CATEGORY_ATTR = @"category";
//static NSString * const MACRO_BG_ROWS_ATTR = @"rows";
/*return type NSArray < @{
                            @"category":  NSString
                            @"rows": NSArray<
                                    GlucoseRecord
                            }
                        >
 
 */

+ (PMKPromise *)searchRecentBGWithFilter:(NSString *)filter {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            NSMutableArray *results = [[NSMutableArray alloc] init];
            NSString *query = [self sqlForQuery:filter];
            
            sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
            
            NSString* today = [dateFormatter stringFromDate:[NSDate date]];

            if (stmt != NULL) {
                NSMutableDictionary *nameKeys = [[NSMutableDictionary alloc] init];
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    GlucoseRecord *record = [self createWithDBBuffer:stmt];
                    
                    NSString *category = [dateFormatter stringFromDate:record.recordedTime];
                    if ([category isEqualToString:today]) {
                        category = TIME_TODAY;
                    }
                    
                    NSNumber *index = [nameKeys objectForKey:category];
                    
                    NSMutableArray *records = nil;
                    
                    if (index == nil) {
                        records = [[NSMutableArray alloc] init];
                        [results addObject:@{
                                             MACRO_BG_CATEGORY_ATTR: category,
                                             MACRO_BG_ROWS_ATTR: records
                                             }];
                        [nameKeys setObject:[NSNumber numberWithUnsignedInteger:(results.count - 1)] forKey:category];
                    }
                    else {
                        records = [results objectAtIndex:[index unsignedIntegerValue]][MACRO_BG_ROWS_ATTR];
                    }
                    
                    [records addObject:record];
                    
                }
                     
                sqlite3_finalize(stmt);
            }
            
            
            fulfill(results);
        });
    }];
}

-(NSString*)toXML {
    
    if ([self.note length] < 1) {
        self.note = @"";
    }
    
    return [NSString stringWithFormat:@"<Glucose_Record> \
            <Level>%f</Level> \
            <RecordedTime>%@</RecordedTime> \
            <UploadingVersion>%@</UploadingVersion> \
            <GlucoseType>%@</GlucoseType> \
            <Uuid>%@</Uuid> \
            <Note>%@</Note> \
        </Glucose_Record>",
            [self.level valueWithMMOL], [GGUtils stringFromDate:self.recordedTime], self.uploadingVersion, self.type, self.uuid, self.note];
    
}



/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
        NSString* sql = [NSString stringWithFormat:@"insert or replace into GlucoseRecord \
                         (level, type, uploadingVersion, recordedTime, note, uuid) values (%f, %@, \"%@\", %f, %@, %@)",
                         [self.level valueWithMMOL],
                         self.type, self.uploadingVersion,
                         [self.recordedTime timeIntervalSince1970],
                         [GGUtils toSQLString:self.note],
                         [GGUtils toSQLString:self.uuid]];
    
    return sql;
}



- (NSString*) sqlForCreateTable {
    
    return @"create table if not exists GlucoseRecord (level double, type integer,uploadingVersion text, recordedTime double UNIQUE, note text, uuid text)";
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select level, type, uploadingVersion, recordedTime, note, uuid from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(instancetype) createWithDBBuffer:(void*) source {
    GlucoseRecord* record = [[GlucoseRecord alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.level = [[BGValue alloc] initWithMMOL:sqlite3_column_double(stmt,0)];
    record.type =  [NSNumber numberWithInt: sqlite3_column_int(stmt, 1)];
    record.uploadingVersion = [NSString stringWithUTF8String:(char*) sqlite3_column_text(stmt, 2)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 4)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 5)];
    
    return record;
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////

-(void)deleteGlucoseRecordWithID:(NSString *)uuid{
    
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    [database open];
    
    [database executeUpdateWithFormat:@"DELETE FROM GlucoseRecord WHERE uuid = %@", uuid];
    [database executeQuery:@"VACUUM GlucoseRecord"];
    
    [database close];
    
    
    [[GlucoguideAPI sharedService] deleteRecordWithRecord:3 andUUID:uuid];
    
}


@end
