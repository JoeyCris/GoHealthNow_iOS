//
//  DBRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_DBRecord_h
#define GlucoGuide_DBRecord_h

#import "PromiseKit/PromiseKit.h"
#import <sqlite3.h>


//struct DBGuard
//{
//    DBGuard(const char* path)
//    sqlite3* db(void)
//    ~DBGuard()
//    
//private:
//    const char* path_;
//    sqlite3* db_;
//};


@protocol DBProtocol<NSObject>

- (NSString*) sqlForInsert;
//-(id)initWithDBBuffer:(void*) source;

+(id) createWithDBBuffer:(void*) source;

- (NSString*) sqlForCreateTable;
+ (NSString*) sqlForQuery:(NSString*) filter;

//NSArray<DBProtocol> queryFromDB:(NSString*) filter;
+(PMKPromise *) queryFromDB:(NSString*) filter;

@end

@interface DBHelper : NSObject

//+ (sqlite3*)openDB;
+(sqlite3_stmt* ) queryGGRecord:(const char*)sql;
+(sqlite3_stmt* ) queryDataWithPath:(const char*)sql path:(const char*) path;

+ (NSString*)getDBPath:(NSString*) userId;

+ (BOOL)insertToDB:(id<DBProtocol>)record;

+ (BOOL) executeSql:(NSString*)sql;
+ (BOOL)executeSqlWithPath:(NSString*)sql path: (NSString*) path ;

+(PMKPromise *) queryFromDB:(Class<DBProtocol>)type :(NSString*) filter ;

#pragma mark - DB Upgrade Methods

// See here for documentation:
// https://github.com/GlucoGuideRD/GlucoGuide-iOS/wiki/Upgrading-the-SQLite-Database

+ (NSDictionary *)upgradeMethodInfo;
+ (PMKPromise *)upgradeWithMethodNames:(NSArray *)upgradeMethodNames;
+ (BOOL)setDatabaseVersion:(int)newDatabaseVersion;

+ (NSNumber *)upgrade_0_to_1;

@end


//generate unique objectid with type of int64. similar as mongodb's objectId
@interface ObjectId : NSObject

//-(NSDate*) getTimestamp;
//-(instancetype) initWithCode:(sqlite3_uint64) code;

-(instancetype) initWithString:(NSString*) str;

//@property (nonatomic, readonly) sqlite3_uint64 code;

@property (nonatomic, readonly) NSString* str;

@end

#endif
