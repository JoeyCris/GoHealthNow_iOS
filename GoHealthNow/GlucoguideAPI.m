//
//  GlucoguideAPI.m
//  GlucoGuide
//
//  Created by kthakore on 11/01/14.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//


#import <Foundation/Foundation.h>


#import "XMLDictionary/XMLDictionary.h"

#import "Reachability.h"
#import "ServicesConstants.h"
#import "GlucoguideAPI.h"
#import "HttpClient.h"
#import "GGUtils.h"
#import "User.h"

@interface GlucoguideAPI()

@property Reachability* hostReach;
@property NSLock* retrieveLock;


@end


@implementation GlucoguideAPI;

//NSString* const GGAPI_FILEUPLOAD_URL = @"http://[2001:2::aab1:9ef3:87ff:feb8:9306]:3000/GlucoGuide/fileupload/";
//NSString* const GGAPI_BASEURL =@"http://[2001:2::aab1:9ef3:87ff:feb8:9306]:3000/GlucoGuide/";
//NSString* const GGAPI_HOSTNAME =@"http://[2001:2::aab1:9ef3:87ff:feb8:9306]:3000";
//NSString* const GGAPI_BARCODE_URL = @"http://[2001:2::aab1:9ef3:87ff:feb8:9306]:3000/GlucoGuide/upcfooditems/";


#ifdef DEBUG

/* Before, it was:
 
 NSString* const GGAPI_GET_METADATA =@"https://test.glucoguide.com/GlucoGuide/metadata/list/";
 
 NSString* const GGAPI_INPUT_SELECTION =@"https://test.glucoguide.com/GlucoGuide/inputSelection/";
 
 NSString* const GGAPI_FOOD_SEARCH =@"https://test.glucoguide.com/GlucoGuide/foods/search/";
 NSString* const GGAPI_FOOD_ITEM_SEARCH =@"https://test.glucoguide.com/GlucoGuide/foods/item/";
 NSString* const GGAPI_FOOD_ITEM_AUTOCOMPLETE =@"https://test.glucoguide.com/GlucoGuide/foods/autocomplete/";
 
 NSString* const GGAPI_BARCODE_URL = @"https://test.glucoguide.com/GlucoGuide/upcfooditems/";
 NSString* const GGAPI_FILEUPLOAD_URL = @"https://api.glucoguide.com/GlucoGuide/fileupload/";
 NSString* const GGAPI_BASEURL =@"https://test.glucoguide.com/GlucoGuide/";
 NSString* const GGAPI_HOSTNAME =@"test.glucoguide.com";
 
  The test.glucoguide.api was shut down by UWO the time I developed new functionality so I changed them all to api.glucoguide.com .
  Afterwards, developers can change it back to the URLs above."
 
 */


NSString* const GGAPI_GET_METADATA =@"https://api.glucoguide.com/GlucoGuide/metadata/list/";

NSString* const GGAPI_INPUT_SELECTION =@"https://api.glucoguide.com/GlucoGuide/inputSelection/";

NSString* const GGAPI_FOOD_SEARCH =@"https://api.glucoguide.com/GlucoGuide/foods/search/";
NSString* const GGAPI_FOOD_ITEM_SEARCH =@"https://api.glucoguide.com/GlucoGuide/foods/item/";
NSString* const GGAPI_FOOD_ITEM_AUTOCOMPLETE =@"https://api.glucoguide.com/GlucoGuide/foods/autocomplete/";

NSString* const GGAPI_BARCODE_URL = @"https://api.glucoguide.com/GlucoGuide/upcfooditems/";
NSString* const GGAPI_FILEUPLOAD_URL = @"https://api.glucoguide.com/GlucoGuide/fileupload/";
NSString* const GGAPI_BASEURL =@"https://api.glucoguide.com/GlucoGuide/";
NSString* const GGAPI_HOSTNAME =@"api.glucoguide.com";
//NSString* const GGAPI_HOSTNAME =@"129.100.20.40";


NSString* const GGAPI_GENERAL_FILEUPLOAD_URL =@"https://api.glucoguide.com/GlucoGuide/upload/files";


#else

NSString* const GGAPI_GET_METADATA =@"https://api.glucoguide.com/GlucoGuide/metadata/list/";

NSString* const GGAPI_INPUT_SELECTION =@"https://api.glucoguide.com/GlucoGuide/inputSelection/";

NSString* const GGAPI_FOOD_SEARCH =@"https://api.glucoguide.com/GlucoGuide/foods/search/";
NSString* const GGAPI_FOOD_ITEM_SEARCH =@"https://api.glucoguide.com/GlucoGuide/foods/item/";
NSString* const GGAPI_FOOD_ITEM_AUTOCOMPLETE =@"https://api.glucoguide.com/GlucoGuide/foods/autocomplete/";

NSString* const GGAPI_BARCODE_URL = @"https://api.glucoguide.com/GlucoGuide/upcfooditems/";
NSString* const GGAPI_FILEUPLOAD_URL = @"https://api.glucoguide.com/GlucoGuide/fileupload/";
NSString* const GGAPI_BASEURL =@"https://api.glucoguide.com/GlucoGuide/";
NSString* const GGAPI_HOSTNAME =@"api.glucoguide.com";
//NSString* const GGAPI_HOSTNAME = @"129.100.20.40";

