//
//  ExerciseGoal.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-04-02.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "ExerciseGoal.h"
#import "GGUtils.h"
#import "User.h"
#import "GlucoguideAPI.h"

@implementation ExerciseGoal

@synthesize uuid;
@synthesize type;
@synthesize target;
@synthesize createdTime;

+ (instancetype) lastRecord {
    NSString* query = [NSString stringWithFormat: @"%@ limit 1", [ExerciseGoal sqlForQuery:nil] ];
    
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
    
    ExerciseGoal* record = nil;
    
    if(stmt != NULL) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            record = [ExerciseGoal createWithDBBuffer:stmt];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return record;
}

+ (instancetype) lastRecordWithExerciseType:(GoalType)type {
    NSString* query = [ExerciseGoal sqlForQuery:[NSString stringWithFormat:@"type=%d", type]];
    
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
    
    ExerciseGoal* record = nil;
    
    if(stmt != NULL) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            record = [ExerciseGoal createWithDBBuffer:stmt];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return record;
}

/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (id, type, target, uuid, createdTime) values (%d, %d, %f, %@, %f)",
                     //(id, target, duration, createdTime) values (1, %f, %lu, %f)",
                     [self class],
                     self.type,
                     self.type,
                     [self.target doubleValue],
                     [GGUtils toSQLString:self.uuid],
                     [self.createdTime timeIntervalSince1970]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    ExerciseGoal* record = [[ExerciseGoal alloc] init];

    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    record.type = (GoalType)sqlite3_column_int(stmt, 0);
    record.target = [NSNumber numberWithDouble:sqlite3_column_double(stmt, 1)];
    record.uuid = [GGUtils stringWithCString:(char *)sqlite3_column_text(stmt, 2)];
    record.createdTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    
    return record;
}

- (NSString*) sqlForCreateTable {
    return [NSString stringWithFormat:@"create table if not exists %@ (id integer PRIMARY KEY, type integer, target double, uuid text, createdTime double)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select type, target, uuid, createdTime from %@ %@ order by createdTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

@end
