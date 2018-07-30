//
//  GlucoseRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-07-06.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "GlucoseRecord.h"
#import "User.h"

@interface GlucoseRecordTests : XCTestCase

@end

@implementation GlucoseRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSearchDailyFastBG {
    // This is an example of a functional test case.
    //+ (PMKPromise *)searchDailyCalories:(NSDate*)fromDate toDate:(NSDate*)toDate;
    PMKPromise * promise = [GlucoseRecord searchDailyFastBG: [NSDate dateWithTimeIntervalSinceNow: -60*60*24*7]
                             toDate:[NSDate date]];
    
    
        while(! promise.pending) {
    
            //break;
        }
    
        if(promise.fulfilled) {

            NSArray* records = (NSArray*) [promise value];
    
            NSLog(@"search count: %lu", (unsigned long)[records count]);
    
            for(NSDictionary* record in records) {
                NSLog(@"fast bg value: %@ day: %@",
                      record[MACRO_FASTBG_NAME_ATTR],
                      record[MACRO_FASTBG_RECORDEDDAY_ATTR]);
            }
        }
    
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
