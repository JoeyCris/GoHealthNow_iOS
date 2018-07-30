//
//  MealCalculator.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-29.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "MealCalculator.h"
#import "XMLDictionary/XMLDictionary.h"
#import "FoodItem.h"
#import "User.h"
#import <Math.h>
#import "CalorieDistribution.h"

float Default_Float_Max = 100;
float Default_Float_Min = -100;

@interface MealCalculator ()

@property (nonatomic) float totalAdjustmentScore;
@property (nonatomic) float totalScore;
@property (nonatomic) NSMutableArray *adjustmentStatements;

@property (nonatomic) NSDictionary *scoringRules;
@property (nonatomic) float subTargetRatio; // Protien, Fat, Carbs

@end

@implementation MealCalculator
@synthesize subTargetRatio;

+ (id)sharedModel {
    static MealCalculator* sharedModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc] init];
    });
    
    return sharedModel;
}

- (NSDictionary *)scoringRules {
    if (!_scoringRules) {
        _scoringRules = [[User sharedModel] scoringMacroDict];
    }
    
    return _scoringRules;
}

- (void)reset {
    self.scoringRules = nil;
    NSLog(@"NILLING SCORING RULES");
}

- (NSDictionary *)mealTargetRatios {
    NSMutableDictionary *targetRatioDict = [[NSMutableDictionary alloc] init];
    
    NSDictionary *allMeals = [self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD];
    for (NSDictionary *meals in allMeals) {
        if ([[meals objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_QUCIK_ESTIMATE]) {
            NSArray *dailyMeal = [meals valueForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL];

            for (NSDictionary *meal in dailyMeal) {
                NSDictionary *nutrition = [meal[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION] lastObject];
                NSNumber *targetRatio = nutrition[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO];
                NSString *mealType = meal[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE];
                
                if ([mealType isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK]) {
                    targetRatio = [NSNumber numberWithFloat:[targetRatio floatValue] * 3.0];
                }
                
                targetRatioDict[mealType] = targetRatio;
            }
            
            break;
        }
    }
    
    return targetRatioDict;
}

- (void)updateMealTargetRatiosWithDict:(NSDictionary *)targetRatioDict {
    // validate that the ratios add up to one
    CGFloat ratioSum = 0;
    for (NSString *mealType in targetRatioDict) {
        ratioSum += [targetRatioDict[mealType] floatValue];
    }

    if (roundf(ratioSum * 100) / 100.0 == 1.0 == 1.0) {
        NSDictionary *allMeals = [self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD];
        for (NSDictionary *meals in allMeals) {
            NSArray *dailyMeal = [meals valueForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL];
            
            for (NSDictionary *meal in dailyMeal) {
                NSString *mealType = meal[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE];
                
                for (NSMutableDictionary *nutrition in meal[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION]) {
                    // check if the target ratio key is present before changing it
                    if ([nutrition objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO])
                    {
                        if ([mealType isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK]) {
                            nutrition[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] = [NSNumber numberWithFloat:[targetRatioDict[mealType] floatValue] / 3.0];
                        }
                        else {
                            nutrition[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] = targetRatioDict[mealType];
                        }
                    }
                }
            }
        }
    }
}

/*
 Dict Structure {
 @"Calories":{
                @"min":float
                @"max":float
                @"curr":float
                @"ratio":float
                @"calsperunit":float
                }
 @"Carbs":{
            }
 @"Fats":{
            }
 @"Protein":{
                }
 }
 */


//See Nutrution Facts (BUTTON) (Gauges)
+ (NSDictionary *)getQuickEstimateValuesForType:(QuickEstimateValueType)quickEstimateValueType forMeal:(MealType)mealType {

    NSDictionary *scoreRulesTmp = [[User sharedModel] scoringMacroDict];
    
    NSMutableDictionary *rt = [[NSMutableDictionary alloc] init];

    float rangeFactor = [[scoreRulesTmp objectForKey:MACRO_NEXML_MEAL_SCORING_RANGEFACTOR] floatValue];
    //float maxProgress = [[scoreRulesTmp objectForKey:MACRO_NEXML_MEAL_SCORING_MAXPROGRESS] floatValue];
    
    float targetCalories = [[User sharedModel] getTargetCalories];
    
    NSDictionary *allMeals = [scoreRulesTmp objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD];
    for (NSDictionary *meals in allMeals) {
        if ([[meals objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_QUCIK_ESTIMATE]) {
            NSArray *dailyMeal = [meals valueForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL];
            NSArray *nutrition;
            for (NSDictionary *meal in dailyMeal) {
                nutrition = [meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION];
                if (mealType == MealTypeSnack && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK]) {
                    break;
                }
                else if (mealType == MealTypeBreakfast && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST]) {
                    break;
                }
                else if (mealType == MealTypeLunch && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH]) {
                    break;
                }
                else if (mealType == MealTypeDinner && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER]) {
                    break;
                }
            }
            
            float subTargetRatio;
            
            float target = targetCalories * [[nutrition[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] floatValue];
            for (int i=0;i<4;i++) {
                
                
                
                ///IF STATEMENT TRUMPS XML (NUTRITION MACRO) FILE AND REPLACES CARBS/PRO/FAT WITH SERVER PROVIDED VALUES
                
                if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Carbs"]) {
                    
                    subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Carbs"] floatValue];
                    
                }else if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Protein"]) {
                    
                    subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Protein"] floatValue];
                    
                }else if  ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Fats"]) {
                    
                    subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue];
                    
                }else{
                    
                    subTargetRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                }
                
                ////
                
                float calsPerUnit = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT] floatValue];
                float min = target * rangeFactor * subTargetRatio;
                float max = target * (1 + (1 - rangeFactor)) * subTargetRatio;
                
                NSString *key;
                
                if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CALORIES]) {
                    key = @"Calories";
                }
                else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CARBS]) {
                    key = @"Carbs";
                }
                else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FATS]) {
                    key = @"Fats";
                }
                else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_PROTEIN]) {
                    key = @"Protein";
                }
                
                float curr = quickEstimateValueType == QuickEstimateValueTypeIdeal ? max/calsPerUnit/2 : 0.0;
                
                NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithFloat:min/calsPerUnit], @"min",
                                                                                 [NSNumber numberWithFloat:max/calsPerUnit], @"max",
                                                                                 [NSNumber numberWithFloat:curr], @"curr",
                                                                                 [NSNumber numberWithFloat:subTargetRatio], @"ratio",
                                                                                 [NSNumber numberWithFloat:calsPerUnit], @"calsperunit",
                                                                                 nil];
                [rt setObject:tmp forKey:key];
            }
            break;
        }
    }
    return rt;
}

