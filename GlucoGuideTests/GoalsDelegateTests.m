//
//  GoalsDelegateTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-05-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GoalsDelegate.h"
#import "GGUtils.h"


@interface GoalsDelegateTests : XCTestCase

@end

@implementation GoalsDelegateTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWeigtGoal {
    // This is an example of a functional test case.
    WeightGoal* goal = [[WeightGoal alloc] init];
    
    goal.target = [[WeightUnit alloc] initWithImperial: 1];
    goal.createdTime = [NSDate date];
    
    float lostCals = [goal getDailyCalaries];
    
    XCTAssert((lostCals >= (1/7*3.5)), @"Success");
    
    
}

- (void)testWeigtGoalOptions {
    // This is an example of a functional test case.
    NSArray* options = [WeightGoal getOptions];
    
    NSLog(@"%@", options[1]);
    
    float target = [options[1][@"value"] floatValue];
    
    WeightGoal* goal = [[WeightGoal alloc] init];
    goal.target = [[WeightUnit alloc] initWithMetric: target];
    goal.createdTime = [NSDate date];
    
    XCTAssert(YES, @"Success");
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end