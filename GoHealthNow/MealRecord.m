//
//  MealRecord.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

#import "MealRecord.h"


#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "ServicesConstants.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

NSString* const MEALRECORD_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Meal_Records>  %@ </Meal_Records> \
<Created_Time>%@</Created_Time> \
</User_Record>";

@implementation MealPhoto
@end

@implementation MealScore

+ (NSString *)getScoreRatingWithScore:(NSInteger) score {
    if (score >= 80.0) {
        return [LocalizationManager getStringFromStrId:@"Excellent"];
    }
    else if (score >= 60.0 && score < 80) {
        return [LocalizationManager getStringFromStrId:@"Fair"];
    }
    else { // < 60.0
       return [LocalizationManager getStringFromStrId:@"Needs Improvement"];
    }
}

@end

@interface MealRecord ()
@property (atomic, retain)  NSMutableArray* foods_;

@property (atomic)  BOOL createdFromDB_;

@property (atomic)  BOOL photoChanged;

@property (atomic, copy) NSString* imageName_;

@property (atomic) Boolean hasImage_;

@end

@implementation MealRecord

////

+ (PMKPromise *)save:(NSArray*) records {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@""];
    for(MealRecord *record in records) {
        [xmlRecords appendString:[record toXML]];
        [DBHelper insertToDB: record];
    }
    
    User* user = [User sharedModel];
    return [[GlucoguideAPI sharedService] saveRecordWithXML:
            [NSString stringWithFormat:MEALRECORD_UPLOADING,
              user.userId,
              xmlRecords,
              [GGUtils stringFromDate:[NSDate date]]
            ]];
}



// In the implementation
-(instancetype)copyWithZone:(NSZone *)zone
{
    
    MealRecord *record = [[MealRecord alloc] init];
    
    record.oid = nil;
    
    record.recordedTime = self.recordedTime;
    record.foods = [self.foods copy];
    record.imageName_ = [self.imageName_ copy];
    record.name = [self.name copy];
    
    record.photoChanged = self.photoChanged;
    record.carb = self.carb;
    record.pro = self.pro;
    record.fat = self.fat;
    record.fibre = self.fibre;
    record.sugar = self.sugar;
    record.cals = self.cals;
    record.score = self.score;
    record.type = self.type;
    record.createdType = self.createdType;
    record.note = self.note;
    

    
    return record;
}

-(void) addFood:(FoodItem*) food {
    if(self.foods_ == nil) {
        self.foods_ = [[NSMutableArray alloc] init];
    }
    
    [self.foods_ addObject:food];
    
}

- (void)updateFood:(FoodItem *)food AtIndex:(NSUInteger)index {
    if(self.foods_.count > index) {
        [self.foods_ replaceObjectAtIndex:index withObject:food];
    }
}

-(void) removeFoodAtIndex:(NSUInteger)index {
    if(self.foods_.count > index) {
        [self.foods_ removeObjectAtIndex:index];
    }
}

-(void) setFoods:(NSArray*) records {
    self.foods_ = [NSMutableArray arrayWithArray:records];
}

-(NSArray*) foods {
    
//    if(self.createdBy == MealCreatedBySearch) {
        if(self.foods_ == nil) {
            if(self.createdFromDB_) {
                if(self.oid != nil) {
                    //search selectedFoods from db
                    NSString* foodFilter = [NSString stringWithFormat:@"mealId = '%@'", self.oid.str];
                    NSArray* selectedFoods = [FoodItem searchRecentFood: foodFilter];
                    self.foods_ = [NSMutableArray arrayWithArray:selectedFoods];
                }
            } else {
                self.foods_ =[[NSMutableArray alloc] init];
            }
        }
 //   }
    
    return self.foods_;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%0.1f calories", self.cals];
}

