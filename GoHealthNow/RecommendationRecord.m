//
//  RecommendationRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-11.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "XMLDictionary/XMLDictionary.h"

#import "RecommendationRecord.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "GGUtils.h"
#import "ServicesConstants.h"

#import "HttpClient.h"


@implementation RecommendationRecord



//<Recommendation>
//<Type>0</Type>
//<Content>Welcome to GlucoGuide!</Content>
//<Createdtime>2014/10/15/08/51/33</Createdtime>
//</Recommendation>
+(instancetype) createWithDictionary:(NSDictionary*) record {
    
    if((record[@"Type"] == nil)||(record[@"Content"] == nil)||(record[@"Createdtime"] == nil) ){
        NSLog(@"property is null when create recommendation %@", record);
        
        return nil;
        
    }
    
    RecommendationRecord* recommendation = [[RecommendationRecord alloc] init];
    
    NSUInteger type = [record[@"Type"] integerValue];
    recommendation.type = [RecommendationRecord convertTypeToLocal: type];
    
    recommendation.content = record[@"Content"];
    
    recommendation.content = [recommendation.content stringByReplacingOccurrencesOfString:@"'" withString:@"`"];
    
    
    recommendation.createdTime = [GGUtils dateFromString:record[@"Createdtime"]];
    recommendation.link = record[@"URL"];
    
    //
    NSString* imageURL = record[@"ImageURL"];
    
    if(imageURL != nil) {
        
        recommendation.imageLocation = ImageLocationRemote;
        
        if (![[imageURL substringToIndex:4] isEqualToString:@"http"]) {
            recommendation.imageURL = [NSString stringWithFormat:@"http://%@/%@",
                                       GGAPI_HOSTNAME, imageURL];
        } else {
            recommendation.imageURL = imageURL;
        }
        
        [recommendation cachePhotoToLocal];
    }
    
    
    return recommendation;
}

-(BOOL) cachePhotoToLocal {
    NSString *imageName = [[self.imageURL componentsSeparatedByString:@"/"] lastObject];
    if(imageName != nil) {
        NSString* cachedFilePath = [RecommendationRecord getCachedFilePath: imageName];
        
        if(cachedFilePath != nil){
            //set url to local path
            self.imageLocation = ImageLocationLocal;
            self.imageURL = cachedFilePath;
        } else {
            Response response = [HttpClient downloadFile:self.imageURL
                                path:[GGUtils getCachedPhotoPath]
                            fileName:imageName];
            
            int retCode = [[response objectForKey:@"retCode"] intValue];
            if(retCode == 0) {
                self.imageLocation = ImageLocationLocal;
                NSString* tmpFilePath = [NSString stringWithFormat:@"%@/%@",
                                         [GGUtils getCachedPhotoPath],
                                         imageName];
                self.imageURL = tmpFilePath;
            }
        }
    }
    
    return YES;
}


+(NotificationType) convertTypeToLocal: (NSUInteger) serverType {
    if(serverType == 2 || serverType == 6 || serverType == 8) {
        return NotificationTypeAdvice;
    } else if (serverType == 10) {
        return NotificationTypeHealthTip;
    } else  {
        return NotificationTypeMessage;
    }
}

+(NSString *) getTypeDescription:(NotificationType) type {
    switch (type) {
        case NotificationTypeAdvice:
            return [LocalizationManager getStringFromStrId:@"Advice"];
            break;
        case NotificationTypeHealthTip:
            return [LocalizationManager getStringFromStrId:@"Health Tip"];
        case NotificationTypeMessage:
            return [LocalizationManager getStringFromStrId:@"Message"];
        default:
            return [LocalizationManager getStringFromStrId:@"Message"];
            break;
    }
}


+(NSString*) getCachedFilePath: (NSString*) fileName {
    
//    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    
    NSString* tmpFilePath = [NSString stringWithFormat:@"%@/%@",
                             [GGUtils getCachedPhotoPath],
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

+(PMKPromise *)retrieve {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        User* user = [User sharedModel];
        GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        
        PMKPromise* promise = [ggAPI retrieveRecommendation: user.userId :[NSDate date]];
        
        promise.then(^(id res) {
            
            NSDictionary* dict = (NSDictionary*)res;
            
            if(dict != nil) {
                id records = dict[@"Recommendation"];
                
                if([records isKindOfClass:[NSArray class]]) {
                    
                    for(int i = (int)[records count]-1; i>=0; i--) {
                        NSDictionary* record = records[i];
                        RecommendationRecord* recommendation = [RecommendationRecord createWithDictionary: record];
                        if(recommendation == nil) {
                            continue;
                        }
                        
                        [DBHelper insertToDB: recommendation];
                        [results addObject:recommendation];
                    }
                } else if([records isKindOfClass:[NSDictionary class]]){
                    RecommendationRecord* recommendation = [RecommendationRecord createWithDictionary: records];
                    
                    if(recommendation != nil) {
                        [DBHelper insertToDB: recommendation];
                        [results addObject:recommendation];
                    }
                }
                
            }
            
            
            fulfill(results);
            
        }).catch(^(NSError* error) {
            reject(error);
            
        });
    }];
}

