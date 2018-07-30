//
//  GlucoguideAPI.h
//  GlucoGuide
//
//  Created by kthakore on 11/01/14.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "PromiseKit/PromiseKit.h"

#import "ServicesConstants.h"

//#import "AFNetworking/AFNetworking.h"
//#import "PromiseKit-AFNetworking/AFNetworking+PromiseKit.h"
//#import "AFXMLDictionaryResponseSerializer.h"
//#import "AFXMLDictionaryRequestSerializer.h"

#ifndef GlucoGuide_GlucoguideAPI_h
#define GlucoGuide_GlucoguideAPI_h

FOUNDATION_EXPORT  NSString *const GGAPI_BASEURL;
FOUNDATION_EXPORT  NSString *const GGAPI_HOSTNAME;

@interface GlucoguideAPI : NSObject

+ (id)sharedService;

//return NSDictionary* of user profile , if this user profile never
//be uploaded, then only userId is available{}
- (PMKPromise*) createAccount:(NSString*) email pasword:(NSString*) password notificationToken:(NSData*) token;

  //return NSDictionary* of user profile , if this user profile never
  //be uploaded, then only userId is available{}
- (PMKPromise*) authenticate:(NSString*) email pasword:(NSString*) password notificationToken:(NSData*) token;

- (PMKPromise*) facebookAuthenticate:(NSString*)email name:(NSString*)name  notificationToken:(NSData*)token;

//+ (NSDictionary*) userLoginWithXML:(NSString*) loginRequest;
+ (PMKPromise*) userLoginWithXML:(NSString*) loginRequest;

//facebook
+ (PMKPromise*) userFacebookLoginWithXML:(NSString*) facebookLoginRequest;
//BOOL updateProfile(NSDictionary)
- (PMKPromise*) updateProfile:(NSDictionary*) profile;

//return NSDictionary*
- (PMKPromise *)photoRecognition:(NSString *)filePath
                            user:(NSString *)userId
               creationTimeStamp:(NSString *)timeStamp
                            type:(UploadPhotoType)type;

-(PMKPromise *)getInputSelectionWithUserId:(NSString*) userId;


//return NSDictionary*
-(PMKPromise *)getBrandLogoWithUserId:(NSString*) userId
                           AccessCode:(NSString *)accessCode;

-(PMKPromise *)getGoalsWithUserId:(NSString *) userId;

-(NSDictionary *)getActivityLevelWithUserId:(NSString *) userId;

-(NSDictionary *)getCalorieDistributionWithUserId:(NSString *) userId;

//return NSDictionary*
- (PMKPromise *)uploadPhoto:(NSString*) filePath user:(NSString*) userId type:(UploadPhotoType) type;
-(void)sendAudioWithFile:(NSString *)filePath fileName:(NSString *)fileName user:(NSString *)userId creationTimeStamp:(NSString *)timeStamp;

////BOOL uploadPhoto:(NSString*) fileName;
//- (PMKPromise*) uploadPhoto:(NSString*) userId filePath:(NSString*) path;
//BOOL sendMultiPostMessage:(NSString*) fileName;
+(PMKPromise*) sendMultiPostMessage: (NSArray*) paraList;

+(PMKPromise*) sendMultiPostMessageWithoutRetry:(NSArray*) paraList;

+(NSArray*) sendBarcode:(NSString *)barcode;
//+(NSArray *)sendFoodToSearch:(NSString *)foodItem;

+(NSArray *)sendFoodToSearch:(NSString *)foodItem withPageNumber:(int)page;
+(NSDictionary *)getFoodItemFromApiWithProviderID:(int)providerID andItemID:(NSString *)itemID;
+(NSArray *)getAutoCompleteResponseWithKey:(NSString *)partialFoodName;

//BOOL updateProfileWithXML(NSString)
+ (PMKPromise*) updateProfileWithXML:(NSString*) profile;

- (PMKPromise*) saveCustomizedFoodItemWithXML:(NSString *)foodItemXML;

-(NSDictionary *)sendInputSelectionWithArray:(NSMutableArray *)selectionArray;

-(void)deleteRecordWithRecord:(int)type andUUID:(NSString *) uuid;

//NSDictionary* retrieveRecommendation()
//return value example:
//{
//    Recommendation =     {
//        Content = "You have not upload your blood glucose 2 hours after the meal for 3 days. It is extremely important that you upload both meal and 2-hour-after-meal blood glucose in order for us to provide accurate recommendation to you.";
//        Createdtime = "2015-01-12T21:21:41+0000";
//        Type = 3;
//    };
//}
- (PMKPromise*) retrieveRecommendation:(NSString*) userId :(NSDate*) fromTime;

//NSDictionary* retrieveRecommendation()
- (PMKPromise*) retrieveRecommendationWithXML:(NSString*) request;

//BOOL saveRecord(NSDictionary* ggRecords)
//input example:
//    NSDictionary*   ggRecords = @{
//        @"Glucoses_Records": @{
//            @"Glucose_Record":    @[@{
//                @"GlucoseType" : @1,
//                @"Level" : @"6.5",
//                @"RecordedTime" : @"2014/12/15/13/41/13",
//                @"UploadingVersion" : @0,
//                }
//                ]},
//        @"UserID" : @"807"
//        };
- (PMKPromise*) saveRecord:(NSDictionary*) ggRecords;

//BOOL saveRecord(NSDictionary* ggRecords)
- (PMKPromise*) saveRecordWithXML:(NSString*) ggRecords;

+ (BOOL)compareReturnDateWithNowDate:(NSString *)firstDate;

@end

#endif
