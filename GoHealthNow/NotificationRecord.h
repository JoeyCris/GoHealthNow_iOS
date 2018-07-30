//
//  ExerciseRecord.h
//  GlucoGuide
//
//  Created by John Wreford on 2015-09-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_ReminderRecord_h
#define GlucoGuide_ReminderRecord_h

#import <UIKit/UIKit.h>
#import "GGRecord.h"
#import "ServicesConstants.h"


@interface NotificationRecord : NSObject

@property (nonatomic)   NSNumber* reminderType;
@property (nonatomic)   NSString* reminderTime;
@property (nonatomic)   NSNumber *repeatType;
@property (nonatomic)   NSString *uuid;

//Medication Parameters
@property (nonatomic)   NSString *medicineDose;
@property (nonatomic)   NSString *medicineUnit;
@property (nonatomic)   NSString *medicineID;
@property (nonatomic)   NSString *medicineName;
@property (nonatomic)   NSNumber *medicineType;

- (PMKPromise *)saveMedication;
- (PMKPromise *)saveBG;
- (PMKPromise *)saveMeal;
- (PMKPromise *)saveExercise;
- (PMKPromise *)saveBloodPressure;

//BG Paramerters
@property (nonatomic)   NSNumber *glucoseType;

//Exercise Paramerters
@property (nonatomic)   NSNumber *exerciseType;

//Meal Paramerters
@property (nonatomic)   NSNumber *mealType;



@end

#endif