- (PMKPromise *)save {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        
        User* user = [User sharedModel];
        [user updatePointsByAction: [[self class] description]];
        
        
        [DBHelper insertToDB: self];
        
        [SelectedFood saveToDB:self.oid foods:self.foods];
        
        NSString* xmlRecord = [NSString stringWithFormat:MEALRECORD_UPLOADING,
                               user.userId,
                               [self toXML],
                               [GGUtils stringFromDate:[NSDate date]]];
        
        dispatch_group_t saveImagesToDiskGroup = dispatch_group_create();
        NSMutableSet *imageData = [[NSMutableSet alloc] init];
        
        // save food item images
        for (FoodItem *eachFood in self.foods) {
            if (eachFood.imageData) {
                [imageData addObject:eachFood.imageData];
            }
        }
        
        NSInteger imageDataCount = [imageData count];
        dispatch_group_enter(saveImagesToDiskGroup);

        if (imageDataCount == 0) {
            // no images to save
            dispatch_group_leave(saveImagesToDiskGroup);
        }
        else {
            __block NSInteger imageDataSavedCount = 0;
            
            for (FoodImageData *foodImageData in imageData) {
                [foodImageData saveToFile].finally(^{
                    imageDataSavedCount++;
                    
                    // only leave when all images have been saved to disk
                    if (imageDataCount == imageDataSavedCount) {
                        dispatch_group_leave(saveImagesToDiskGroup);
                    }
                });
            }
        }
        
        // The notify block fires when all images have been saved to disk or there are no images to save
        dispatch_group_notify(saveImagesToDiskGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            if(self.photoChanged && (self.imageName_ != nil)) {
                [self uploadMealPhoto].then(^(id res){
                    
                    self.photoChanged = false;
                    
                    [[GlucoguideAPI sharedService] saveRecordWithXML:
                     xmlRecord].then(^(id res) {
                        fulfill(res);
                    });
                    
                }).catch(^(id res) {
                    reject(res);
                });
                
            } else {
                [[GlucoguideAPI sharedService] saveRecordWithXML:xmlRecord].then(^(id res) {
                    fulfill(res);
                }).catch(^(id error) {
                    reject(error);
                });
                
            }
        });
        
    }];
    
}

// TODO - NOT thread safe
+ (PMKPromise *)autoEstimateWithImage:(UIImage *)image {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if(image) {
            User *user = [User sharedModel];
            
            // save temp image to disk
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData *data = UIImageJPEGRepresentation(image, 1);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
            NSString *timeStamp = [dateFormatter stringFromDate:[NSDate date]];
            
            NSString *imageName = [NSString stringWithFormat:@"image_%@.jpg", timeStamp];
            NSString *filePath =[NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], imageName];
            BOOL fileCreationSuccess = [fileManager createFileAtPath:filePath
                                                            contents:data
                                                          attributes:nil];
            
            if (fileCreationSuccess) {
                GlucoguideAPI *ggAPI = [GlucoguideAPI sharedService];
                [ggAPI photoRecognition:filePath
                                   user:user.userId
                      creationTimeStamp:timeStamp
                                   type:PhotoForFoodRecognition].then(^(id res) {
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
                NSDictionary* details = [NSDictionary dictionaryWithObject:@"Failed to save image to disk" forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
                
                reject(error);
            }
        } else {
            NSDictionary* details = [NSDictionary dictionaryWithObject:@"image can not be null" forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
            
            reject(error);
        }
    }];
}

- (PMKPromise *)uploadMealPhoto {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        if(self.imageName_ != nil) {
            User* user = [User sharedModel];
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
            
            NSString* filePath =[NSString stringWithFormat:@"%@/%@",
                                 [GGUtils getCachedPhotoPath],
                                 self.imageName_];
            //
            NSArray* paraList = @[ @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_DATE,
                                       FORM_PARAMETER_VALUE: [dateFormatter stringFromDate:[NSDate date]],
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_MEALPHOTO,
                                       FORM_PARAMETER_VALUE: filePath,
                                       FORM_PARAMETER_ISFILE: @YES,
                                       FORM_PARAMETER_MIMETYPE: PHOTO_UPLOAD_PARA_TYPE},
                                   
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_USERID,
                                       FORM_PARAMETER_VALUE: user.userId,
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_NOTE,
                                       FORM_PARAMETER_VALUE: @"",
                                       FORM_PARAMETER_ISFILE: @NO},
                                   @{
                                       FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_FOREXPERT,
                                       FORM_PARAMETER_VALUE: @"FALSE",
                                       FORM_PARAMETER_ISFILE: @NO},
                                   ];
            
            
            
            [GlucoguideAPI sendMultiPostMessage:paraList].then(^(id res){
                fulfill(res);
                
            }).catch(^(id res) {
                reject(res);
            });
        }
        
    }];
    
}

