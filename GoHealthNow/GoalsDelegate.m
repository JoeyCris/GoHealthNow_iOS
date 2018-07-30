//
//  GoalsDelegate.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GoalsDelegate.h"
#import "User.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "Constants.h"
#import "ChooseBirthYearViewController.h"

//#define GOALS_FILE @"goalsfile_%@.xml"

//@interface GoalsDelegate ()
////@property (readwrite, nonatomic)  WeightGoal* weightGoal;
//
//@end

NSString* const GOALS_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Goal_Records>  %@ </Goal_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

@interface GoalsDelegate()

@end


@implementation GoalsDelegate


+ (instancetype) sharedService {
    static GoalsDelegate* sharedService = nil;
    
    if( sharedService == nil) {
        @synchronized(self){
            if( sharedService == nil) {
                sharedService = [[self alloc] init];
            }
        }
        
    }
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //        sharedService = [[self alloc] init];
    //    });
    return sharedService;
    
}

-(instancetype)init {
    if (self = [super init]){
        self.goals = [[NSMutableArray alloc] init];
        for (int i=0;i<GOALS_TYPE_COUNT;i++) {
            [self.goals addObject:[NSNull null]];
        }
    }
    
    return self;
}

-(PMKPromise *)saveGoals {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        
        for (int i=0;i<[self.goals count];i++) {
            if ([self.goals[i] isEqual:[NSNull null]])
                continue;
            
            if ([self.goals[i] isKindOfClass:[WeightGoal class]]) {
                ((WeightGoal *)self.goals[i]).createdTime = [NSDate date];
            }
            else if ([self.goals[i] isKindOfClass:[ExerciseGoal class]]) {
                ((ExerciseGoal *)self.goals[i]).createdTime = [NSDate date];
            }
            [DBHelper insertToDB:[self.goals objectAtIndex:i]];
            
        }
            User* user = [User sharedModel];
            NSString* xmlRecord = [NSString stringWithFormat:GOALS_UPLOADING,
                                   user.userId,
                                   [self toXML],
                                   [GGUtils stringFromDate:[NSDate date]]];
            
            [[GlucoguideAPI sharedService] saveRecordWithXML:xmlRecord].then(^(id res) {
                
            }).catch(^(id res) {
                fulfill(@NO);
            });
            
        
        fulfill(@YES);
    }];
}

-(PMKPromise *)saveGoalsWithoutUploading {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        
        for (int i=0;i<[self.goals count];i++) {
            if ([self.goals[i] isEqual:[NSNull null]])
                continue;
            [DBHelper insertToDB:[self.goals objectAtIndex:i]];
        }
        fulfill(@YES);
    }];

}

-(PMKPromise *)cleanGoals {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        self.goals = nil;
        self.goals = [[NSMutableArray alloc] init];
        for (int i=0;i<GOALS_TYPE_COUNT;i++) {
            [self.goals addObject:[NSNull null]];
        }
        fulfill(@YES);
        
    }];
}

-(PMKPromise*)loadGoals {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        @try {
            self.goals[GoalTypeWeight] = [WeightGoal lastRecord];
        }
        @catch (NSException *exception) {
        }
        @finally {
        }
        @try {
            self.goals[GoalTypeExerciseModerateVigorous] = [ExerciseGoal lastRecordWithExerciseType:GoalTypeExerciseModerateVigorous];
        }
        @catch (NSException *exception) {
        }
        @finally {
            [self generateWeeklyExerciseGoalIfNotExistWithType:GoalTypeExerciseModerateVigorous];
        }
        @try {
            self.goals[GoalTypeExerciseDailyStepsCount] = [ExerciseGoal lastRecordWithExerciseType:GoalTypeExerciseDailyStepsCount];
        }
        @catch (NSException *exception) {
        }
        @finally {
            [self generateExerciseGoalIfNotExistWithType:GoalTypeExerciseDailyStepsCount];
        }
        @try {
            self.goals[GoalTypeExerciseWeeklyStepsCount] = [ExerciseGoal lastRecordWithExerciseType:GoalTypeExerciseWeeklyStepsCount];
        }
        @catch (NSException *exception) {
        }
        @finally {
            [self generateExerciseGoalIfNotExistWithType:GoalTypeExerciseWeeklyStepsCount];
        }
        
        fulfill(@YES);
        
    }];
}

-(void)generateExerciseGoalIfNotExistWithType:(GoalType)type {
    if ([self.goals[type] isEqual:[NSNull null]]) {
        User *user = [User sharedModel];
        ExerciseGoal *goal = [[ExerciseGoal alloc] init];
        goal.type = type;
        goal.createdTime = [NSDate date];
        goal.uuid = (NSString *)[[NSUUID UUID] UUIDString];
        NSUInteger age = [ChooseBirthYearViewController ageFromDate:user.dob];
        
        if (age>60) {
            goal.target = @(5000*(type==GoalTypeExerciseWeeklyStepsCount? 5:1));
        }
        else if (age<18) {
            goal.target = @(12000*(type==GoalTypeExerciseWeeklyStepsCount? 5:1));
        }
        else {
            goal.target = @(7500*(type==GoalTypeExerciseWeeklyStepsCount? 5:1));
        }
        self.goals[type] = goal;
        [self saveGoalsWithoutUploading];
    }
}

