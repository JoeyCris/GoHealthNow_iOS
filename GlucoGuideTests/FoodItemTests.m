//
//  FoodItemTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-30.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "FoodItem.h"

@interface FoodItemTests : XCTestCase

@end

@implementation FoodItemTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSearchFood {
    // This is an example of a functional test case.
    NSString* filter = @"Beans, adzuki, yokan (bean jelly)";
    
    PMKPromise* promise = [FoodItem searchForFoodWithName: filter];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* allRecords = (NSArray*) [promise value];
        
        if(allRecords.count > 1) {
            NSLog(@"%@", allRecords[0]);
        }
        for(NSArray* records in allRecords) {
            FoodItem* food = records[0];
            NSLog(@"category: %@", food.category);
            
            NSArray* options = food.servingSizeOptions;
            for(ServingSize* ss in options) {
                NSLog(@"convert fact: %f", ss.convertFact);
            }
            
            
            XCTAssert(food.foodId == 3246, @"Pass");
        }
        
    } else {
        
        XCTAssert(NO, @"Falied");
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testSearchRecentFoodWithType {
    
    PMKPromise* promise = [FoodItem searchRecentFoodWithType:MealTypeBreakfast];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* allRecords = (NSArray*) [promise value];
        

        for(FoodItem* food in allRecords) {
            
            NSLog(@"food id: %lld", food.foodId);
            
            NSArray* options = food.servingSizeOptions;
            for(ServingSize* ss in options) {
                NSLog(@"convert fact: %f", ss.convertFact);
            }
            
            
            XCTAssert(food.foodId == 3246, @"Pass");
        }
        
    } else {
        
        XCTAssert(NO, @"Falied");
    }
    
    XCTAssert(YES, @"Pass");
}




- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