+ (PMKPromise *)addMealPhoto:(MealPhoto*) photo {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        User* user = [User sharedModel];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
        
        
        //save photo to cache folder
        NSString* filePath =[NSString stringWithFormat:@"%@/meal_%@.jpg",
                             [GGUtils getCachedPhotoPath],
                             [dateFormatter stringFromDate:photo.createdTime]];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSData* data = UIImageJPEGRepresentation(photo.image, 1);
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        
        
        //
        NSArray* paraList = @[ @{
                                   FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_DATE,
                                   FORM_PARAMETER_VALUE: [dateFormatter stringFromDate:[NSDate date]],
                                   FORM_PARAMETER_ISFILE: @NO},
                               @{
                                   FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_MEALPHOTO,
                                   FORM_PARAMETER_VALUE: filePath,
                                   FORM_PARAMETER_ISFILE: @YES,
                                   FORM_PARAMETER_MIMETYPE: PHOTO_UPLOAD_PARA_TYPE},
                               
                               @{
                                   FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_USERID,
                                   FORM_PARAMETER_VALUE: user.userId,
                                   FORM_PARAMETER_ISFILE: @NO},
                               @{
                                   FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_NOTE,
                                   FORM_PARAMETER_VALUE: photo.note,
                                   FORM_PARAMETER_ISFILE: @NO},
                               @{
                                   FORM_PARAMETER_NAME: PHOTO_UPLOAD_PARA_FOREXPERT,
                                   FORM_PARAMETER_VALUE: photo.toExpert? @"TRUE": @"FALSE",
                                   FORM_PARAMETER_ISFILE: @NO},
                               ];
        
        
        
        [GlucoguideAPI sendMultiPostMessage:paraList].then(^(id res){
            fulfill(res);
            
        }).catch(^(id res) {
            reject(res);
        });
        
    }];
    
}

+ (PMKPromise *)addMealPhoto:(UIImage*) image date: (NSDate*) date note: (NSString*) note {
    MealPhoto* photo = [[MealPhoto alloc] init];
    
    photo.image = image;
    photo.createdTime = date;
    photo.note = note;
    photo.toExpert = YES;
    
    return [MealRecord addMealPhoto:photo];

}


//return type NSArrary<float, dateOfDay>
+ (PMKPromise *)searchDailyCalories:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            if((fromDate == nil) || (toDate == nil)) {
                fulfill(nil);
            } else {
                //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
                NSString* query = [NSString stringWithFormat:@"select sum(cals), datetime(recordedTime, 'unixepoch') from MealRecord  where recordedTime >= %f and recordedTime <= %f group by datetime(recordedTime, 'unixepoch')",
                                   [fromDate timeIntervalSince1970], [toDate timeIntervalSince1970]];
                
                NSMutableArray* results = [[NSMutableArray alloc] init];
                sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
                
                if(stmt != NULL) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                        
                        NSNumber* calories = [NSNumber numberWithFloat:
                                              sqlite3_column_int(stmt, 0)];
                        
                        NSString* dayStr = [NSString stringWithUTF8String:
                                            (const char*)sqlite3_column_text(stmt,1) ];
                        
                        NSDate* recordedDay = [GGUtils dateFromSQLString: dayStr];
                        
                        [results addObject:@{@"calories": calories, @"recordedDay": recordedDay}];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
}