/*
 qeDict structure requirement
 ////////////////////////////////////////  /\___/\
 @{                                     / ( o   o )        orz..                  Not $998, Not $98, ONLY $9.8(+HST)!!
    @"Calories":float                   / (  =^=  )         orz...                                / \
    @"Carbs":float                      / (        )         orz...                              / ! \
    @"Fats":float                       / (         )                                           /_OMG_\
    @"Protein":float                    / (          )))))))))))                                  | |
        }                               /       Felix is a fatty----------->>>> Miracle App 1000Kg->10Kg in 1 Month
 ////////////////////////////////////////           Use GoHealthNow :)))))))) ASAP!!
 */
/*
- (NSDictionary *)scoreForUser:(User *)user withQuickEstimate:(NSDictionary *)qeDict forMealType:(MealType)mealType {
    self.totalScore = 100.0;
    float subScoreCaloriesMinus = 0.0f;
    float subScoreCarbsMinus = 0.0f;
    float subScoreFatsMinus = 0.0f;
    float subScoreProteinMinus = 0.0f;
    float subScoreSugarMinus = 0.0f;
    
    float calories = [[qeDict objectForKey:@"Calories"] floatValue];
    float carbs = [[qeDict objectForKey:@"Carbs"] floatValue];
    float fats = [[qeDict objectForKey:@"Fats"] floatValue];
    float protein = [[qeDict objectForKey:@"Protein"] floatValue];
    float sugar = [[qeDict objectForKey:@"Sugar"] floatValue]; 
    
    NSMutableArray *recommendations = [[NSMutableArray alloc] initWithCapacity:0];
    
    //float rangeFactor = [[self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_RANGEFACTOR] floatValue];
    //float maxProgress = [[self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_MAXPROGRESS] floatValue];
    
    float targetCalories = [[User sharedModel] getTargetCalories];
    
    NSDictionary *allMeals = [self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD];
    for (NSDictionary *meals in allMeals) {
        if ([[meals objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_QUCIK_ESTIMATE]) {
            NSArray *dailyMeal = [meals valueForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL];
            NSArray *nutrition;
            for (NSDictionary *meal in dailyMeal) {
                nutrition = [meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION];
                if (mealType == MealTypeSnack && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK]) {
                    break;
                }
                else if (mealType == MealTypeBreakfast && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST]) {
                    break;
                }
                else if (mealType == MealTypeLunch && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH]) {
                    break;
                }
                else if (mealType == MealTypeDinner && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER]) {
                    break;
                }
            }
            float target = targetCalories * [[nutrition[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] floatValue];
            
            if (mealType == MealTypeSnack) {
                for (int i=0;i<4;i++) {
                    
                    ///IF STATEMENT TRUMPS XML (NUTRITION MACRO) FILE AND REPLACES CARBS/PRO/FAT WITH SERVER PROVIDED VALUES
                    
                    if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Carbs"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Carbs"] floatValue];
                        
                    }else if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Protein"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Protein"] floatValue];
                        
                    }else if  ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Fats"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue];
                        
                    }else{
                        
                        subTargetRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                    }
                    
                    ////
                    
                    float ideal = target * subTargetRatio;
                    float scoreP = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ATTR] floatValue];
                    if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CALORIES]) {
                        //Calories
                        subScoreCaloriesMinus = (fabsf(calories - ideal) / ideal) * scoreP;
                        if (subScoreCaloriesMinus > scoreP)
                            subScoreCaloriesMinus = scoreP;
                    }
                }
            }
            else {
                for (int i=0;i<4;i++) {
                    
                    ///
                    
                    if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Carbs"]) {
                       
                       subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Carbs"] floatValue];
                    
                    }else if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Protein"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Protein"] floatValue];
                        
                    }else if  ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Fats"]) {
                    
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue];

                    }else{
                        
                        subTargetRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                        
                    }
                    
                    ////

                    float calsPerUnit = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT] floatValue];
                    float ideal = target * subTargetRatio;
                    float scoreP = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ATTR] floatValue];
                    if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CARBS]) {
                        //Carbs
                        subScoreCarbsMinus = (fabsf(carbs * calsPerUnit - ideal) / ideal) * scoreP;
                        if (subScoreCarbsMinus > scoreP)
                            subScoreCarbsMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FATS]) {
                        //Fats
                        subScoreFatsMinus = (fabsf(fats * calsPerUnit - ideal)  / ideal) * scoreP;
                        if (subScoreFatsMinus > scoreP)
                            subScoreFatsMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_PROTEIN]) {
                        //Protein
                        subScoreProteinMinus = (fabsf(protein * calsPerUnit - ideal) / ideal) * scoreP;
                        if (subScoreProteinMinus > scoreP)
                            subScoreProteinMinus = scoreP;
                    }
                    else
                        continue;
                }
            }
            break;
        }
    }
    
    float SugarOfCarbs = (sugar / carbs) * 100;
    
    
    if (mealType != MealTypeSnack) {
        if (SugarOfCarbs >= 71) {
            subScoreSugarMinus = 25;
        }else if (SugarOfCarbs >= 50){
            subScoreSugarMinus = 5;
        }
    }
    
    self.totalScore -= subScoreCaloriesMinus +subScoreCarbsMinus +subScoreFatsMinus +subScoreProteinMinus +subScoreSugarMinus;
    
    if (self.totalScore < 0){
        self.totalScore = 0;
    }
    
    NSDictionary *nutritionFacts = [self nutritionFactsForUser:user withFoodItems:nil orQuickEstimateMeal:qeDict];
    
    return @{
             MC_SCORE_KEY: [NSNumber numberWithFloat:self.totalScore],
             MC_NUTRITION_FACTS_KEY: nutritionFacts,
             MC_ADJUST_STATEMENTS_KEY: recommendations
             };
}
*/

