//
//  DBRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "DBHelper.h"
#import "User.h"

#include <libkern/OSAtomic.h>
#include <sys/time.h>

#import <objc/runtime.h>


static volatile int32_t gOidIncrement = 0;

#define GGTimeIntervalSince2015  1420088400

class DBGuard
{
public:
    DBGuard(const char* path) : path_(path), db_(NULL) {};
    sqlite3* db(void) {
        if(db_ == NULL) {
            int retCode = sqlite3_open(path_, &(db_));
            if (retCode!=SQLITE_OK) {
                db_ = NULL;
                NSLog(@"FAILED TO OPEN DB with retCode: %d", retCode);
            }
        }
        
        return db_;
    };
    
    void release(void) {
        if(db_ != NULL) {
            sqlite3_close(db_);
            db_ = NULL;
        }
    };
    
    ~DBGuard() {
        if(db_ != NULL) {
            sqlite3_close(db_);
            db_ = NULL;
        }
    };
    
private:
    const char* path_;
    sqlite3* db_;
};

@implementation DBHelper

#pragma mark - DB Upgrade Methods

+ (int)queryDatabaseVersion {
//    [DBHelper executeSql:[NSString stringWithFormat:@"PRAGMA user_version = %d;", 0]];
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    
    sqlite3* db = guard.db();
    
    static sqlite3_stmt *stmt_version;
    int databaseVersion;
    
    if(sqlite3_prepare_v2(db, "PRAGMA user_version;", -1, &stmt_version, NULL) == SQLITE_OK) {
        while(sqlite3_step(stmt_version) == SQLITE_ROW) {
            databaseVersion = sqlite3_column_int(stmt_version, 0);
        }
        NSLog(@"%s: the databaseVersion is: %d", __FUNCTION__, databaseVersion);
    } else {
        NSLog(@"%s: ERROR Preparing: , %s", __FUNCTION__, sqlite3_errmsg(db) );
    }
    sqlite3_finalize(stmt_version);
    
    return databaseVersion;
}

+ (BOOL)setDatabaseVersion:(int)newDatabaseVersion
{
    if (newDatabaseVersion > 0) {
        NSString *newDataVersionSql = [NSString stringWithFormat:@"PRAGMA user_version = %d;", newDatabaseVersion];
        NSLog(@"upgrading DB version to %d", newDatabaseVersion);
        return [DBHelper executeSql:newDataVersionSql];
    }
    
    return NO;
}

+ (NSDictionary *)upgradeMethodInfo
{
    int databaseVersion = [DBHelper queryDatabaseVersion];
    NSMutableArray *upgradeMethodNames = [[NSMutableArray alloc] init];
    
    int unsigned numMethods;
    Method *methods = class_copyMethodList(objc_getMetaClass("DBHelper"), &numMethods);
    
    for (int i = 0; i < numMethods; i++) {
        NSString *method = NSStringFromSelector(method_getName(methods[i]));
        
        if ([method hasPrefix:[NSString stringWithFormat:@"upgrade_%d_to_", databaseVersion]]) {
            [upgradeMethodNames addObject:method];
            databaseVersion++;
        }
    }
    
    free(methods);
    
    return @{@"upgradeMethodNames": upgradeMethodNames,
             @"newDatabaseVersion": [NSNumber numberWithInt:databaseVersion]};
}

+ (PMKPromise *)upgradeWithMethodNames:(NSArray *)upgradeMethodNames {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        NSString *newDatabaseVersion = nil;
        BOOL success = NO;
        
        for (NSString *upgradeMethodName in upgradeMethodNames) {
            NSLog(@"performing upgrade method: %@", upgradeMethodName);
            
            SEL upgradeMethoSelector = NSSelectorFromString(upgradeMethodName);
            if ([[DBHelper class] respondsToSelector:upgradeMethoSelector]) {
                success = [[[DBHelper class] performSelector:upgradeMethoSelector] boolValue];
            }
            
            // don't continue upgrading if there was an error
            if (!success) {
                NSLog(@"FAILURE for upgrade method: %@", upgradeMethodName);
                break;
            }
            
            NSArray *methodComponents = [upgradeMethodName componentsSeparatedByString:@"_"];
            newDatabaseVersion = methodComponents.lastObject;
        }
        
        BOOL versionUpdateSuccess = [DBHelper setDatabaseVersion:[newDatabaseVersion intValue]];
        if (success && versionUpdateSuccess) {
            resolve(@YES);
        }
        else {
            NSDictionary *details = [NSDictionary dictionaryWithObject:@"Failed to upgrade Database" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            resolve(error);
        }
    }];
}