+ (PMKPromise *)lastMealScore {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {

        User *user = [User sharedModel];
        FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];

        
        if(![database open])
        {
            [database open];
        }
        
        if ([database tableExists:@"MealRecord"]){
        
            NSString* query = @"select score from MealRecord order by recordedTime desc limit 1";
            
            FMResultSet *resultSet = [database executeQuery:query];
            sqlite3_stmt *stmt = [[resultSet statement] statement];
            
            NSNumber* result = nil;
            
            if(stmt != NULL) {
                if (sqlite3_step(stmt) == SQLITE_ROW) {
                    double score = sqlite3_column_double(stmt, 0);
                    result = [NSNumber numberWithDouble:score];
                }
            }
            
            fulfill(result);
        }else{
            fulfill(0);
        }

        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [database close];
            }];
        
    }];
}

//return type NSArrary<float, dateOfDay>
+ (PMKPromise *)searchSummaryCalories:(SummaryPeroidType) peroid fromDate: (NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
                dispatch_promise(^{
        if((fromDate == nil) || (toDate == nil)) {
            fulfill(nil);
        } else {
            //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
            NSString* query = [NSString stringWithFormat:@"select sum(cals), %@ from MealRecord  where recordedTime >= %f and recordedTime <= %f group by %@",
                               [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid],
                               [fromDate timeIntervalSince1970],
                               [toDate timeIntervalSince1970],
                               [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid]];
            
            NSMutableArray* results = [[NSMutableArray alloc] init];
            sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
            
            if(stmt != NULL) {
                while (sqlite3_step(stmt) == SQLITE_ROW) {
                    
                    NSNumber* calories = [NSNumber numberWithFloat:
                                          sqlite3_column_int(stmt, 0)];
                    
                    NSString* dayStr = [NSString stringWithUTF8String:
                                        (const char*)sqlite3_column_text(stmt,1) ];
                    
                    NSDate* recordedDay = [GGUtils dateFromSQLString: dayStr];
                    
                    [results addObject:@{@"calories": calories, @"recordedDay": recordedDay}];
                }
                
                sqlite3_finalize(stmt);
            }
            
            fulfill(results);
        }
                });
    }];
}

+ (PMKPromise *)searchAverageScore:(SummaryPeroidType) peroid fromDate:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        dispatch_promise(^{
            
            //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
            NSMutableArray* results = [[NSMutableArray alloc] init];
            
            if((toDate != nil)) {
                
                NSString* query = [NSString stringWithFormat:@"select (type != 0), avg(score), %@ from MealRecord  where recordedTime >= %f and recordedTime <= %f group by (type != 0), %@",
                                   [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid],
                                   [fromDate timeIntervalSince1970],
                                   [toDate timeIntervalSince1970],
                                   [GGUtils genPeroidTimeByType:@"recordedTime" peroid:peroid]];
                
                //NSMutableArray* results = [[NSMutableArray alloc] init];
                sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
                
                if(stmt != NULL) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                        
                        MealScore* record = [[MealScore alloc] init];
                        
                        record.type = sqlite3_column_int(stmt, 0);
                        record.score = sqlite3_column_double(stmt, 1);
                        
                        NSString* dayStr = [NSString stringWithUTF8String:
                                            (const char*)sqlite3_column_text(stmt,2) ];
                        
                        record.recordedDay  = [GGUtils dateFromSQLString: dayStr];
                        
                        [results addObject:record];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
    
}

+ (PMKPromise *)searchDailyScore:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        dispatch_promise(^{
            //select (type != 0), avg(score), date(recordedTime) from MealRecord group by (type != 0), date(recordedTime);
            if((fromDate == nil) || (toDate == nil)) {
                fulfill(nil);
            } else {
                /*NSString* query = [NSString stringWithFormat:@"select (type != 0), avg(score), date(recordedTime, 'unixepoch') from MealRecord  where recordedTime >= %f and recordedTime <= %f group by (type != 0), date(recordedTime, 'unixepoch')",
                                   [fromDate timeIntervalSince1970],
                                   [toDate timeIntervalSince1970]]; */
                NSString* query = [NSString stringWithFormat:@"select (type != 0), avg(score), datetime(recordedTime, 'unixepoch') from MealRecord  where recordedTime >= %f and recordedTime <= %f group by (type != 0), datetime(recordedTime, 'unixepoch')",
                                   [fromDate timeIntervalSince1970],
                                   [toDate timeIntervalSince1970]];
                
                NSMutableArray* results = [[NSMutableArray alloc] init];
                sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
                
                if(stmt != NULL) {
                    while (sqlite3_step(stmt) == SQLITE_ROW) {
                        
                        MealScore* record = [[MealScore alloc] init];
                        
                        record.type = sqlite3_column_int(stmt, 0);
                        record.score = sqlite3_column_double(stmt, 1);
                        
                        NSString* dayStr = [NSString stringWithUTF8String:
                                            (const char*)sqlite3_column_text(stmt,2) ];
                        
                        record.recordedDay  = [GGUtils dateFromSQLString: dayStr];
                        
                        [results addObject:record];
                    }
                    
                    sqlite3_finalize(stmt);
                }
                
                fulfill(results);
            }
        });
    }];
}