//+(PMKPromise *)retrieve {
//    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
//        User* user = [User sharedModel];
//        GlucoguideAPI* ggAPI = [GlucoguideAPI sharedService];
//        
//        NSMutableArray* results = [[NSMutableArray alloc] init];
//        
//        PMKPromise* promise = [ggAPI retrieveRecommendation: user.userId :[NSDate date]];
//        
//        promise.then(^(id res) {
//            
//            NSDictionary* dict = (NSDictionary*)res;
//            
//            if(dict != nil) {
//                id records = dict[@"Recommendation"];
//                
//                if([records isKindOfClass:[NSArray class]]) {
//                    
//                    for(NSDictionary* record in records) {
//                        RecommendationRecord* recommendation = [RecommendationRecord createWithDictionary: record];
//                        if(recommendation == nil) {
//                            continue;
//                        }
//                        
//                        [DBHelper insertToDB: recommendation];
//                        [results addObject:recommendation];
//                    }
//                } else if([records isKindOfClass:[NSDictionary class]]){
//                    RecommendationRecord* recommendation = [RecommendationRecord createWithDictionary: records];
//                    
//                    if(recommendation != nil) {
//                        [DBHelper insertToDB: recommendation];
//                        [results addObject:recommendation];
//                    }
//                }
//                
//            }
//            
//            fulfill(results);
//            
//        }).catch(^(NSError* error) {
//            reject(error);
//            
//        });
//    }];
//}
//- (BOOL) save;
-(PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        [DBHelper insertToDB: self];
        
        fulfill(@YES);
        
        
    }];
}

+ (PMKPromise *)save:(NSArray*) records {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        for(RecommendationRecord *record in records) {
            [DBHelper insertToDB: record];
        }
        
        fulfill(@YES);
        
   }];

}

-(NSString*) toXML {
    return @"";
}


/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
//    NSString* ctx =  [self.content stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""];

    
    NSString* sql = [NSString stringWithFormat:@"insert OR REPLACE into RecommendationRecord \
                     (type, content, imageURL, link, createdtime) values (%d, \'%@\', %@, %@, %f)",
                     self.type,
                     self.content,
                     toSQLStr(self.imageURL),
                     toSQLStr(self.link),
                     [self.createdTime timeIntervalSince1970]];
    
    return sql;
}



- (NSString*) sqlForCreateTable {
    
    return @"create table if not exists RecommendationRecord (type integer,content text, imageURL text, link text, createdtime double)";
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select type, content, imageURL, link, createdtime from  %@ %@ order by createdtime desc, type desc",
            [self class], whereStatement];
}

+(instancetype) createWithDBBuffer:(void*) source {
    RecommendationRecord* record = [[RecommendationRecord alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    //    @property (nonatomic)           NSNumber* type;
    //    @property (nonatomic, copy)     NSString* content;
    //    @property (nonatomic)           NSDate* createdtime;
    
    record.type = (NotificationType)sqlite3_column_int(stmt, 0);
    record.content = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 1)];
    record.imageURL = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 2)];
    record.link = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)];
    record.createdTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,4)];
    
    if((record.imageURL != nil) && (record.imageURL.length > 8)){
        if( ![[record.imageURL substringToIndex:4] isEqualToString:@"http"]) {
            record.imageLocation = ImageLocationLocal;
            
            NSFileManager* fileManager = [NSFileManager defaultManager];
            
            BOOL fileExist = [fileManager fileExistsAtPath:record.imageURL];
            
            if(! fileExist) {
                //update path
                NSString *imageName = [[record.imageURL componentsSeparatedByString:@"/"] lastObject];
                if(imageName != nil) {
                    record.imageURL = [NSString stringWithFormat:@"%@/%@",
                                       [GGUtils getCachedPhotoPath],
                                       imageName];
                }
            }
        } else {
            record.imageLocation = ImageLocationRemote;
            
            [record cachePhotoToLocal];
        }
    }
    
    return record;
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////




@end
