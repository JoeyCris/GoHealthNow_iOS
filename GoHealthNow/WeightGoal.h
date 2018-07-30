//
//  WeightGoal.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_WeightGoal_h
#define GlucoGuide_WeightGoal_h

#import "WeightRecord.h"
#import "Constants.h"

extern NSString * const WEIGHT_GOAL_OPTIONS_DESC_KEY;
extern NSString * const WEIGHT_GOAL_OPTIONS_VAL_KEY;
extern NSString * const WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY;
extern NSString * const WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY;

@interface WeightGoal : NSObject<DBProtocol>

@property (nonatomic, retain) WeightUnit* target; //lost xxx lb per week
//@property (nonatomic) NSUInteger duration;
@property (nonatomic, copy) NSDate* createdTime;

@property (nonatomic) NSString *uuid;
@property (nonatomic) WeightGoalType type;

//NSArray<@"description":@"", @"value": float>
+(NSArray*) getOptions;

+ (instancetype)lastRecord;

-(float) getDailyCalaries;
//-(instancetype)createWithDictionary:(NSDictionary*) dict;

@end

#endif