NSString* const GGAPI_GENERAL_FILEUPLOAD_URL =@"https://api.glucoguide.com/GlucoGuide/upload/files";

//facebook
NSString* const GGAPI_FACEBOOK =@"https://api.glucoguide.com/GlucoGuide/upload/files";
#endif




NSString* const GGAPI_PARA_USERLOGIN =@"<LoginInfo ><LoginType >%d</LoginType><UserID >0</UserID><Email >%@</Email><Password >%@</Password> <RegistrationID>%@</RegistrationID><DeviceType>1</DeviceType><AppID>%d</AppID><Language>%@</Language></LoginInfo>";

//facebook
NSString* const GGAPI_PARA_FACEBOOKLOGIN =@"<LoginInfo><Email >%@</Email><FirstName>%@</FirstName><LastName >%@</LastName><OauthProvider>0</OauthProvider><RegistrationID></RegistrationID><DeviceType>1</DeviceType><AppID>1</AppID> <Language>0</Language></LoginInfo>";

//@"<LoginInfo><Email >%@</Email><FirstName >%@</FirstName><LastName >%@</LastName><OauthProvider>0</OauthProvider><!-- //0: Facebook  --><RegistrationID></RegistrationID><DeviceType>1</DeviceType><!-- //0: Android, 1: iOS --><AppID>1</AppID> <!-- 0: GlucoGuide, 1: GoMobileHealth  --><Language>0</Language> <!-- 0: English, 1: French  --></LoginInfo>";

NSString* const GGAPI_PARA_UPDATEPROFILE =@"<Profile> %@ </Profile>";
NSString* const GGAPI_PARA_RECOMMENDATION = @"\
<Recommendation_Request> \
<UserID>%@</UserID> \
<VersionNumber>2.1.3</VersionNumber> \
<Latest_RecommendationTime>%@</Latest_RecommendationTime> \
</Recommendation_Request> ";

NSString* const GGAPI_PARA_RECORDUPLOADING =@"\
<User_Record> %@ \
<Created_Time>%@</Created_Time> \
</User_Record>";

NSString* const GGAPI_PARA_BRANDINGLOGO =@"\
<BrandInfo> \
<UserID>%@</UserID> \
<AccessCode>%@</AccessCode> \
</BrandInfo>";


+ (id) sharedService {
    static GlucoguideAPI* sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
        
    });
    return sharedService;
}

-(id)init {
    if (self = [super init]){
        
        
        self.retrieveLock = [[NSLock alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.hostReach = [Reachability reachabilityForInternetConnection];
        
        [self.hostReach startNotifier];
        
        NetworkStatus netStatus = [self.hostReach currentReachabilityStatus];
        
        if (netStatus != NotReachable) {
            //NSLog(@"receive network change, status: %ld", netStatus);
            [NSTimer scheduledTimerWithTimeInterval:30.0
                                             target:self
                                           selector:@selector(retryCachedMessage)
                                           userInfo:nil
                                            repeats:NO];
        }
        
        
    }
    return self;
}

- (void)reachabilityChanged:(NSNotification *)note {
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    if (netStatus != NotReachable) {
        NSLog(@"receive network change, status: %u", netStatus);
        [NSTimer scheduledTimerWithTimeInterval:30.0
                                         target:self
                                       selector:@selector(retryCachedMessage)
                                       userInfo:nil
                                        repeats:NO];
    }
}



//+(PMKPromise*) sendPostMessageWithRetry: (NSString*) url :(NSString*) paraName :(NSString*)paraValue {
+(Response) sendPostMessageWithRetry: (NSString*) url :(NSString*) paraName :(NSString*)paraValue {
    
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode != 0) {
        
        //cache message locally.
        NSString* cachedFilePath =[NSString stringWithFormat:@"%@/post_%@_%f",
                                   
                                   [GlucoguideAPI getLocalTempDir], paraName,
                                   
                                   [[NSDate date] timeIntervalSince1970]];
        
        NSError* error = nil;
        
        
        
        NSDictionary* dict = @{@"url":url,
                               @"messageType":[NSNumber numberWithChar: GGMessageTypePost],
                               @"paraName": paraName, @"paraValue": paraValue};
        
        
        
        NSString* content = [NSString stringWithFormat:@"<PostMsg> %@ </PostMsg>", [dict innerXML]];
        
        
        
        [content writeToFile:cachedFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        
    }
    
    return response;
}
//
+(PMKPromise*) sendMultiPostMessage: (NSArray*) paraList {
    return [GlucoguideAPI sendMultiPostMessageWithRetry:GGAPI_FILEUPLOAD_URL formParameters:paraList];
}

//return NSDictionary*
- (PMKPromise *)photoRecognition:(NSString *)filePath
                            user:(NSString *)userId
               creationTimeStamp:(NSString *)timeStamp
                            type:(UploadPhotoType)type
{
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        if(filePath != nil) {
            NSArray<NSString *> *filePathComponents = [filePath componentsSeparatedByString:@"/"];
            NSString *imageName = filePathComponents.lastObject;
            
            NSArray* paraList = @[ @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_DATE,
                                       FORM_PARAMETER_VALUE: timeStamp,
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_MEALPHOTO,
                                       FORM_PARAMETER_VALUE: filePath,
                                       FORM_PARAMETER_ISFILE: @YES,
                                       FORM_PARAMETER_MIMETYPE: PHOTO_UPLOAD_PARA_TYPE},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_USERID,
                                       FORM_PARAMETER_VALUE: userId,
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_PHOTONAME,
                                       FORM_PARAMETER_VALUE: imageName,
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_PHOTOTYPE,
                                       FORM_PARAMETER_VALUE: [NSString stringWithFormat:@"%ld", (long)type],
                                       FORM_PARAMETER_ISFILE: @NO}
                                   ];
            
            
            
            [GlucoguideAPI sendMultiPostMessageWithoutRetry:paraList].then(^(id res){
                [res setObject:imageName forKey:@"Image_name"];
                fulfill(res);
            }).catch(^(id res) {
                reject(res);
            });
        }
        
    }];
}
//////////////