// Picture / Manual Search
- (NSDictionary *)scoreForUser:(User *)user withFoodItems:(NSArray *)foodItems forMealType:(MealType)mealType {
    
    self.totalScore = 100;
    
    NSDictionary *nutritionFacts = [self nutritionFactsForUser:user withFoodItems:foodItems orQuickEstimateMeal:nil];
    NSMutableArray *recommendations = [[NSMutableArray alloc] initWithObjects:@{},@{},@{},@{}, nil];
    
    float subScoreCaloriesMinus = 0.0f;
    float subScoreNetCarbsMinus = 0.0f;
    float subScoreFatsMinus = 0.0f;
    float subScoreProteinMinus = 0.0f;
    float subScoreSugarMinus = 0.0f;
    float subScoreFiberMinus = 0.0f;
    float subScoreUnhealthyFatMinus = 0.0f;
    float subScoreSodiumMinus = 0.0f;
    
    float calories = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_CAL] floatValue];
    float carbs = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_CARB] floatValue];
    float fats = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_FAT] floatValue];
    float protein = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_PRO] floatValue];
    float fiber = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_FIB] floatValue];
    float sodium = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_SODIUM] floatValue];
    float sugar = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][@"sugar"] floatValue];
    
    //float rangeFactor = [[self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_RANGEFACTOR] floatValue];
    //float maxProgress = [[self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_MAXPROGRESS] floatValue];
    
    float targetCalories = [[User sharedModel] getTargetCalories];
    
    NSDictionary *allMeals = [self.scoringRules objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD];
    for (NSDictionary *meals in allMeals) {
        if ([[meals objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_LOGTYPE_ATTR_SEARCH]) {
            NSArray *dailyMeal = [meals valueForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL];
            NSArray *nutrition;
            for (NSDictionary *meal in dailyMeal) {
                nutrition = [meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION];
                if (mealType == MealTypeSnack && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK]) {
                    break;
                }
                else if (mealType == MealTypeBreakfast && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST]) {
                    break;
                }
                else if (mealType == MealTypeLunch && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH]) {
                    break;
                }
                else if (mealType == MealTypeDinner && [[meal objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER]) {
                    break;
                }
            }
            float target = targetCalories * [[nutrition[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] floatValue];
            
            if (mealType == MealTypeSnack) {
                for (int i=0;i<8;i++) {
                    
                    ///
                    
                    if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Carbs"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Carbs"] floatValue];
                        
                    }else if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Protein"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Protein"] floatValue];
                        
                    }else if  ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Fats"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue];
                        
                    }else{
                        
                        subTargetRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                        
                    }
                    
                    ////
                    
                    float ideal = target * subTargetRatio;
                    float scoreP = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ATTR] floatValue];
                    if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CALORIES]) {
                        //Calories
                        //subScoreCaloriesMinus = (fabsf(calories - ideal) / ideal) * scoreP;
                        if (calories >= ideal) {
                            subScoreCaloriesMinus = [self calculateScoreDeductionWithDelta:(fabsf(calories - ideal) / ideal) andScoreP:scoreP];
                        }
                        if (subScoreCaloriesMinus > scoreP)
                            subScoreCaloriesMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FIBER]) {
                        //Fiber
                        NSString *statement;
                        NSString *flag;
                        float lowBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_LOWBOUND] floatValue];
                        
                        if (fiber < lowBound)
                            subScoreFiberMinus = 5;
                        
                        if (fiber<lowBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[0] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_UNHEALTHYFAT]) {
                        //UnHealthyFat
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        float uFat = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_SATUREDFAT] floatValue] + [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_TRANSFAT] floatValue];

                        float calRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] floatValue];
                        float subCalRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                        float idealCalRatio = calRatio * subCalRatio;
                        
                        //float prct = uFat/([[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue]*targetCalories/9);
                        float prct = uFat/(idealCalRatio*targetCalories/9);
                        
                        if (prct>highBound)
                            subScoreUnhealthyFatMinus = 5;
                        
                        if (prct>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[1] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SODIUM]) {
                        //Sodium
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        
                        if (sodium > highBound)
                            subScoreSodiumMinus = 5;
                        
                        if (sodium>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[2] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SUGAR_RATIO]) {
                        //Sugar
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        float lowBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_LOWBOUND] floatValue];
                        
                        float sugarRatio = sugar / carbs;
                        if (sugar > 15 && sugarRatio > highBound)
                            subScoreSugarMinus = 5*5;
                        else if (sugarRatio <= highBound && sugarRatio >= lowBound)
                            subScoreSugarMinus = 5;
                        else
                            subScoreSugarMinus = 0;
                        
                        if (sugar>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        
                        if ([statement isEqualToString:@""])
                            statement = @"--";
                        
                        recommendations[3] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else
                        continue;
                }
            }
            else {
                for (int i=0;i<8;i++) {
                   
                    ///
                    
                    if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Carbs"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Carbs"] floatValue];
                        
                    }else if ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Protein"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Protein"] floatValue];
                        
                    }else if  ([[nutrition[i] objectForKey:@"_name"] isEqualToString:@"Fats"]) {
                        
                        subTargetRatio = [[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue];
                        
                    }else{
                        
                        subTargetRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                        
                    }
                    
                    ////
                    
                    float calsPerUnit = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_CALSPERUNIT] floatValue];
                    float ideal = target * subTargetRatio;
                    float scoreP = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ATTR] floatValue];
                    if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_CARBS]) {
                        //Net Carbs
                        subScoreNetCarbsMinus = [self calculateScoreDeductionWithDelta:(fabsf(carbs * calsPerUnit - ideal) / ideal) andScoreP:scoreP];
                        //subScoreNetCarbsMinus = (fabsf(netCarbs * calsPerUnit - ideal) / ideal) * scoreP;
                        if (subScoreNetCarbsMinus > scoreP)
                            subScoreNetCarbsMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FATS]) {
                        //Fats
                        subScoreFatsMinus = [self calculateScoreDeductionWithDelta:(fabsf(fats * calsPerUnit - ideal)  / ideal) andScoreP:scoreP];
                        //subScoreFatsMinus = (fabsf(fats * calsPerUnit - ideal)  / ideal) * scoreP;
                        if (subScoreFatsMinus > scoreP)
                            subScoreFatsMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_PROTEIN]) {
                        //Protein
                        subScoreProteinMinus = [self calculateScoreDeductionWithDelta:(fabsf(protein * calsPerUnit - ideal) / ideal) andScoreP:scoreP];
                        //subScoreProteinMinus = (fabsf(protein * calsPerUnit - ideal) / ideal) * scoreP;
                        if (subScoreProteinMinus > scoreP)
                            subScoreProteinMinus = scoreP;
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_FIBER]) {
                        //Fiber
                        NSString *statement;
                        NSString *flag;
                        float lowBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_LOWBOUND] floatValue];
                        
                        if (fiber < lowBound)
                            subScoreFiberMinus = 5;
                        
                        if (fiber<lowBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[0] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_UNHEALTHYFAT]) {
                        //UnHealthyFat
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        float calRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_TARGETRATIO] floatValue];
                        float subCalRatio = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_SUBTARGETRATIO] floatValue];
                        float idealCalRatio = calRatio * subCalRatio;
                        
                        float uFat = [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_SATUREDFAT] floatValue] + [nutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_TRANSFAT] floatValue];
                        //float prct = uFat/([[[[CalorieDistribution sharedService] getCalorieDistribDictionary] objectForKey:@"Fat"] floatValue]*targetCalories/9);
                        float prct = uFat/(idealCalRatio*targetCalories/9);
                        
                        if (prct>highBound)
                            subScoreUnhealthyFatMinus = 5;
                        
                        if (prct>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[1] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SODIUM]) {
                        //Sodium
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        
                        if (sodium > highBound)
                            subScoreSodiumMinus = 5;
                        
                        if (sodium>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        recommendations[2] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else if ([[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_NAME_ATTR_SUGAR_RATIO]) {
                        //Sugar
                        NSString *statement;
                        NSString *flag;
                        float highBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_HIGHBOUND] floatValue];
                        float lowBound = [[nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_LOWBOUND] floatValue];

                        float sugarRatio = sugar / carbs;
                        if (sugar > 15 && sugarRatio > highBound)
                            subScoreSugarMinus = 5*5;
                        else if (sugarRatio <= highBound && sugarRatio >= lowBound)
                            subScoreSugarMinus = 5;
                        else
                            subScoreSugarMinus = 0;
                        
                        if (sugarRatio>highBound) {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_WARNINGSTATEMENT_FLAG;
                        }
                        else {
                            statement = [nutrition[i] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT];
                            flag = MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG;
                        }
                        
                        if ([statement isEqualToString:@""])
                            statement = @"--";
                        
                        recommendations[3] = @{ MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT:statement,
                                                MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG:flag};
                    }
                    else
                        continue;
                }

            }
            break;
        }
    }
    /*
    float SugarOfCarbs = (sugar / carbs) * 100;
    
    NSLog(@"Sugar: %f / Carbs: %f = %f", sugar, carbs, SugarOfCarbs);
    
    if (SugarOfCarbs >= 71) {
        subScoreSugarMinus = 25;
        
    }else if (SugarOfCarbs >= 50){
        subScoreSugarMinus = 5;
    }
    */
    
    
    //if (mealType != MealTypeSnack) {
        self.totalScore -= (int)(subScoreCaloriesMinus +subScoreNetCarbsMinus +subScoreFatsMinus +subScoreProteinMinus +subScoreSugarMinus +subScoreFiberMinus +subScoreUnhealthyFatMinus +subScoreSodiumMinus);
    /*}else{
        self.totalScore -= (int)(subScoreCaloriesMinus +subScoreNetCarbsMinus +subScoreFatsMinus +subScoreProteinMinus +subScoreSugarMinus +subScoreFiberMinus);
    }
    */
    if (self.totalScore < 0){
        self.totalScore = 0;
    }
    
    NSLog([NSString stringWithFormat:@"SCORE DEDUCTION FACT\nCalories:%.6f\nNetCarb:%.6f\nFat:%.6f\nProtein:%.6f\nSugar:%.6f\nFiber:%.6f\nUFat:%.6f\nSodium:%.6f\n", subScoreCaloriesMinus,
           subScoreNetCarbsMinus, subScoreFatsMinus, subScoreProteinMinus, subScoreSugarMinus, subScoreFiberMinus, subScoreUnhealthyFatMinus, subScoreSodiumMinus]);

    return @{
             MC_SCORE_KEY: [NSNumber numberWithFloat:self.totalScore],
             MC_NUTRITION_FACTS_KEY: nutritionFacts,
             MC_ADJUST_STATEMENTS_KEY: recommendations
             };
}

