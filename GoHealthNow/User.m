//
//  User.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

#import "XMLDictionary/XMLDictionary.h"

#import "User.h"
#import "GoalsDelegate.h"
#import "MealCalculator.h"
#import "ServicesConstants.h"
#import "SecurityStorage.h"
#import "ActivityLevel.h"

#import "GlucoguideAPI.h"

#import "GGUtils.h"
#import "Constants.h"

#import "HttpClient.h"
#import <UIKit/UIKit.h>

#define USER_PROFILE @"userprofile_%@.xml"
#define DEFAULT_BMI_VALUE 24.9
#define DEFAULT_POINT_GOAL @"";//Try to gain 470 points in this week"
#define DEFAULT_POINT_VALUE 10000

@interface BrandingLogo ()

@end

@implementation BrandingLogo
@synthesize brandLogo;
@synthesize brandName;
@synthesize brandUrl;
@synthesize brandId;
@synthesize brandAccessCode;
@synthesize brandLogoUrl;

-(NSString *)getBrandName {
    return brandName;
}

-(NSString *)getBrandUrl {
    return brandUrl;
}

-(UIImage *)getBrandLogo {
    return brandLogo;
}

-(NSString *)getBrandLogoUrl {
    return brandLogoUrl;
}

-(NSString *)getBrandId {
    return brandId;
}

-(NSString *)getBrandAccessCode; {
    return brandAccessCode;
}

-(BOOL)isSameBrand:(NSString *)pBrandId {
    return pBrandId == brandId ? YES : NO;
}

-(NSString*) getCachedFilePath: (NSString*) fileName {
    
    //    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //
    NSString* tmpFilePath = [NSString stringWithFormat:@"%@/%@",
                             [GGUtils getCachedBrandPath],
                             fileName];
    
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    //        BOOL isDir = FALSE;
    //        BOOL isFileExist = [fileManager fileExistsAtPath:tmpFilePath isDirectory:&isDir];
    
    BOOL isFileExist = [fileManager fileExistsAtPath:tmpFilePath ];
    
    if(isFileExist) {
        return tmpFilePath;
    } else {
        return nil;
    }
}

- (void)saveRemoteBrandLogoToLocalWithUrl:(NSString *)url {
    if (url == nil)
        return;
    NSString *imgUrl;
    if (![[url substringToIndex:4] isEqualToString:@"http"]) {
        imgUrl = [NSString stringWithFormat:@"http://%@/%@",
                                   GGAPI_HOSTNAME, url];
    }
    else {
        imgUrl = url;
    }
    NSString *imageExt = [[imgUrl componentsSeparatedByString:@"."] lastObject];
    Response response = [HttpClient downloadFile:imgUrl
                                            path:[GGUtils getCachedBrandPath]
                                        fileName:[NSString stringWithFormat:@"%@.%@", [self getBrandId], imageExt]];
    
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode == 0) {
        [self loadBrandLogoFromLocalWithID:[self getBrandId]];
        NSLog(@"Successfully downloaded branding logo.\n");
    }
    else {
        NSLog(@"Failed to download branding logo.\n");
    }
}

- (void)loadBrandLogoFromLocalWithID:(NSString *)brandId {
    NSString *imageName = [self getCachedFilePath:[NSString stringWithFormat:@"%@.%@", [self getBrandId] ,[[[self getBrandLogoUrl] componentsSeparatedByString:@"."] lastObject]]];
    if (imageName != nil) {
        self.brandLogo = [UIImage imageWithContentsOfFile:imageName];
    }
    else {
        [self saveRemoteBrandLogoToLocalWithUrl:self.brandLogoUrl];
    }
}

- (void)resetToDefault {
    self.brandLogo = nil;
    self.brandId = nil;
    self.brandName = nil;
    self.brandUrl = nil;
    self.brandAccessCode = nil;
    self.brandLogoUrl = nil;
}

@end

@interface BMI ()

//@property (nonatomic) float value_;
//@property (nonatomic) User* user_;
@end

@implementation BMI


//BMIUnderweight =0, //= <18.5
//BMINormalWeight, // = 18.5–24.9
//BMIOverWeight, // = 25–29.9
//BMIObesity // = BMI of 30 or greater
-(BMICategory) getCategory {
    float value = [self getValue];
    if(value <= 18.5) {
        return BMIUnderweight;
    }else if(value <= 24.9){
        return BMINormalWeight;
    }else if(value <= 29.9) {
        return BMIOverWeight;
    }else {
        return BMIObesity;
    }
}

//-(instancetype) initWithUser:(User *)user {
//    if(self = [super init]) {
//            self.user_ = user;
//    }
//
//    return self;
//}

-(float) getValue {
    User* user = [User sharedModel];
    
    if(user.height == nil || user.weight == nil) {
        return DEFAULT_BMI_VALUE;
    }
    
    float height = [user.height valueWithMetric]/100;
    float weight = [user.weight valueWithMetric];
    
    if(height > 3 || weight > 300) {
        return  DEFAULT_BMI_VALUE;
    }
    
    return weight/height/height;

    
}



