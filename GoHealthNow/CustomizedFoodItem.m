//
//  CustomizedFoodItem.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "CustomizedFoodItem.h"
#import "Constants.h"
#import "User.h"
#import "FMDatabase.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"


/*
 
 <UserID>559d6512179d37bd8ceac753</UserID>
 <FoodItem>
 <Name>food name</Name>
 <FoodPhoto>123.jpg</FoodPhoto>
 <Calories>1</Calories>
 <Carbs>2</Carbs>
 <Protein>3</Protein>
 <Fat>4</Fat>
 </FoodItem>

 */

NSString* const FOOD_UPLOADING = @"\
<UserDefinedFood> \
<UserID>%@</UserID> \
<FoodItem> %@ </FoodItem>\
</UserDefinedFood>";

@interface ServingSize()

@property (nonatomic, readwrite)           float transFat;
@property (nonatomic, readwrite)           float saturatedFat;
@property (nonatomic, readwrite)           float protein; //g
//@property (nonatomic, readwrite)           float iron; //mg
@property (nonatomic, readwrite)           float fat; //g
@property (nonatomic, readwrite)           float sugar;
@property (nonatomic, readwrite)           float carbs; //g
@property (nonatomic, readwrite)           float sodium;//mg
@property (nonatomic, readwrite)           float fibre;//???

@property (nonatomic, readwrite)   float calories;//???


@end

@interface CustomizedFoodItem ()

@property (nonatomic)           float transFat_;
@property (nonatomic)           float saturatedFat_;
@property (nonatomic)           float protein_; //g
@property (nonatomic)           float iron_; //mg
@property (nonatomic)           float fat_; //g
@property (nonatomic)           float sugar_;
@property (nonatomic)           float carbs_; //g
@property (nonatomic)           float sodium_;//mg
@property (nonatomic)           float fibre_;//???
@property (nonatomic)           float calories_;//???

@property (retain)     NSArray* options_;

@end

@implementation CustomizedFoodItem

@synthesize recordedTime;
@synthesize uuid;

+(CustomizedFoodItem *)createFoodWithManualInputName:(NSString *)name Cals:(float)cals andCarbs:(float)carbs andProtein:(float)protein andFat:(float)fat andFibre:(float)fibre andImageData:(FoodImageData *)imageData {
    CustomizedFoodItem *food = [[CustomizedFoodItem alloc] init];
    food.name = name;
    food.calories_ = cals;
    food.carbs_ = carbs;
    food.protein_ = protein;
    food.fat_ = fat;
    food.fibre_ = fibre;
    
    food.transFat_ = 0;
    food.saturatedFat_ = 0;
    food.sugar_ = 0;
    food.sodium_ = 0;
    //food.fibre_ = 0;
    food.iron_ = 0;
    food.label = FoodLabelNotGiven;
    
    food.category = [LocalizationManager getStringFromStrId:@"Customized Food"];
    
    food.userLabel = 0;
    
    food.userDefaultServingSize = [LocalizationManager getStringFromStrId:@"1 serving"];
    
    food.creationType = FoodItemCreationTypeManualInput;
    
    food.imageData = imageData;
    
    food.portionSize = 1;
    food.defaultServingSize = food.userDefaultServingSize;
    
    return food;
}

+(NSString *)  dbFields {
    return @"foodId, hierarchy, subhierarchy, name, label, `serving_size`, `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, `diet_fiber`, `sugars`, `protein`, `iron`, creationType, imageName, recordedTime, uuid";
}

#pragma mark - Methods for searching in user DB

+(CustomizedFoodItem *)  searchForFoodWithID:(long long) foodId {
    CustomizedFoodItem* food = nil;
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    NSString *query = [NSString stringWithFormat:@"select %@ from %@ where id = %lld", [self dbFields], [self class], foodId];
    
    FMResultSet *resultSet = [database executeQuery:query];
    sqlite3_stmt *stmt = [[resultSet statement] statement];
    
    if(stmt != NULL) {
        
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            food = [CustomizedFoodItem createWithDBBuffer:stmt];
        }
    }
    
    [database close];
    
    return food;
}