-(void)generateWeeklyExerciseGoalIfNotExistWithType:(GoalType)type{
    if ([self.goals[type] isEqual:[NSNull null]]) {
        ExerciseGoal *goal = [[ExerciseGoal alloc] init];
        goal.type = type;
        goal.createdTime = [NSDate date];
        goal.uuid = (NSString *)[[NSUUID UUID] UUIDString];
        goal.target = @150;
        
        self.goals[type] = goal;
        [self saveGoalsWithoutUploading];
    }
    
}

-(PMKPromise *)loadGoalsFromServer {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        User *user = [User sharedModel];
        [[GlucoguideAPI sharedService] getGoalsWithUserId:user.userId].then(^(id res) {
            if ([res count] == 1) {
                fulfill(@NO);
            }
            else {
                NSDictionary *weightGoal = [res objectForKey:@"WeightGoal"];
                NSDictionary *exerciseGoal = [res objectForKey:@"ExerciseGoal"];
                if (weightGoal) {
                    WeightGoal *wg = [[WeightGoal alloc] init];
                    wg.target = [[WeightUnit alloc] initWithMetric:[[weightGoal objectForKey:@"Target"] floatValue]];
                    wg.createdTime = [GGUtils dateFromString:[weightGoal objectForKey:@"RecordedTime"]];
                    wg.type = [[weightGoal objectForKey:@"Type"] intValue];
                    wg.uuid = [weightGoal objectForKey:@"Uuid"];
                    self.goals[GoalTypeWeight] = wg;
                }
                if (exerciseGoal) {
                    if ([exerciseGoal isKindOfClass:[NSArray class]]) {
                        for (NSDictionary *e in exerciseGoal) {
                            ExerciseGoal *eg = [[ExerciseGoal alloc] init];
                            eg.type = [[e objectForKey:@"Type"] intValue];
                            eg.target = [NSNumber numberWithInteger:[[e objectForKey:@"Target"] integerValue]];
                            eg.uuid = [e objectForKey:@"Uuid"];
                            eg.createdTime = [GGUtils dateFromString:[e objectForKey:@"RecordedTime"]];
                            self.goals[eg.type] = eg;
                        }
                    }
                    else {
                        ExerciseGoal *eg = [[ExerciseGoal alloc] init];
                        eg.type = [[exerciseGoal objectForKey:@"Type"] intValue];
                        eg.target = [NSNumber numberWithInteger:[[exerciseGoal objectForKey:@"Target"] integerValue]];
                        eg.uuid = [exerciseGoal objectForKey:@"Uuid"];
                        eg.createdTime = [GGUtils dateFromString:[exerciseGoal objectForKey:@"RecordedTime"]];
                        self.goals[eg.type] = eg;
                    }
                }
                fulfill(@YES);
            }
        }).catch(^(){
            fulfill(@NO);
        });
    }];
}

-(PMKPromise *)saveGoalsWithType:(GoalType)type {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (type == GoalTypeExerciseDailyStepsCount || type == GoalTypeExerciseWeeklyStepsCount) {
            ((ExerciseGoal*)self.goals[type]).createdTime = [NSDate date];
        }
        else if (type == GoalTypeWeight) {
            ((WeightGoal*)self.goals[type]).createdTime = [NSDate date];
        }
        [DBHelper insertToDB: self.goals[type]];
        
        User* user = [User sharedModel];
        
        NSString* xmlRecord = [NSString stringWithFormat:GOALS_UPLOADING,
                               user.userId,
                               [self toXMLWithType:type],
                               [GGUtils stringFromDate:[NSDate date]]];
        
        [[GlucoguideAPI sharedService] saveRecordWithXML:xmlRecord].then(^(id res) {
            fulfill(@YES);
        }).catch(^(id res) {
            fulfill(@NO);
        });
    }];
}

-(PMKPromise *)cleanGoalsWithType:(GoalType)type {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {

        self.goals[type] = [NSNull null];
        
        fulfill(@YES);
        
    }];
}

-(PMKPromise*)loadGoalsWithType:(GoalType)type {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        if (type == GoalTypeWeight) {
            self.goals[type] = [WeightGoal lastRecord];
        }
        else {
            self.goals[type] = [ExerciseGoal lastRecordWithExerciseType:type];
        }
        
        fulfill(@YES);
        
    }];
}

