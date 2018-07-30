//
//  A1CRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "A1CRecord.h"
#import "GGUtils.h"
#import "User.h"
#import "GlucoguideAPI.h"

NSString* const A1CRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<A1C_Records>  %@ </A1C_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

//static NSNumber* a1c_ = nil;

@implementation A1CRecord

static float a1c_;
+ (float) getA1C
{ @synchronized(self) { return a1c_; } }
+ (void) setA1C:(float)val
{ @synchronized(self) { a1c_ = val; } }





-(NSDictionary*) toDictionary {
    
    return @{@"A1C":self.value, @"Date":[GGUtils stringFromDate:self.recordedTime] };
    
}

-(id) initWithDictionary:(NSDictionary*) record {
    if (self = [super init] ) {
        
        
        self.value = (record[@"A1C"] != [NSNull null]) ? record[@"A1C"]: nil;
        
        
        self.recordedTime = (record[@"Date"] != [NSNull null]) ? [GGUtils dateFromString:record[@"Date"]] : nil;
        
    }
    
    return self;
}

//GGRecord
//- (BOOL) save;
-(PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        a1c_ = [self.value floatValue];
        
        [DBHelper insertToDB: self];
        
        User* user = [User sharedModel];

        [user updatePointsByAction: [[self class] description]];
        
        NSString* xmlRecord = [NSString stringWithFormat:A1CRECORD_UPLOADING,
                               user.userId,
                               [self toXML],
                               [GGUtils stringFromDate:[NSDate date]]];
        
        
        [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord].then(^(id res){
            fulfill(res);
            
        }).catch(^(id res) {
            reject(res);
        });
        
        
        
    }];
}

+ (PMKPromise *)save:(NSArray*) records {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSMutableString* xmlRecords = [NSMutableString stringWithString:@""];
        for(A1CRecord *record in records) {
            [xmlRecords appendString:[record toXML]];
            [DBHelper insertToDB: record];
        }
        
        User* user = [User sharedModel];
        
        [[GlucoguideAPI sharedService ]saveRecordWithXML:
         [NSString stringWithFormat:A1CRECORD_UPLOADING,
          user.userId,
          xmlRecords,
          [GGUtils stringFromDate:[NSDate date]]
          ]].then(^(id res){
             fulfill(res);
             
         }).catch(^(id res) {
             reject(res);
         });
        
    }];
    
}

-(NSString*)toXML {
    return [NSString stringWithFormat:@"<A1C_Record> \
            <A1CValue>%f</A1CValue> \
            <RecordedTime>%@</RecordedTime> \
            <Uuid>%@</Uuid>\
            </A1C_Record>",
            [self.value floatValue], [GGUtils stringFromDate:self.recordedTime], self.uuid];
    
}

+ (PMKPromise *)searchRecentA1CWithFilter:(NSString *)filter {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        dispatch_promise(^{
            NSMutableArray *results = [[NSMutableArray alloc] init];
            NSString *query = [self sqlForQuery:filter];
            
            sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
            
            if (stmt != NULL) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    A1CRecord *record = [self createWithDBBuffer:stmt];
                    [results addObject:record];
                }
                sqlite3_finalize(stmt);
            }
            fulfill(results);
        });
    }];
}

+ (PMKPromise *)searchA1C:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            
            if((fromDate == nil) || (toDate == nil)) {
                fulfill(nil);
            } else {
                NSString* query = [NSString stringWithFormat:@"select value, datetime(recordedTime, 'unixepoch') from %@  where recordedTime >= %f and recordedTime <= %f group by datetime(recordedTime, 'unixepoch')", [self class],
                                   [fromDate timeIntervalSince1970],
                                   [toDate timeIntervalSince1970]];
                
                NSMutableArray* results = [[NSMutableArray alloc] init];
                sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
                
                if(stmt != NULL) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                                                                                //:sqlite3_column_double(stmt, 0)];
                        
                        NSString* dayStr = stringWithCString((const char*)sqlite3_column_text(stmt,1));
                        
                        NSDate* recordedDay  = [GGUtils dateFromSQLString: dayStr];
                        
                        NSDictionary *a1cDict = @{
                                                  @"A1C":[NSNumber numberWithDouble:sqlite3_column_double(stmt, 0)],
                                                  @"Date":dayStr};
                        
                        A1CRecord *a1c = [[A1CRecord alloc] initWithDictionary:a1cDict];
                        
                        /*
                        if ([results count] != 0) {
                            if ([GGUtils isSameDayOfDate:recordedDay andDate2:[results[[results count]-1] objectForKey:MACRO_A1C_RECORDEDDAY_ATTR]]) {
                                [results removeObjectAtIndex:[results count]-1];
                            }
                        }
                        */
                        [results addObject:@{
                                             MACRO_A1C_NAME_ATTR:a1c,
                                             MACRO_A1C_RECORDEDDAY_ATTR:recordedDay}];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
}


//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (value, recordedTime, uuid, note) values (%f, %f, %@, %@)",
                     [self class],
                     [self.value floatValue],
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.uuid],
                     [GGUtils toSQLString:self.note]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    A1CRecord* record = [A1CRecord alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.value =  [NSNumber numberWithDouble: sqlite3_column_double(stmt, 0)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,1)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 2)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)];
    
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (value integer,recordedTime double UNIQUE, uuid text, note text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select value, recordedTime, uuid, note from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

@end