- (NSString *)description {
    return [NSString stringWithFormat: @"%.1f (%@)", [self getValue], [self categoryDescription]];
}

- (NSString *)categoryDescription {
    switch ([self getCategory]) {
        case BMIUnderweight:
            return [LocalizationManager getStringFromStrId:@"Underweight"];
            break;
        case BMINormalWeight:
            return [LocalizationManager getStringFromStrId:@"Normal weight"];
        case BMIOverWeight:
            return [LocalizationManager getStringFromStrId:@"Overweight"];
        case BMIObesity:
            return [LocalizationManager getStringFromStrId:@"Obese"];
        default:
            return [LocalizationManager getStringFromStrId:@"Unknown"];
            break;
    }
}

@end

@interface User ()

@property BOOL loggedin;
@property (nonatomic, retain) NSDate* registrationTime;

@property (readwrite, nonatomic,copy) NSString* email;
@property (readwrite, nonatomic, copy) NSString* password;
@property (readwrite, nonatomic, copy) NSString* userId;

@property (readwrite, nonatomic) BMI* bmi;
//@property (readwrite, nonatomic) A1CRecord* a1c;
//@property (readwrite, nonatomic) WeightRecord* weight;

@property (readwrite, nonatomic) NSNumber* a1c;
@property (readwrite, nonatomic) WeightUnit* weight;

@property (readwrite, atomic) NSUInteger points;
@property (readwrite, nonatomic) NSString* pointsGoalMsg;

@property (atomic) NSMutableDictionary* todayActions_;

@property (nonatomic) NSNumber* flagForServer;

@property (nonatomic) NSData* notificationToken;


@end

@implementation User


+ (id) sharedModel {
    static User* sharedModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc] init];
    });
    return sharedModel;
    
}

-(id)init {
    
    if (self = [super init]){
        self.loggedin = NO;
        self.introShownCount = 0;
        
        NSDictionary* creds = [self readPassWord];
        if(creds != nil) {
            self.email = creds[KEY_USERNAME];
            self.password = creds[KEY_PASSWORD];
            self.userId = creds[KEY_USERID];
            self.notificationToken = nil;
            self.ethnicity = 6;
            self.specialID = nil;
            
            NSDictionary* profile = [self loadProfile];
            
            if(profile != nil) {
                [self initWithProfile:profile];
                self.loggedin = YES;
                
                [self autoLogin];
            }
        }
        
    }
    
    return self;
    
}

- (PMKPromise*) resetNotificationToken:(NSData*) token {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        //authenticate background, if failed then logout by force and it will take effect when next init
        if(![self.notificationToken isEqualToData: token]) {
            self.notificationToken = token;
            
            if(self.userId != nil) {
                [self autoLogin];
            }
        }
        
        fulfill(@YES);
    }];
}

//- (BOOL) updatePoint;
- (PMKPromise*) updatePointsByAction:(NSString*) action {
    return nil;
    
//    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
//        
//        if( self.todayActions_[action] == nil ) {
//            self.todayActions_[action] = @1;
//            
//            if([action isEqualToString:@"signUp"]) {
//                self.points = DEFAULT_POINT_VALUE;
//            } else if( [action isEqualToString:@"signIn"]) {
//                self.points += 50;
//            } else {
//                self.points += 22;
//            }
//        } else {
//            //self.todayActions_[action] = [self.todayActions_[action] intValue] + 1;
//        }
//        //input item: add meal, upload photo, bg, bp, a1c, exercise, sleep, insulin
//        //128*7 = weekly points 900
//        //monthly points 3,600
//        
//        fulfill(@YES);
//    }];
}

- (BOOL) autoLogin {
    dispatch_promise(^{
        [self updatePointsByAction:@"signIn"];
        
        self.loggedin = YES;
        
        GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
        [ggAPI authenticate: self.email pasword:self.password notificationToken:self.notificationToken].then(^(NSDictionary* userData) {
            
            [self resetStateAfterLogin:userData];
            
        }).catch(^(NSError* error) {
            NSLog(@"failed to authenticate when user init, detail information: %@", [error localizedDescription]);
            
            if(error.code == XAuthenticateFailed) {
                self.loggedin = NO;
                [self deletePassWord];
            }
        });
    
    });
    
    return YES;
}



//- (BOOL) addWeightRecord;
- (PMKPromise*) addWeightRecord:(WeightUnit*) weight :(NSDate*) recordedTime{
    
    self.weight = weight;
    
    WeightRecord* weightRecord = [[WeightRecord alloc] init];
    weightRecord.value = weight;
    weightRecord.recordedTime = recordedTime;
    weightRecord.uuid = (NSString *)[[NSUUID UUID] UUIDString];
    
    //update target targetCalories
    //self.targetCalories =[self calculateTargetCalories];
    
    return [weightRecord save];
}

