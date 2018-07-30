//
//  NoteRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-03-20.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NoteRecord.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "GGUtils.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"

NSString* const NOTERECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Note_Records FeatureID=\"01\">  %@ </Note_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

@implementation NotePhoto

-(void)loadImageWithPath:(NSString *)path {
    if (path) {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSString *fullPath  = [NSString stringWithFormat:@"%@/%@",
                               [GGUtils getCachedPhotoPath],
                               path];
        
        BOOL fileExist = [fileManager fileExistsAtPath:fullPath];
        
        if(fileExist) {
            self.image = [UIImage imageWithContentsOfFile:fullPath];
            self.imageName = path;
        }
    }
}

- (PMKPromise *)saveToFile {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        dispatch_promise(^{
            if (self.image && self.imageName) {
                NSString *filePath =[NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], self.imageName];
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSData *data = UIImageJPEGRepresentation(self.image, 1);
                
                BOOL success = [fileManager createFileAtPath:filePath
                                                    contents:data
                                                  attributes:nil];
                
                if (success) {
                    resolve(@YES);
                }
                else {
                    NSDictionary *details = [NSDictionary dictionaryWithObject:@"Failed to save food image to disk" forKey:NSLocalizedDescriptionKey];
                    NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
                    
                    resolve(error);
                }
            }
            else {
                resolve(@YES);
            }
        });
    }];
}

@end

@implementation NoteRecord


//- (BOOL) save;
-(PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        [DBHelper insertToDB: self];
        
        User* user = [User sharedModel];
        
        NSString* xmlRecord = [NSString stringWithFormat:NOTERECORD_UPLOADING,
                               user.userId,
                               [self toXML],
                               [GGUtils stringFromDate:[NSDate date]]];
        
        [self.image saveToFile];
        
        [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord].then(^(id res){
            fulfill(res);
            
        }).catch(^(id res) {
            reject(res);
        });
        
    }];
}

+ (PMKPromise *)save:(NSArray*) records {
    
    
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSMutableString* xmlRecords = [NSMutableString stringWithString:@""];
        for(NoteRecord *record in records) {
            [xmlRecords appendString:[record toXML]];
            [DBHelper insertToDB: record];
            [record.image saveToFile];
        }
        
        
        User* user = [User sharedModel];
        
        [[GlucoguideAPI sharedService ]saveRecordWithXML:
         [NSString stringWithFormat:NOTERECORD_UPLOADING,
          user.userId,
          xmlRecords,
          [GGUtils stringFromDate:[NSDate date]]
          ]].then(^(id res){
             fulfill(res);
             
         }).catch(^(id res) {
             reject(res);
         });
        
    }];
    
}

//<NoteContent>JDJDJdDJ</NoteContent>
//<RecordedTime>2015-03-19T10:22:37-0400</RecordedTime>
//<UploadingVersion>0</UploadingVersion>
//<NoteType>Diet</NoteType>
-(NSString*)toXML {
    return [NSString stringWithFormat:@"<Note_Record> \
            <NoteType>%@</NoteType> \
            <NoteContent>%@</NoteContent> \
            <RecordedTime>%@</RecordedTime> \
            <UploadingVersion>0</UploadingVersion> \
            <NotePhoto>%@</NotePhoto> \
            <NoteAudio>%@</NoteAudio>\
            </Note_Record>",
            [NoteRecord getTypeDescription:self.type],
            self.content, [GGUtils stringFromDate:self.recordedTime], self.image.imageName==nil? @"":self.image.imageName, self.audioFileName == nil ? @"" : self.audioFileName];
    
}