-(void)sendAudioWithFile:(NSString *)filePath fileName:(NSString *)fileName user:(NSString *)userId creationTimeStamp:(NSString *)timeStamp{
    
    NSArray* paraList = @[ @{
                               FORM_PARAMETER_NAME: @"date",
                               FORM_PARAMETER_VALUE: timeStamp,
                               FORM_PARAMETER_ISFILE: @NO},//
                           @{
                               FORM_PARAMETER_NAME: @"file_name",
                               FORM_PARAMETER_VALUE: filePath,
                               FORM_PARAMETER_ISFILE: @YES,
                               FORM_PARAMETER_MIMETYPE: @"audio/mpeg3"},
                           @{
                               FORM_PARAMETER_NAME: @"user_id",
                               FORM_PARAMETER_VALUE: userId,
                               FORM_PARAMETER_ISFILE: @NO},
                           @{
                               FORM_PARAMETER_NAME: @"file_name",
                               FORM_PARAMETER_VALUE: fileName,
                               FORM_PARAMETER_ISFILE: @NO},
                           @{
                               FORM_PARAMETER_NAME: @"file_type",
                               FORM_PARAMETER_VALUE: @"mp3",
                               FORM_PARAMETER_ISFILE: @NO}
                           ];
    
    Response response = [HttpClient sendMultiPostMessage:GGAPI_GENERAL_FILEUPLOAD_URL :paraList];
    NSString* data = response[@"data"];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    
    NSLog(@"audio data response: %@", response);
    if(retCode == 0) {
        
        NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
        NSLog(@"Audio Response: %@", dict);
        
        
    } else {
        NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
        NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
        
       NSLog(@"Audio Response Error: %@", error);
    }
    
    
}


/////////////

+(PMKPromise*) sendMultiPostMessageWithoutRetry:(NSArray*) paraList {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        Response response = [HttpClient sendMultiPostMessage:GGAPI_FILEUPLOAD_URL :paraList];
        NSString* data = response[@"data"];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            
            NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
            
            fulfill(dict);
            
        } else {
            NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
            
            reject(error);
        }
        
    }];
}

-(PMKPromise *)getInputSelectionWithUserId:(NSString*) userId {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        Response response = [HttpClient sendPostMessage:GGAPI_GET_METADATA :@"userID" :userId];
        
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            NSLog(@"input selection server response: %@", data);
            NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
            
            fulfill(dict);
        }
        else {
            NSLog(@"failed to request input selection. return message: %@", response);
            NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        }
    }];
}

+(PMKPromise*) sendMultiPostMessageWithRetry: (NSString*) url formParameters:(NSArray*) paraList;  {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        Response response = [HttpClient sendMultiPostMessage:url :paraList];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode != 0) {
            
            //cache message locally.
            NSString* cachedFilePath =[NSString stringWithFormat:@"%@/multipost_photo_%f",
                                       
                                       [GlucoguideAPI getLocalTempDir],
                                       [[NSDate date] timeIntervalSince1970]];
            
            NSError* error = nil;
            
            
            
            NSDictionary* dict = @{@"url":url,
                                   @"messageType":[NSNumber numberWithChar: GGMessageTypeMultiPost],
                                   @"paraList": paraList};
            
            
            
            NSString* content = [NSString stringWithFormat:@"<MultiPostMsg> %@ </MultiPostMsg>", [dict innerXML]];
            
            
            
            [content writeToFile:cachedFilePath atomically:YES
                        encoding:NSUTF8StringEncoding error:&error];
            
            fulfill(@(YES));
            
            
        } else {
            NSString* data = [[response objectForKey:@"data"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            
            if([data isEqualToString:@"success"]) {
                //fulfill([NSNumber numberWithBool:YES]);
                fulfill(@(YES));
            } else {
                //fulfill([NSNumber numberWithBool:NO]);
                fulfill(@(NO));
            }
            
        }
        
    }];
}

