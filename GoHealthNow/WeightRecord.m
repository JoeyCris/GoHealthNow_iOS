//
//  WeightRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "WeightRecord.h"
#import "GGUtils.h"
#import "User.h"
#import "GlucoguideAPI.h"

NSString* const WEIGHTRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Weight_Records>  %@ </Weight_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";


@interface LengthUnit ()

@property (nonatomic) float value_;


@end

@implementation LengthUnit

-(instancetype) initWithMetric:(float) value {
    if (self = [super init]){
        self.value_ = value;
    }
    
    return self;
    
}

-(instancetype) initWithImperial:(char) feet :(char) inches { // 1 feet = 12 inches; 1 inch = 2.54 cm
    if (self = [super init]){
        if(![self setValueWithImperial:feet :inches]) {
            self.value_ = 0.0;
        }
    }
    
    return self;
}

-(BOOL) setValueWithMetric:(float) value {
    
    self.value_ = value;
    
    return YES;
    
}

-(BOOL) setValueWithImperial:(char) feet :(char) inches { // 1 feet = 12 inches; 1 inch = 2.54 cm
    
    if(feet > 20 || inches > 11) {
        return NO;
    } else {
        self.value_ = (12* feet + inches) * 2.54;
        
        return YES;
    }
}

- (BOOL)setValueWithImperialWithInches:(float)inches {
    self.value_ = inches * 2.54;
    return YES;
}

-(float) valueWithMetric {
    
    return self.value_;
}

//{"feet": 5, "inches": 7}
-(NSDictionary*) valueWithImperial {
    //char feet = floor(self.value_ /2.54/12);
    int inches = (round(self.value_/2.54) );
    
    char feet = inches/12;
    
    inches = inches % 12;
    
    return @{IMPERIAL_UNIT_HEIGHT_FEET:[NSNumber numberWithChar:feet], IMPERIAL_UNIT_HEIGHT_INCHES:[NSNumber numberWithInt:inches]};
}

-(float) valueWithImperialInchesOnly {
    return self.value_ / 2.54;
}

@end



@interface WeightUnit ()

@property (nonatomic) float value_;


@end

@implementation WeightUnit

+(float) convertToMetric:(float) imperialValue {
    return imperialValue * 0.4536;
}

-(id) initWithMetric:(float) value {
    if (self = [super init]){
        self.value_ = value;
    }
    
    return self;
    
}

-(id) initWithImperial:(float) value {
    if (self = [super init]){
        self.value_ = value * 0.4536;
    }
    
    return self;
}

-(BOOL) setValueWithMetric:(float) valueKG {//kg
    self.value_ = valueKG;
    
    return YES;
}
-(BOOL) setValueWithImperial:(float) valueLB {
    self.value_ = valueLB *0.4536;
    
    return YES;
}


-(float) valueWithMetric {
    return self.value_;
}
-(float) valueWithImperial {
    return self.value_ /0.4536;
}


@end

@implementation WeightRecord

-(NSDictionary*) toDictionary {
    
    return @{MSG_WEIGHT:[NSNumber numberWithInt:[self.value valueWithMetric]],
             @"Date": [GGUtils stringFromDate:self.recordedTime] };
}

-(id) initWithDictionary:(NSDictionary*) record {
    if (self = [super init] ) {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:ISO8601_DATE_FORMATE];
        
        
        self.value = (record[@"Weight"] != nil) ?
        [[WeightUnit alloc] initWithMetric: [record[@"Weight"] floatValue]]: nil;
        
        
        self.recordedTime = (record[@"Date"] != nil) ? [GGUtils dateFromString:record[@"Date"]] : nil;
        
    }
    
    return self;
}

+ (PMKPromise *)searchWeight:(NSDate*)fromDate toDate:(NSDate*)toDate {
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
                        WeightUnit *weight = [[WeightUnit alloc] initWithMetric:sqlite3_column_double(stmt, 0)];
                        
                        NSString* dayStr = stringWithCString(
                                                             (const char*)sqlite3_column_text(stmt,1));
                        
                        NSDate* recordedDay  = [GGUtils dateFromSQLString: dayStr];
                        
                        if ([results count] != 0) {
                            if ([GGUtils isSameDayOfDate:recordedDay andDate2:[results[[results count]-1] objectForKey:MACRO_WEIGHT_RECORDEDDAY_ATTR]]) {
                                [results removeObjectAtIndex:[results count]-1];
                            }
                        }
                        
                        [results addObject:@{
                                             MACRO_WEIGHT_NAME_ATTR:weight,
                                             MACRO_WEIGHT_RECORDEDDAY_ATTR:recordedDay}];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
}

//- (BOOL) save;
-(PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        [DBHelper insertToDB: self];
        
        User* user = [User sharedModel];
        
        [user updatePointsByAction: [[self class] description]];
        
        NSString* xmlRecord = [NSString stringWithFormat:WEIGHTRECORD_UPLOADING,
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
        for(WeightRecord *record in records) {
            [xmlRecords appendString:[record toXML]];
            [DBHelper insertToDB: record];
        }
        
        
        User* user = [User sharedModel];
        
        [[GlucoguideAPI sharedService ]saveRecordWithXML:
                [NSString stringWithFormat:WEIGHTRECORD_UPLOADING,
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
    return [NSString stringWithFormat:@"<Weight_Record> \
            <WeightValue>%f</WeightValue> \
            <Uuid>%@</Uuid> \
            <RecordedTime>%@</RecordedTime> \
            </Weight_Record>",
            [self.value valueWithMetric], self.uuid, [GGUtils stringFromDate:self.recordedTime]];
    
}



/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (value, recordedTime, note, uuid) values (%f, %f, %@, %@)",
                     [self class],
                     [self.value valueWithMetric],
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.note],
                     [GGUtils toSQLString:self.uuid]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    WeightRecord* record = [WeightRecord alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
    record.value = [[WeightUnit alloc] initWithMetric: sqlite3_column_double(stmt, 0)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,1)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 2)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)];
    
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (value double, recordedTime double UNIQUE, note text, uuid text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select value, recordedTime, note, uuid from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////



@end