+(PMKPromise *) searchForFoodWithName:(NSString*) filter {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSArray* filters = [filter componentsSeparatedByString:@" "];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        
        NSString* bonus = [CustomizedFoodItem getBonusStr: filters];
        NSString* whereStatement = [CustomizedFoodItem getWhereStr: filters];
        
        User *user = [User sharedModel];
        FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
        
        if(![database open])
        {
            [database open];
        }
        //select %@ , %@ as bonus from FOOD where %@ order by bonus desc limit 25
        NSString *query = [NSString stringWithFormat:@"select %@ , %@ as bonus from %@ where %@ order by bonus desc limit 25", [self dbFields], bonus, [self class], whereStatement];
        
        FMResultSet *resultSet = [database executeQuery:query];
        sqlite3_stmt *stmt = [[resultSet statement] statement];
        
        if(stmt != NULL) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                FoodItem* food = [CustomizedFoodItem createWithDBBuffer:stmt];
                [results addObject:food];
            }
        }
        
        [database close];
        
        fulfill(results);
    }];
}



+(PMKPromise *)addFoodItemPhoto: (UIImage *)photo {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        if(photo) {
            User *user = [User sharedModel];
            
            // save temp image to disk
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData *data = UIImageJPEGRepresentation(photo, 1);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:PHOTO_UPLOAD_DATE_FORMATE];
            NSDate *creationDate = [NSDate date];
            NSString *timeStamp = [dateFormatter stringFromDate:creationDate];
            
            NSString *imageName = [NSString stringWithFormat:@"CustomizedFoodItem_%@.jpg", timeStamp];
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

#pragma mark - GGRecord 

-(PMKPromise *)save {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        User *user = [User sharedModel];
        
        NSString *xml = [NSString stringWithFormat:FOOD_UPLOADING, user.userId, [self toXML]];
        
        [[GlucoguideAPI sharedService] saveCustomizedFoodItemWithXML:xml].then(^(NSMutableDictionary *res){
            self.foodId = [[res objectForKey:@"FoodID"] longLongValue];
            
            ServingSize *ss = [[ServingSize alloc] init];
            
            ss.foodId = self.foodId;
            ss.ssId = [[res objectForKey:@"ServingSizeID"] integerValue];
            ss.name = [LocalizationManager getStringFromStrId:@"1 serving"];
            ss.convertFact = 1.0;
            
            ss.transFat = self.transFat;
            ss.sugar = self.sugar;
            ss.sodium = self.sodium;
            ss.fibre = self.fibre;
            ss.carbs = self.carbs;
            ss.protein = self.protein;
            ss.fat = self.fat;
            ss.calories = self.calories;
            
            self.servingSize = ss;
            
            NSMutableArray<ServingSize *> *tempOptions = [[NSMutableArray alloc] initWithObjects:ss, nil];
            self.options_ = tempOptions;
            
            if ([DBHelper insertToDB:self]) {
                //save photo
                if (self.imageData) {
                    dispatch_promise(^{
                        if (self.imageData) {
                            NSString *filePath =[NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], self.imageData.imageName];
                            
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            NSData *data = UIImageJPEGRepresentation(self.imageData.image, 1);
                            
                            BOOL success = [fileManager createFileAtPath:filePath
                                                                contents:data
                                                              attributes:nil];
                            
                            if (!success) {
                                NSLog(@"Failed to save food image to disk.\n");
                            }
                        }
                    });
                }
                
                fulfill(@YES);
            }
            else {
                fulfill(@NO);
            }
        }).catch(^(NSError *error){
            reject(error);
        }).finally(^(){
            
        });
    }];
}

+ (PMKPromise *)save:(NSArray*) records {
    return [PMKPromise new:^(PMKFulfiller fulfill, PMKRejecter reject) {
        
    }];
}