// We need to use NSNumber as the return type because
// performSelector can only handle objects. Thus BOOL cannot
// be used. See this for more info:
// http://www.tomdalling.com/blog/cocoa/why-performselector-is-more-dangerous-than-i-thought/
+ (NSNumber *)upgrade_0_to_1
{
    BOOL success = NO;
    
    // default creationType is search
    NSString *alters = @"ALTER TABLE `SelectedFood` ADD COLUMN `imageName` TEXT; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `creationType` INTEGER DEFAULT 1; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `calories` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `total_fat` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `sat_fat` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `trans_fat` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `sodium` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `total_carbs` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `diet_fiber` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `sugars` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `protein` REAL; \
                         ALTER TABLE `SelectedFood` ADD COLUMN `iron` REAL;";
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    char *errorMsg = NULL;
    int retCode = sqlite3_exec(db, [alters UTF8String], NULL, NULL, &errorMsg);
    NSLog(@"retCode: %d", retCode);
    if (retCode == SQLITE_OK) {
        success = YES;
    }
    
    if (!success && errorMsg != NULL) {
        // ignore the failure of the alter table statements
        // if they failed due to the table not existing. In that case
        // the alter tables are not required as the table hasn't even been created yet.
        // The create table syntax will handle creating these columns
        NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
        NSLog(@"alter error msg: %@", errorMsgStr);
        if([errorMsgStr hasPrefix:@"no such table: "]) {
            success = YES;
        }
        
        sqlite3_free(errorMsg);
    }
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

+ (NSNumber *)upgrade_1_to_2 {
    BOOL success = NO;
    
    // default creationType is search
    NSString *alters = @"ALTER TABLE `ServingSize` ADD COLUMN `calories` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `total_fat` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `sat_fat` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `trans_fat` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `sodium` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `total_carbs` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `diet_fiber` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `sugars` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `protein` REAL; \
                         ALTER TABLE `ServingSize` ADD COLUMN `iron` REAL;";
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    char *errorMsg = NULL;
    int retCode = sqlite3_exec(db, [alters UTF8String], NULL, NULL, &errorMsg);
    NSLog(@"retCode: %d", retCode);
    if (retCode == SQLITE_OK) {
        success = YES;
    }
    
    if (!success && errorMsg != NULL) {
        // ignore the failure of the alter table statements
        // if they failed due to the table not existing. In that case
        // the alter tables are not required as the table hasn't even been created yet.
        // The create table syntax will handle creating these columns
        NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
        NSLog(@"alter error msg: %@", errorMsgStr);
        if([errorMsgStr hasPrefix:@"no such table: "]) {
            success = YES;
        }
        
        sqlite3_free(errorMsg);
    }
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

+ (NSNumber *)upgrade_2_to_3 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    [altersArr addObject:@"ALTER TABLE `ExerciseRecord` ADD COLUMN `recordEntryTime` double; \
                           ALTER TABLE `ExerciseRecord` ADD COLUMN `entryType` INTEGER; \
                           ALTER TABLE `ExerciseRecord` ADD COLUMN `steps` INTEGER; \
                           ALTER TABLE `ExerciseRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `MedicationRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `GlucoseRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `A1CRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `WeightRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `WeightGoal` ADD COLUMN `type` INTEGER; \
                           ALTER TABLE `WeightGoal` ADD COLUMN `uuid` TEXT"];
    
    [altersArr addObject:@"ALTER TABLE `NoteRecord` ADD COLUMN `imagePath` TEXT; "];
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

+ (NSNumber *)upgrade_3_to_4 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `NotificationMedicineRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `NotificationBloodGlucoseRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `NotificationDietRecord` ADD COLUMN `uuid` TEXT; "];
    
    [altersArr addObject:@"ALTER TABLE `NotificationExerciseRecord` ADD COLUMN `uuid` TEXT; "];
    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}
//
+ (NSNumber *)upgrade_4_to_5 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `MealRecord` ADD COLUMN `fibre` double; "];
    [altersArr addObject:@"ALTER TABLE `MealRecord` ADD COLUMN `sugar` double; "];
    
    [altersArr addObject:@"ALTER TABLE `GlucoseRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `MedicationRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `ExerciseRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `A1CRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `WeightRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `SleepRecord` ADD COLUMN `note` text; "];
    [altersArr addObject:@"ALTER TABLE `MealRecord` ADD COLUMN `note` text; "];
    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}