//NSArray< { @"category":@"", @"rows": NSArray<MealRecord> >
+ (PMKPromise *)searchRecentMeal:(NSString*) filter {//:(NSDate*)fromDate toDate:(NSDate*)toDate {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSString* query = [self sqlForQuery:filter];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
        
        NSString* today = [dateFormatter stringFromDate:[NSDate date]];
        
        if(stmt != NULL) {
            NSMutableDictionary* namekeys = [[NSMutableDictionary alloc] init];
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                MealRecord* record = [self createWithDBBuffer:stmt];
                
                
                NSString* category = [dateFormatter stringFromDate:record.recordedTime];
                if([category isEqualToString:today]) {
                    category = TIME_TODAY;
                }
                
                //insert record to category
                NSNumber* index = [namekeys objectForKey:category];
                
                NSMutableArray* meals = nil;
                
                if(index == nil) {
                    
                    meals = [[NSMutableArray alloc] init];
                    [results addObject:@{@"category": category, @"rows":meals}];
                    [namekeys setObject:[NSNumber numberWithUnsignedInteger:(results.count - 1)] forKey:category];
                } else {
                    meals = [results objectAtIndex: [index unsignedIntegerValue]][@"rows"];
                }
                
                [meals addObject:record];
                
                
            }
            
            sqlite3_finalize(stmt);
            
            
        }
        
        fulfill(results);
        
    }];
}

-(void)setImage:(UIImage*) image {
    
    @synchronized(self){
        self.photoChanged = YES;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
        
        //save photo to cache folder
        self.imageName_ =[NSString stringWithFormat:@"meal_%@.jpg",                      [dateFormatter stringFromDate:[NSDate date]]];
        
        NSFileManager* fileManager = [NSFileManager defaultManager];
        NSData* data = UIImageJPEGRepresentation(image, 1);
        [fileManager createFileAtPath:[NSString stringWithFormat:@"%@/%@",                      [GGUtils getCachedPhotoPath],self.imageName_]
                             contents:data attributes:nil];
    }
    
}

- (Boolean)hasMealImage {
    return self.hasImage;
}