-(NSString*) toXML {
    NSString *xml = [NSString stringWithFormat:@" <Name>%@</Name>\
                                                 <FoodPhoto>%@</FoodPhoto>\
                                                    <Calories>%f</Calories>\
                                                       <Carbs>%f</Carbs>\
                                                     <Protein>%f</Protein>\
                                                         <Fat>%f</Fat>\
                                                           <Fibre>%f</Fibre>",
                                                            self.name,
                                                            (self.imageData.imageName == nil ? @"":self.imageData.imageName),
                                                            self.calories,
                                                            self.carbs,
                                                            self.protein,
                                                            self.fat,
                                                            self.fibre];
    return xml;
}

#pragma mark - DBProtocol 
- (NSString*) sqlForInsert {

    NSString* sql = [NSString stringWithFormat:@"insert or replace into %@ \
                     (foodId, hierarchy, subhierarchy, name, label, `serving_size`, \
                     `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, \
                     `diet_fiber`, `sugars`, `protein`, `iron`, creationType, \
                     imageName, recordedTime, uuid) \
                     values (%lld, %@, %@, %@, %lu, %@, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %@, %f, %@)",
                     [self class],
                     self.foodId,
                     [GGUtils toSQLString:self.hierarchy],
                     [GGUtils toSQLString:self.subHierarchy],
                     [GGUtils toSQLString:self.name],
                     (unsigned long)self.label,
                     [GGUtils toSQLString:self.userDefaultServingSize],
                     self.calories, self.fat, self.saturatedFat, self.transFat,
                     self.sodium, self.carbs, self.fibre, self.sugar, self.protein,
                     self.iron, self.creationType, [GGUtils toSQLString:self.imageData.imageName],
                     [self.recordedTime timeIntervalSince1970],
                     [GGUtils toSQLString:self.uuid]];
    
    return sql;
}



+(instancetype) createWithDBBuffer:(void*) source {
    CustomizedFoodItem* food = [[CustomizedFoodItem alloc] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    // foodId, hierarchy, subhierarchy, name, label, `serving_size`, \
    `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, \
    `diet_fiber`, `sugars`, `protein`, `iron`, creationType, \
    imageName, recordedTime, uuid
    
    food.foodId = sqlite3_column_int64(stmt, 0);
    food.hierarchy = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 1)];
    food.subHierarchy = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 2)];
    food.name = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 3)];
    food.userLabel = sqlite3_column_int(stmt, 4);
    food.userDefaultServingSize = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 5)];
    
    food.calories_ = sqlite3_column_double(stmt,6);
    food.fat_ = sqlite3_column_double(stmt,7);
    food.saturatedFat_ = sqlite3_column_double(stmt,8);
    food.transFat_ = sqlite3_column_double(stmt,9);
    food.sodium_ = sqlite3_column_double(stmt,10);
    food.carbs_ = sqlite3_column_double(stmt,11);
    food.fibre_ = sqlite3_column_double(stmt,12);
    food.sugar_ = sqlite3_column_double(stmt,13);
    food.protein_ = sqlite3_column_double(stmt,14);
    food.iron_ = sqlite3_column_double(stmt, 15);
    
    food.creationType = sqlite3_column_int(stmt, 16);
    
    food.category = [LocalizationManager getStringFromStrId:@"Customized Foods"];
    
    NSString *imageName = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 17)];
    if (imageName) {
        food.imageData = [[FoodImageData alloc] initWithImage:[UIImage imageWithContentsOfFile:@""] name:imageName];
    }
    
    food.recordedTime = [NSDate dateWithTimeIntervalSince1970:sqlite3_column_double(stmt,18)];
    food.uuid = [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt, 19)];
    
    return food;
}

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (foodId integer, hierarchy TEXT, subhierarchy TEXT, name text, label integer, `serving_size` TEXT, `calories` REAL, `total_fat` REAL, `sat_fat` REAL, `trans_fat` REAL, `sodium` REAL, `total_carbs` REAL, `diet_fiber` REAL, `sugars` REAL, `protein` REAL, `iron` REAL, creationType INTEGER DEFAULT 3, imageName TEXT, recordedTime double, uuid text);",
            [self class]];
}

+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select from %@ %@ order by recordedTime desc",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

@end