-(void)uploadMP3:(NSString *)mp3FilePath{
    
    User *user = [User sharedModel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
    NSDate *creationDate = [NSDate date];
    NSString *timeStamp = [dateFormatter stringFromDate:creationDate];
    
     /*
    
    //AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSLog(@"user: %@ - timestamp: %@ - filename: %@", user.userId, timeStamp, self.audioFileName);
    
    NSDictionary *parameters = @{@"user_id": user.userId,
                                 @"date": timeStamp,
                                 @"file_name":self.audioFileName,
                                 @"file_type":@"mp3"};
    
    
    *////
    
    GlucoguideAPI *ggAPI = [GlucoguideAPI sharedService];
    [ggAPI sendAudioWithFile:mp3FilePath fileName:self.audioFileName user:user.userId creationTimeStamp:timeStamp];
    
    
    /*
    /////
    NSURL *filePath = [NSURL fileURLWithPath:mp3FilePath];
    
    NSData *data = [[NSData alloc]init];
    data = [NSData dataWithContentsOfFile:filePath.path];
    
    NSLog(@"filepath: %@", filePath);
    
    #ifdef DEBUG
    NSString* const GGAPI_GENERAL_FILEUPLOAD_URL =@"https://test.glucoguide.com/GlucoGuide/upload/files";
    #else
    NSString* const GGAPI_GENERAL_FILEUPLOAD_URL =@"https://api.glucoguide.com/GlucoGuide/upload/files";
    #endif
    
    /////////
    
    
    ////////
    
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:GGAPI_GENERAL_FILEUPLOAD_URL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:self.audioPath fileName:self.audioPath mimeType:@"audio/mpeg3"];
        
    } error:nil];
    
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSURLSessionUploadTask *uploadTask;
    uploadTask = [manager
                  uploadTaskWithStreamedRequest:request
                  progress:^(NSProgress * _Nonnull uploadProgress) {
                      
                  }
                  completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                      if (error) {
                          NSLog(@"Error: %@", error);
                      } else {
                          NSLog(@"%@ %@", response, responseObject);
                      }
                  }];
    
    [uploadTask resume];
    
    */
}

/////////////////internal interface

//typedef enum {
//    NoteTypeDiet = 0,
//    NoteTypeExercise,
//    NoteTypeGlucose,
//    NoteTypeWeight,
//    NoteTypeOthers
//} NoteType;
+(NSString*)getTypeDescription: (NoteType) type {
    switch (type) {
        case NoteTypeDiet:
            return @"Diet";
            break;
        case NoteTypeExercise:
            return @"Exercise";
            break;
        case NoteTypeGlucose:
            return @"Blood Glucose";
            break;
        case NoteTypeWeight:
            return MSG_WEIGHT;
            break;
        case NoteTypeOthers:
            return @"Others";
            break;
        default:
            return @"Others";
            break;
    }
}

//NSArray<DBProtocol> queryDataByTime:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (PMKPromise *)queryDataByTime:(NSDate*)fromDate toDate:(NSDate*)toDate {
    NSString* filter = nil;
    if(fromDate != nil){
        if(toDate != nil) {
            filter = [NSString stringWithFormat:@"recordedTime >= %f and recordedTime <= %f",
                      [fromDate timeIntervalSince1970],[toDate timeIntervalSince1970]];
        } else {
            filter = [NSString stringWithFormat:@"recordedTime >= %f",
                      [fromDate timeIntervalSince1970]];
        }
    }
    return [DBHelper queryFromDB:[self class] : filter];
}


/////////////////////////
//DBProtocol
- (NSString*) sqlForInsert {
    
    NSString* sql = [NSString stringWithFormat:@"insert into %@ \
                     (type, content, recordedTime, imagePath, audioPath) values (%u, \"%@\",  %f, \"%@\" , \"%@\")",
                     [self class],
                     self.type, self.content,
                     [self.recordedTime timeIntervalSince1970],
                     self.image.imageName==nil?@"": self.image.imageName,
                     self.audioPath];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    NoteRecord* record = [NoteRecord alloc ];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    record.type =  sqlite3_column_int(stmt, 0);
    record.content = [NSString stringWithUTF8String:(char*) sqlite3_column_text(stmt, 1)];
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,2)];
    NotePhoto *tmpNP = [[NotePhoto alloc] init];
    record.image = tmpNP;
    [record.image loadImageWithPath:[GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)]];
    record.audioPath = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 4)];
    
    return record;
}


- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ \
            (type integer,content text, recordedTime double unique, imagePath text, audioPath text)",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select type, content, recordedTime, imagePath, audioPath from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

+(PMKPromise *)addNotePhoto: (UIImage *)photo {
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if(photo) {
            User *user = [User sharedModel];
            
            // save temp image to disk
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData *data = UIImageJPEGRepresentation(photo, 0.3);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
            NSDate *creationDate = [NSDate date];
            NSString *timeStamp = [dateFormatter stringFromDate:creationDate];
            
            NSString *imageName = [NSString stringWithFormat:@"note_%@.jpg", timeStamp];
            NSString *filePath =[NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], imageName];
            BOOL fileCreationSuccess = [fileManager createFileAtPath:filePath
                                                            contents:data
                                                          attributes:nil];
            
            if (fileCreationSuccess) {
                
                GlucoguideAPI *ggAPI = [GlucoguideAPI sharedService];
                [ggAPI photoRecognition:filePath
                                   user:user.userId
                      creationTimeStamp:timeStamp
                                   type:UploadPhotoOnly].then(^(id res) {
                    [res setObject:creationDate forKey:@"Image_creationdate"];
                    fulfill(res);
                }).catch(^(id res) {
                    reject(res);
                }).finally(^{
                    // delete temp image from disk
                    NSError *error;
                    [fileManager removeItemAtPath:filePath error:&error];
                    NSLog(@"delete file at path: %@", filePath);
                    
                });
            }
            else {
                // failed to save file
                NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Failed to save image to disk"] forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
                
                reject(error);
            }
        } else {
            NSDictionary* details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"image can not be null"] forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        }
    }];
}

/////////////////////////


@end