- (float)calculateScoreDeductionWithDelta:(float)delta andScoreP:(float)scoreP {
    static	double	fourthOrderPar	=	2368;
    static	double	thirdOrderPar	=	-3896;
    static	double	secondOrderPar	=	2042;
    static  double	firstOrderPar = 11;
    static	double	ratio	=	1.0f/525.0f;
    double	deductionRatio = ratio * (fourthOrderPar * pow(delta, 4) + thirdOrderPar * pow(delta, 3) + secondOrderPar * pow(delta,2) + firstOrderPar* pow(delta, 1));
    return	(float)deductionRatio * scoreP;
    
}

- (void)adjustScoreWithRule:(NSDictionary *)scoreRule withNutritionFactValue:(NSNumber *)nutritionFactValue {
    float nutritionFactFloatValue = [nutritionFactValue floatValue];
    
    NSArray *scoreRuleAdjustments = nil;
    if ([scoreRule[MC_XML_TAG_ADJUSTMENT] isKindOfClass:[NSDictionary class]]) {
        scoreRuleAdjustments = @[scoreRule[MC_XML_TAG_ADJUSTMENT]];
    }
    else {
        scoreRuleAdjustments = scoreRule[MC_XML_TAG_ADJUSTMENT];
    }
    
    NSString* statement = nil;
    NSString* scoreType = nil;
    
    float adjustmentScore = 0.0;

    for (NSDictionary *adjustment in scoreRuleAdjustments) {

        float scoreRuleLowerBound = Default_Float_Min;
        float scoreRuleUpperBound = Default_Float_Max;
        
        if(![adjustment[MC_XML_ADJUSTMENT_HIGH_ATTR] isEqualToString: MC_XML_ADJUSTMENT_INF_VALUE]) {
            scoreRuleUpperBound = [(NSString*)adjustment[MC_XML_ADJUSTMENT_HIGH_ATTR] floatValue];
        }
        
        if(![adjustment[MC_XML_STATEMENT_LOW_ATTR] isEqualToString: MC_XML_ADJUSTMENT_MINUS_INF_VALUE]) {
            scoreRuleLowerBound = [(NSString*)adjustment[MC_XML_STATEMENT_LOW_ATTR] floatValue];
        }
        
        if (nutritionFactFloatValue >= scoreRuleLowerBound && nutritionFactFloatValue <=scoreRuleUpperBound) {
            float interval = [(NSString*)adjustment[MC_XML_ADJUSTMENT_INTERVAL_ATTR] floatValue];
            
            float factor = 0;
            if(scoreRuleLowerBound != Default_Float_Min) {
                scoreType = MC_XML_STATEMENT_SCORETYPE_HIGH;//@"high";
                factor = (nutritionFactFloatValue - scoreRuleLowerBound)/ interval;
            } else if(scoreRuleUpperBound != Default_Float_Max) {
                scoreType = MC_XML_STATEMENT_SCORETYPE_BELOW;//@"below";
                factor = (scoreRuleUpperBound - nutritionFactFloatValue )/interval;
            }
            
            adjustmentScore += factor * [(NSString*)adjustment[MC_XML_ADJUSTMENT_SCORE_ATTR] floatValue];
        }
        
        //self.totalScore += self.totalAdjustmentScore;

    }
    

    NSArray* pointStatements = nil;
    
    if ([scoreRule[MC_XML_TAG_POINTSTATEMENT] isKindOfClass:[NSDictionary class]]) {
        pointStatements = @[scoreRule[MC_XML_TAG_POINTSTATEMENT]];
    }
    else {
        pointStatements = scoreRule[MC_XML_TAG_POINTSTATEMENT];
    }
    
    float absoluteScore = fabsf(adjustmentScore);
    for (NSDictionary *point in pointStatements) {
        if(absoluteScore <=5) {
            scoreType = MC_XML_STATEMENT_SCORETYPE_BALANCE; //@"balance";
        }
        
        if([scoreType isEqualToString:point[MC_XML_STATEMENT_TYPE_ATTR]]) {
            float lowPointBound = [(NSString*)point[MC_XML_STATEMENT_LOW_ATTR] floatValue];
            float highPointBound = Default_Float_Max;
            
            if(![point[MC_XML_STATEMENT_HIGH_ATTR] isEqualToString:MC_XML_ADJUSTMENT_INF_VALUE]) {
                highPointBound = [(NSString*)point[MC_XML_STATEMENT_HIGH_ATTR] floatValue];
            }
            
            if( absoluteScore >= lowPointBound
               && absoluteScore <= highPointBound) {
                statement = point[MC_XML_STATEMENT_TEXT];
            }
        }
    }
    
    self.totalAdjustmentScore += adjustmentScore;
    
    if(statement != nil) {
        [self.adjustmentStatements addObject:statement];
        
        //for test
//        NSDictionary *adjustmentStatements = @{@"statement": statement,
//                                               @"adjustmentScore": [NSNumber numberWithFloat:adjustmentScore]};
//        [self.adjustmentStatements addObject:adjustmentStatements];
    }
}

