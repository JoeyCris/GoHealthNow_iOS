//
//  DBRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "A1CRecord.h"
#import "WeightRecord.h"

@interface DBRecordTests : XCTestCase

@end

@implementation DBRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testInsert {
    // This is an example of a functional test case.
    A1CRecord* record = [[A1CRecord alloc] init];
    
    record.value = [NSNumber numberWithDouble:6.5];
    record.recordedTime = [NSDate date];
    
    [DBHelper insertToDB:record];
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testA1CSave {
    // This is an example of a functional test case.
    A1CRecord* record = [[A1CRecord alloc] init];
    
    record.value = [NSNumber numberWithDouble:6.5];
    record.recordedTime = [NSDate date];
    
    [record save];
    
    
    XCTAssert(YES, @"Pass");
}



- (void)testA1CQuery {
    // This is an example of a functional test case.
    PMKPromise* promise = [A1CRecord queryFromDB:nil];
    
    //NSLog(@"%@", [self class] );
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* results = (NSArray*) [promise value];
        
        for(A1CRecord* record in results) {
            NSLog(@"record value: %@", record.value);
        }
    }
    
    XCTAssert(YES, @"Pass");
}

- (void)testWeightSave {
    // This is an example of a functional test case.
    WeightRecord* record = [[WeightRecord alloc] init];
    
    record.value = [[WeightUnit alloc ] initWithMetric:76.5];
    record.recordedTime = [NSDate date];
    
    [record save];
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