+(NSArray *)sendBarcode:(NSString *)barcode{
    
    Response response = [HttpClient sendPostMessage:GGAPI_BARCODE_URL :@"upc" :barcode];
    
    switch ([[[NSDictionary dictionaryWithXMLString: [response objectForKey:@"data"]] objectForKey:@"UPCScaning_Status"]integerValue]) {
        case 0:{
            NSLog(@"NO ERROR");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"0", [NSDictionary dictionaryWithXMLString: [response objectForKey:@"data"]], nil];
            return responseArray;
            break;
        }
        case 1:{
            NSLog(@"Barcode Format Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"Barcode Format Error\nPlease Try Again", nil];
            return responseArray;
            break;
        }
        case 2:
        {
            NSLog(@"Barcode Not Found Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"Barcode Not Found In Database", nil];
            return responseArray;
            break;
        }
        default:
            break;
    }
    
    return nil;
}

//////

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    
    NSLog(@"connection: %@ - error: %@", connection, error);
    
}


+(NSArray *)sendFoodToSearch:(NSString *)foodItem withPageNumber:(int)page{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GGAPI_FOOD_SEARCH]];
    request.timeoutInterval = 4;
    
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

    NSString *stringData = [NSString stringWithFormat:@"pageNumber=%d&key=%@", page,foodItem];

    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    NSURLResponse *res = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
   
    NSDictionary *response = [NSDictionary dictionaryWithXMLData:responseData];
    
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)res;
    NSInteger statusCode = [HTTPResponse statusCode];

    
    switch (statusCode) {
        case 200:{
          
            NSNumber *providerID =  [response objectForKey:@"ProviderID"];
            
            if (!providerID || ([[response objectForKey:@"Food"] count] == 0 && page == 0)) {
                
                providerID = [NSNumber numberWithInt:9999];
                
                NSArray *responseArray = [[NSArray alloc]initWithObjects:providerID, [response objectForKey:@"Food"], nil];
                return responseArray;
                break;
                
            }else{
            
                NSArray *responseArray = [[NSArray alloc]initWithObjects:providerID, [response objectForKey:@"Food"], nil];
                return responseArray;
                break;
            }
            
        }
        case 404:{
            NSError *err = [NSError errorWithDomain:NSNetServicesErrorDomain code:404 userInfo:@{ERROR_DICT_DESCRIPTION:@"Server returned 404, redirected to local db search."}];
            NSLog(@"Server returned 404.");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", err, nil];
            return responseArray;
            break;
        }
        case 1:{
            NSError *err = [NSError errorWithDomain:NSNetServicesErrorDomain code:1 userInfo:@{ERROR_DICT_DESCRIPTION:@"Format Error\nPlease Try Again"}];
            NSLog(@"Format Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", err, nil];
            return responseArray;
            break;
        }
        case 2:
        {
            NSError *err = [NSError errorWithDomain:NSNetServicesErrorDomain code:2 userInfo:@{ERROR_DICT_DESCRIPTION:@"Not Found In Database"}];
            NSLog(@"Not Found Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", err, nil];
            return responseArray;
            break;
        }
        default:
            NSLog(@"Dic: %@", response);
            NSLog(@"Data: %@", responseData);
            NSLog(@"Morw: %@", HTTPResponse);
            NSLog(@"Auto Complete Error: %@", res);
            break;
    }
 
    return nil;
}


+(NSArray *)getAutoCompleteResponseWithKey:(NSString *)partialFoodName{
    
    if ([partialFoodName length] < 2) {
        partialFoodName = @"";
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GGAPI_FOOD_ITEM_AUTOCOMPLETE]];
    request.timeoutInterval = 4;
    
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *stringData = [NSString stringWithFormat:@"key=%@", partialFoodName];
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    NSURLResponse *res = nil;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
    
    NSDictionary *responseDic = [NSDictionary dictionaryWithXMLData:responseData];

    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)res;
    NSInteger statusCode = [HTTPResponse statusCode];

     switch (statusCode) {
     case 200:{       
         
         if ([[responseDic objectForKey:@"Suggestion"] isKindOfClass:[NSArray class]]) {
             NSArray *responseArray = [[NSArray alloc] initWithArray:[responseDic objectForKey:@"Suggestion"]];
             return responseArray;
         }else{
             
             NSArray *tempArray = [[NSArray alloc] initWithObjects:[responseDic objectForKey:@"Suggestion"], nil];
             return tempArray;
         }
         
         
     break;
     }
    
     case 1:{
     NSLog(@"AutoComplete Format Error");
     NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"AutoComplete Format Error\nPlease Try Again", nil];
     return responseArray;
     break;
     }
     case 2:
     {
     NSLog(@"AutoComplete Not Found Error");
     NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"AutoComplete Not Found In Database", nil];
     return responseArray;
     break;
     }
     default:
             NSLog(@"Dic: %@", responseDic);
             NSLog(@"Data: %@", responseData);
             NSLog(@"Morw: %@", HTTPResponse);
             NSLog(@"Auto Complete Error: %@", res);
     break;
     }
     
     return nil;
 
}