- (NSDictionary *)nutritionFactsForUser:(User *)user withFoodItems:(NSArray *)foodItems orQuickEstimateMeal:(NSDictionary *)qeDict {
    float targetCalories = [user getTargetCalories];//[self dailyTargetCaloriesForUser:user];
    
    float mealCaloriesRatio = 0.0;
    float carbsCaloriesRatio = 0.0;
    float sugarCaloriesRatio = 0.0;
    float fatCaloriesRatio = 0.0;
    float proCaloriesRatio = 0.0;
    
    float transFatRatio = 0.0;
    float satureFatRatio = 0.0;
    float unhealthyFatRatio = 0.0;
    
    float fiberAmount = 0.0;
    float carbAmount = 0.0;
    float proAmount = 0.0;
    float fatAmount = 0.0;
    float sugarAmount = 0.0;
    float calAmount = 0.0;
    
    //
    float starchAmount = 0.0;
    float saturedFatAmount = 0.0;
    float transFatAmount = 0.0;
    float sodiumAmount = 0.0;
    
    if (foodItems != nil) {
        for (FoodItem *foodItem in foodItems) {
            carbAmount += foodItem.carbs * foodItem.portionSize;
            proAmount += foodItem.protein * foodItem.portionSize;
            fatAmount += foodItem.fat * foodItem.portionSize;
            fiberAmount += foodItem.fibre * foodItem.portionSize;
            sugarAmount += foodItem.sugar * foodItem.portionSize;
            saturedFatAmount += foodItem.saturatedFat * foodItem.portionSize;
            transFatAmount += foodItem.transFat * foodItem.portionSize;
            sodiumAmount += foodItem.sodium * foodItem.portionSize;
            
            starchAmount += (foodItem.carbs - foodItem.fibre - foodItem.sugar) * foodItem.portionSize;
            
            calAmount += foodItem.calories * foodItem.portionSize;
            
        }
        
        //calAmount = carbAmount * 4 + proAmount * 4 + fatAmount * 9;
        //calAmount = (sugarAmount + proAmount + starchAmount) * 4 + fiberAmount * 2 + fatAmount * 9;
        
        mealCaloriesRatio = calAmount / targetCalories;
        carbsCaloriesRatio = carbAmount * 4 / calAmount;
        sugarCaloriesRatio = sugarAmount * 4 / calAmount;
        fatCaloriesRatio = fatAmount * 9 / calAmount;
        proCaloriesRatio = proAmount * 4 / calAmount;
        
        transFatRatio = transFatAmount * 9 / calAmount;
        satureFatRatio = saturedFatAmount * 9 / calAmount;
        unhealthyFatRatio = (transFatAmount + saturedFatAmount) / fatAmount;
    }
    else if (qeDict != nil) {
        float calories = [[qeDict objectForKey:@"Calories"] floatValue];
        float carbs = [[qeDict objectForKey:@"Carbs"] floatValue];
        float fats = [[qeDict objectForKey:@"Fats"] floatValue];
        float protein = [[qeDict objectForKey:@"Protein"] floatValue];
        
        calAmount = calories;
        carbAmount = carbs;
        fatAmount = fats;
        proAmount = protein;
    }
    
    
    return @{
             MC_NUTRITION_KEY_AMOUNTS: @{
                     MC_NUTRITION_KEY_FIB: [NSNumber numberWithFloat:fiberAmount],
                     MC_NUTRITION_KEY_SUG: [NSNumber numberWithFloat:sugarAmount],
                     MC_NUTRITION_KEY_FAT: [NSNumber numberWithFloat:fatAmount],
                     MC_NUTRITION_KEY_PRO: [NSNumber numberWithFloat:proAmount],
                     MC_NUTRITION_KEY_CAL: [NSNumber numberWithFloat:calAmount],
                     MC_NUTRITION_KEY_CARB: [NSNumber numberWithFloat:carbAmount],
                     MC_NUTRITION_KEY_STARCH: [NSNumber numberWithFloat:starchAmount],
                     MC_NUTRITION_KEY_SATUREDFAT: [NSNumber numberWithFloat:saturedFatAmount],
                     MC_NUTRITION_KEY_TRANSFAT: [NSNumber numberWithFloat:transFatAmount],
                     MC_NUTRITION_KEY_SODIUM: [NSNumber numberWithFloat:sodiumAmount],
                     MC_NUTRITION_KEY_NETCARB: [NSNumber numberWithFloat:carbAmount - fiberAmount]
                     },
             MC_NUTRITION_KEY_CAL_RATIOS: @{
                     MC_NUTRITION_KEY_CAL: [NSNumber numberWithFloat:mealCaloriesRatio],
                     MC_NUTRITION_KEY_CARB: [NSNumber numberWithFloat:carbsCaloriesRatio],
                     MC_NUTRITION_KEY_SUG: [NSNumber numberWithFloat:sugarCaloriesRatio],
                     MC_NUTRITION_KEY_FAT: [NSNumber numberWithFloat:fatCaloriesRatio],
                     MC_NUTRITION_KEY_PRO: [NSNumber numberWithFloat:proCaloriesRatio],
                     MC_NUTRITION_KEY_SATUREDFAT: [NSNumber numberWithFloat:satureFatRatio],
                     MC_NUTRITION_KEY_TRANSFAT: [NSNumber numberWithFloat:transFatRatio],
                     MC_NUTRITION_KEY_UNHEALTHYFAT: [NSNumber numberWithFloat:unhealthyFatRatio]
                     }
             };
}

@end
