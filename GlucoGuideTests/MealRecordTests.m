//
//  MealRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-03-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MealRecord.h"

@interface MealRecordTests : XCTestCase

@end

@implementation MealRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUploadPhoto {
    // This is an example of a functional test case.
    //NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
//    NSBundle* bundle = [NSBundle mainBundle];
//    NSString* photoPath = [bundle pathForResource:@"meal_20150225_133623" ofType:@"jpg" inDirectory:nil];
    //UIImage* image = [[UIImage alloc]initWithContentsOfFile:photoPath];
    
    //NSString* document = [path objectAtIndex:0];
    
    //NSString* fileName = [document stringByAppendingPathComponent:@"meal_20150306_121212.jpg"];
    
    //[MealRecord addMealPhoto:image date:[NSDate date] note:@"auto test"];
    
    XCTAssert(YES, @"Pass");
}



- (void)testSearchRecentMeal {
    // This is an example of a functional test case.
    //NSString* filter = @"bbq";
    
    PMKPromise* promise = [MealRecord searchRecentMeal:nil];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        //NSArray* records = (NSArray*) [promise value];
        NSArray* allRecords = (NSArray*) [promise value];

        for(NSDictionary* records in allRecords) {
            NSArray* meals = records[@"rows"];
            NSLog(@"category: %@, meals count: %lu", records[@"category"], meals.count);

            
//            for(MealRecord* meal in meals) {
//                NSLog(@"foods: %f", ss.convertFact);
//            }
            
        }
    }
    
    
        XCTAssert(YES, @"Pass");
}

- (void)testSearchAverageScore {
    // This is an example of a functional test case.
    //+ (PMKPromise *)searchDailyCalories:(NSDate*)fromDate toDate:(NSDate*)toDate;
    [MealRecord searchDailyCalories:[NSDate dateWithTimeIntervalSinceNow: -60*60*24*7]
                             toDate:[NSDate date]];
    
    [MealRecord searchAverageScore:SummaryPeroidDaily
                          fromDate:[NSDate dateWithTimeIntervalSinceNow: -60*60*24*7]
                            toDate:[NSDate date]];

    
    
    
}

- (void)testSearchDailyCalories {
    // This is an example of a functional test case.
    //+ (PMKPromise *)searchDailyCalories:(NSDate*)fromDate toDate:(NSDate*)toDate;
    [MealRecord searchDailyCalories:[NSDate dateWithTimeIntervalSinceNow: -60*60*24*7]
                             toDate:[NSDate date]];
    
//    PMKPromise* promise = [MealRecord searchDailyCalories:
//                           [NSDate date] toDate:[NSDate date]];
//    
//    while(! promise.pending) {
//        
//        break;
//    }
//    
//    if(promise.fulfilled) {
//        //NSArray* records = (NSArray*) [promise value];
//        NSArray* records = (NSArray*) [promise value];
//        
//        NSLog(@"search count: %lu", (unsigned long)[records count]);
//        
////        for(FoodItem* record in records) {
////            NSLog(@"food name: %@ category: %@", record.name, record.category);
////        }
//    }
    
    
    
}

//14610|203720365178881|KFC Snacker|1|0|1.00 x 1 item (119g), 321.0 calories
- (void)testSelectedFoodSave {

    SelectedFood* food = [[SelectedFood alloc] init];
//    food.foodId = 14610;
//    food.mealId = [[ObjectId alloc] initWithCode:203720365178881];
//    food.name = @"KFC Snacker";
//    food.portionSize = 0;
//    food.servingSizeId = 123123;
    
    

    
    [DBHelper insertToDB:food];
    
    
}

- (void)testMealSave {
    // This is an example of a functional test case.
    MealRecord* meal = [[MealRecord alloc] init];
    
    //    <Meal_Record>
    //    <Food_Records>
    //    <Food_Record>
    //    <FoodItem>
    //    <FoodItemID>8231</FoodItemID>
    //    </FoodItem>
    //    <FoodItemServingSize>1.0</FoodItemServingSize>
    //    </Food_Record>
    //    </Food_Records>
    //    <Carb>22.0</Carb>
    //    <Pro>0.0</Pro>
    //    <Fat>0.0</Fat>
    //    <Cals>88.0</Cals>
    //    <RecordedTime>2014/10/24/13/41/17</RecordedTime>
    
    // This is an example of a functional test case.
    NSString* filter = @"BBQ";
    
    PMKPromise* promise = [FoodItem searchForFoodWithName: filter];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* allRecords = (NSArray*) [promise value];
        
        
        FoodItem* food = allRecords[0][0];
        
        food.servingSize = food.servingSizeOptions[0];
        //    </Meal_Record>
        meal.carb = 5.911;
        meal.pro = 9.54415;
        meal.fat = 15.7047;
        meal.cals = 404.0;
        meal.fibre = 0.117;
        meal.type = MealTypeLunch;
        meal.score = 74;
        meal.createdType = MealCreatedBySearch;
        meal.recordedTime = [NSDate date];
        //meal.imageName_ = @"19b47ef1-ac65-42a7-8b9d-514f1e852812.jpg";
        //19b47ef1-ac65-42a7-8b9d-514f1e852812.jpg	43bca527-d4c2-44d0-a55d-d83be1697aa4.jpg
        
//        meal.foods = [[NSMutableArray alloc] init];
//        
        [meal addFood:food];
        
        
        MealRecord *copiedMeal = [meal copy];
        
        meal.name = @"meal";
        [meal removeFoodAtIndex: meal.foods.count -1 ];
        
        food.portionSize = 1.2;
        
        NSLog(@"copied meal: %@", copiedMeal.name);
        
        PMKPromise* p2 = [meal save];
        while(1) {
            
            //break;
        }
        
            
            XCTAssert(YES, @"Pass");
            

    }
    
    
}

- (void)testMealBatchSave {
    // This is an example of a functional test case.
    NSMutableArray* records = [[NSMutableArray alloc] init];
    
    for(int i =0; i <2; i++) {
        
        MealRecord* meal = [[MealRecord alloc] init];
        
        meal.carb = 22.0;
        meal.pro = 0.0;
        meal.fat = 0.0;
        meal.cals = 88.0;
        meal.recordedTime = [NSDate dateWithTimeIntervalSinceNow: -(60*i* 60)];
        
        FoodItem* food = [[FoodItem alloc] init];
        food.foodId = 8231; //[NSNumber numberWithInt:8231];
        food.portionSize = 1.0; //[NSNumber numberWithFloat:1.0];
        
        
        [meal addFood:food];
        
        [records addObject: meal];
        
    }
    
    [MealRecord save: records].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