-(NSString*)toXML {
    NSString *rt = @"";
    for (int i=0;i<GOALS_TYPE_COUNT;i++) {
        if ([self.goals[i] isEqual:[NSNull null]])
            continue;
        NSString *appendStr = @"";
        if (i==GoalTypeWeight) {
            appendStr = [NSString stringWithFormat:@"<WeightGoal> \
                                <Uuid>%@</Uuid> \
                                <Target>%.2f</Target> \
                                <Type>%d</Type> \
                                <RecordedTime>%@</RecordedTime> \
                                </WeightGoal>",
                                ((WeightGoal *)self.goals[GoalTypeWeight]).uuid,
                                [((WeightGoal *)self.goals[GoalTypeWeight]).target valueWithMetric],
                                ((WeightGoal *)self.goals[GoalTypeWeight]).type,
                                [GGUtils stringFromDate:((WeightGoal *)self.goals[i]).createdTime]];
        }
        else {
            appendStr = [NSString stringWithFormat:@"<ExerciseGoal> \
                         <Uuid>%@</Uuid> \
                         <Type>%d</Type> \
                         <Target>%f</Target> \
                         <RecordedTime>%@</RecordedTime> \
                         </ExerciseGoal> ",
                         ((ExerciseGoal *)self.goals[i]).uuid,
                         ((ExerciseGoal *)self.goals[i]).type,
                         [((ExerciseGoal *)self.goals[i]).target doubleValue],
                         [GGUtils stringFromDate:((ExerciseGoal *)self.goals[i]).createdTime]];
        }
        rt = [NSString stringWithFormat:@"%@%@", rt, appendStr];
    }
    return rt;
}


-(NSString *)toXMLWithType:(GoalType)type {
    if (type == GoalTypeWeight) {
        return [NSString stringWithFormat:@"<WeightGoal> \
                <Uuid>%@</Uuid> \
                <Target>%.2f</Target> \
                <Type>%d</Type> \
                <RecordedTime>%@</RecordedTime> \
                </WeightGoal>",
                ((WeightGoal *)self.goals[GoalTypeWeight]).uuid,
                [((WeightGoal *)self.goals[GoalTypeWeight]).target valueWithMetric],
                ((WeightGoal *)self.goals[GoalTypeWeight]).type,
                [GGUtils stringFromDate:((WeightGoal *)self.goals[type]).createdTime]];
    }
    else {
        return [NSString stringWithFormat:@"<ExerciseGoal> \
                <Uuid>%@</Uuid> \
                <Type>%d</Type> \
                <Target>%f</Target> \
                <RecordedTime>%@</RecordedTime> \
                </ExerciseGoal> ",
                ((ExerciseGoal *)self.goals[type]).uuid,
                ((ExerciseGoal *)self.goals[type]).type,
                [((ExerciseGoal *)self.goals[type]).target doubleValue],
                [GGUtils stringFromDate:((ExerciseGoal *)self.goals[type]).createdTime]];
    }
}

-(PMKPromise *)updateExerciseGoalAfterFinishWithType:(GoalType)type andCurrStep:(NSInteger)currStep {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (type == GoalTypeExerciseDailyStepsCount) {
            if (![self.goals[GoalTypeExerciseDailyStepsCount] isEqual:[NSNull null]]) {
                if (![((ExerciseGoal *)self.goals[GoalTypeExerciseDailyStepsCount]).target isEqual:@0]) {
                    NSInteger oldTarget = [((ExerciseGoal *)self.goals[GoalTypeExerciseDailyStepsCount]).target integerValue];
                    NSInteger newTarget = oldTarget+1000;
                    if (newTarget<=currStep) {
                        newTarget = currStep + 1000;
                    }
                    ((ExerciseGoal *)self.goals[GoalTypeExerciseDailyStepsCount]).target = [NSNumber numberWithInteger:newTarget];
                    ((ExerciseGoal *)self.goals[GoalTypeExerciseDailyStepsCount]).createdTime = [NSDate date];
                    [self saveGoalsWithType:GoalTypeExerciseDailyStepsCount].then(^() {
                        fulfill(@YES);
                    });
                }
                else {
                    fulfill(@NO);
                }
            }
            else {
                fulfill(@NO);
            }
        }
        else if (type == GoalTypeExerciseWeeklyStepsCount) {
            if (![self.goals[GoalTypeExerciseWeeklyStepsCount] isEqual:[NSNull null]]) {
                if (![((ExerciseGoal *)self.goals[GoalTypeExerciseWeeklyStepsCount]).target isEqual:@0]) {
                    NSInteger oldTarget = [((ExerciseGoal *)self.goals[GoalTypeExerciseWeeklyStepsCount]).target integerValue];
                    NSInteger newTarget = oldTarget + 5000;
                    if (newTarget <= currStep) {
                        newTarget = currStep + 5000;
                    }
                    ((ExerciseGoal *)self.goals[GoalTypeExerciseWeeklyStepsCount]).target = [NSNumber numberWithInteger:newTarget];
                    ((ExerciseGoal *)self.goals[GoalTypeExerciseWeeklyStepsCount]).createdTime = [NSDate date];
                    [self saveGoalsWithType:GoalTypeExerciseWeeklyStepsCount].then(^() {
                        fulfill(@YES);
                    });
                }
                else {
                    fulfill(@NO);
                }
            }
            else {
                fulfill(@NO);
            }
        }
        else {
            fulfill(@NO);
        }
    }];
}

//- (PMKPromise*) resetWeightGoal: (WeightGoal*) goal {
//    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
//        
//        self.weightGoal = goal;
//        [DBHelper insertToDB: goal];
//        
//        fulfill(@YES);
//    
//    }];
//}

@end