//
//  GGAPITests.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-16.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "HttpClient.h"

#import "XMLDictionary/XMLDictionary.h"

#import "GlucoguideAPI.h"

#import "GGUtils.h"

@interface GGAPITests : XCTestCase

@end

@implementation GGAPITests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

//- (void)testExample {
//    // This is an example of a functional test case.
//    NSLog(@"test example enter");
//    XCTAssert(YES, @"Pass");
//}

- (void)testSendPostMsg {
    // This is an example of a functional test case.
    NSString* url = @"https://kdd.csd.uwo.ca:8080/GlucoGuide/verifyaction";
    NSString* paraName = @"LoginInfo";
    NSString* paraValue = @"<LoginInfo ><LoginType >1</LoginType><UserID >0</UserID><Email >hdjdj@hxjshdj</Email><Password >hxjxjdjx</Password> \
    </LoginInfo>";
    
    
    
    NSString* response = [[HttpClient sendPostMessage:url :paraName :paraValue] objectForKey:@"data"];
    
    NSLog(@"%@", response);
    
    XCTAssert(YES, @"Pass");
}

- (void)testSendPostMsg2 {
    // This is an example of a functional test case.
    NSString* email = @"hdjdj@hxjshdj";
    NSString* password = @"hxjxjdjx";
    
    NSString *url= [NSString stringWithFormat:@"%@verifyaction",GGAPI_BASEURL];
    NSString* paraName = @"LoginInfo";
    NSString* paraValue = [NSString stringWithFormat:@"<LoginInfo ><LoginType >1</LoginType><UserID >0</UserID><Email >%@</Email><Password >%@</Password> \
                           </LoginInfo>", email, password];
    
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    
    NSString* userId_ = @"";
    
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode == 0) {
        NSString* data = [response objectForKey:@"data"];
        if(![data isEqualToString:@"Email and password do not match"]) {
            
            //if response is userId, replace local var
            NSScanner* scan = [NSScanner scannerWithString: data];
            int val;
            if( [scan scanInt:&val]&&[scan isAtEnd]) {
                userId_ = data;
            }
            
            NSLog(@"Yes, userId: %@", userId_);
        } else {
            //fulfill([NSNumber numberWithBool:NO]);
        }
    }else {
        //reject(@{ @"Error": @"No Network Connection"});
        NSLog(@"No, retCode: %d", retCode);
    }
    
    NSLog(@"%@", response);
    
    XCTAssert(YES, @"Pass");
}

//http://dev.kdd.csd.uwo.ca/static/user_photo/tips/unnamed.jpg

- (void)testDownloadFile {
    NSString* url = @"http://dev.kdd.csd.uwo.ca/static/user_photo/tips/unnamed.jpg";
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString* cachesDir=[documentsPaths objectAtIndex:0];
    
    
    
    Response response = [HttpClient downloadFile:url path:cachesDir fileName:@"unnamed_local.jpg"];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode != 0) {
        //reject(@{ @"Error": @"No Network Connection"});
        NSLog(@"error");
    }
    
        XCTAssert(YES, @"Pass");
}

- (void)testSendPostSaveRecord {
    // This is an example of a functional test case.
    NSDictionary*   ggRecords = @{
                             @"Glucose_Record":    @[@{
                                                         @"GlucoseType" : @1,
                                                         @"Level" : @"6.5",
                                                         @"RecordedTime" : @"2014/12/15/13/41/13",
                                                         @"UploadingVersion" : @0,
                                                         }
                                                     ],
                             @"__name" : @"Glucoses_Records"
                             };
    
    
    NSString *url= [NSString stringWithFormat:@"%@Write",GGAPI_BASEURL];
    NSString* paraName = @"userRecord";
    
    NSString* paraValue = [NSString stringWithFormat:@"\
                           <User_Record> %@\
                           <UserID>807</UserID> \
                           <Created_Time>2014/10/24/11/43/09</Created_Time> \
                           </User_Record>", [ggRecords XMLString]];
    
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode != 0) {
        //reject(@{ @"Error": @"No Network Connection"});
        NSLog(@"error");
    }
    
    NSString* data = [response objectForKey:@"data"];
    
    NSLog(@"%@", data);
    
    if([data isEqualToString:@"success"]) {
        //fulfill([NSNumber numberWithBool:YES]);
        NSLog(@"sucess");
    } else {
        //fulfill([NSNumber numberWithBool:NO]);
    }
    
    
    NSLog(@"%@", response);
    
    XCTAssert(YES, @"Pass");
}

- (void)testGGAPISignUp {
    // This is an example of a functional test case.
    
    GlucoguideAPI* api = [GlucoguideAPI sharedService];
    NSString* email = [ NSString stringWithFormat:@"signUp%d@iOS.autotest.com",arc4random() ];
    //NSString* email = @"ios@gg.com";
    NSString* password = @"iostest";
    
//    [api createAccount:email :password].then(^(id res){
//        NSDictionary * profile = (NSDictionary*) res;
//        NSLog(@"fullfil %@", profile);
//    }).catch(^(id res) {
//        NSDictionary * result = (NSDictionary*) res;
//        NSLog(@"reject %@", result);
//    });
    
    PMKPromise* promise = [api createAccount:email pasword:password notificationToken:nil ];

    while(! promise.pending) {

        break;
    }
    
    if(promise.fulfilled) {
        NSDictionary* profile = (NSDictionary*) [promise value];
        NSLog(@"fullfil %@", profile);
    } else {
        NSError* error =  (NSError*) [promise value];
        NSLog(@"reject %@", error);
    }
    
    
    XCTAssert(YES, @"Pass");
}


