//
//  RecommendationRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-12.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "RecommendationRecord.h"

#import "XMLDictionary/XMLDictionary.h"

@interface RecommendationRecordTests : XCTestCase

@end

@implementation RecommendationRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSave {
    // This is an example of a functional test case.
    RecommendationRecord* record = [[RecommendationRecord alloc] init];
    
    
    record.type = [NSNumber numberWithInt:1];
    //record.content = @"You have not upload your blood glucose 2 hours after the meal for 3 days. It is extremely important that you upload both meal and 2-hour-after-meal blood glucose in order for us to provide accurate recommendation to you.";
    record.content = [NSString stringWithFormat:@"Recommendation at %@", [NSDate date]];
    record.createdTime = [NSDate date];
    
    [record save].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testQueryFromDB {
    // This is an example of a functional test case.
    
    PMKPromise* promise = [RecommendationRecord queryFromDB:nil];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* records = (NSArray*) [promise value];
        
        for(RecommendationRecord* record in records) {
            NSLog(@"recommendation createdtime %@", record.createdTime);
        }
    }
        
    XCTAssert(YES, @"Pass");

    
    
}

- (void)testSave2 {
    // This is an example of a functional test case.
    
    NSString* respone = @"<Recommendation> \
    <Type>3</Type> \
    <Content>You have not uploaded your meal records for 3 days.  It is extremely important that you upload both meal and 2-  hour-after-meal blood glucose in order for us to provide accurate recommendation to you.</Content> \
        <Createdtime>2015-02-02T17:42:25+0000</Createdtime> \
        <ImageURL>http://kdd.csd.uwo.ca/static/user_photo/983/meal_20150115_120601.jpg</ImageURL> \
        </Recommendation>";
    
    NSDictionary* dict = [NSDictionary dictionaryWithXMLString:respone];
    
    RecommendationRecord* record = [RecommendationRecord createWithDictionary:dict];
        
    [record save];
    

    XCTAssert(YES, @"Falied");
    
}

- (void)testRetrieve {
    // This is an example of a functional test case.
    
    PMKPromise* promise = [RecommendationRecord retrieve];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        
        NSArray* result = (NSArray*) [promise value];
        
        for(RecommendationRecord* record in result) {
            NSLog(@"recommendation createdtime %@", record.createdTime);
        }
        
    } else {
        NSError * result = (NSError*) [promise value];
        NSLog(@"reject %@", result);
    }
   
    XCTAssert(YES, @"Falied");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