/////Getting INVALID XML response from server Emailed Robert to ask why;
-(NSDictionary *)sendInputSelectionWithArray:(NSMutableArray *)selectionArray{
    
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GGAPI_INPUT_SELECTION]];
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    User* user = [User sharedModel];
    NSString *uuid = [[NSUUID UUID] UUIDString];
    
    NSMutableString *stringData = [NSMutableString stringWithFormat:@"<InputSelection><UserID>%@</UserID><Uuid>%@</Uuid><Selections>", user.userId,uuid];
    
    for (int i = 0; i < [selectionArray count]; ++ i) {
        
        [stringData appendString:[NSString stringWithFormat:@"<Selection>%@</Selection>", [selectionArray objectAtIndex:i]]];
    }
    
    [stringData appendString:[NSString stringWithFormat:@"</Selections><RecordedTime>%@</RecordedTime></InputSelection>", [GGUtils stringFromDate:[NSDate date]]]];
    
    NSString *stringDataSend = [NSString stringWithFormat:@"InputSelection=%@", stringData];
     
    NSData *requestBodyData = [stringDataSend dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    NSURLResponse *res = nil;

     NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
     NSDictionary *response = [NSDictionary dictionaryWithXMLData:responseData];
    
    return response;    
}


+(NSDictionary *)getFoodItemFromApiWithProviderID:(int)providerID andItemID:(NSString *)itemID {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:GGAPI_FOOD_ITEM_SEARCH]];
    request.timeoutInterval = 4;
    
    
    request.HTTPMethod = @"POST";
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSString *stringData = [NSString stringWithFormat:@"providerID=%d&itemID=%@", providerID, itemID];
    
    NSLog(@"sending search for: %@", stringData);
    
    NSData *requestBodyData = [stringData dataUsingEncoding:NSUTF8StringEncoding];
    request.HTTPBody = requestBodyData;
    
    NSURLResponse *res = nil;
    
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&res error:nil];
    
    NSLog(@"res: %@", res);
    
    NSDictionary *response = [NSDictionary dictionaryWithXMLData:responseData];
    
    switch ([[[NSDictionary dictionaryWithXMLString: [response objectForKey:@"data"]] objectForKey:@"Item"]integerValue]) {
        case 0:{
            NSLog(@"NO ERROR");
            return response;
            break;
        }
        case 1:{
            NSLog(@"Format Error");
            return response;
            break;
        }
        case 2:
        {
            NSLog(@"Not Found Error");
            return response;
            break;
        }
        default:
            break;
    }
    
    return nil;
    
    /*
    NSArray* paraList = @[ @{
                               @"ProviderID": [NSNumber numberWithInt:providerID],
                               @"ItemID": itemID}];
    
    NSLog(@"para: %@", paraList);
    
    
     Response response = [HttpClient sendMultiPostMessage:GGAPI_FOOD_ITEM_SEARCH: paraList];
    
    NSLog(@"response: %@", response);
    
    switch ([[[NSDictionary dictionaryWithXMLString: [response objectForKey:@"data"]] objectForKey:@"Item"]integerValue]) {
        case 0:{
            NSLog(@"NO ERROR");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"0", [NSDictionary dictionaryWithXMLString: [response objectForKey:@"data"]], nil];

            NSLog(@"responseArray: %@", responseArray);
            
            
            return responseArray;
            break;
        }
        case 1:{
            NSLog(@"Format Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"Format Error\nPlease Try Again", nil];
            return responseArray;
            break;
        }
        case 2:
        {
            NSLog(@"Not Found Error");
            NSArray *responseArray = [[NSArray alloc] initWithObjects:@"1", @"Not Found In Database", nil];
            return responseArray;
            break;
        }
        default:
            break;
    }
    
    return nil;

 */
    
}

/////

+(NSString*) getLocalTempDir {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    
    NSString *cachesDir = [NSString stringWithFormat:@"%@/ggCachedMsg", [paths objectAtIndex:0]];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:cachesDir isDirectory:&isDir];
    
    
    if(!(isDirExist && isDir))
        
    {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"Create cached message directory failed.");
            
        }
        
    }
    
    return cachesDir;
    
}



//-(PMKPromise*) retryCachedMessage {
-(void) retryCachedMessage {
    dispatch_promise(^{
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSError* error = nil;
        NSString* filePath = [GlucoguideAPI getLocalTempDir];
        
        NSArray *fileList = [[NSArray alloc] init];
        
        fileList = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
        
        for (NSString *file in fileList) {
            
            NSString *path = [filePath stringByAppendingPathComponent:file];
            
            if([fileManager fileExistsAtPath:path ]){
                
                NSDictionary* message = [NSDictionary dictionaryWithXMLFile:path];
                
                Response response = nil;
                
                GGServerMessageType messageType = [message[@"messageType"] intValue];
                if(messageType == GGMessageTypePost) {
                    
                    response = [HttpClient sendPostMessage:message[@"url"]
                                                          :message[@"paraName"] : message[@"paraValue"]];
                } else if(messageType == GGMessageTypeMultiPost){
                    //need to do
                    response = [HttpClient sendMultiPostMessage:message[@"url"]
                                                               :message[@"paraList"]];
                }
                
                int retCode = [[response objectForKey:@"retCode"] intValue];
                
                if(retCode == 0) {
                    //remove cached file
                    [fileManager removeItemAtPath:path error:&error];
                    //removeFileAtPath
                }
            }
        }
        
    });
}

