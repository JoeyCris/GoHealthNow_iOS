//
//  InsulinRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-06-30.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

//#import "InsulinRecord.h"
#import "User.h"


@interface InsulinRecordTests : XCTestCase

@end

@implementation InsulinRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testGetAllInsulins {
    // This is an example of a functional test case.
    
//    NSArray* insulins = [InsulinRecord getAllInsulins];
//    for(NSDictionary* dict in insulins) {
//        NSLog(@"id: %@, name: %@",
//              dict[MACRO_INSULIN_XML_ID_ATTR],
//              dict[MACRO_INSULIN_XML_NAME_ATTR]);
//    }
//    
//    XCTAssert(insulins.count == 9, @"Pass");
}

- (void)testSetCustomizedInsulins {
//    // This is an example of a functional test case.
//    
//    NSMutableArray* insulins = [NSMutableArray arrayWithArray:
//    [InsulinRecord getAllInsulins] ];
//    
//    User* user = [User sharedModel];
//    
//    user.insulins = insulins;
//    
//    
//    PMKPromise* promise = [user save];
//    
//    while(! promise.pending) {
//        
//        break;
//    }
//    
////    if(promise.fulfilled) {
////        NSArray* allRecords = (NSArray*) [promise value];
////        
////        
////    } else {
////        
////        XCTAssert(NO, @"Falied");
////    }
//    
//    XCTAssert(YES, @"Pass");
}

- (void)testSave {
    // This is an example of a functional test case.
    
//    NSArray* insulins = [InsulinRecord getAllInsulins];
//
//    InsulinRecord* record = [[InsulinRecord alloc]init];
//    
//    record.insulinId = insulins[0][MACRO_INSULIN_XML_ID_ATTR];
//    record.dose = 2;
//    record.recordedTime = [NSDate date];
//    
//    [record save];
//    
//    while(1) {
//        
//        //break;
//    }
//    
//    XCTAssert(insulins.count == 9, @"Pass");
}

- (void)testSearchLastInsulin {
//    // This is an example of a functional test case.
//    
//    PMKPromise* promise = [InsulinRecord searchLastInsulin];
//    
//    
//    while(! promise.pending) {
//        
//        break;
//    }
//    
//    if(promise.fulfilled) {
//        InsulinRecord* insulin = (InsulinRecord*) [promise value];
//        
//        
//        NSLog(@"last insulin recordedTime %@", insulin.recordedTime);
//        
//    }
//    
//    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
