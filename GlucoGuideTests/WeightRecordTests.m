//
//  WeightRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "WeightRecord.h"

@interface WeightRecordTests : XCTestCase

@end

@implementation WeightRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWeightCreate {
    // This is an example of a functional test case.
    WeightUnit* w1 = [[WeightUnit alloc] initWithMetric:299];
    
    NSLog(@"weight1 with imperial %f", [w1 valueWithImperial]);

    WeightUnit* w2 = [[WeightUnit alloc] initWithImperial:659];
    
    NSLog(@"weight2 with metric %f", [w2 valueWithMetric]);
    
    [w1 setValueWithImperial:659 ];
    
    
    XCTAssert([w1 valueWithMetric] == [w2 valueWithMetric], @"Pass");
}

- (void)testWeightSave {
    // This is an example of a functional test case.
    WeightRecord* record = [[WeightRecord alloc] init];
    
    record.value = [[WeightUnit alloc ] initWithMetric:76.5];
    record.recordedTime = [NSDate date];
    
    [record save];
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testWeightQuery {
    // This is an example of a functional test case.
    PMKPromise* promise = [WeightRecord queryFromDB:nil];
    
    //NSLog(@"%@", [self class] );
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* results = (NSArray*) [promise value];
        
        for(WeightRecord* record in results) {
            NSLog(@"record value: %f", [record.value valueWithMetric]);
        }
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
