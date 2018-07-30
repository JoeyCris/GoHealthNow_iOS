//
//  GlucoGuideTests.m
//  GlucoGuideTests
//
//  Created by Siddarth Kalra on 2014-10-23.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface GlucoGuideTests : XCTestCase

@end

@implementation GlucoGuideTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    NSString* dateString = @"2014-12-05T22:11:26+0000";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate* time = [dateFormatter dateFromString:dateString];
    NSLog(@"from server: %@", [dateFormatter stringFromDate:time]);
    
    NSString* str = [dateFormatter stringFromDate:[NSDate date]];
    NSLog(@"current time: %@", str);
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
