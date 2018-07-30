//
//  Exercise.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-29.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_Exercise_h
#define GlucoGuide_Exercise_h

#import "GGRecord.h"
#import "DBHelper.h"
#import "Constants.h"

@interface ExerciseRecord : NSObject<GGRecord, DBProtocol>

//+ (BOOL) save:(NSArray*) records;
//+ (PMKPromise *)save:(NSArray*) records;
//
////- (BOOL) save;
-(PMKPromise *)saveToServer;

//NSArrary<{exerciseType: value}>
+ (PMKPromise *)calculateTodayCalories;
+ (PMKPromise *)calculateTodayMinutes;
+ (PMKPromise *)calculateTotalMinutesFrom:(NSDate*)fromDate toDate:(NSDate*)toDate;

//NSArrary<@{@"minutes": minutes, @"recordedDay": recordedDay}>
+ (PMKPromise *)searchDailyMinutes:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (PMKPromise *)searchSummaryMinutes:(SummaryPeroidType) peroid fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (PMKPromise *)searchRecentExerciseWithFilter:(NSString *)filter;

+(NSDictionary *)totalMinsWeek;


-(NSString*) toXML;

@property (nonatomic)     NSNumber* minutes;
@property (nonatomic)     NSNumber* calories;
//@property (nonatomic)     NSNumber* interval;
@property (nonatomic)           NSDate* recordedTime;
@property (nonatomic)           ExerciseType type;

@property (nonatomic)   NSNumber *entryType;
@property (nonatomic)   NSDate *recordEntryTime;
@property (nonatomic)   NSNumber *steps;
@property (nonatomic)   NSString *uuid;
@property (nonatomic)   NSString *note;

@end

#endif