- (PMKPromise*) addWeightRecord:(WeightUnit*) weight :(NSDate*) recordedTime :(NSString *) note{

        self.weight = weight;
        
        WeightRecord* weightRecord = [[WeightRecord alloc] init];
        weightRecord.value = weight;
        weightRecord.recordedTime = recordedTime;
        weightRecord.note = note;
        weightRecord.uuid = (NSString *)[[NSUUID UUID] UUIDString];
    
        //update target targetCalories
        //self.targetCalories =[self calculateTargetCalories];
        
        return [weightRecord save];
}

- (void) updateA1CToUser: (NSNumber*) a1c{
    self.a1c = a1c;
}



//- (BOOL) addA1CRecord;
- (PMKPromise*) addA1CRecord:(NSNumber*) a1c :(NSDate*) recordedTime {
    
//        self.a1c = a1c;

        A1CRecord* record = [[A1CRecord alloc] init];
        
        record.value = a1c;
        record.recordedTime = recordedTime;
        
        return [record save];
}

-(PMKPromise*)login:(NSString*) email :(NSString*) password {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (self.loggedin) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Already Logged in"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        } else if ( email == nil || password == nil || [email isEqualToString:@""] || [password isEqualToString:@""]) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Email and Password cannot be empty"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else {
            [self updatePointsByAction:@"signIn"];
            
            GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
            
            [ggAPI authenticate: email pasword:password notificationToken:self.notificationToken].then(^(NSDictionary* res) {
                    
                self.loggedin = YES;
                
                self.email = email;
                self.password = password;
                
                [self resetStateAfterLogin:res];
                
                fulfill(@YES);
            
            }).catch(^(NSError* error) {
                self.loggedin = NO;
                reject(error);
                
            });
        }
        

    }];
    
    
}
- (PMKPromise*) facebookLogin:(NSString*)faceBookEmail :(NSString*)name{
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (self.loggedin) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Already Logged in"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        } else if ( faceBookEmail == nil || [faceBookEmail isEqualToString:@""]) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Email and Password cannot be empty"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else {
            [self updatePointsByAction:@"signIn"];
            
            GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
            
            [ggAPI facebookAuthenticate:faceBookEmail name:name notificationToken:self.notificationToken].then(^(NSDictionary* res) {
                
                self.loggedin = YES;
                
                self.email = faceBookEmail;
                self.password = @"12345";
                
                [self resetStateAfterLogin:res];
                
                fulfill(@YES);
                
            }).catch(^(NSError* error) {
                self.loggedin = NO;
                reject(error);
                
            });
        }
        
        
    }];
    
    
}
-(void) resetStateAfterLogin:(NSDictionary*) remoteProfile {
    self.loggedin = YES;
    
    self.userId = remoteProfile[@"UserID"];
    
    //merge the local profile and the server response and then reset user properties
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[self loadProfile]];
    
    for(id key in [remoteProfile allKeys]) {
        //special case:  local :OrganizationCode  server:access code
        if ([key isEqualToString:@"AccessCode"]) {
            [dict setObject:[remoteProfile objectForKey:key] forKey:@"OrganizationCode"];
        }
        else {
            [dict setObject:[remoteProfile objectForKey:key] forKey:key ];
        }
    }
    
    [self initWithProfile:dict];
    
    
    [self saveToLocal];
    
    [[GoalsDelegate sharedService] loadGoals];
}

-(PMKPromise*)logout{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        [self save].then(^(BOOL success) {
            [self deletePassWord];
            
            self.loggedin = NO;
            self.userId = nil;
            self.email = nil;
            self.password = nil;
            
            self.points = DEFAULT_POINT_VALUE;
            
            self.todayActions_  = nil;
            
            GoalsDelegate* goalsDelegate = [GoalsDelegate sharedService];
            [goalsDelegate cleanGoals];
            
            MealCalculator *mealCalculator = [MealCalculator sharedModel];
            [mealCalculator reset];
            
            fulfill(@YES);
            
        }).catch(^(NSError *error) {
            //reject(error);
            self.loggedin = NO;
            self.userId = nil;
            self.email = nil;
            self.password = nil;
            
            MealCalculator *mealCalculator = [MealCalculator sharedModel];
            [mealCalculator reset];
            
            fulfill(@YES);
        });
    }];
}

-(BOOL) isValidEmail:(NSString*) email {
    NSRange range = [email rangeOfString:@"@"];
    
    BOOL bValid = (range.location != NSNotFound)
      && (range.location != (email.length - 1));
    
    return bValid;
}

-(PMKPromise*)signUp:(NSString*) email :(NSString*) password {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if (self.loggedin) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Already Logged in"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else if ( email == nil || password == nil || [email isEqualToString:@""] || [password isEqualToString:@""]) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Email and Password cannot be empty"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else if ( ![self isValidEmail:email]) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Invalid email address"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else if ( password.length <= 4) {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Password is too short"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
            
        } else {
            GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
            
            [ggAPI createAccount: email pasword:password notificationToken:self.notificationToken].then(^(id res) {
                
                self.loggedin = YES;
                
                self.registrationTime = [NSDate date];
                self.email = email;
                self.password = password;
                //self.userId = res[@"UserID"];
                
                NSDictionary* result = (NSDictionary*) res;
                [self initWithProfile: result];
                [self saveToLocal];
                
                fulfill(@YES);
                
            }).catch(^(NSError* error) {
                self.loggedin = NO;
                reject(error);
                
            });
        }
        

    }];
    
    
}



