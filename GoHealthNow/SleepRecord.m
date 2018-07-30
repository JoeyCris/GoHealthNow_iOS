//
//  Sleep.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-31.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "SleepRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"

NSString* const SLEEPRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Sleep_Records>  %@ </Sleep_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";


@interface SleepRecord()

@property (nonatomic, retain)           NSString* uploadingVersion;

@end


@implementation SleepRecord

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(SleepRecord *record in records) {
        [xmlRecords appendString:[record toXML]];
    }
    
    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:
            [NSString stringWithFormat:SLEEPRECORD_UPLOADING,
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
    
    User* user = [User sharedModel];
    
    [DBHelper insertToDB: self];

    [user updatePointsByAction: [[self class] description]];
    
    NSString* xmlRecord = [NSString stringWithFormat:SLEEPRECORD_UPLOADING,
                           user.userId,
                           [self toXML],
                           [GGUtils stringFromDate:[NSDate date]]];
    
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
    
}


-(NSString*)toXML {
    return [NSString stringWithFormat:@"<Sleep_Record> \
            <Minutes>%@</Minutes> \
            <RecordedTime>%@</RecordedTime> \
            <UploadingVersion>%@</UploadingVersion> \
            <Sick>%@</Sick> \
            <Stressed>%@</Stressed> \
            <Uuid>%@</Uuid>\
            </Sleep_Record> ",
            self.minutes,
            [GGUtils stringFromDate:self.recordedTime],
            self.uploadingVersion, self.sick, self.stressed, self.uuid];
    
}

/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (minutes, sick, stressed, recordedTime, uuid, note) values (%@, %@, %@, %f, %@, %@)",
                     [self class],
                     self.minutes,
                     self.sick,
                     self.stressed,
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.uuid],
                     [GGUtils toSQLString:self.note]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    SleepRecord* record = [SleepRecord alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.minutes = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 0)];
    record.sick = [NSNumber numberWithInt: sqlite3_column_int(stmt, 1)];
    record.stressed = [NSNumber numberWithInt: sqlite3_column_int(stmt, 2)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 4)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 5)];
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (minutes double, sick integer, stressed integer,recordedTime double UNIQUE, uuid text, note text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select minutes, sick, stressed, recordedTime, uuid, note from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////


@end