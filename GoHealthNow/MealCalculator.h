//
//  MealCalculator.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-29.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Constants.h"


@interface MealCalculator : NSObject

@property (nonatomic, readonly) NSDictionary *scoringRules;

+ (id)sharedModel;
- (NSDictionary *)scoreForUser:(User *)user withFoodItems:(NSArray *)foodItems forMealType:(MealType)mealType;
//- (NSDictionary *)scoreForUser:(User *)user withQuickEstimate:(NSDictionary *)qeDict forMealType:(MealType)mealType;

// These two methods allow for the retrieval and modification of the meal target ratios
// stored in the macro nutrients XML file
- (NSDictionary *)mealTargetRatios;
- (void)updateMealTargetRatiosWithDict:(NSDictionary *)targetRatioDict;

// reset the state of the MealCalculator
- (void)reset;

+ (NSDictionary *)getQuickEstimateValuesForType:(QuickEstimateValueType)quickEstimateValueType forMeal:(MealType)mealType;

@end