- (PMKPromise*) save {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        if (!self.isLoggedIn) {
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XNotLoggedIn userInfo:nil];
            reject(error);
        }
        else {
            GoalsDelegate* goalsDelegate = [GoalsDelegate sharedService];
            [goalsDelegate saveGoals];
            
            MealCalculator *mealCalculator = [MealCalculator sharedModel];
            [self saveScoringMacroDict:mealCalculator.scoringRules];
            
            if([self saveToLocal]) {
                
                NSString* xml = [[self toDictForServer] innerXML];
                
                //
                //  Due to hash problem, now disable the hash check when saving the profile
                //
                //
                
                //NSLog(@"%@\n", xml);
                NSUInteger svrHash = [xml hash];
                //NSLog(@"[Curr profile hash]Server:%@  local:%@\n",self.flagForServer , [NSNumber numberWithUnsignedInteger:svrHash]);
                
                //if([self.flagForServer unsignedIntegerValue] != svrHash) {
                    
                    self.flagForServer = [NSNumber numberWithUnsignedInteger:svrHash];
                    
                    NSString* profile = [NSString stringWithFormat:@"<Profile> %@ </Profile>", xml];
                
                        NSLog(@"xmlToServer: %@", profile);
                
                    [GlucoguideAPI updateProfileWithXML:profile].then(^(id res) {
                        fulfill(res);
                    }).catch(^(id res) {
                        reject(res);
                    });
                //} else {
                //    NSLog(@"same as before");
                //    fulfill(@YES);
                //}
            } else {
                
                fulfill(@YES);
            }
            
        }
    }];
    
}