+ (PMKPromise*) userLoginWithXML:(NSString*) loginRequest {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSString *url= [NSString stringWithFormat:@"%@verifyaction",GGAPI_BASEURL];
        NSString* paraName = @"LoginInfo";
        
        Response response = [HttpClient sendPostMessage:url :paraName :loginRequest];
        
        NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            
            if(![data isEqualToString:@"Email and password do not match"] && ![data isEqualToString:@"Account already exists"]) {
                
                
                NSScanner* scan = [NSScanner scannerWithString: data];
                int val;
                
                //the response is userId
                if( [scan scanInt:&val]&&[scan isAtEnd]) {
                    //self->userId_ = data;
                    fulfill(@{@"UserID":data});
                } else { // the response is userProfile
                    NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
                    
                    if([dict[@"__name"] isEqualToString:@"Profile"]) {
                        fulfill(dict);
                    } else {
                        
                        NSString* errorMsg = (data.length >= 100) ? [data substringToIndex:99]: data;
                        
                        NSDictionary* details = [NSDictionary dictionaryWithObject:
                                                 [NSString stringWithFormat:@"%@\n%@", SERVER_MESSAGE_UNKNOWN_ERROR, errorMsg]forKey:NSLocalizedDescriptionKey];//
                        
                        NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
                        
                        reject(error);
                    }
                }
                
            } else {
                NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
                
                reject(error);
            }
            
        } else {
            NSLog(@"this is  first login");

            
            NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
            
            reject(error);
        }
        
    }];
    
    
}

//facebook
+ (PMKPromise*) userFacebookLoginWithXML:(NSString*) facebookLoginRequest {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSString* paraName = @"LoginInfo";
        NSString *url= [NSString stringWithFormat:@"%@oauthsignin",GGAPI_BASEURL];
        
        
        Response response = [HttpClient sendPostMessage:url :paraName :facebookLoginRequest];
        
        NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            
            if(![data isEqualToString:@"facebookEmail and password do not match"] && ![data isEqualToString:@"Account already exists"]) {
                
                
                NSScanner* scan = [NSScanner scannerWithString: data];
                int val;
                
                //the response is userId
                if( [scan scanInt:&val]&&[scan isAtEnd]) {
                    //self->userId_ = data;
                    fulfill(@{@"UserID":data});
                } else { // the response is userProfile
                    NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
                    
                    //add registrationTime  judge  2018-07-19T16:02:32+0000
                    NSString *RegistrationTime = dict[@"RegistrationTime"];
                    
                    if (![RegistrationTime isEqualToString:@""]){
                        BOOL isFaceBookFirstLogin = [GlucoguideAPI compareReturnDateWithNowDate:RegistrationTime];
                        User *user = [User sharedModel];

                        if (!isFaceBookFirstLogin) {
                            user.isFreshUser = NO;
                        }else{
                            user.isFreshUser = YES;
                        }
                        
                    }
                    
                    if([dict[@"__name"] isEqualToString:@"Profile"]) {
                        fulfill(dict);
                    } else {
                        
                        NSString* errorMsg = (data.length >= 100) ? [data substringToIndex:99]: data;
                        
                        NSDictionary* details = [NSDictionary dictionaryWithObject:
                                                 [NSString stringWithFormat:@"%@\n%@", SERVER_MESSAGE_UNKNOWN_ERROR, errorMsg]forKey:NSLocalizedDescriptionKey];//
                        
                        NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
                        
                        reject(error);
                    }
                }
                
            } else {
                NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
                
                reject(error);
            }
            
        } else {
            
            NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
            
            reject(error);
        }
        
    }];
    
    
}

+(BOOL)compareReturnDateWithNowDate:(NSString *)firstDate {
    
    // Standard Format  EEE MMM d HH:mm:ss Z yyyy
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    
    NSDate *create = [formater dateFromString:firstDate];
    NSString *nowDateStr = [formater stringFromDate:[NSDate date]];
    NSDate *now = [formater dateFromString:nowDateStr];
    
    NSTimeInterval timeDifference = [now timeIntervalSinceDate:create];
    if (timeDifference - 120 >= 0.000001) {
        //facebook exits login
        NSLog(@"highter  2 minuters");
        return NO;
    }else{
        //facebook new login
        NSLog(@"lower  2 minuters");
        return YES;
    }
}


//- (PMKPromise*) createAccount:(NSString*) email pasword:(NSString*) password notificationToken:(NSData*) token {
//
//    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
//
//        NSString* deviceToken = (token == nil)? @"" :
//        [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]
//            stringByReplacingOccurrencesOfString: @" " withString: @""];
//
//        NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_USERLOGIN, 0, email, password,
//                               deviceToken];
//
//        NSString *url= [NSString stringWithFormat:@"%@verifyaction",GGAPI_BASEURL];
//        NSString* paraName = @"LoginInfo";
//
//        Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
//
//        NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
//        int retCode = [[response objectForKey:@"retCode"] intValue];
//        if(retCode == 0) {
//
//            if(![data isEqualToString:@"Email and password do not match"] && ![data isEqualToString:@"Account already exists"]) {
//
//
//                NSScanner* scan = [NSScanner scannerWithString: data];
//                int val;
//
//                //the response is userId
//                if( [scan scanInt:&val]&&[scan isAtEnd]) {
//                    //self->userId_ = data;
//                    fulfill(@{@"UserID":data});
//                } else { // the response is userProfile
//                    NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
//                    fulfill(dict);
//                }
//
//            } else {
//                NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
//                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
//
//                reject(error);
//            }
//
//        } else {
//
//            NSDictionary* details = [NSDictionary dictionaryWithObject:data forKey:NSLocalizedDescriptionKey];//
//            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
//
//            reject(error);
//        }
//
//    }];
//
//}


