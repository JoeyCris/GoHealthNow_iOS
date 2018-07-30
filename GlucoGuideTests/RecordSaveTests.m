//
//  RecordSaveTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "MealRecord.h"
#import "ExerciseRecord.h"
#import "SleepRecord.h"
#import "GlucoseRecord.h"


@interface RecordSaveTests : XCTestCase

@end

@implementation RecordSaveTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testSearchFood {
//    // This is an example of a functional test case.
//    NSString* filter = @"pineapple syrup";
//    
//    [MealRecord searchForFoodWithName: filter].then(^(id res){
//        NSArray* foods = (NSArray*) res;
//        
//        XCTAssert([foods count] == 1, @"Pass");
//        
//    }).catch(^(id res) {
//        
//        XCTAssert(NO, @"Falied");
//    });
//
//    
//    
//    
//}


- (void)testObjectId {
    // This is an example of a functional test case.
    ObjectId* oid = [[ObjectId alloc] init];
    
    NSLog(@"objectid: %@", oid.str);
    
    XCTAssert(YES, @"Pass");
    
}

- (void)testSleepSave {
    // This is an example of a functional test case.
    SleepRecord* record = [[SleepRecord alloc] init];
    
//    <Sleep_Record>
//    <Minutes>435</Minutes>
//    <RecordedTime>2014/10/24/13/41/33</RecordedTime>
//    <UploadingVersion>0</UploadingVersion>
//    <Sick>0</Sick>
//    <Stressed>0</Stressed>
//    </Sleep_Record>
    
    record.minutes = [NSNumber numberWithInt:435];
    record.sick = [NSNumber numberWithInt:0];
    record.stressed = [NSNumber numberWithInt:0];
    record.recordedTime = [NSDate date];
    
    [record save].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testSleepBatchSave {

    // This is an example of a functional test case.
    NSMutableArray* records = [[NSMutableArray alloc] init];
        
    for(int i =0; i <2; i++) {
        
        SleepRecord* record = [[SleepRecord alloc] init];
    
        record.minutes = [NSNumber numberWithInt:435];
        record.sick = [NSNumber numberWithInt:0];
        record.stressed = [NSNumber numberWithInt:0];
        record.recordedTime = [NSDate dateWithTimeIntervalSinceNow: -(60*i* 60)];
        
        [records addObject:record];
    }
    
    
    [SleepRecord save: records].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testGlucoseSave {
    // This is an example of a functional test case.
    GlucoseRecord* record = [[GlucoseRecord alloc] init];
    
//    <Glucose_Record>
//    <Level>6.5</Level>
//    <RecordedTime>2014/10/24/13/41/13</RecordedTime>
//    <UploadingVersion>0</UploadingVersion>
//    <GlucoseType>1</GlucoseType>
//    </Glucose_Record>
    
    record.level = [[BGValue alloc] initWithMMOL:6.5];
    record.type = [NSNumber numberWithInt:1];
    //record.uploadingVersion = @"0";
    record.recordedTime = [NSDate date];
    
    [record save].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testGlucoseQuery {
    // This is an example of a functional test case.
    PMKPromise* promise = [GlucoseRecord queryFromDB:nil];

    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* records = (NSArray*) [promise value];
        
        for(GlucoseRecord* record in records) {
            NSLog(@"record createdTime: %@", record.recordedTime);
        }
        
    }


        
    XCTAssert(YES, @"Falied");

    
    
}

- (void)testGlucoseBatchSave {
    
    // This is an example of a functional test case.
    NSMutableArray* records = [[NSMutableArray alloc] init];
    
    for(int i =0; i <2; i++) {
        
        GlucoseRecord* record = [[GlucoseRecord alloc] init];
        
        //    <Glucose_Record>
        //    <Level>6.5</Level>
        //    <RecordedTime>2014/10/24/13/41/13</RecordedTime>
        //    <UploadingVersion>0</UploadingVersion>
        //    <GlucoseType>1</GlucoseType>
        //    </Glucose_Record>
        
        record.level =  [[BGValue alloc] initWithMG:6.5];
        record.type = [NSNumber numberWithInt:1];
        //record.uploadingVersion = @"0";
        record.recordedTime = [NSDate dateWithTimeIntervalSinceNow: -(60*i* 60)];
        
        [records addObject:record];
    }
    
    
    [GlucoseRecord save: records].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testExerciseSave {
    // This is an example of a functional test case.
    ExerciseRecord* record = [[ExerciseRecord alloc] init];
    
//    <Exercise_Record>
//    <Minutes>90</Minutes>
//    <Type>Moderate</Type>
//    <Interval>0</Interval>
//    <RecordedTime>2014/10/24/13/41/29</RecordedTime>
//    <Calories>505.18823</Calories>
//    <UploadingVersion>0</UploadingVersion>
//    </Exercise_Record>
    
    record.minutes = [NSNumber numberWithFloat:90];
    record.calories = [NSNumber numberWithFloat:505.18823];
    record.type = ExerciseTypeModerate;
    record.recordedTime = [NSDate date];
    
    [record save].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testExerciseBatchSave {
    
    // This is an example of a functional test case.
    NSMutableArray* records = [[NSMutableArray alloc] init];
    
    for(int i =0; i <5; i++) {
        
        ExerciseRecord* record = [[ExerciseRecord alloc] init];
        
        record.minutes = [NSNumber numberWithFloat:90];
        //record.interval = [NSNumber numberWithFloat:0];
        record.calories = [NSNumber numberWithFloat:505.18823];
        record.type = ExerciseTypeModerate;
        record.recordedTime = [NSDate dateWithTimeIntervalSinceNow: -(12*60*i* 60)];
        
        [records addObject:record];
    }
    
    
    [ExerciseRecord save: records].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}


- (void)testCalculateTodayCalories {
    // This is an example of a functional test case.
    
    PMKPromise* promise = [ExerciseRecord calculateTodayCalories];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        //NSArray* records = (NSArray*) [promise value];
        NSDictionary* allRecords = (NSDictionary*) [promise value];
        
        NSLog(@"calculateTodayCalories: %@", allRecords);
        
    }
    
        XCTAssert(YES, @"Falied");
    
    
    
}


- (void)testCalculateTodayMinutes {
    // This is an example of a functional test case.
    
    PMKPromise* promise = [ExerciseRecord calculateTodayMinutes];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        //NSArray* records = (NSArray*) [promise value];
        NSDictionary* allRecords = (NSDictionary*) [promise value];
        
        NSLog(@"calculateTodayCalories: %@", allRecords);
        
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
