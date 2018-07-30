//
//  Food.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_Food_h
#define GlucoGuide_Food_h

#import <UIKit/UIKit.h>
#import "PromiseKit/PromiseKit.h"
#import "DBHelper.h"
#import "Constants.h"

#define MAX_RESULTS_FOR_ONLINE_FOOD_SEARCH 50

@interface ServingSize: NSObject<NSCopying, DBProtocol>

@property (nonatomic) long long foodId;
@property (nonatomic) NSUInteger ssId;
@property (nonatomic, copy)     NSString* name;
@property (nonatomic) float convertFact;

@property (nonatomic, readonly)           float transFat;
@property (nonatomic, readonly)           float saturatedFat;
@property (nonatomic, readonly)           float protein; //g
//@property (nonatomic, readonly)           float iron; //mg
@property (nonatomic, readonly)           float fat; //g
@property (nonatomic, readonly)           float sugar;
@property (nonatomic, readonly)           float carbs; //g
@property (nonatomic, readonly)           float sodium;//mg
@property (nonatomic, readonly)           float fibre;//???

@property (nonatomic, readonly)   float calories;//???

@end

//sumarry information
// select a.fd_id, a.l_fd_nme, b.fd_grp_nme from food_nm a, food_grp b where l_fd_nme like '%kfc%' and a.fd_grp_id == b.fd_grp_id;

//servingSize
//select a.msr_id, a.msr_nme, b.conv_fac from measure a, conv_fac b where fd_id=511834 and a.msr_id = b.msr_id;


typedef enum {
    FoodLabelNotGiven = 0, //"Not Given"
    FoodLabelInModeration, //"In Moderation"
    FoodLabelLessOften, //"Less Often"
    FoodLabelMoreOften //"More Often"

} FoodLabelType;

// Responsible for handling everything to do with the image
// of a FoodItem
@interface FoodImageData : NSObject

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *imageName;

- (instancetype)initWithImage:(UIImage *)image name:(NSString *)name;
- (instancetype)initWithName:( NSString *)name;

- (PMKPromise *)saveToFile;
- (PMKPromise *)loadFromFile; // returns a UIImage

@end

@interface SelectedFood: NSObject<DBProtocol>

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) long long foodId;
@property (nonatomic, readonly, retain) ObjectId* mealId;
@property (nonatomic, readonly) float portionSize;
//@property (nonatomic, readonly) NSString* description;
@property (nonatomic, readonly) NSUInteger servingSizeId;
@property (nonatomic, readonly) FoodItemCreationType creationType;
@property (nonatomic, readonly) NSString *imageName;

@property (nonatomic, readonly) float transFat;
@property (nonatomic, readonly) float saturatedFat;
@property (nonatomic, readonly) float protein; //g
@property (nonatomic, readonly) float fat; //g
@property (nonatomic, readonly) float sugar;
@property (nonatomic, readonly) float carbs; //g
@property (nonatomic, readonly) float sodium;//mg
@property (nonatomic, readonly) float fibre;//???
@property (nonatomic, readonly) float calories;//???
//@property (nonatomic, readonly) float iron; //mg

//BOOL saveToDB:(ObjectId*) mealId foods:(NSArray<FoodItem*>*) foods;
+(PMKPromise *)  saveToDB:(ObjectId*) mealId foods:(NSArray*) foods;

////return value FoodItem
//-(PMKPromise *)  searchFoodInDetail;
//
////return type NSArray<SelectedFood>
//+(PMKPromise *)  searchRecentFood:(NSString*) filter;
////-(BOOL) save;


@end

@interface FoodItem : NSObject<NSCopying>

@property(nonatomic) FoodImageData *imageData;
@property (nonatomic) FoodItemCreationType creationType;

@property (nonatomic, copy)     NSString* name;
@property (nonatomic)           long long foodId;
@property (nonatomic)           FoodLabelType label;
@property (nonatomic, copy)     NSString* category;
@property (nonatomic)           int providerID;
@property (nonatomic, copy)     NSString* providerItemID;

@property (nonatomic)           bool fromLocalDB;

//just for complier, will be delated later
@property (nonatomic, copy)   NSString* foodClass;
@property (nonatomic, copy)     NSString* defaultServingSize;
// end

////array<ServingSize>
@property (retain, readonly)     NSArray* servingSizeOptions;


@property (nonatomic, readonly)           float transFat;
@property (nonatomic, readonly)           float saturatedFat;
@property (nonatomic, readonly)           float protein; //g
//@property (nonatomic)           float iron; //mg
@property (nonatomic, readonly)           float fat; //g
@property (nonatomic, readonly)           float sugar;
@property (nonatomic, readonly)           float carbs; //g
@property (nonatomic, readonly)           float sodium;//mg
@property (nonatomic, readonly)           float fibre;//???

@property (nonatomic, readonly)   float calories;//???
//-(float) getCalories;

@property (atomic, retain) ServingSize* servingSize; //init to nil
@property (nonatomic) float portionSize; //init with zero

//+({category, NSArray<FoodItem>*}) searchFoodWithName:(NSString*) filter;
+(PMKPromise *)  searchForFoodWithName:(NSString*) filter;

//return type NSArray<FoodItem>
//FoodItem will ordered by frenquency and same FoodId will
//only return one record
+(PMKPromise *)  searchRecentFoodWithType:(MealType) type;

//return type NSArray<FoodItem>
+(NSArray *)  searchRecentFood:(NSString*) filter;

+(PMKPromise *)searchRecentFoodWithFilter:(NSString *)filter;

+(PMKPromise *) newSearchFoodWithName:(NSString *)filter withPage:(int)page; /////////////////////NEW
+(NSDictionary *)getFoodItemFromInternetWithProvider:(int)ProviderID andItemID:(NSString *)itemID; /////NEW

+(NSString*) getBonusStr:(NSArray*) filters;
+(NSString*) getWhereStr:(NSArray*) filters;

+(instancetype) createWithSelectedFood:(SelectedFood*) record;
- (instancetype)initWithClassificationData:(NSDictionary *)classificationData;

@end


#endif