- (PMKPromise*) createAccount:(NSString*) email pasword:(NSString*) password notificationToken:(NSData*) token {
    
    NSString* deviceToken = (token == nil)? @"" :
    [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_USERLOGIN, 0, email, password,
                           deviceToken, [GGUtils getAppType],[NSString stringWithFormat:@"%d", [GGUtils getSystemLanguageSetting]]];
    
    return [GlucoguideAPI userLoginWithXML:paraValue];
}

- (PMKPromise*) authenticate:(NSString*) email pasword:(NSString*) password notificationToken:(NSData*) token {
    
    NSString* deviceToken = (token == nil)? @"" :
    [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    
    
    //    [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]
    //     stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_USERLOGIN, 1, email, password,
                           deviceToken, [GGUtils getAppType], [NSString stringWithFormat:@"%d", [GGUtils getSystemLanguageSetting]]];
    
    return [GlucoguideAPI userLoginWithXML:paraValue];
}

//facebook
- (PMKPromise*) facebookAuthenticate:(NSString*)email name:(NSString*)name  notificationToken:(NSData*) token {
    
    NSString* deviceToken = (token == nil)? @"" :
    [[[[token description]stringByReplacingOccurrencesOfString: @"<" withString: @""]                  stringByReplacingOccurrencesOfString: @">" withString: @""]
     stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_FACEBOOKLOGIN, email, name,@""];
    
    return [GlucoguideAPI userFacebookLoginWithXML:paraValue];
}


- (PMKPromise*) updateProfile:(NSDictionary*) profile {
    
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_UPDATEPROFILE, [profile innerXML]];
    
    return [GlucoguideAPI updateProfileWithXML:paraValue];
}

+ (PMKPromise*) updateProfileWithXML:(NSString*) profile {
    
    dispatch_promise(^{
        
        NSString *url= [NSString stringWithFormat:@"%@regaction",GGAPI_BASEURL];
        NSString* paraName = @"Profile";
        
        Response response = [HttpClient sendPostMessage:url :paraName :profile];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            
            if(![data isEqualToString:@"Initial Registration Success"]) {
                NSLog(@"failed to upload profile to server. return message: %@", data);
            }
        } else {
            NSLog(@"failed to upload profile to server. return message: %@", response);
        }
        
    });
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        fulfill(@(YES));
    }];
}

-(PMKPromise *)getBrandLogoWithUserId:(NSString*) userId AccessCode:(NSString *)accessCode {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        NSString *url= [NSString stringWithFormat:@"%@brand",GGAPI_BASEURL];
        NSString *paraName = @"accesscode";
        NSString *paraValue = [NSString stringWithFormat:GGAPI_PARA_BRANDINGLOGO, userId, accessCode];
        
        Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            NSLog(@"brand server response: %@", data);
            NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
            
            fulfill(dict);
        }
        else {
            NSLog(@"failed to request the branding logo. return message: %@", response);
            NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        }
    }];
}

-(PMKPromise *)getGoalsWithUserId:(NSString *) userId {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject){
        NSString *url= [NSString stringWithFormat:@"%@goals/list_recent",GGAPI_BASEURL];
        NSString *paraName = @"userID";
        NSString *paraValue = userId;
        Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if(retCode == 0) {
            NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
            
            fulfill(dict);
        } else {
            NSLog(@"failed to request the goals. return message: %@", response);
            NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        }
        
    }];
}

-(void)deleteRecordWithRecord:(int)type andUUID:(NSString *)uuid{
    
    User* user = [User sharedModel];
    
    NSString *url= [NSString stringWithFormat:@"%@delete",GGAPI_BASEURL];
    NSString *paraName = @"userRecord";
    NSString *paraValue = [NSString stringWithFormat:@"<User_Record><UserID>%@</UserID><Records><Record><Type>%d</Type><Uuid>%@</Uuid></Record></Records><Created_Time>%@</Created_Time></User_Record", user.userId, type, uuid, [GGUtils stringFromDate:[NSDate date]]];
    
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    NSString *retCode = [response objectForKey:@"retCode"];
    
    NSLog(@"Delete Return Code: %@", retCode);
    
    
}



-(NSDictionary *)getActivityLevelWithUserId:(NSString *) userId {
    
    NSString *url= [NSString stringWithFormat:@"%@activity_level/list_recent",GGAPI_BASEURL];
    NSString *paraName = @"userID";
    NSString *paraValue = userId;
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode == 0) {
        NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
        
        return dict;
        
    } else {
        NSLog(@"failed to request the goals. return message: %@", response);
        //NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
        //NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
        
        NSDictionary *errorDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:1.2], @"ActivityLevel",
                                   @"Profile", @"_name",
                                   nil];
        NSLog(@"Error with return from Server Activity Level");
        
        return errorDict;
    }
    
}