-(UIImage*) loadImage {
    @synchronized(self){
        UIImage* image = nil;
        
        if(self.imageName_ != nil) {
            if ([self.imageName_ isEqualToString:@""])
                return nil;
            //            NSData *imageData = [NSData dataWithContentsOfFile:
            //                                 [NSString stringWithFormat:@"%@/%@",                      [GGUtils getCachedPhotoPath],self.imageName_]];
            
            image = [UIImage imageWithContentsOfFile:
                     [NSString stringWithFormat:@"%@/%@",
                      [GGUtils getCachedPhotoPath],self.imageName_]];
        }
        
        return image;
    }
}

-(UIImage*) loadIconImage {
    return nil;
}

///


-(void)removeMealWithID:(NSString* )MealID{
   
    
    int FoodID = 0;
    NSString *imagePath;
    
    ///
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    if ([database tableExists:@"SelectedFood"]){
        
        NSString* query = [NSString stringWithFormat:@"SELECT foodId FROM SelectedFood WHERE mealId = '%@' limit 1", MealID];
        FMResultSet *resultSet = [database executeQuery:query];
        
        
        while([resultSet next])
        {
            FoodID = [resultSet intForColumn:@"foodId"];
        }
        
    }
    
    NSString* query2 = [NSString stringWithFormat:@"SELECT imagePath FROM MealRecord WHERE id = '%@' limit 1", MealID];
    FMResultSet *resultSet2 = [database executeQuery:query2];
    
    while([resultSet2 next])
    {
        imagePath = [resultSet2 stringForColumn:@"imagePath"];
    }
    
    [database executeUpdateWithFormat:@"DELETE FROM ServingSize WHERE FD_ID = %d", FoodID];
    [database executeUpdateWithFormat:@"DELETE FROM SelectedFood WHERE mealId = %@", MealID];
    [database executeUpdateWithFormat:@"DELETE FROM MealRecord WHERE id= %@", MealID];
    
    [database executeQuery:@"VACUUM ServingSize"];
    [database executeQuery:@"VACUUM SelectedFood"];
    [database executeQuery:@"VACUUM MealRecord"];
    
    [database close];

    if (imagePath) {
        NSString *filePath =[NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], imagePath];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    [[GlucoguideAPI sharedService] deleteRecordWithRecord:0 andUUID:MealID];
    
}

///


-(NSString*)toXML {
    
    if(self.oid == nil) {
        self.oid = [[ObjectId alloc] init];
    }
    
    if ([self.note length] < 1) {
        self.note = @"";
    }
    
    return  [NSString stringWithFormat: @" \
            <Meal_Record> \
            %@ \
            <Carb>%f</Carb> \
            <Fibre>%f</Fibre> \
            <Sugar>%f</Sugar> \
            <Pro>%f</Pro> \
            <Fat>%f</Fat> \
            <Cals>%f</Cals> \
            <MealPhoto>%@</MealPhoto> \
            <DeviceMealID>%@</DeviceMealID> \
            <MealType>%lu</MealType> \
            <MealScore>%f</MealScore>\
            <MealEnterType>%lu</MealEnterType> \
            <RecordedTime>%@</RecordedTime> \
            <Note>%@</Note>\
            </Meal_Record> ",
            [self foodsToXML : self.foods],
            self.carb, self.fibre, self.sugar, self.pro,
            self.fat, self.cals,
            ggString(self.imageName_),
            self.oid.str,
            (unsigned long) self.type,
            self.score,
            (unsigned long) self.createdType,
            [GGUtils stringFromDate:self.recordedTime],
            self.note];
}

-(NSString*)foodsToXML:(NSArray*) foods {
    
    NSMutableString* xmlRecords =  [NSMutableString stringWithString:@"<Food_Records>"];
    for(FoodItem* foodItem in foods) {
        
        NSString *foodImageName = foodItem.imageData.imageName ? foodItem.imageData.imageName : @"";
        
        NSString* xml = [NSString stringWithFormat:@" \
         <Food_Record> \
         <FoodItem> <FoodItemID>%lld</FoodItemID> </FoodItem> \
         <FoodItemServingSize>%f</FoodItemServingSize> \
         <ServingSizeID>%lu</ServingSizeID> \
         <ProviderID>%d</ProviderID> \
         <FoodItemLogType>%d</FoodItemLogType> \
         <FoodItemPhoto>%@</FoodItemPhoto> \
         </Food_Record> ",
         foodItem.foodId,
         foodItem.portionSize,
         (unsigned long)foodItem.servingSize.ssId,
         foodItem.providerID,
         foodItem.creationType,
         foodImageName];
        
        [xmlRecords appendString:xml];
    }
    
    [xmlRecords appendString:@"</Food_Records>"];
    
    return xmlRecords;
}


