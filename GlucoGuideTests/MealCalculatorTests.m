////
////  MealCalculatorTests.m
////  GlucoGuide
////
////  Created by Crul on 2015-01-29.
////  Copyright (c) 2015 GlucoGuide. All rights reserved.
////
//
////#import <Cocoa/Cocoa.h>
//#import <XCTest/XCTest.h>
//#import "MealCalculator.h"
//#import "FoodItem.h"
//
//@interface MealCalculator (Testing)
//
//- (float)dailyTargetCaloriesForUser:(User *)user;
//- (NSDictionary *)nutritionFactsForUser:(User *)user withFoodItems:(NSArray *)foodItems;
//
//@end
//
//@interface MealCalculatorTests : XCTestCase
//
//@end
//
//@implementation MealCalculatorTests
//
//- (void)setUp {
//    [super setUp];
//    // Put setup code here. This method is called before the invocation of each test method in the class.
//    [self setUpTestUser];
//}
//
//- (void)tearDown {
//    // Put teardown code here. This method is called after the invocation of each test method in the class.
//    [super tearDown];
//}
//
//- (void)setUpTestUser {
//    User *user = [User sharedModel];
//    
//    if (!user.weight) {
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
//        [dateComponents setYear:1975];
//        
//        user.dob = [calendar dateFromComponents:dateComponents];
//        user.height = [[LengthUnit alloc] initWithMetric:152.4];
//        user.gender = GenderTypeMale;
//        
//        WeightUnit *weight = [[WeightUnit alloc] initWithMetric:100.0];
//        
//        [user addWeightRecord:weight :[NSDate date]];
//    }
//}
//
//- (NSArray *)foodItems {
//    NSMutableArray *foodItems = [NSMutableArray array];
//    
//    FoodItem *foodItem1 = [[FoodItem alloc] init];
//    foodItem1.portionSize = 5.0;
//    foodItem1.protein = 10.0;
//    foodItem1.carbs = 10.0;
//    foodItem1.sugar = 10.0;
//    foodItem1.fat = 10.0;
//    foodItem1.fibre = 10.0;
//    
//    FoodItem *foodItem2 = [[FoodItem alloc] init];
//    foodItem2.portionSize = 10.0;
//    foodItem2.protein = 20.0;
//    foodItem2.carbs = 20.0;
//    foodItem2.sugar = 20.0;
//    foodItem2.fat = 20.0;
//    foodItem2.fibre = 20.0;
//    
//    [foodItems addObject:foodItem1];
//    [foodItems addObject:foodItem2];
//    
//    return foodItems;
//}
//
//- (void)testFemaleTargetCalories {
//    User *testUser = [User sharedModel];
//    MealCalculator *mealCalculator = [MealCalculator sharedModel];
//    
//    testUser.gender = GenderTypeFemale;
//    
//    float targetCalories = [mealCalculator dailyTargetCaloriesForUser:testUser];
//    
//    NSLog(@"female target: %.f", targetCalories);
//    
//    XCTAssert(round(targetCalories) == round(1701.0), @"Pass");
//}
//
//- (void)testMaleTargetCalories {
//    User *testUser = [User sharedModel];
//    MealCalculator *mealCalculator = [MealCalculator sharedModel];
//    
//    testUser.gender = GenderTypeMale;
//    
//    float targetCalories = [mealCalculator dailyTargetCaloriesForUser:testUser];
//    
//    NSLog(@"male target: %.f", targetCalories);
//    
//    XCTAssert(targetCalories == 1926.0, @"Pass");
//}
//
//- (void)testNutritionFacts {
//    User *testUser = [User sharedModel];
//    MealCalculator *mealCalculator = [MealCalculator sharedModel];
//    
//    NSDictionary *nutritionFacts = [mealCalculator nutritionFactsForUser:testUser withFoodItems:[self foodItems]];
//    NSLog(@"nutritionFacts: %@", nutritionFacts);
//    
//    XCTAssertNotNil(nutritionFacts, @"Pass Nil Test");
//    XCTAssert([[nutritionFacts allKeys] count] == 2, @"Pass Keys Count Test");
//}
//
//- (void)testSnackScore {
//    User *testUser = [User sharedModel];
//    MealCalculator *mealCalculator = [MealCalculator sharedModel];
//    NSArray *foodItems = [self foodItems];
//    
//    NSDictionary *scoreInfo = [mealCalculator scoreForUser:testUser
//                                             withFoodItems:foodItems
//                                               forMealType:MealTypeSnack];
//    
//    XCTAssertNotNil(scoreInfo, @"Pass Nil Test");
//    XCTAssert([[scoreInfo allKeys] count] == 3, @"Pass Keys Count Test");
//}
//
//- (void)testMealScore {
//    User *testUser = [User sharedModel];
//    MealCalculator *mealCalculator = [MealCalculator sharedModel];
//    NSArray *foodItems = [self foodItems];
//    
//    NSDictionary *scoreInfo = [mealCalculator scoreForUser:testUser
//                                             withFoodItems:foodItems
//                                               forMealType:MealTypeBreakfast];
//    
//    XCTAssertNotNil(scoreInfo, @"Pass Nil Test");
//    XCTAssert([[scoreInfo allKeys] count] == 3, @"Pass Keys Count Test");
//}
//
//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}
//
//
//@end
