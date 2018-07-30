//
//  MealRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_MealRecord_h
#define GlucoGuide_MealRecord_h


#import "FoodItem.h" 
#import "GGRecord.h"
#import "Constants.h"
#import "DBHelper.h"
#import "GGUtils.h"

@interface MealPhoto: NSObject

@property (nonatomic) UIImage* image;
@property (nonatomic)     NSDate* createdTime;
@property (nonatomic)     NSString* note;
@property (nonatomic)     BOOL toExpert;

@end

@interface MealScore: NSObject

@property (nonatomic) NSDate* recordedDay;
@property (nonatomic) MealType type;
@property (nonatomic) float score;

+ (NSString *)getScoreRatingWithScore:(NSInteger) score;

@end



@interface MealRecord : NSObject<GGRecord, DBProtocol, NSCopying>

//+ (BOOL) save:(NSArray<MealRecord>*) records;
//+ (PMKPromise *)save:(NSArray*) records;

////+({category, NSArray<{id, name}>*}) searchFoodWithName:(NSString*) filter;
//+(PMKPromise *)  searchFoodBriefly:(NSString*) filter;
//
////+(FoodItem) searchFoodWithName:(NSString*) filter;
//+(PMKPromise *)  searchFoodDetail:(NSNumber*) foodID;

//+ (BOOL) addMealPhoto:(NSString*) filePath;
//+ (PMKPromise *)addMealPhoto:(UIImage*) image date: (NSDate*) date note: (NSString*) note;//(NSString*) filePath;
//+ (PMKPromise *)addMealPhoto:(MealPhoto*) photo;

//return type NSArray<MealRecord>
//+(PMKPromise *)  retrieveRecentMeal:(NSNumber*) maxNumber :(NSString*) filter;


//return type NSArrary<MealScore>
+ (PMKPromise *)searchDailyScore:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (PMKPromise *)searchAverageScore:(SummaryPeroidType) peroid fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;

//return type NSNumber<double value>
+ (PMKPromise *)lastMealScore;

//return type NSArrary<f@{@"calories": calories, @"recordedDay": NSDate* }>
+ (PMKPromise *)searchDailyCalories:(NSDate*)fromDate toDate:(NSDate*)toDate;

+ (PMKPromise *)searchSummaryCalories:(SummaryPeroidType) peroid fromDate: (NSDate*)fromDate toDate:(NSDate*)toDate;


//NSArray< { @"category":@"", @"rows": NSArray<MealRecord> >
+ (PMKPromise *)searchRecentMeal:(NSString*) filter;


//- (BOOL) save;
//-(PMKPromise *)save;
- (NSString*) toXML;

- (Boolean)hasMealImage;

+ (PMKPromise *)autoEstimateWithImage:(UIImage *)image;

-(void)setImage:(UIImage*) image;

-(UIImage*) loadImage;

-(UIImage*) loadIconImage; //load image with icon size

-(void) addFood:(FoodItem*) food;
- (void)updateFood:(FoodItem *)food AtIndex:(NSUInteger)index;
-(void) removeFoodAtIndex:(NSUInteger)index;

-(void)removeMealWithID:(NSString* )MealID;


@property (atomic) Boolean hasImage;
@property (atomic, retain)     ObjectId* oid;
@property (atomic, copy)     NSString* name;
@property (atomic)     float carb;//NSNumber* carb;
@property (atomic)     float pro;//NSNumber* pro;
@property (atomic)     float fat;//NSNumber* fat;
@property (atomic)     float fibre;//NSNumber* fat;
@property (atomic)     float cals;//NSNumber* cals;
@property (atomic)     float sugar;//NSNumber* sugar
//@property (nonatomic)     float protein;
@property (atomic)     float score;
@property (atomic)     MealType type;
@property (atomic)     MealCreatedType createdType;
@property (atomic)           NSDate* recordedTime;
@property (atomic,  retain)    NSArray* foods;       //NSMutableArray* foods; //NSArray<FoodItem>
@property (atomic)  NSString *note;
@property (atomic)  int providerID;
@property (atomic)  NSString *providerItemID;

@end



#endif