/////////////////////////
//DBProtocol


- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (id text PRIMARY KEY, carb double, pro double, fat double, fibre double, sugar double, cals double, score double, type integer, createdBy integer, imagePath text, name text, note text, providerID integer, providerItemID text, recordedTime double)",
            [self class]];
}

- (NSString*) sqlForInsert {

    if(self.oid == nil) {
        self.oid = [[ObjectId alloc] init];
    }
    
    NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ \
                     (id, carb, pro, fat, fibre, sugar, cals, score, type, createdBy, imagePath, name, note, providerID, providerItemID,recordedTime) \
                     VALUES (%@, %f, %f, %f, %f, %f, %f, %f, %d, %d, %@, %@, %@, %d, %@, %f)",
                     [self class],
                     [GGUtils toSQLString:self.oid.str],
                     self.carb,
                     self.pro,
                     self.fat,
                     self.fibre,
                     self.sugar,
                     self.cals,
                     self.score,
                     self.type,
                     self.createdType,
                     [GGUtils toSQLString:self.imageName_],
                     [GGUtils toSQLString:self.name],
                     [GGUtils toSQLString:self.note],
                     self.providerID,
                     [GGUtils toSQLString:self.providerItemID],
                     [self.recordedTime timeIntervalSince1970] ];
    
    return sql;
}


//@property (nonatomic)     NSNumber* carb;
//@property (nonatomic)     NSNumber* pro;
//@property (nonatomic)     NSNumber* fat;
//@property (nonatomic)     NSNumber* cals;
//@property (nonatomic)     NSNumber* score; //float
//@property (nonatomic)     MealType type;
//@property (nonatomic)           NSDate* recordedTime;

+(instancetype) createWithDBBuffer:(void*) source {
    MealRecord* record = [[MealRecord alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    
//    record.carb = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 0)];
//    record.pro = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 1)];
//    record.fat = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 2)];
//    record.cals = [NSNumber numberWithDouble: sqlite3_column_double(stmt, 3)];
    record.carb = sqlite3_column_double(stmt, 0);
    record.pro = sqlite3_column_double(stmt, 1);
    record.fat = sqlite3_column_double(stmt, 2);
    record.fibre = sqlite3_column_double(stmt, 3);
    record.sugar = sqlite3_column_double(stmt, 4);
    record.cals = sqlite3_column_double(stmt, 5);
    record.score = sqlite3_column_double(stmt, 6);
    record.type = sqlite3_column_int(stmt, 7);
    record.recordedTime = [NSDate dateWithTimeIntervalSince1970: sqlite3_column_double(stmt,8)];
    record.oid = [[ObjectId alloc] initWithString: [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,9)]];
    record.createdType = sqlite3_column_int(stmt,10);
    record.imageName_ = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,11)];
    record.name = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,12)];
    record.note = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,13)];
    record.providerID = sqlite3_column_int(stmt, 14);
    record.providerItemID = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,14)];
    
    record.createdFromDB_ = YES;
    
    if ([record loadImage]) {
        record.hasImage = YES;
    }
    else {
        record.hasImage = NO;
    }
    
    return record;
}


+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select carb, pro, fat, fibre, sugar, cals, score, type, recordedTime, id, createdBy, imagePath, name, note, providerID, providerItemID from %@ %@ order by recordedTime desc, type desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////


@end;