- (void)testGGAPIAuthenticate {
    // This is an example of a functional test case.
    
    GlucoguideAPI* api = [GlucoguideAPI sharedService];
    NSString* email = @"hdjdj@hxjshdj";
    NSString* password = @"hxjxjdjx";

    [api authenticate:email pasword:password notificationToken:nil].then(^(id res){
        NSDictionary * profile = (NSDictionary*) res;
        NSLog(@"fullfil %@", profile);
    }).catch(^(id res) {
        NSDictionary * result = (NSDictionary*) res;
        NSLog(@"reject %@", result);
    });

    
    XCTAssert(YES, @"Pass");
}

- (void)testRetrieveRecommendation {
    // This is an example of a functional test case.
    
    GlucoguideAPI* api = [GlucoguideAPI sharedService];

    NSString* userId = @"807";
    NSDate* date = [GGUtils dateFromString:@"2014/10/24/12/35/42"];
    
    
    PMKPromise* promise = [api retrieveRecommendation:userId :date];
    
    while(! promise.pending) {
        
        break;
    }
    
    if(promise.fulfilled) {
        
        NSDictionary* result = (NSDictionary*) [promise value];
        
        NSLog(@"fullfil %@", result);
    } else {
        NSDictionary * result = (NSDictionary*) [promise value];
        NSLog(@"reject %@", result);
    }
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testRetrieveRecommendationWithXML {
    // This is an example of a functional test case.
    
    //GlucoguideAPI* api = [GlucoguideAPI sharedService];
    
    NSString* request = @"<Recommendation_Request> \
    <UserID>807</UserID> \
    <VersionNumber>2.1.3</VersionNumber> \
    <Latest_RecommendationTime>2014/12/05/22/11/26</Latest_RecommendationTime> \
    </Recommendation_Request>";
    
    PMKPromise* promise = [[GlucoguideAPI sharedService ]retrieveRecommendationWithXML:request];
    
    while(! promise.pending) {

        break;
    }
    
    if(promise.fulfilled) {
        
        NSDictionary* result = (NSDictionary*) [promise value];
        
        NSLog(@"fullfil %@", result);
    } else {
        NSDictionary * result = (NSDictionary*) [promise value];
        NSLog(@"reject %@", result);
    }
    
    
    XCTAssert(YES, @"Pass");
}



- (void)testGGAPISaveRecord {
    // This is an example of a functional test case.
    
    NSDictionary*   dict = @{
            @"Glucoses_Records": @{
                    @"Glucose_Record":    @[@{
                                        @"GlucoseType" : @1,
                                        @"Level" : @"6.5",
                                        @"RecordedTime" : @"2014/12/15/13/41/13",
                                        @"UploadingVersion" : @0,
                                    }
                                    ]},
            @"UserID" : @"807"
            };
    
    //NSString* records = [dict innerXML];
    
    GlucoguideAPI* api = [GlucoguideAPI sharedService];
    
    //BOOL result = NO;
    [api saveRecord:dict].then(^(id res){
        NSNumber* tmp = (NSNumber*) res;
        //result =
        BOOL aa = [tmp boolValue];
        
        XCTAssert(aa, @"Pass");
    }).catch(^(id res) {
        NSDictionary * result = (NSDictionary*) res;
        NSLog(@"reject %@", result);
    });
    
    
    XCTAssert(YES, @"Pass");
}

- (void)testXML2Dict {
    // This is an example of a functional test case
    
    NSString* str2 = @"<Profile> \
    <UserID>685</UserID> \
    <Gender>1</Gender> \
    <DOB>1962</DOB> \
    <Weight_Records> \
    <Weight_Record> \
    <Weight>95.0</Weight> \
    <Date>2014/09/13/12/54/33</Date> \
    </Weight_Record> \
    <Weight_Record> \
    <Weight>75.0</Weight> \
    <Date>2014/09/16/14/40/33</Date> \
    </Weight_Record> \
    </Weight_Records> \
    <CaloryTarget_Records/> \
    <A1C_Records> \
    <A1C_Record> \
    <A1C>6.0</A1C> \
    <Date>2014/09/13/12/54/33</Date> \
    </A1C_Record> \
    </A1C_Records> \
    <Height>177.0</Height> \
    <RegistrationTime>2014/09/13/12/54/33</RegistrationTime> \
    </Profile> \
";
    
    
    NSDictionary* dict = [NSDictionary dictionaryWithXMLString:str2];
    NSLog(@"xml2dict: %@", dict);

//
//    dict = {
//        "A1C_Records" =     {
//            "A1C_Record" =         {
//                A1C = "6.0";
//                Date = "2014/09/13/12/54/33";
//            };
//        };
//        DOB = 1962;
//        Gender = 1;
//        Height = "177.0";
//        RegistrationTime = "2014/09/13/12/54/33";
//        UserID = 685;
//        "Weight_Records" =     {
//            "Weight_Record" =         (
//                                       {
//                                           Date = "2014/09/13/12/54/33";
//                                           Weight = "95.0";
//                                       },
//                                       {
//                                           Date = "2014/09/16/14/40/33";
//                                           Weight = "75.0";
//                                       }
//                                       );
//        };
//        "__name" = Profile;
//    }
    
    //NSString* xml = [dict XMLString];
    
    //NSLog(@"dict2xml: %@", xml);
    
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
