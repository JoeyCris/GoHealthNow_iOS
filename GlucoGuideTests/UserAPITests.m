//
//  StorageAPITests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-27.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "XMLDictionary/XMLDictionary.h"

//#import "UserDataSerializer.h"
#import "User.h"
#import "GGUtils.h"

@interface UserAPITests : XCTestCase

@end

@implementation UserAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



//- (void)testUserDataSerializerLoadProfile {
//    // This is an example of a functional test case.
//    
//    NSDictionary* profile = [UserDataSerializer loadProfile];
//    
//    NSLog(@"%@", profile);
//    
//    XCTAssert(YES, @"Pass");
//}
//
//- (void)testUserDataSerializerSaveProfile {
//    // This is an example of a functional test case.
//    
//        NSString* tmp = @" \
//        <Profile> \
//        <UserID>685</UserID> \
//        <Gender>1</Gender> \
//        <DOB>1962</DOB> \
//        <Weight_Records> \
//        <Weight_Record> \
//        <Weight>95.0</Weight> \
//        <Date>2014/09/13/12/54/33</Date> \
//        </Weight_Record> \
//        <Weight_Record> \
//        <Weight>75.0</Weight> \
//        <Date>2014/09/16/14/40/33</Date> \
//        </Weight_Record> \
//        </Weight_Records> \
//        <CaloryTarget_Records/> \
//        <A1C_Records> \
//        <A1C_Record> \
//        <A1C>6.0</A1C> \
//        <Date>2014/09/13/12/54/33</Date> \
//        </A1C_Record> \
//        </A1C_Records> \
//        <Height>177.0</Height> \
//        <RegistrationTime>2014/09/13/12/54/33</RegistrationTime> \
//        </Profile> ";
//    
//    NSDictionary* profile = [NSDictionary dictionaryWithXMLString:tmp];
//    
//    BOOL ret = [UserDataSerializer saveProfile:profile];
//    
//    
//    XCTAssert(ret, @"Pass");
//}
//
//- (void)testUserDataSerializerSavePassword {
//    // This is an example of a functional test case.
//    NSString* email = @"hdjdj@hxjshdj";
//    NSString* password = @"hxjxjdjx";
//    
//    [UserDataSerializer savePassWord:email :password];
//    
//    //NSLog(@"%@", profile);
//    
//    XCTAssert(YES, @"Pass");
//}

//- (void)testUserDataSerializerReadPassword {
//    // This is an example of a functional test case.
//    
//    NSDictionary* dict = [UserDataSerializer readPassWord];
//    
//    NSLog(@"%@", dict);
//    
//    XCTAssert(YES, @"Pass");
//}

- (void)testUserInit {
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    //NSDictionary* dict = [user getProfile];
    
    NSLog(@"%@", user.email);
    
        
    
    XCTAssert(YES, @"Pass");
}

- (void)testUserToDict {
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    
    [user.height setValueWithMetric:190];
    
        NSLog(@"BMI: %f",[user.bmi getValue]);
    
    WeightUnit* weight = [[WeightUnit alloc] initWithMetric:100];
    [user addWeightRecord:weight :[NSDate date]];
//
//    [user addA1CRecord:[NSNumber numberWithFloat:5.5] :[NSDate date]];

    user.organizationCode = @"1234";
    NSLog(@"BMI: %f",[user.bmi getValue]);
    
    
    NSLog(@"%@", [user toDictionary]);
    
    [user save];
    
    XCTAssert(YES, @"Pass");
}


- (void)testUserSignUp {
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    [user logout];
    
    PMKPromise* promise = [user signUp: @"t666@t.com" : @"t1"];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        
        XCTAssert(YES, @"Pass");
    } else {
        NSError * result = (NSError*) [promise value];
        NSLog(@"reject %@", result);
        
        //XCTAssert(NO, @"Falied");
    }
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testUserSignIn {
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    [user logout];
    
    PMKPromise* promise = [user login: @"robert_t2134@t.com" : @"t1"];
    
    while(! promise.pending) {
        
        break;
    }
    
    
    
    if(promise.fulfilled) {
        
        user.firstName = @"Robert";
        user.lastName = @"Wang";
        
        user.organizationCode = @"1234";
        
        //user.height = [NSNumber numberWithFloat:[user.height floatValue]+ 0.1];
        
        [user save];
        
        XCTAssert(YES, @"Pass");
    } else {
        NSError * result = (NSError*) [promise value];
        NSLog(@"reject %@", result);
        
        //XCTAssert(NO, @"Falied");
    }
    
    
    XCTAssert(YES, @"Pass");
}

//- (void)testUserSaveToLocal {
//    // This is an example of a functional test case.
//    
//    User* user = [User sharedModel];
//    
//    user.height = [NSNumber numberWithFloat:[user.height floatValue]+ 0.1];
//    
//    [user saveToLocal];
//    
//    NSLog(@"after save user.height: %@", user.height);
//    
//    XCTAssert(YES, @"Pass");
//}

- (void)testUserSave {
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    user.firstName = @"Robert";
    user.lastName = @"Wang";
    
    user.organizationCode = @"1234";
    
    //user.height = [NSNumber numberWithFloat:[user.height floatValue]+ 0.1];
    
    [user save];
    
    NSLog(@"after save user.height: %@", user.height);
    
    XCTAssert(YES, @"Pass");
}

- (void)testHeight {
    // This is an example of a functional test case.
    
    LengthUnit* height = [[LengthUnit alloc] initWithMetric:170];
    
    NSLog(@"%@", [height valueWithImperial]);
    
    [height setValueWithImperial:5 :7];
    
    NSLog(@"%f", [height valueWithMetric]);
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testGetTargetCalories{
    // This is an example of a functional test case.
    
    User* user = [User sharedModel];
    
    NSLog(@"%f", [user getTargetCalories]);
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