///

+ (NSNumber *)upgrade_5_to_6 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `MedicationRecord` RENAME TO 'tmp'; "];
    
    [altersArr addObject:@"CREATE TABLE 'MedicationRecord' ('medicationId' text, 'dose' float, 'measurement' char(4), 'recordedTime' float, 'uuid' text, 'note' text) "];
    
    [altersArr addObject:@"INSERT INTO 'MedicationRecord' (medicationId, dose, measurement, recordedTime, uuid, note) SELECT medicationId, dose, measurement, recordedTime, uuid, note FROM 'tmp'"];
    
    [altersArr addObject:@"DROP TABLE tmp"];

    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

///

+ (NSNumber *)upgrade_6_to_7 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"CREATE TABLE 'BPRecord' ('systolic' double, 'diastolic' double, 'heartRate' double, 'recordedTime' double, 'uuid' text) "];
    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}




+ (NSNumber *)upgrade_7_to_8 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `MealRecord` ADD COLUMN `providerItemID` text; "];
    [altersArr addObject:@"ALTER TABLE `FoodItem` ADD COLUMN `providerItemID` text; "];
    [altersArr addObject:@"ALTER TABLE `SelectedFood` ADD COLUMN `providerItemID` text; "];
    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}


+ (NSNumber *)upgrade_8_to_9 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    
    [altersArr addObject:@"ALTER TABLE `BPRecord` RENAME TO 'tmp'; "];
    
    [altersArr addObject:@"CREATE TABLE 'BPRecord' ('systolic' double, 'diastolic' double, 'pulse' double, 'recordedTime' double, 'uuid' text) "];
    
    [altersArr addObject:@"INSERT INTO 'BPRecord' (systolic, diastolic, pulse, recordedTime, uuid) SELECT systolic, diastolic, heartRate, recordedTime, uuid FROM 'tmp'"];
    
    [altersArr addObject:@"DROP TABLE tmp"];
    
    
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

+ (NSNumber *)upgrade_9_to_10 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `BPRecord` ADD COLUMN `note` text; "];
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}

+ (NSNumber *)upgrade_10_to_11 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `SleepRecord` ADD COLUMN `uuid` text; "];
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}


+ (NSNumber *)upgrade_11_to_12 {
    BOOL success = YES;
    
    // default creationType is search
    NSMutableArray *altersArr = [[NSMutableArray alloc] init];
    
    [altersArr addObject:@"ALTER TABLE `NoteRecord` ADD COLUMN `audioPath` text; "];
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    sqlite3* db = guard.db();
    
    if (db == NULL) {
        NSLog(@"DB is null");
    }
    
    for (NSString *alter in altersArr) {
        char *errorMsg = NULL;
        int retCode = sqlite3_exec(db, [alter UTF8String], NULL, NULL, &errorMsg);
        NSLog(@"retCode: %d", retCode);
        if (retCode == SQLITE_OK && success) {
            success = YES;
        }
        
        if (!success && errorMsg != NULL) {
            // ignore the failure of the alter table statements
            // if they failed due to the table not existing. In that case
            // the alter tables are not required as the table hasn't even been created yet.
            // The create table syntax will handle creating these columns
            NSString *errorMsgStr = [NSString stringWithUTF8String:errorMsg];
            NSLog(@"alter error msg: %@", errorMsgStr);
            if([errorMsgStr hasPrefix:@"no such table: "] && success) {
                success = YES;
            }
            else {
                success = NO;
            }
            
            sqlite3_free(errorMsg);
        }
    }
    
    
    guard.release();
    
    return [NSNumber numberWithBool:success];
}



