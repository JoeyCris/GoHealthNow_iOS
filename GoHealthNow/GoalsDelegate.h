//
//  GoalsDelegate.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_GoalsDelegate_h
#define GlucoGuide_GoalsDelegate_h

#import "WeightGoal.h"
#import "ExerciseGoal.h"

@interface GoalsDelegate : NSObject


+ (instancetype)sharedService;

//- (BOOL) addWeightGoal;
//- (PMKPromise*) resetWeightGoal: (WeightGoal*) goal;

//- (BOOL) save;
-(PMKPromise *)saveGoals;
-(PMKPromise *)saveGoalsWithoutUploading;

-(PMKPromise *)cleanGoals;

-(PMKPromise*)loadGoals;

-(PMKPromise *)saveGoalsWithType:(GoalType)type;

-(PMKPromise *)cleanGoalsWithType:(GoalType)type;

-(PMKPromise*)loadGoalsWithType:(GoalType)type;

-(PMKPromise *)loadGoalsFromServer;

-(PMKPromise *)updateExerciseGoalAfterFinishWithType:(GoalType)type andCurrStep:(NSInteger)currStep;


//@property (nonatomic)  WeightGoal* weightGoal;
//@property (nonatomic)  ExerciseGoal* exerciseGoalModerateVigorous;
//@property (nonatomic)  ExerciseGoal* exerciseGoalDailyStep;
//@property (nonatomic)  ExerciseGoal* exerciseGoalWeeklyStep;

@property (nonatomic) NSMutableArray *goals;

@end

#endif
