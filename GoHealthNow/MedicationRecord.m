//
//  MedicationRecord.h
//  GlucoGuide
//
//  Created by John Wreford on 2015-09-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MedicationRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "XMLUpdateClass.h"

#import "XMLDictionary/XMLDictionary.h"

#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


NSString* const MEDICATIONRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Medicine_Records>  %@ </Medicine_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

NSString* const MEDICATION_XML_TEMPLATE = @"<Medicine_Record> \
<Dose>%lu</Dose> \
<Unit>%@</Unit> \
<RecordedTime>%@</RecordedTime> \
<MedicineID>%@</MedicineID> \
<MedicineName>%@</MedicineName> \
<Uuid>%@</Uuid>\
<Note>%@</Note>\
</Medicine_Record>";

NSString* const MEDICATION_XML_TEMPLATE_CUSTOM_MEDICINE = @"<Medicine_Record> \
<Dose>%f</Dose> \
<Unit>%@</Unit> \
<RecordedTime>%@</RecordedTime> \
<MedicineName>%@</MedicineName> \
<Uuid>%@</Uuid>\
<Note>%@</Note>\
</Medicine_Record>";

@implementation MedicationRecord


+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(MedicationRecord *record in records) {
        [xmlRecords appendString:[record toXML]];
    }
    
    
    User* user = [User sharedModel];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:
            [NSString stringWithFormat:MEDICATIONRECORD_UPLOADING,
             user.userId,
             xmlRecords,
             [GGUtils stringFromDate:[NSDate date]]
             ]];
}



- (PMKPromise *)save {
    
    User* user = [User sharedModel];
    
    [user updatePointsByAction: [[self class] description]];
    
    [DBHelper insertToDB: self];
    
    NSString* xmlRecord = [NSString stringWithFormat:MEDICATIONRECORD_UPLOADING,
                           user.userId,
                           [self toXML],
                           [GGUtils stringFromDate:[NSDate date]]];
    
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
    
}

-(NSString*)toXML {
    
    if ([[self.medicationId substringToIndex:3] isEqualToString:@"cus"]) {
        return [NSString stringWithFormat:MEDICATION_XML_TEMPLATE_CUSTOM_MEDICINE,
                self.dose,
                self.measurement,
                [GGUtils stringFromDate:self.recordedTime],
                [self getMedicationNameWithID:self.medicationId],
                self.uuid,
                self.note
                ];
    }else{
            return [NSString stringWithFormat:MEDICATION_XML_TEMPLATE,
                    (unsigned long)self.dose,
                    self.measurement,
                    [GGUtils stringFromDate:self.recordedTime],
                    self.medicationId,
                    [self getMedicationNameWithID:self.medicationId],
                    self.uuid,
                    self.note
                    ];
        }
}

-(NSString *)getMedicationNameWithID:(NSString *)medID{
    
    NSArray *allMedication = [[NSArray alloc] initWithArray:[MedicationRecord getAllMedications]];
    
    for (NSDictionary *item in allMedication)
    {
            if ([[item objectForKey:@"_ID"] isEqualToString:medID]) {
                return [item objectForKey:@"_Name"];
                break;
            }
    }
    
    return nil;
}

+(NSArray*) getAllMedications {
    
    return [[XMLUpdateClass getInstance] medicationXMLDict][@"Medicine"];
}

+ (NSArray *)getUserMedications {
    NSString* query = @"select medicationId, dose, recordedTime, measurement, uuid, note from MedicationRecord";
    
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    if(stmt != NULL) {
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            [tempArray addObject:[GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 0)]];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return tempArray;
}

+ (NSArray *)getUserMedicationsDetailed {
    NSString* query = @"select medicationId, dose, recordedTime, measurement, uuid, note from MedicationRecord";
    
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    
    NSString* today = [dateFormatter stringFromDate:[NSDate date]];
    
    if(stmt != NULL) {
        NSMutableDictionary* namekeys = [[NSMutableDictionary alloc] init];
        
        while (sqlite3_step(stmt) == SQLITE_ROW)
        {
            MedicationRecord *record = [self createWithDBBuffer:stmt];
            
            NSString* category = [dateFormatter stringFromDate:record.recordedTime];
            if([category isEqualToString:today]) {
                category = TIME_TODAY;
            }
            
            //insert record to category
            NSNumber* index = [namekeys objectForKey:category];
            
            NSMutableArray *meds = nil;
            
            if (index == nil) {
                meds = [[NSMutableArray alloc] init];
                [tempArray addObject:@{@"category": category, @"rows":meds}];
                
                [namekeys setObject:[NSNumber numberWithUnsignedInteger:(tempArray.count - 1)] forKey:category];
            }
            else {
                meds = [tempArray objectAtIndex: [index unsignedIntegerValue]][@"rows"];
            }
            
            [meds addObject:record];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return tempArray;
}

//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (medicationId, dose, measurement, recordedTime, uuid, note) values (%@, %f, %@, %f, %@, %@)",
                     [self class],
                     [GGUtils toSQLString:self.medicationId],
                     self.dose,
                     [GGUtils toSQLString:self.measurement],
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.uuid],
                     [GGUtils toSQLString:self.note]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    MedicationRecord *record = [[MedicationRecord alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    record.medicationId = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 0)];
    record.dose = sqlite3_column_double(stmt, 1);
    record.measurement = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,2)];
    record.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 4)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 5)];

    return record;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (medicationId text, dose float, measurement char(4), recordedTime float, uuid text, note text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select medicationId, dose, recordedTime, measurement, uuid, note from %@ %@ order by recordedTime desc",
            
           
            [self class], whereStatement];
}

-(void)deleteMedicationRecordWithID:(NSString *)uuid{
    
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    [database open];
    
    [database executeUpdateWithFormat:@"DELETE FROM MedicationRecord WHERE uuid = %@", uuid];
    [database executeQuery:@"VACUUM MedicationRecord"];
    
    [database close];
    
    
    [[GlucoguideAPI sharedService] deleteRecordWithRecord:4 andUUID:uuid];
    
}


+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

@end