#pragma mark - Methods

+ (NSString*)getDBPath {
    
    User* user = [User sharedModel];
    
    NSAssert(user.userId != nil && ![user.userId isEqualToString:@"0"], @"userId is nil when openDB");
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat: @"ggrecord_%@.db", user.userId]];
    
    return databaseFilePath;
    
}

+ (NSString*)getDBPath:(NSString*) userId {
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString *databaseFilePath=[[documentsPaths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat: @"ggrecord_%@.db", userId]];
    
    return databaseFilePath;
}

//create table
+ (BOOL)createTable:(sqlite3*) database : (id<DBProtocol>) record {
    
    char *errorMsg;
    const char *sql=[[record sqlForCreateTable] UTF8String];
    
    if (sqlite3_exec(database, sql, NULL, NULL, &errorMsg)==SQLITE_OK) {
        //NSLog(@"create ok.");
        
        return YES;
    }
    else {
        NSLog( @"can not create table, SQL: %@, Error Message: %@",
              [NSString stringWithUTF8String: sql],
              [NSString stringWithUTF8String: errorMsg] );
        
        return NO;
        
    }
}

//query table
+(sqlite3_stmt* ) queryDataWithPath:(const char*)sql path:(const char*) path {

    DBGuard guard(path);
    
    sqlite3* db = guard.db();
    
    if(db != NULL) {
        sqlite3_stmt* stmt;
  
        int retCode = sqlite3_prepare_v2(db, sql, -1, &stmt, nil);
        
        if(retCode == SQLITE_OK) {
            return stmt;
            
            
        } else {
            NSString* msg = [NSString stringWithUTF8String:
                             sqlite3_errmsg(db)];

            NSLog( @"failed to query data. SQL: %@, Error Code: %d, Message: %@",

                  [NSString stringWithUTF8String:sql], retCode, msg);
            
        }
    }
    
    return NULL;
    
}

+(sqlite3_stmt* ) queryGGRecord:(const char*)sql {
    NSString* path = [DBHelper getDBPath];
    return [DBHelper queryDataWithPath:sql path:[path UTF8String]];

    
}

//insert table
+ (BOOL)executeSql:(NSString*)sql {

    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    
    sqlite3* db = guard.db();
    
    if(db == NULL) {
        return NO;
    }
    
    char *errorMsg;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        //        NSLog(@"insert ok.");
        
        return YES;
    }
    
    NSLog( @"can not execute sql to table, Error Message: %@ SQL: %@",
          [NSString stringWithUTF8String: errorMsg],
          sql);
    
    return NO;
    
}

//insert table
+ (BOOL)executeSqlWithPath:(NSString*)sql path: (NSString*) path {
    
    DBGuard guard([path UTF8String]);
    
    sqlite3* db = guard.db();
    
    if(db == NULL) {
        return NO;
    }
    
    char *errorMsg;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        //        NSLog(@"insert ok.");
        
        return YES;
    }
    
    NSLog( @"can not insert it to table, Error Message: %@ SQL: %@",
          [NSString stringWithUTF8String: errorMsg],
          sql);
    
    return NO;
    
}

