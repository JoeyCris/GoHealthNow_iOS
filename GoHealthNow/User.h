//
//  User.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-19
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_User_h
#define GlucoGuide_User_h

#import "PromiseKit/PromiseKit.h"

#import "ServicesConstants.h"
#import "WeightRecord.h"
#import "A1CRecord.h"
#import "Constants.h"


//@class User;


@interface BMI : NSObject

-(float) getValue;
-(BMICategory) getCategory;
- (NSString *)categoryDescription;

@end

@interface BrandingLogo : NSObject

@property (nonatomic, copy)NSString *brandName;
@property (nonatomic, copy)UIImage *brandLogo;
@property (nonatomic, copy)NSString *brandUrl;
@property (nonatomic, copy)NSString *brandId;
@property (nonatomic, copy)NSString *brandAccessCode;
@property (nonatomic, copy)NSString *brandLogoUrl;

-(NSString *)getBrandName;
-(NSString *)getBrandUrl;
-(UIImage *)getBrandLogo;
-(NSString *)getBrandId;
-(NSString *)getBrandAccessCode;
-(NSString *)getBrandLogoUrl;

-(BOOL)isSameBrand:(NSString *)pBrandId;

- (void)saveRemoteBrandLogoToLocalWithUrl:(NSString *)url;

- (void)loadBrandLogoFromLocalWithID:(NSString *)brandId;

- (void)resetToDefault;

@end


@interface User : NSObject

+ (id)sharedModel;

-(BOOL) isLoggedIn;

//- (BOOL) login;
- (PMKPromise*) login:(NSString*) email :(NSString*) password;

//- (BOOL) signUp;
- (PMKPromise*) signUp:(NSString*) email :(NSString*) password;

//- (BOOL) logout;
- (PMKPromise*) logout;

- (PMKPromise*) facebookLogin:(NSString*)faceBookEmail :(NSString*)name;
//- (BOOL) save;
- (PMKPromise*) save;

//- (BOOL) addWeightRecord;
- (PMKPromise*) addWeightRecord:(WeightUnit*) weight :(NSDate*) date;
- (PMKPromise*) addWeightRecord:(WeightUnit*) weight :(NSDate*) date :(NSString *) note;

- (void) updateA1CToUser: (NSNumber*) a1c;
////- (BOOL) addA1CRecord;
//- (PMKPromise*) addA1CRecord:(NSNumber*) a1c :(NSDate*) date;

//- (BOOL) setDeviceToken;
- (PMKPromise*) resetNotificationToken:(NSData*) token;

//- (BOOL) updatePoint;
- (PMKPromise*) updatePointsByAction:(NSString*) action;

- (float) getTargetCalories;

- (void)updateBrandWithAccesscode;
- (void)updateBrandWithAccesscode:(NSString *)accessCode;

- (NSString*)fullUserName;

- (NSDictionary *)scoringMacroDict;
- (void)saveScoringMacroDict:(NSDictionary *)xmlDictionary;

//@property () BOOL loggedin;

@property (readonly, nonatomic, copy) NSString* email;
@property (readonly, nonatomic, copy) NSString* password;
@property (readonly, nonatomic, copy) NSString* userId;

@property (nonatomic, copy) NSString* firstName;
@property (nonatomic, copy) NSString* lastName;
@property (nonatomic, copy) NSString* organizationCode;

@property (nonatomic, copy) NSString* specialID;

@property (nonatomic) GenderType gender;
@property (nonatomic) NSDate* dob;
@property (nonatomic) BGUnit bgUnit;//BGUnit
@property (nonatomic) MeasureUnit measureUnit; //MeasureUnit
//@property (nonatomic) char loginTimes;

@property (nonatomic) BrandingLogo *brandLogo;

@property (nonatomic) LengthUnit* height;
@property (nonatomic) LengthUnit* waistSize;
@property (readonly, nonatomic) BMI* bmi;
//@property (readonly, nonatomic) A1CRecord* a1c;
//@property (readonly, nonatomic) WeightRecord* weight;
//@property (readonly, nonatomic) NSNumber* a1c;
@property (readonly, nonatomic) NSNumber* a1c;
@property (readonly, nonatomic) WeightUnit* weight;
@property (readonly, nonatomic) NSUInteger points;
@property (readonly, nonatomic) NSString* pointsGoalMsg;

@property (nonatomic) BOOL isFreshUser; // this will be YES when a brand new user has been setup
@property (nonatomic) NSUInteger introShownCount;
@property (nonatomic) NSMutableDictionary *helpTipsShownTracker;
@property (nonatomic) NSArray* medications;

@property (nonatomic) NSArray *condition;
@property (nonatomic) int ethnicity;


@property(nonatomic) float activityLvl;

//for test
- (NSMutableDictionary*) toDictForServer;
- (NSDictionary*) toDictionary;


@end
#endif
