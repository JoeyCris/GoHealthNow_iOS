//
//  ExerciseGoal.h
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-04-02.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ExerciseRecord.h"
#import "Constants.h"


@interface ExerciseGoal : NSObject<DBProtocol>

@property (nonatomic) GoalType type;
@property (nonatomic) NSNumber *target;
@property (nonatomic, copy) NSDate *createdTime;
@property (nonatomic) NSString *uuid;

+ (instancetype)lastRecord;
+ (instancetype) lastRecordWithExerciseType:(GoalType)type;

@end