//insert table
+ (BOOL)insertToDB:(id<DBProtocol>)record {
    
    
    char *errorMsg;
    
    NSString* path = [DBHelper getDBPath];
    DBGuard guard([path UTF8String]);
    
    sqlite3* db = guard.db();
    
    if(db == NULL) {
        return NO;
    }
    
    if (sqlite3_exec(db, [[record sqlForInsert] UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
        //        NSLog(@"insert ok.");
        
        return YES;
    } else {
        
        NSString* msg = [NSString stringWithUTF8String: errorMsg];
        if([msg hasPrefix:@"no such table: "]) {
            if([DBHelper createTable:db :record]) {
                
                if (sqlite3_exec(db, [[record sqlForInsert]  UTF8String], NULL, NULL, &errorMsg)==SQLITE_OK) {
                    //                    NSLog(@"insert ok.");
                    return YES;
                }
            }
        }
    }
    
    NSLog( @"can not insert it to table, Error Message: %@",[NSString stringWithUTF8String: errorMsg]  );
    return NO;
    
}

//+(NSArray*) queryFromDB {//:(NSString*) filter {
+(PMKPromise *) queryFromDB:(Class<DBProtocol>)type :(NSString*) filter {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        
        NSString* path = [DBHelper getDBPath];
        DBGuard guard([path UTF8String]);
        
        sqlite3* db = guard.db();
        if(db != NULL) {
            sqlite3_stmt* stmt;
            
            //const char* query = [[type sqlForQuery: filter] UTF8String];
            NSString* sql = [type sqlForQuery: filter];
            
            int retCode = sqlite3_prepare_v2(db, [sql UTF8String], -1, &stmt, nil);
            
            if(retCode == SQLITE_OK) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    
                    [results addObject:[type createWithDBBuffer:stmt]];
                }
                
                sqlite3_finalize(stmt);
            } else {
                NSString* msg = [NSString stringWithUTF8String:
                                 sqlite3_errmsg(db)];

                NSLog( @"Failed to query data, SQL: %@, Error Code: %d, Message: %@",

                      sql,retCode, msg);
            }
            
            
            //sqlite3_close(db);
        }
        fulfill(results);
        
    }];
}


////////////////



@end


@interface ObjectId ()

//@property (nonatomic, copy) NSString* str_;
//@property (nonatomic, readwrite) sqlite3_uint64 code;

@property (nonatomic) NSUUID* uuid;

@end

@implementation ObjectId

-(instancetype) init {
    
    if (self = [super init]){
        
        self.uuid = [[NSUUID alloc] init];
        
        //        NSLog(@"time: %lu, nsdate: %lu, 2015: %lu", timestamp, (unsigned long)[[NSDate date] timeIntervalSince1970], timeInterval2015);
        
    }
    
    return self;
}

-(instancetype) initWithString:(NSString*) str {
    if (self = [super init]){
        
        self.uuid = [[NSUUID alloc] initWithUUIDString:str];
        
    }
    
    return self;
}

//@property (nonatomic, readonly) sqlite3_uint64 code;

-(NSString*) str {
    return [self.uuid UUIDString];
}


//-(instancetype) init {
//    
//    if (self = [super init]){
//        int32_t newValue = OSAtomicIncrement32(&gOidIncrement);
//        
//        
//        struct timeval time;
//        gettimeofday(&time, NULL);
//        
//        sqlite3_uint64 timestamp = time.tv_sec - GGTimeIntervalSince2015; //[[NSDate date] timeIntervalSince1970];
//        
//        //        unsigned long timeInterval2015 = [[GGUtils dateOfYear:@"2015"]timeIntervalSince1970];
//        
//        self.code = (timestamp << 3*8) + (newValue & 0xFFFFFF);
//        
//        //        NSLog(@"time: %lu, nsdate: %lu, 2015: %lu", timestamp, (unsigned long)[[NSDate date] timeIntervalSince1970], timeInterval2015);
//        
//    }
//    
//    return self;
//}
//
//
//-(instancetype) initWithCode:(sqlite3_uint64) code{
//    if (self = [super init]) {
//        //        unsigned long timestamp = oid >> 3*8;
//        //
//        //        NSAssert(timestamp >= GGTimeIntervalSince2015, @"invalid objectId");
//        
//        self.code = code;
//    }
//    
//    return self;
//}

//-(NSDate*) getTimestamp {
//    
//}

@end
