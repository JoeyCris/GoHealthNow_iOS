//
//  InsulinRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-06-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "InsulinRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"

#import "XMLDictionary/XMLDictionary.h"

NSString* const INSULINRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Insulin_Records>  %@ </Insulin_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

NSString* const INSULIN_XML_TEMPLATE = @"<Insulin_Record> \
<Dose>%lu</Dose> \
<InsulinID>%@</InsulinID> \
<RecordedTime>%@</RecordedTime> \
</Insulin_Record>";


@implementation InsulinRecord

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(InsulinRecord*record in records) {
        [xmlRecords appendString:[record toXML]];
    }
    
    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:
            [NSString stringWithFormat:INSULINRECORD_UPLOADING,
             user.userId,
             xmlRecords,
             [GGUtils stringFromDate:[NSDate date]]
             ]];
}



- (PMKPromise *)save {
    
    User* user = [User sharedModel];
    
    [user updatePointsByAction: [[self class] description]];
    
    [DBHelper insertToDB: self];
    
    NSString* xmlRecord = [NSString stringWithFormat:INSULINRECORD_UPLOADING,
                           user.userId,
                           [self toXML],
                           [GGUtils stringFromDate:[NSDate date]]];
    
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
    
}



-(NSString*)toXML {
    return [NSString stringWithFormat:INSULIN_XML_TEMPLATE,
            (unsigned long)self.dose,
            self.insulinId,
            [GGUtils stringFromDate:self.recordedTime]
            ];
    
}

+(NSArray*) getAllInsulins {
    

    NSBundle* bundle = [NSBundle mainBundle];
    NSString* filePath = [bundle pathForResource:@"insulins" ofType:@"xml" inDirectory:@"assets"];
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    if(![fileMgr fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary* insulins = [NSDictionary dictionaryWithXMLFile:filePath];
    
    return insulins[@"Insulin"];
}

+ (PMKPromise *)searchLastInsulin {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSString* query = [NSString stringWithFormat: @"%@ limit 1", [InsulinRecord sqlForQuery:nil] ];
        
        sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
        
        InsulinRecord* record = nil;
        
        if(stmt != NULL) {
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                record = [InsulinRecord createWithDBBuffer:stmt];

            }
        }
        
        sqlite3_finalize(stmt);
        
        fulfill(record);
    }];
}

/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (insulinId, dose, recordedTime) values (%@, %lu, %f)",
                     [self class],
                     [GGUtils toSQLString:self.insulinId],
                     (unsigned long) self.dose,
                     [self.recordedTime timeIntervalSince1970]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    InsulinRecord* record = [[InsulinRecord alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    record.insulinId = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 0)];
    record.dose = sqlite3_column_int(stmt, 1);
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,2)];
    
    
    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (insulinId text, dose integer, recordedTime double )",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select insulinId, dose, recordedTime from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////


@end