-(NSDictionary *)getCalorieDistributionWithUserId:(NSString *) userId {
    
    NSString *url= [NSString stringWithFormat:@"%@macros/list_recent", GGAPI_BASEURL];
    NSString *paraName = @"userID";
    NSString *paraValue = userId;
    Response response = [HttpClient sendPostMessage:url :paraName :paraValue];
    int retCode = [[response objectForKey:@"retCode"] intValue];
    if(retCode == 0) {
        NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
        NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
        
        return dict;
    } else {
        NSLog(@"failed to request the goals. return message: %@", response);
        //NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
        // NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
        
        NSDictionary *errorDict =  [[NSDictionary alloc] initWithObjectsAndKeys:
                                    [NSNumber numberWithFloat:0.5], @"Carbs",
                                    [NSNumber numberWithFloat:0.2], @"Protein",
                                    [NSNumber numberWithFloat:0.3], @"Fat",
                                    @"Macros", @"_name",
                                    nil];
        
        NSLog(@"Error with return from Server macros calories");
        
        return errorDict;
    }
}

- (PMKPromise*) retrieveRecommendation:(NSString*) userId :(NSDate*) fromTime{
    
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_RECOMMENDATION, userId, [GGUtils stringFromDate:fromTime]];
    
    return [self retrieveRecommendationWithXML:paraValue];
    
    
}



//NSDictionary* retrieveRecommendation()
- (PMKPromise*) retrieveRecommendationWithXML:(NSString*) request {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        //if there is a retrieveRecommendation call, just ignore the new call
        if ([self.retrieveLock tryLock]) {
            
            NSString *url= [NSString stringWithFormat:@"%@recaction",GGAPI_BASEURL];
            NSString* paraName = @"infile";
            
            
            Response response = [HttpClient sendPostMessage:url :paraName :request];
            [self.retrieveLock unlock];
            
            int retCode = [[response objectForKey:@"retCode"] intValue];
            if(retCode != 0) {
                NSDictionary* details = [NSDictionary dictionaryWithObject:response forKey:NSLocalizedDescriptionKey];//
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
                
                reject(error);
            }
            
            NSString* data = [[response objectForKey:@"data"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            
            if(![data isEqualToString:@"No Recommendation"]) {
                
                NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
                
                if([dict[@"__name"] isEqualToString:@"Recommendations"]) {
                    fulfill(dict);
                } else {
                    NSDictionary* details = [NSDictionary dictionaryWithObject:SERVER_MESSAGE_UNKNOWN_ERROR
                                                                        forKey:NSLocalizedDescriptionKey];//
                    NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XConnectionFailed userInfo:details];
                    
                    reject(error);
                }
            } else {
                fulfill(nil);
            }
        }
    }];
}

//BOOL saveRecord(NSDictionary* ggRecords)
- (PMKPromise*) saveRecord:(NSDictionary*) ggRecords{
    NSString* paraValue = [NSString stringWithFormat:GGAPI_PARA_RECORDUPLOADING,
                           [GGUtils stringFromDate:[NSDate date]],
                           [ggRecords innerXML]];
    
    return [self saveRecordWithXML:paraValue];
}

//BOOL uploadPhoto:(NSString*) fileName;
- (PMKPromise*) uploadPhoto:(NSString*) userId filePath:(NSString*) path {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
    
    
    NSArray* paraList = @[ @{
                               FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_DATE,
                               FORM_PARAMETER_VALUE: [dateFormatter stringFromDate:[NSDate date]],
                               FORM_PARAMETER_ISFILE: @NO},
                           @{
                               FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_MEALPHOTO,
                               FORM_PARAMETER_VALUE: path,
                               FORM_PARAMETER_ISFILE: @YES,
                               FORM_PARAMETER_MIMETYPE: PHOTO_UPLOAD_PARA_TYPE},
                           
                           @{
                               FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_USERID,
                               FORM_PARAMETER_VALUE: userId,
                               FORM_PARAMETER_ISFILE: @NO},
                           ];
    
    
    return [GlucoguideAPI sendMultiPostMessageWithRetry:GGAPI_FILEUPLOAD_URL formParameters:paraList];
    
    
}


- (PMKPromise*) saveRecordWithXML:(NSString*) ggRecords  {
    dispatch_promise(^{
        
        NSString *url= [NSString stringWithFormat:@"%@Write",GGAPI_BASEURL];
        NSString* paraName = @"userRecord";
        
        [GlucoguideAPI sendPostMessageWithRetry:url :paraName :ggRecords];
        
    });
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        fulfill(@(YES));
    }];
    
}

- (PMKPromise*) saveCustomizedFoodItemWithXML:(NSString *)foodItemXML {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        NSString *url = [NSString stringWithFormat:@"%@addUserFoodItem", GGAPI_BASEURL];
        NSString *paraName = @"UserFoodItem";
        
        Response response = [HttpClient sendPostMessage:url :paraName :foodItemXML];
        int retCode = [[response objectForKey:@"retCode"] intValue];
        if (retCode == 0) {
            NSString* data = [[response objectForKey:@"data"]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] ];
            NSDictionary* dict = [NSDictionary dictionaryWithXMLString:data];
            fulfill(dict);
        }
        else {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[response objectForKey:@"data"]forKey:NSLocalizedDescriptionKey];//
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XAuthenticateFailed userInfo:details];
            
            reject(error);
        }
    }];
}


@end
