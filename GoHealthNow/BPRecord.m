
#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "BPRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"

#import "FMDatabase.h"


NSString* const BPRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<BloodPressureRecords> %@ </BloodPressureRecords> \
<Created_Time>%@</Created_Time> \
</User_Record>";

@interface BPRecord()

@property (nonatomic, retain)           NSString* uploadingVersion;

@end



@implementation BPRecord

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(BPRecord *record in records) {
        [xmlRecords appendString:[record toXML]];
    }
    
    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:
            [NSString stringWithFormat:BPRECORD_UPLOADING,
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
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        User* user = [User sharedModel];
        
        [user updatePointsByAction: [[self class] description]];
        
        NSString* xmlRecord = [NSString stringWithFormat:BPRECORD_UPLOADING,
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



+ (PMKPromise *)searchRecentBPWithFilter:(NSString *)filter {
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
                    BPRecord *record = [self createWithDBBuffer:stmt];
                    
                    NSString *category = [dateFormatter stringFromDate:record.recordedTime];
                    if ([category isEqualToString:today]) {
                        category = TIME_TODAY;
                    }
                    
                    NSNumber *index = [nameKeys objectForKey:category];
                    
                    NSMutableArray *records = nil;
                    
                    if (index == nil) {
                        records = [[NSMutableArray alloc] init];
                        [results addObject:@{
                                             MACRO_BP_CATEGORY_ATTR: category,
                                             MACRO_BP_ROWS_ATTR: records
                                             }];
                        [nameKeys setObject:[NSNumber numberWithUnsignedInteger:(results.count - 1)] forKey:category];
                    }
                    else {
                        records = [results objectAtIndex:[index unsignedIntegerValue]][MACRO_BP_ROWS_ATTR];
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
    
    return [NSString stringWithFormat:@"<BloodPressureRecord> \
            <Systolic>%@</Systolic> \
            <Diastolic>%@</Diastolic> \
            <Pulse>%@</Pulse> \
            <Note>%@</Note> \
            <Uuid>%@</Uuid> \
            <RecordedTime>%@</RecordedTime> \
            </BloodPressureRecord> ",
            self.systolic, self.diastolic, self.pulse, self.note, self.uuid, [GGUtils stringFromDate:self.recordedTime]];
    
}


/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (systolic, diastolic, pulse, recordedTime, note, uuid) values (%@, %@, %@, %f, %@, %@)",
                     [self class],
                     self.systolic,
                     self.diastolic,
                     self.pulse,
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.note],
                     [GGUtils toSQLString:self.uuid]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    BPRecord* record = [BPRecord alloc];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.systolic = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 0)];
    record.diastolic = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 1)];
    record.pulse = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 2)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 4)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 5)];
    
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (systolic double, diastolic double, pulse double,recordedTime double UNIQUE, note text, uuid text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select systolic, diastolic, pulse, recordedTime, note, uuid from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

-(void)deleteBPRecordWithID:(NSString *)uuid{
    
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    [database open];
    
    [database executeUpdateWithFormat:@"DELETE FROM BPRecord WHERE uuid = %@", uuid];
    [database executeQuery:@"VACUUM BPRecord"];
    
    [database close];
    
    
    [[GlucoguideAPI sharedService] deleteRecordWithRecord:2 andUUID:uuid];
    
}


/////////////////////////




@end
