//
//  WeightGoal.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeightGoal.h"
#import "GGUtils.h"
#import "user.h"
#import "GlucoguideAPI.h"

NSString * const WEIGHT_GOAL_OPTIONS_DESC_KEY = @"description";
NSString * const WEIGHT_GOAL_OPTIONS_VAL_KEY = @"value";
NSString * const WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY = @"type";
NSString * const WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY = @"matchingValueFromOtherUnitType";

const float MaxLostCalories = 1105;

@implementation WeightGoal

+ (NSArray *)getOptions {
    User* user = [User sharedModel];
    
    if(user.measureUnit == MUnitMetric) {
        return @[
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 1 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @1,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:2]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 0.8 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.8,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1.5]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 0.5 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.5,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 0.2 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.2,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:0.5]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Maintain my current weight"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.0,
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.0,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 0.2 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.2,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:0.5]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 0.5 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.5,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 0.8 kilograms per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY:  @0.8,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1.5]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
             @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 1 kilogram per week"],
               WEIGHT_GOAL_OPTIONS_VAL_KEY: @1,
               WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:2]],
               WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]}];
    } else {
        return @[
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 2 lbs per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:2]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @1,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 1 1/2 lbs per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1.5]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.8,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 1 lb per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.5,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Gain 1/2 lb per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:0.5]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.2,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeGainWeight]},
                    @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Maintain my current weight"],
                      WEIGHT_GOAL_OPTIONS_VAL_KEY: @0.0,
                      WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.0,
                      WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 1/2 lb per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:0.5]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.2,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 1 lb per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.5,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 1 1/2 lbs per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:1.5]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @0.8,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]},
                 @{WEIGHT_GOAL_OPTIONS_DESC_KEY: [LocalizationManager getStringFromStrId:@"Lose 2 lbs per week"],
                   WEIGHT_GOAL_OPTIONS_VAL_KEY: [NSNumber numberWithFloat:[WeightUnit convertToMetric:2]],
                   WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY: @1,
                   WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY: [NSNumber numberWithInt:WeightGoalTypeLoseWeight]}];
    }
}

-(float) getDailyCalaries {
    
    float lostCalaries = [self.target valueWithImperial] /7 * 3500;
    
    if(lostCalaries > MaxLostCalories) {
        lostCalaries = MaxLostCalories;
    }
    
    return (self.type==WeightGoalTypeLoseWeight? 1:-1 )* lostCalaries;
}

+ (instancetype)lastRecord {
    NSString* query = [NSString stringWithFormat: @"%@ limit 1", [WeightGoal sqlForQuery:nil] ];
    
    sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
    
    WeightGoal* record = nil;
    
    if(stmt != NULL) {
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            record = [WeightGoal createWithDBBuffer:stmt];
        }
    }
    
    sqlite3_finalize(stmt);
    
    return record;
}


/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (id, type, target, uuid, createdTime) values (1, %d, %f, %@ ,%f)",
                     //(id, target, duration, createdTime) values (1, %f, %lu, %f)",
                     [self class],
                     self.type,
                     [self.target valueWithMetric],
                     [GGUtils toSQLString:self.uuid],
                     //(unsigned long)self.duration,
                     [self.createdTime timeIntervalSince1970]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    WeightGoal* record = [WeightGoal alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    int type = sqlite3_column_int(stmt, 0);
    if (type) {
        record.type = type;
    }
    else
        record.type = WeightGoalTypeLoseWeight; // in the past, we only have losing weight option
    
    record.target = [[WeightUnit alloc] initWithMetric: sqlite3_column_double(stmt, 1)];
    record.createdTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,3)];
    
    record.uuid = [GGUtils stringWithCString:(char *)sqlite3_column_text(stmt, 2)];
    if (record.uuid == nil) {
        record.uuid = (NSString *)[[NSUUID UUID] UUIDString];
    }
    
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
/*
-(NSString*)toXML {
    return [NSString stringWithFormat:@"<WeightGoal> \
            <Tatget>%@</Target> \
            <Type>%@</Type> \
            <RecordedTime>%@</RecordedTime> ",
            ];
}
*/

/////////////////////////

@end
