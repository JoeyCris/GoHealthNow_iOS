//
//  NoteRecordTests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-04-06.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "NoteRecord.h"
#import "GGUtils.h"


@interface NoteRecordTests : XCTestCase

@end

@implementation NoteRecordTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testNoteSave {
    // This is an example of a functional test case.
    NoteRecord* record = [[NoteRecord alloc] init];
    
    //<NoteContent>JDJDJdDJ</NoteContent>
    //<RecordedTime>2015-03-19T10:22:37-0400</RecordedTime>
    //<UploadingVersion>0</UploadingVersion>
    //<NoteType>Diet</NoteType>
    
    record.content =  @"JDJDJdDJ";
    record.type = NoteTypeDiet;
    record.recordedTime = [NSDate date];
    
    [record save].then(^(id res){
        BOOL ret = [(NSNumber*) res boolValue];
        
        XCTAssert(ret, @"Pass");
        
    }).catch(^(id res) {
        
        XCTAssert(NO, @"Falied");
    });
    
    
}

- (void)testNoteQueryFromDB {
    // This is an example of a functional test case.
    
    //<NoteContent>JDJDJdDJ</NoteContent>
    //<RecordedTime>2015-03-19T10:22:37-0400</RecordedTime>
    //<UploadingVersion>0</UploadingVersion>
    //<NoteType>Diet</NoteType>
    
    PMKPromise* promise = [NoteRecord queryFromDB:nil];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* records = (NSArray*) [promise value];
        
        for(NoteRecord* record in records) {
            NSLog(@"note record: recordedTime %@", record.recordedTime);
        }
    }

    
    
}

- (void)testNoteQueryDataByTime {
    // This is an example of a functional test case.
    //NoteRecord* record = [[NoteRecord alloc] init];
    
    //<NoteContent>JDJDJdDJ</NoteContent>
    //<RecordedTime>2015-03-19T10:22:37-0400</RecordedTime>
    //<UploadingVersion>0</UploadingVersion>
    //<NoteType>Diet</NoteType>
    NSDate* from = [GGUtils dateFromString: @"2015-04-06T09:10:44-0400"];
    NSDate* to = [NSDate date];
    
    PMKPromise* promise = [NoteRecord queryDataByTime:from toDate:to];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        NSArray* records = (NSArray*) [promise value];
        
        for(NoteRecord* record in records) {
            NSLog(@"note record: recordedTime %@", record.recordedTime);
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
