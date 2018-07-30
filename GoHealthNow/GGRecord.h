//
//  GGRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-03.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_GGRecord_h
#define GlucoGuide_GGRecord_h

//#import "MealRecord.h"
//#import "GlucoseRecord.h"
//#import "SleepRecord.h"
//#import "ExerciseRecord.h"
#import "PromiseKit/PromiseKit.h"

@protocol GGRecord<NSObject>

//+ (BOOL) save:(NSArray<MealRecord>*) records;
+ (PMKPromise *)save:(NSArray*) records;

//- (BOOL) save;
-(PMKPromise *)save;

- (NSString*) toXML;

//reminders
-(PMKPromise *)saveMedication;
-(PMKPromise *)saveBG;
-(PMKPromise *)saveExercise;
-(PMKPromise *)saveMeal;
-(PMKPromise *)saveBloodPressure;


@end

#endif