- (void) initWithProfile:(NSDictionary*) userData {
    
    self.userId = userData[@"UserID"];
    
    self.gender = (userData[@"Gender"] != nil) ? [userData[@"Gender"] intValue ]: GenderTypeMale;
    self.bgUnit = (userData[@"BGUnit"] != nil) ? [userData[@"BGUnit"] intValue ]: BGUnitMMOL;
    self.measureUnit = (userData[@"MeasureUnit"] != nil) ? [userData[@"MeasureUnit"] intValue ]: MUnitMetric;
    //self.loginTimes = (userData[@"LoginTimes"] != nil) ? [userData[@"LoginTimes"] intValue ]: 1;
    
    if (userData[@"introShownCount"] != nil) {
        self.introShownCount = [(NSString *)userData[@"introShownCount"] integerValue];
    }
    else {
        self.introShownCount = 0;
    }
    
    // If a user specific DB exists then this is not a fresh user
    // If the DB doesn't exist then we are dealing with a fresh user
    NSString *dbPath = [DBHelper getDBPath:self.userId];
    BOOL dbExists = [[NSFileManager defaultManager] fileExistsAtPath:dbPath];
    self.isFreshUser = !dbExists;
    
    if (userData[@"helpTipsShownTracker"] != nil) {
        self.helpTipsShownTracker = userData[@"helpTipsShownTracker"];
    }
    else {
        self.helpTipsShownTracker = [[NSMutableDictionary alloc] init];
    }
    
    self.dob = [self isVaildFloatValue: userData[@"DOB"]] ? [GGUtils dateOfYear:userData[@"DOB"] ] : [GGUtils dateOfYear:@"1975" ] ;
    
    if([self isVaildFloatValue: userData[@"Weight"] ]) {
        self.weight = [[WeightUnit alloc] initWithMetric: [(NSString*)userData[@"Weight"] floatValue]];
        
    } else {
        self.weight = [[WeightUnit alloc] initWithMetric: 80.0];
    }
    
    if([self isVaildFloatValue: userData[@"Height"] ]) {
        self.height = [[LengthUnit alloc] initWithMetric:[(NSString*)userData[@"Height"] floatValue]];
    } else {
        self.height = [[LengthUnit alloc] initWithMetric:176];
    }
    
    self.firstName = (userData[@"FirstName"] != nil) ? userData[@"FirstName"]  : nil;
    self.lastName = (userData[@"LastName"] != nil) ? userData[@"LastName"]  : nil;
    self.organizationCode = (userData[@"OrganizationCode"] != nil) ? userData[@"OrganizationCode"] : nil;
    
    if (userData[@"specialID"]) {
        
        NSString *tempSpecialID = userData[@"specialID"];
        self.specialID = tempSpecialID;
    }else{
        self.specialID = nil;
    }
    
    if (userData[@"Ethnicity"]) {
        
        NSNumber *tempNumber = userData[@"Ethnicity"];
        self.ethnicity = [tempNumber intValue];
    }
    
    if (userData[@"Conditions"]) {
        
        NSString *tempString = [NSString stringWithFormat:@"%@", userData[@"Conditions"][@"Condition"]];
               
        NSString *newString = [[tempString componentsSeparatedByCharactersInSet:
                                [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                               componentsJoinedByString:@""];
        
        NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:3];
        
        switch ([newString length]) {
            case 1:
                [tempArray addObject:[newString substringToIndex:1]];
                break;
            case 2:
                [tempArray addObject:[newString substringToIndex:1]];
                [tempArray addObject:[newString substringWithRange:NSMakeRange(1, 1)]];
                break;
            case 3:
                [tempArray addObject:[newString substringToIndex:1]];
                [tempArray addObject:[newString substringWithRange:NSMakeRange(1, 1)]];
                [tempArray addObject:[newString substringWithRange:NSMakeRange(2, 1)]];
                break;
        }
        
        self.condition = tempArray;
    }
    
    ///
    
    if(userData[@"Points"] != nil) {
        self.points = [(NSString *)userData[@"Points"] integerValue];
    }
    
    if(self.points < DEFAULT_POINT_VALUE) {
        self.points = DEFAULT_POINT_VALUE;
    }
    
    if(userData[@"PromoteMessage"] != nil) {
        self.pointsGoalMsg = userData[@"PromoteMessage"];
    } else {
        self.pointsGoalMsg = DEFAULT_POINT_GOAL;
    }
    
    if(userData[@"WaistSize"] != nil) {
        self.waistSize = [[LengthUnit alloc] initWithMetric:[userData[@"WaistSize"] floatValue]];
    } else {
        self.waistSize = [[LengthUnit alloc] initWithMetric:95.1];
    }
    
    
    
    if(self.bmi == nil) {
        self.bmi = [[BMI alloc] init];
    }
    self.medications = [User getmedication: userData[@"medication"]];
    
    if (self.brandLogo == nil) {
        self.brandLogo = [[BrandingLogo alloc] init];
        self.brandLogo.brandId = (NSString *)userData[@"brandlogo_id"];
        self.brandLogo.brandName = (NSString *)userData[@"brandlogo_name"];
        self.brandLogo.brandUrl = (NSString *)userData[@"brandlogo_url"];
        self.brandLogo.brandAccessCode = (NSString *)userData[@"brandlogo_accesscode"];
        self.brandLogo.brandLogoUrl = (NSString *)userData[@"brandlogo_logourl"];
        if ([self.brandLogo.brandAccessCode isEqualToString:self.organizationCode]) {
            [self.brandLogo loadBrandLogoFromLocalWithID:self.brandLogo.brandLogoUrl];
        }
        else {
            if (self.brandLogo.brandAccessCode == nil || self.organizationCode == nil) {
                [self.brandLogo resetToDefault];
                if (self.organizationCode) {
                    [self updateBrandWithAccesscode];
                }
            }
            else {
                [self updateBrandWithAccesscode];
            }
        }
    }
    
    [self updateInputSelection];
    
    NSInteger flagForServerIntVal = [(NSString *)userData[@"flagForServer"] integerValue];
    self.flagForServer = [NSNumber numberWithInteger:flagForServerIntVal];
     
}

+ (NSArray*) getmedication:(id) records {
    
    NSArray *medication = nil;
    
    if(records != nil) {
        
        if([records isKindOfClass:[NSArray class]]) {
            
            medication = records;
        } else if([records isKindOfClass:[NSDictionary class]]){
            medication = @[records];
        }
    }
    return medication;
}


- (void)updateInputSelection {
    [[GlucoguideAPI sharedService] getInputSelectionWithUserId:self.userId].then(^(id res) {
        NSMutableArray *inputSelectionData = [[(NSDictionary *)res objectForKey:@"InputSelections"] objectForKey:@"Selection"];
        
        NSArray *inputSelectionRowLabels = @[INPUT_SELECTION_ROW_DIET, INPUT_SELECTION_ROW_EXERCISE, INPUT_SELECTION_ROW_GLUCOSE, INPUT_SELECTION_ROW_BLOODPRESSURE, INPUT_SELECTION_ROW_MEDICATION, INPUT_SELECTION_ROW_A1C, INPUT_SELECTION_ROW_WEIGHT, INPUT_SELECTION_ROW_SLEEP];
        
        NSMutableArray *selectedInputs = [[NSMutableArray alloc] initWithCapacity:[inputSelectionRowLabels count]];
        
        for(int i = 0; i < [inputSelectionRowLabels count]; i++){
            if ([inputSelectionData containsObject:inputSelectionRowLabels[i]]){
                [selectedInputs addObject:@YES];
            }
            else {
                [selectedInputs addObject:@NO];
            }
        }
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userAndSelectedInputs = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userAndSelectedInputs"]];
        
        [userAndSelectedInputs setObject:selectedInputs forKey:self.userId];
        [prefs setObject:userAndSelectedInputs forKey:@"userAndSelectedInputs"];
        [prefs synchronize];

    }).catch(^(NSError* error) {

    });
}





- (void)updateBrandWithAccesscode {
    if (![self.organizationCode isEqualToString:self.brandLogo.brandAccessCode]) {
         [self updateBrandWithAccesscode:self.organizationCode];
    }
}

- (void)updateBrandWithAccesscode:(NSString *)accessCode {
    if ([self.organizationCode isEqualToString:self.brandLogo.brandAccessCode])
        return;
    if (self.brandLogo == nil) {
        self.brandLogo = [[BrandingLogo alloc] init];
    }
    
    [self.brandLogo resetToDefault];
    
    [[GlucoguideAPI sharedService] getBrandLogoWithUserId:self.userId AccessCode:accessCode].then(^(id res) {
        if (!([(NSDictionary *)res objectForKey:@"BrandID"]!=nil &&
            [(NSDictionary *)res objectForKey:@"Name"]!=nil)) {
            NSLog(@"Invaild branding info- AccessCode not Found On Server. Resetted.\n");
            [self.brandLogo resetToDefault];
        }
        
        if (![self.brandLogo isSameBrand:[(NSDictionary *)res objectForKey:@"BrandID"]]) {
            self.brandLogo.brandUrl  = [(NSDictionary *)res objectForKey:@"HomePage"];
            self.brandLogo.brandName = [(NSDictionary *)res objectForKey:@"Name"];
            self.brandLogo.brandId   = [(NSDictionary *)res objectForKey:@"BrandID"];
            self.brandLogo.brandLogoUrl = [(NSDictionary *)res objectForKey:@"Logo"];
            [self.brandLogo loadBrandLogoFromLocalWithID:self.brandLogo.brandId];
            self.brandLogo.brandAccessCode = self.organizationCode;
        }
    }).catch(^(NSError* error) {
        NSLog(@"Failed to get brandlogo with accesscode: %@\n", accessCode);
    });
}

- (BOOL) isVaild:(NSString*) data {
    
    return (data != nil) && (![data isEqualToString:@""])
    && (![data isEqualToString:@"0"]);

    
}

- (BOOL) isVaildFloatValue:(NSString*) data {
    
    return (data != nil) && (![data isEqualToString:@""])
    && (![data isEqualToString:@"0"]) && ([data floatValue] > 0);
    
    
}


- (NSMutableDictionary*) toDictForServer {
    
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    
//    if(self.a1c != nil) {
//        [dict setObject:@{@"A1C_Record": [self.a1c toDictionary]} forKey:@"A1C_Records"];
//    }
    
    [dict setObject:self.userId forKey:@"UserID" ];
  
    [dict setObject:[NSNumber numberWithChar: self.gender] forKey:@"Gender"];
    
    [dict setObject:[NSNumber numberWithChar:self.bgUnit] forKey:@"BGUnit"];
    
    [dict setObject:[NSNumber numberWithChar:self.measureUnit] forKey:@"MeasureUnit"];
    
    [dict setObject:[NSNumber numberWithInt:[GGUtils getSystemLanguageSetting]] forKey:@"Language"];
    [dict setObject:[NSNumber numberWithInt:[GGUtils getAppType]] forKey:@"AppID"];
    
    if(self.dob != nil) {
        [dict setObject:[GGUtils stringOfYear:self.dob] forKey:@"DOB"];
    }
    
    if(self.height != nil) {
        [dict setObject:[NSNumber numberWithInt:[self.height valueWithMetric]] forKey:@"Height"];
    }
    
    if(self.registrationTime != nil) {
        [dict setObject:[GGUtils stringFromDate:self.registrationTime] forKey:@"RegistrationTime"];
    }
    
    if(self.firstName != nil) {
        [dict setObject:self.firstName forKey:@"FirstName" ];
    }
    
    if(self.lastName != nil) {
        [dict setObject:self.lastName forKey:@"LastName" ];
    }
    
    if(self.organizationCode != nil) {
        [dict setObject:self.organizationCode forKey:@"OrganizationCode" ];
    }
    
    if (self.specialID != nil) {
        [dict setObject:self.specialID forKey: @"specialID"];
    }
    
    if(self.waistSize != nil) {
        [dict setObject:[NSNumber numberWithFloat:[self.waistSize valueWithMetric]] forKey:@"WaistSize" ];
    }
    
    if(self.bmi != nil) {
        [dict setObject:[NSNumber numberWithFloat:[self.bmi getValue]] forKey:@"BMI" ];
    }
    else {
        self.bmi = [[BMI alloc] init];
        [dict setObject:[NSNumber numberWithFloat:[self.bmi getValue]] forKey:@"BMI"];
        NSLog(@"BMI is empty when composing the dict for uploading. \n Initialized a new BMI!\n");
    }
    
    if([NSNumber numberWithInt:self.ethnicity] != nil){
        [dict setObject:[NSNumber numberWithInt:self.ethnicity] forKey:@"Ethnicity"];
    }
    
    if (self.condition != nil) {
        
        NSMutableString *tempString = [[NSMutableString alloc] init];
        
        for (int i = 0; i < [self.condition count]; i++) {
            
            NSString *tempStringConditionPart = [NSString stringWithFormat:@"%@", [self.condition objectAtIndex:i]];
            
            [tempString appendString:[NSString stringWithFormat:@"<Condition>%@</Condition>", tempStringConditionPart]];
        }
        
        [dict setObject:tempString forKey:@"Conditions"];
    }
    
    [dict setObject:[GGUtils stringFromDate:[NSDate date]] forKey:@"updatedTime"];

    return dict;
    
}

- (NSDictionary*) toDictionary {
    
    NSMutableDictionary* dict = [self toDictForServer];
    
    [dict setObject:[NSNumber numberWithChar: self.bgUnit] forKey:@"BGUnit" ];
    [dict setObject:[NSNumber numberWithChar: self.measureUnit] forKey:@"MeasureUnit" ];
    
    if(self.flagForServer != nil) {
        [dict setObject:self.flagForServer forKey:@"flagForServer" ];
    }
    
    if(self.introShownCount > APP_MAX_INTRO_SHOWN_COUNT + 1) {
        self.introShownCount = APP_MAX_INTRO_SHOWN_COUNT + 1;
    }
    [dict setObject:[NSNumber numberWithInteger:self.introShownCount] forKey:@"introShownCount"];
    NSLog(@"Saving the introShownCount value=%lu", (unsigned long)self.introShownCount);
    [dict setObject:self.helpTipsShownTracker forKey:@"helpTipsShownTracker"];
    
    [dict setObject:[NSNumber numberWithInteger:self.points] forKey:@"Points" ];
    
    if(self.weight != nil) {
        [dict setObject:[NSNumber numberWithInt:[self.weight valueWithMetric]] forKey:@"Weight"];
    }
    
    if(self.medications != nil) {
        [dict setObject:self.medications forKey:@"medication"];
    }
    
    if (self.brandLogo != nil) {
        if ([self.brandLogo getBrandName] != nil)
            [dict setObject:[self.brandLogo getBrandName] forKey:@"brandlogo_name"];
        if ([self.brandLogo getBrandId] != nil)
            [dict setObject:[self.brandLogo getBrandId] forKey:@"brandlogo_id"];
        if ([self.brandLogo getBrandUrl] != nil)
            [dict setObject:[self.brandLogo getBrandUrl] forKey:@"brandlogo_url"];
        if ([self.brandLogo getBrandAccessCode] != nil)
            [dict setObject:[self.brandLogo getBrandAccessCode] forKey:@"brandlogo_accesscode"];
        if ([self.brandLogo getBrandLogoUrl] != nil)
            [dict setObject:[self.brandLogo getBrandLogoUrl] forKey:@"brandlogo_logourl"];
    }
    
    if (self.condition != nil) {
        
        NSMutableString *tempString = [[NSMutableString alloc] init];
        
        for (int i = 0; i < [self.condition count]; i++) {
            
            NSString *tempStringConditionPart = [NSString stringWithFormat:@"%@", [self.condition objectAtIndex:i]];
            
            [tempString appendString:[NSString stringWithFormat:@"<Condition>%@</Condition>", tempStringConditionPart]];
        }
        
        [dict setObject:tempString forKey:@"Conditions"];
    }

    if([NSNumber numberWithInt:self.ethnicity] != nil){
        [dict setObject:[NSNumber numberWithInt:self.ethnicity] forKey:@"Ethnicity"];
    }
    
    if (self.specialID != nil) {
        [dict setObject:self.specialID forKey: @"specialID"];
    }

    [dict setObject:[GGUtils stringFromDate:[NSDate date]] forKey:@"updatedTime"];
    
    return dict;
    
}

-(NSString*) profileFilePath {
    NSArray* path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* document = [path objectAtIndex:0];
    
    NSString* fileName = [NSString stringWithFormat:USER_PROFILE, self.userId];
    return [document stringByAppendingPathComponent:fileName];
}

-(NSDictionary*) loadProfile {
    
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    
    NSString* filePath = [self profileFilePath];
    
    if(![fileMgr fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSDictionary* profile = [NSDictionary dictionaryWithXMLFile:filePath];
    
    return profile;
}



- (BOOL) saveToLocal {
    [self savePassWord:self.email :self.password];
    
    //self.targetCalories = [self calculateTargetCalories];
    
    NSString* filePath = [self profileFilePath];
    NSError* error = nil;
    
    
    NSString* content = [NSString stringWithFormat:@"<Profile> %@ </Profile>", [[self toDictionary] innerXML]];
    
    
    [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"Profile successfully saved to local.\n");
    
    return YES;
    
    
}


-(void)savePassWord:(NSString *)userName :(NSString *)passWord
{
    NSAssert(self.userId != nil, @"self.userId != nil");
    NSAssert(userName!= nil, @"userName != nil");
    NSAssert(passWord!= nil, @"passWord != nil");
    
    //NSString* key = [NSString stringWithFormat:KEY_USERNAME_PASSWORD, self.userId ];
    
    NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    [usernamepasswordKVPairs setObject:userName forKey:KEY_USERNAME];
    [usernamepasswordKVPairs setObject:passWord forKey:KEY_PASSWORD];
    [usernamepasswordKVPairs setObject:self.userId forKey:KEY_USERID];
    
    [SecurityStorage save:KEY_USERNAME_PASSWORD data:usernamepasswordKVPairs];
}

-(NSDictionary*)readPassWord
{
    //NSAssert(self.userId != nil, @"self.userId != nil");
    
    //NSString* key = [NSString stringWithFormat:KEY_USERNAME_PASSWORD, self.userId ];
    NSMutableDictionary *usernamepasswordKVPair = (NSMutableDictionary *)[SecurityStorage load:KEY_USERNAME_PASSWORD];
    
    
    return usernamepasswordKVPair;
}

-(void)deletePassWord
{
    //NSString* key = [NSString stringWithFormat:KEY_USERNAME_PASSWORD, self.userId];
    [SecurityStorage delete:KEY_USERNAME_PASSWORD];
}

- (float)getTargetCalories {

    float targetCalories = 0.0;
    
    NSDate *now = [NSDate date];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents *nowComps = [cal components:NSCalendarUnitYear fromDate:now];
    NSDateComponents *dobComps = [cal components:NSCalendarUnitYear fromDate:self.dob];
    NSUInteger currentYear = nowComps.year;
    NSUInteger userDobYear = dobComps.year;
    
    float bmrConstant = self.gender == GenderTypeFemale ? FEMALE_BMR_CONSTANT : MALE_BMR_CONSTANT;
    float bmrWeightConstant = self.gender == GenderTypeFemale ? FEMALE_BMR_WEIGHT_CONSTANT : MALE_BMR_WEIGHT_CONSTANT;
    float bmrHeightConstant = self.gender == GenderTypeFemale ? FEMALE_BMR_HEIGHT_CONSTANT : MALE_BMR_HEIGHT_CONSTANT;
    float bmrAgeConstant = self.gender == GenderTypeFemale ? FEMALE_BMR_AGE_CONSTANT : MALE_BMR_AGE_CONSTANT;
    
    float weightParam = bmrWeightConstant * [self.weight valueWithMetric];
    float heightParam = bmrHeightConstant * [self.height valueWithMetric];
    float ageParam = bmrAgeConstant * (currentYear - userDobYear);

//    static float const FEMALE_BMR_CONSTANT = 447.593;
//    static float const FEMALE_BMR_WEIGHT_CONSTANT = 9.247;
//    static float const FEMALE_BMR_HEIGHT_CONSTANT = 3.098;
//    static float const FEMALE_BMR_AGE_CONSTANT = 4.330;
//    static float const MALE_BMR_CONSTANT = 88.362;
//    static float const MALE_BMR_WEIGHT_CONSTANT = 13.397;
//    static float const MALE_BMR_HEIGHT_CONSTANT = 4.799;
//    static float const MALE_BMR_AGE_CONSTANT = 5.677;
    
//    A = Daily total calories  = BMR x 1.2
//    For Men, BMR = 88.362 + (13.397 x weight in kg) + (4.799 x height in cm) - (5.677 x age in years)
//    For Women, BMR = 447.593 + (9.247 x weight in kg) + (3.098 x height in cm) - (4.330 x age in years)
    
    
    float activityLevel = [[ActivityLevel sharedService] userActivityLevel];
    
    targetCalories = (bmrConstant + weightParam + heightParam - ageParam) * activityLevel;
    
    //weight lost factor
    GoalsDelegate* goals = [GoalsDelegate sharedService];
    float dailyLostCalories = 0;
    if(goals.goals[GoalTypeWeight] != [NSNull null]) {
        dailyLostCalories = [((WeightGoal*)goals.goals[GoalTypeWeight]) getDailyCalaries];
    }

    return targetCalories - dailyLostCalories;
}

- (NSDictionary *)scoringMacroDict {
    NSString *xmlPath = [self userSpecificScoringMacroFilePath];
    BOOL userSpecificScoringMacroFileExists = [[NSFileManager defaultManager] fileExistsAtPath:xmlPath];
    
    if (!userSpecificScoringMacroFileExists) {
        xmlPath = [[NSBundle mainBundle] pathForResource:MACRO_NUTRIENT_ESTIMATION_FILE ofType:@"xml"];
    }
    
    return [NSDictionary dictionaryWithXMLFile:xmlPath];
}

- (void)saveScoringMacroDict:(NSDictionary *)xmlDictionary {
    NSString *filePath = [self userSpecificScoringMacroFilePath];
    NSError *error = nil;
    
    [[xmlDictionary XMLString] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
}

- (NSString *)userSpecificScoringMacroFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.xml", MACRO_NUTRIENT_ESTIMATION_FILE, self.userId];
    
    return [document stringByAppendingPathComponent:fileName];
}

-(BOOL) isLoggedIn {
    return self.loggedin;
}

- (NSString*)fullUserName {
    if (self.firstName && self.lastName) {
        return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
    }
    else if (self.firstName && !self.lastName) {
        return self.firstName;
    }
    else if (!self.firstName && self.lastName) {
        return self.lastName;
    }
    else {
        return nil;
    }
}

@end
