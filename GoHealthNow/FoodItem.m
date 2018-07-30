//
//  Food.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-22.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FoodItem.h"
#import <sqlite3.h>
#import "GGUtils.h"
#import "User.h"
#import "FMDatabase.h"
#import "CustomizedFoodItem.h"

#import "GlucoguideAPI.h"
#import "XMLDictionary.h"

NSString* const QUERY_FOOD_FORMAT = @"select %@ , %@ as bonus from FOOD where %@ order by bonus desc limit 25";
NSString* const FoodCategoryCanadianNutrition = @"Canadian Food";
NSString* const SERVING_SIZE_QUERY_EXTRA_COLS = @", `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, `diet_fiber`, `sugars`, `protein`";

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

@implementation ServingSize


- (instancetype)copyWithZone:(NSZone *)zone {
    ServingSize *servingSize = [[ServingSize alloc] init];
    
    servingSize.foodId = self.foodId;
    servingSize.ssId = self.ssId;
    servingSize.name = self.name;
    servingSize.convertFact = self.convertFact;
    
    servingSize.transFat = self.transFat;
    servingSize.protein = self.protein;
    servingSize.fat = self.fat;
    servingSize.sugar = self.sugar;
    servingSize.carbs = self.carbs;
    servingSize.sodium = self.sodium;
    servingSize.fibre = self.fibre;
    servingSize.calories = self.calories;
    
    return servingSize;
}

- (BOOL)isEqual:(id)object {
    if ([object isKindOfClass:[ServingSize class]]) {
        ServingSize *ssObject = (ServingSize *)object;
        
        return ssObject.foodId = self.foodId &&
               ssObject.ssId == self.ssId &&
               [ssObject.name isEqualToString:self.name] &&
               ssObject.convertFact == self.convertFact &&
               ssObject.transFat == self.transFat &&
               ssObject.protein == self.protein &&
               ssObject.fat == self.fat &&
               ssObject.sugar == self.sugar &&
               ssObject.carbs == self.carbs &&
               ssObject.sodium == self.sodium &&
               ssObject.fibre == self.fibre &&
               ssObject.calories == self.calories;
    }
    else {
        return NO;
    }
}

#pragma mark - Database Methods

- (NSString *)sqlForInsert {
    long long foodId = self.foodId;
    Class class = [self class];
    
    
     NSString *tempString = [self.name stringByReplacingOccurrencesOfString:@"\"" withString:@"''"];
                 
    
                 
    
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@ (`FD_ID`, `MSR_ID`, `MSR_NME`, `CONV_FAC`, \
                                                                 `calories`, `total_fat`, `sat_fat`, `trans_fat`, \
                                                                 `sodium`, `total_carbs`, `diet_fiber`, `sugars`, `protein`) \
                                                      VALUES (%lld, %lu, %@, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f)",
                                                class, foodId,
                                                (unsigned long)self.ssId, [GGUtils toSQLString:tempString], self.convertFact,
                                                self.calories, self.fat, self.saturatedFat, self.transFat, self.sodium,
                                                self.carbs, self.fibre, self.sugar, self.protein];
    
    return sql;

}

+ (id)createWithDBBuffer:(void *)source {
    ServingSize *record = [[ServingSize alloc] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt *)source;
    
    record.ssId = sqlite3_column_int(stmt, 0);
    record.name = [GGUtils stringWithCString:(const char *) sqlite3_column_text(stmt, 1)];
    record.convertFact = sqlite3_column_double(stmt, 2);
    
    record.calories = sqlite3_column_double(stmt, 3);
    record.fat = sqlite3_column_double(stmt, 4);
    record.saturatedFat = sqlite3_column_double(stmt, 5);
    record.transFat = sqlite3_column_double(stmt, 6);
    record.sodium = sqlite3_column_double(stmt, 7);
    record.carbs = sqlite3_column_double(stmt, 8);
    record.fibre = sqlite3_column_double(stmt, 9);
    record.sugar = sqlite3_column_double(stmt, 10);
    record.protein = sqlite3_column_double(stmt, 11);
    
    return record;
}

- (NSString *)sqlForCreateTable {
    return [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" ( \
                                            `FD_ID`	INTEGER, \
                                            `MSR_ID` INTEGER, \
                                            `MSR_NME` TEXT, \
                                            `CONV_FAC` REAL, \
                                            `calories` REAL, \
                                            `total_fat` REAL, \
                                            `sat_fat` REAL, \
                                            `trans_fat` REAL, \
                                            `sodium` REAL, \
                                            `total_carbs` REAL, \
                                            `diet_fiber` REAL, \
                                            `sugars` REAL, \
                                            `protein` REAL, \
                                            `iron` REAL);", [self class]];
}

+ (NSString *)sqlForQuery:(NSString*)filter
{
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"SELECT `MSR_ID`, `MSR_NME`, `CONV_FAC` %@ \
                                          FROM %@ %@ ",
            SERVING_SIZE_QUERY_EXTRA_COLS, [self class], whereStatement];
}

+ (PMKPromise *)queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}


@end


@interface FoodImageData()

@end

@implementation FoodImageData

- (instancetype)initWithImage:(UIImage *)image name:(NSString *)name {
    if (self = [self init]) {
        _image = image;
        _imageName = name;
    }
    
    return self;
}

- (instancetype)initWithName:(NSString *)name {
    if (self = [self init]) {
        _imageName = name;
    }
    
    return self;
}

- (NSString *)imageFilePath {
    return [NSString stringWithFormat:@"%@/%@", [GGUtils getCachedPhotoPath], self.imageName];
}

- (PMKPromise *)saveToFile {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        dispatch_promise(^{
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSData *data = UIImageJPEGRepresentation(self.image, 0.3f);

            BOOL success = [fileManager createFileAtPath:[self imageFilePath]
                                                contents:data
                                              attributes:nil];

            if (success) {
                resolve(@YES);
            }
            else {
                NSDictionary *details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Failed to save food image to disk"] forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];

                resolve(error);
            }
        });
    }];
}

- (PMKPromise *)loadFromFile {
    return [PMKPromise promiseWithResolver:^(PMKResolver resolve) {
        dispatch_promise(^{
            _image = [UIImage imageWithContentsOfFile:[self imageFilePath]];
            //NSLog(@"%@", [self imageFilePath]);
            if (_image) {
                resolve(@YES);
            }
            else {
                NSDictionary *details = [NSDictionary dictionaryWithObject:[LocalizationManager getStringFromStrId:@"Failed to load food image from disk"] forKey:NSLocalizedDescriptionKey];
                NSError* error = [NSError errorWithDomain:CustomErrorDomain code:XDefultFailed userInfo:details];
                
                resolve(error);
            }
        });
    }];
}

@end

@interface FoodItem ()

@property (nonatomic)           float transFat_;
@property (nonatomic)           float saturatedFat_;
@property (nonatomic)           float protein_; //g
//@property (nonatomic)           float iron; //mg
@property (nonatomic)           float fat_; //g
@property (nonatomic)           float sugar_;
@property (nonatomic)           float carbs_; //g
@property (nonatomic)           float sodium_;//mg
@property (nonatomic)           float fibre_;//???
@property (nonatomic)           float calories_;//???


@property (retain)     NSArray* options_;

@end


static inline const char* getCNFDBPath(void) {
    NSBundle* bundle = [NSBundle mainBundle];
    return [[bundle pathForResource:@"cnf" ofType:@"db" inDirectory:@"assets"] UTF8String];
}

@implementation FoodItem

@synthesize servingSize = _servingSize;

- (void)setServingSize:(ServingSize *)servingSize {
    @synchronized(self) {
        _servingSize = servingSize;
        
        if (self.creationType == FoodItemCreationTypeQuickInput  || self.creationType == FoodItemCreationTypeOnlineSearch) {
            self.calories_ = _servingSize.calories;
            self.fat_ = _servingSize.fat;
            self.saturatedFat_ = _servingSize.saturatedFat;
            self.transFat_ = _servingSize.transFat;
            self.sodium_ = _servingSize.sodium;
            self.carbs_ = _servingSize.carbs;
            self.fibre_ = _servingSize.fibre;
            self.sugar_ = _servingSize.sugar;
            self.protein_ = _servingSize.protein;
        }
    }
}

- (ServingSize *)servingSize {
    ServingSize *ret = nil;
    
    @synchronized(self) {
        ret = _servingSize;
    }
    
    return ret;
}

//return value: FoodItem
//+(PMKPromise *)  searchFoodInDetail:(NSUInteger) foodId {
-(NSArray*) servingSizeOptions {
    
    if(self.options_ == nil) {

        NSString *dbPath;
        NSString *queryFilter = [NSString stringWithFormat:@"`FD_ID` = %lld", self.foodId];
        NSString *query = [ServingSize sqlForQuery:queryFilter];
        
        if (self.creationType == FoodItemCreationTypeSearch) {
            dbPath = [NSString stringWithUTF8String:getCNFDBPath()];
            query = [query stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"FROM %@", NSStringFromClass([ServingSize class])]
                                                     withString:@"FROM measure"];
            query = [query stringByReplacingOccurrencesOfString:SERVING_SIZE_QUERY_EXTRA_COLS
                                                     withString:@""];
        }
        else if (self.creationType == FoodItemCreationTypeQuickInput || self.creationType == FoodItemCreationTypeBarcode || self.creationType == FoodItemCreationTypeManualInput || self.creationType == FoodItemCreationTypeOnlineSearch) {
            User *user = [User sharedModel];
            dbPath = [DBHelper getDBPath:user.userId];
        }
        
        FMDatabase *database = [FMDatabase databaseWithPath:dbPath];
        
        if(![database open])
        {
            [database open];
        }
        
        FMResultSet *resultSet = [database executeQuery:query];
        sqlite3_stmt *stmt = [[resultSet statement] statement];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        
        if(stmt != NULL) {
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                ServingSize* option = [ServingSize createWithDBBuffer:stmt];
                option.foodId = self.foodId;
                
                if(option.convertFact <= 0) {
                    option.convertFact = 1.0;
                }
                
                [results addObject: option];
            }
            
            //sqlite3_finalize(stmt);
        }
      
        self.options_ = results;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [database close];
        }];
    }

    return self.options_;
}


- (NSString *)description {
    if(self.portionSize > 0) {
        NSString *servingSizeName = self.servingSize.name;

        NSString *portionSizeDescFormat = @"%0.2f x %@, %0.1f calories";
        
        if (self.creationType == FoodItemCreationTypeQuickInput || self.creationType == FoodItemCreationTypeBarcode || self.creationType == FoodItemCreationTypeManualInput || self.creationType == FoodItemCreationTypeOnlineSearch) {
            servingSizeName = @"servings";
            portionSizeDescFormat = @"%0.2f %@, %0.1f calories";
        }
        
        return [NSString stringWithFormat:portionSizeDescFormat,
                self.portionSize, servingSizeName, self.calories * self.portionSize];
    }
    
    if (self.creationType == FoodItemCreationTypeQuickInput  || self.creationType == FoodItemCreationTypeBarcode|| self.creationType == FoodItemCreationTypeManualInput || self.creationType == FoodItemCreationTypeOnlineSearch) {
        return [NSString stringWithFormat: @"%0.1f calories", self.calories];
    }
    else if(self.servingSize != nil) {
        return [NSString stringWithFormat: @"%@, %0.1f calories",
                self.servingSize.name, self.calories];
    } else {
        return [NSString stringWithFormat: @"%@, %0.1f calories",
                self.defaultServingSize, self.calories];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone {
    FoodItem *food = [[FoodItem alloc] init];
    
    food.name = self.name;
    food.providerID = self.providerID;
    food.providerItemID = self.providerItemID;
    food.foodId =  self.foodId;
    food.portionSize = self.portionSize;
    food.carbs_ = self.carbs_;
    food.protein_ = self.protein_;
    food.fat_ = self.fat_;
    food.label = self.label;
    food.category = self.category;
    food.sugar_ = self.sugar_;
    food.fibre_ = self.fibre_;
    food.saturatedFat_ = self.saturatedFat_;
    food.transFat_ = self.transFat_;
    food.sodium_ = self.sodium_;
    food.calories_ = self.calories_;
    food.imageData = self.imageData;
    food.creationType = self.creationType;
    food.servingSize = [self.servingSize copy];
    food.defaultServingSize = self.defaultServingSize;
    food.fromLocalDB = self.fromLocalDB;
    
    return food;
}

#pragma mark - properties of nutrition facts

-(float) transFat {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.transFat_;
    } else {
        return self.transFat_;
    }
}

-(float) saturatedFat {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.saturatedFat_;
    } else {
        return self.saturatedFat_;
    }
}

-(float) protein {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.protein_;
    } else {
        return self.protein_;
    }
}

-(float) fat {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.fat_;
    } else {
        return self.fat_;
    }
}

-(float) sugar {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.sugar_;
    } else {
        return self.sugar_;
    }
}

-(float) carbs {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.carbs_;
    } else {
        return self.carbs_;
    }
}

-(float) sodium {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.sodium_;
    } else {
        return self.sodium_;
    }
}

-(float) fibre {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.fibre_;
    } else {
        return self.fibre_;
    }
}

-(float) calories {
    if(self.servingSize != nil) {
        return self.servingSize.convertFact * self.calories_;
    } else {
        return self.calories_;
    }
    
//    float starch = (self.carbs - self.fibre - self.sugar);
//    
//    float calories = (self.sugar + self.protein + starch) * 4 + self.fibre * 2 + self.fat * 9;
//    
//    return calories;
}

-(NSString*) foodClass {
    
    switch (self.label) {
        case FoodLabelInModeration:
            return [LocalizationManager getStringFromStrId:@"In Moderation"];
            break;
        case FoodLabelLessOften:
            return [LocalizationManager getStringFromStrId:@"Less Often"];
            break;
        case FoodLabelMoreOften:
            return [LocalizationManager getStringFromStrId:@"More Often"];
            break;
        default:
            return [LocalizationManager getStringFromStrId:@"Not Given"];
            break;
    }
    
}

+(instancetype) createWithSelectedFood:(SelectedFood*) record {
    FoodItem* food = nil;
    
    if (record.creationType == FoodItemCreationTypeSearch) {
        // build FoodItem Obj from the bundled (built-in) DB
        food = [self searchForFoodWithID: record.foodId];
    }
    else if (record.creationType == FoodItemCreationTypeQuickInput || record.creationType == FoodItemCreationTypeBarcode || record.creationType == FoodItemCreationTypeManualInput || record.creationType == FoodItemCreationTypeOnlineSearch) {
        food = [[FoodItem alloc] init];
        
        food.name = record.name;
        food.foodId = record.foodId;
        
        if (record.creationType == FoodItemCreationTypeBarcode) {
            food.category = [LocalizationManager getStringFromStrId:@"Barcode"];
        }else if (record.creationType == FoodItemCreationTypeQuickInput){
            food.category = [LocalizationManager getStringFromStrId:@"Auto Estimate"];
        }else if (record.creationType == FoodItemCreationTypeManualInput) {
            food.category = [LocalizationManager getStringFromStrId:@"Customized Food"];
        }else if (record.creationType == FoodItemCreationTypeOnlineSearch) {
            food.category = [LocalizationManager getStringFromStrId:@"Online Search"];
        }
        
        food.label = FoodLabelNotGiven;
        
        // Quick Input (aka auto estimate) food items will not be found
        // in the bundled (built-in) DB. Thus, we need to set the nutrition
        // facts manually here from SelectedFood
        food.transFat_ = record.transFat;
        food.saturatedFat_ = record.saturatedFat;
        food.protein_ = record.protein;
        food.fat_ = record.fat;
        food.sugar_ = record.sugar;
        food.carbs_ = record.carbs;
        food.sodium_ = record.sodium;
        food.fibre_ = record.fibre;
        food.calories_ = record.calories;
    }
    
    food.portionSize = record.portionSize;
    food.creationType = record.creationType;

    if (record.imageName && ![record.imageName isEqualToString:@""]) {
        food.imageData = [[FoodImageData alloc] initWithName:record.imageName];
        [food.imageData loadFromFile];
    }
    
    for(ServingSize* ss in food.servingSizeOptions) {
        if( ss.ssId == record.servingSizeId) {
            food.servingSize = ss;
            break;
        }
    }
    
    if (record.creationType == FoodItemCreationTypeQuickInput || record.creationType == FoodItemCreationTypeBarcode || record.creationType == FoodItemCreationTypeManualInput || record.creationType == FoodItemCreationTypeOnlineSearch) {
        food.defaultServingSize = food.servingSize.name;
    }
    
    return food;
}

- (instancetype)initWithClassificationData:(NSDictionary *)classificationData {
    if ([classificationData objectForKey:@"ItemID"] && (self = [self init]))
    {
        if (self.creationType == FoodItemCreationTypeBarcode){
            self.category = [LocalizationManager getStringFromStrId:@"Barcode"];
        }else if (self.creationType == FoodItemCreationTypeOnlineSearch){
            self.category = [LocalizationManager getStringFromStrId:@"Online Search"];
        }else{
            self.creationType = FoodItemCreationTypeQuickInput;
            self.category = [LocalizationManager getStringFromStrId:@"Auto Estimate"];
        }
        
        self.name = [classificationData objectForKey:@"Name"] ? classificationData[@"Name"] : nil;
        self.foodId = [classificationData[@"ItemID"] integerValue];
        self.portionSize = 1.0;
        self.label = FoodLabelNotGiven;
        //self.category = @"Auto Estimate";
        self.saturatedFat_ = 0.0;
        self.transFat_ = 0.0;
        self.sodium_ = 0.0;
        
        self.providerID = [[classificationData objectForKey:@"ProviderID"]intValue];
        self.providerItemID = [classificationData objectForKey:@"ItemID"];

        if ([classificationData objectForKey:@"ServingSizeOptions"] &&
            [((NSDictionary *)classificationData[@"ServingSizeOptions"]) objectForKey:@"ServingSizeOption"])
        {
            NSArray<NSDictionary *> *availableServingSizes = classificationData[@"ServingSizeOptions"][@"ServingSizeOption"];
            
            if ([classificationData[@"ServingSizeOptions"][@"ServingSizeOption"] isKindOfClass:[NSDictionary class]]) {
                availableServingSizes = @[classificationData[@"ServingSizeOptions"][@"ServingSizeOption"]];
            }
            
            NSMutableArray<ServingSize *> *tempOptions = [NSMutableArray arrayWithCapacity:[availableServingSizes count]];
            
            for (NSDictionary *servingSizeData in availableServingSizes) {
                ServingSize *servingSize = [[ServingSize alloc] init];
                
                servingSize.foodId = self.foodId;
                servingSize.ssId = [servingSizeData[@"ServingSizeID"] integerValue];
                servingSize.name = servingSizeData[@"ServingSize"];
                servingSize.convertFact = 1.0;
                
                servingSize.transFat = [servingSizeData[@"TransFat"] floatValue];
                servingSize.sugar = [servingSizeData[@"Sugars"] floatValue];
                servingSize.sodium = [servingSizeData[@"Sodium"] floatValue];
                servingSize.fibre = [servingSizeData[@"Fibre"] floatValue];
                servingSize.carbs = [servingSizeData[@"Carbs"] floatValue];
                servingSize.protein = [servingSizeData[@"Protein"] floatValue];
                servingSize.fat = [servingSizeData[@"Fat"] floatValue];
                servingSize.calories = [servingSizeData[@"Calories"] floatValue];
                
                servingSize.saturatedFat = servingSizeData[@"SaturatedFat"]==nil?0:[servingSizeData[@"SaturatedFat"] floatValue];
                
                [tempOptions addObject:servingSize];
            }
            
            self.carbs_ = tempOptions.firstObject.carbs;
            self.protein_ = tempOptions.firstObject.protein;
            self.fat_ = tempOptions.firstObject.fat;
            self.calories_ = tempOptions.firstObject.calories;
            self.sugar_ = tempOptions.firstObject.sugar;
            self.fibre_ = tempOptions.firstObject.fibre;
            self.transFat_ = tempOptions.firstObject.transFat;
            self.saturatedFat_ = tempOptions.firstObject.saturatedFat;
            
            self.options_ = tempOptions;
            self.defaultServingSize = ((ServingSize *)self.options_.firstObject).name;
        }
    }
    
    return self;
}

#pragma mark - methods about SQL
+(NSString*) getBonusStr:(NSArray*) filters {
    
    //LIKE('%apple%raw%', name)*1 + LIKE('apple%', name)*2 + LIKE('raw%', name)*2 + LIKE('%apple%', name)*2 + LIKE('%raw%', name)*2 - length(name)
    //select name, LIKE('%apple%pie%', name)*2 + LIKE('apple%', name)*2 + LIKE('%apple%', name)*1 + LIKE('pie%', name)*2 + LIKE('%pie%', name)*1 - length(name)/4 as bonus from FoodItem where  (name LIKE '%apple%') and (name LIKE '%pie%') order by bonus desc limit 25
    
    //NSMutableString *bonus1 = [NSMutableString stringWithString:@""];
    //NSMutableString *bonus2 = [NSMutableString stringWithString:@""];
    //NSMutableString *bonus3 = [NSMutableString stringWithString:@""];
    
    //LIKE('%apple' ,name) + LIKE('apple%', name)2
    //LIKE('%apple%pie%', name)2 + LIKE('apple%', name)2 + LIKE('%apple%', name)1 + LIKE('pie%', name)2 + LIKE('%pie%', name)1
    /*
     if (args.length > 1) {
        searchSQL += "LIKE('%";  // jshint ignore:line
        args.forEach(function(arg){
            searchSQL += arg + '%';
        });
        searchSQL += "', name)*2";   // jshint ignore:line
     } 
     else {
        searchSQL += "LIKE('%" + foodName + "' ,name) ";  // jshint ignore:line
     }
     
     args.forEach(function(arg){
        searchSQL += " + LIKE('" + arg + "%', name)*2";  // jshint ignore:line
        if (args.length > 1) {
            searchSQL += " + LIKE('%" + arg + "%', name)*1";  // jshint ignore:line
        }
     });
     searchSQL += ' - length(name)/' + (args.length * 2).toString();
     */
    NSString *searchSQL = @"";
    if ([filters count] > 1) {
         searchSQL = [NSString stringWithFormat:@"%@LIKE('%%", searchSQL];
        for(NSString* keyword in filters) {
            searchSQL = [NSString stringWithFormat:@"%@%@%%", searchSQL, keyword];
        }
        searchSQL = [NSString stringWithFormat:@"%@', name)*2", searchSQL];
    }
    else {
        searchSQL = [NSString stringWithFormat:@"%@LIKE('%%%@' ,name) ", searchSQL, filters[0]];
    }
    
    for(NSString* keyword in filters) {
        searchSQL = [NSString stringWithFormat:@"%@ + LIKE('%@%%', name)*2", searchSQL, keyword];
        if ([filters count] > 1) {
            searchSQL = [NSString stringWithFormat:@"%@ + LIKE('%%%@%%', name)*1", searchSQL, keyword ];
        }
    }
    
    return [NSString stringWithFormat:@"%@ - length(name)/%lu", searchSQL, [filters count]*2];
    
//    for(NSString* keyword in filters) {
//        [bonus1 appendString: [NSString stringWithFormat:@"%%%@", keyword ]];
//        [bonus2 appendString: [NSString stringWithFormat:@"LIKE(\"%@%%\", name)*2 + ", keyword ]];
//        [bonus3 appendString: [NSString stringWithFormat:@"LIKE(\"%%%@%%\", name)*2 + ", keyword ]];
//    }
    
//    return [NSString stringWithFormat:@"LIKE(\"%@\", name)*1 + %@%@0 - length(name)/%lu",
//            bonus1, bonus2, bonus3, [filters count]*2 ];
}

+(NSString*) getWhereStr:(NSArray*) filters {
    NSMutableString *str = [NSMutableString stringWithString:@""];
    
    for(NSString* keyword in filters) {
        [str appendString: [NSString stringWithFormat:@"(name LIKE \"%%%@%%\") AND ", keyword ]];
    }
    
    [str appendString: @"1"];
    
    return str;
}

+(FoodItem *)  searchForFoodWithID:(long long) foodId {
    FoodItem* food = nil;
    FMDatabase *database = [FMDatabase databaseWithPath:[NSString stringWithUTF8String:getCNFDBPath()]];
    
    if(![database open])
    {
        [database open];
    }

    NSString *query = [NSString stringWithFormat:@"select %@ from food where id = %lld", [self dbFields], foodId];
    
    FMResultSet *resultSet = [database executeQuery:query];
    sqlite3_stmt *stmt = [[resultSet statement] statement];
    
    if(stmt != NULL) {
        
        if (sqlite3_step(stmt) == SQLITE_ROW) {
            
            food = [FoodItem createFoodWithDBBuffer:stmt];
            
        }
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [database close];
    }];
    
    return food;
}

+(NSString *)  dbFields {
    return @"name,id,total_carbs, protein, total_fat, serving_size, label , hierarchy as category, sugars, diet_fiber, sat_fat, trans_fat, sodium, calories";
}

////////////////////////////////////////////////////////////
+(NSDictionary *)getFoodItemFromInternetWithProvider:(int)ProviderID andItemID:(NSString *)itemID{

    NSDictionary *responseDictionary = [[NSDictionary alloc] initWithDictionary:[GlucoguideAPI getFoodItemFromApiWithProviderID:ProviderID andItemID:itemID]];
    
    FoodItem *classificationFood = [[FoodItem alloc] initWithClassificationData:responseDictionary];
    
    classificationFood.providerID = [[NSString stringWithFormat:@"%@", [responseDictionary objectForKey:@"ProviderID"]] intValue];
    
    classificationFood.providerItemID = [NSString stringWithFormat:@"%@", [responseDictionary objectForKey:@"ItemID"]];
    classificationFood.creationType = FoodItemCreationTypeOnlineSearch;
    
    return responseDictionary;
}

////////////////////////////////////////////////////////////

+(PMKPromise *)newSearchFoodWithName:(NSString *)filter withPage:(int)page{
    
        return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
            
            NSMutableArray* results = [[NSMutableArray alloc] init];
            
            NSMutableArray* canadianFoods = [[NSMutableArray alloc] init];
            
            NSArray *tempArray = [[NSArray alloc] initWithArray:[GlucoguideAPI sendFoodToSearch:filter withPageNumber:page]];
            
            if ([[tempArray objectAtIndex:0] intValue] == 9999) {
                
                NSArray *arrayEmpty = [[NSArray alloc]init];
                
                NSMutableArray *tempTempArray = [[NSMutableArray alloc]initWithArray:tempArray];
                [tempTempArray insertObject:arrayEmpty atIndex:0];
                tempArray = [[NSArray alloc] initWithArray: tempTempArray];
                
                
                return fulfill(tempArray);
            }
            
            int providerID = [[tempArray objectAtIndex:0] intValue];
            
            bool localSearchDueToError = NO;
        
            if ([[tempArray objectAtIndex:1] isKindOfClass:[NSArray class]]) {
                for (int i = 0; i < [[tempArray objectAtIndex:1] count]; ++i) {
                    
                    FoodItem *food = [[FoodItem alloc] init];
                    food.name = [[[tempArray objectAtIndex:1] objectAtIndex:i] objectForKey:@"Name"];
                    food.category = [[[tempArray objectAtIndex:1] objectAtIndex:i] objectForKey:@"Category"];
                    food.providerItemID = [[[tempArray objectAtIndex:1] objectAtIndex:i] objectForKey:@"ItemID"];
                    food.providerID = providerID;
                    
                    [canadianFoods addObject:food];
                }
            }
            else if ([[tempArray objectAtIndex:1] isKindOfClass:[NSError class]]) {
                //handle the error return
                NSError *err = [tempArray objectAtIndex:1];
                switch (err.code) {
                    case 1:{
                        break;
                    }
                    case 2:{
                        break;
                    }
                    case 404:{
                        if (page == 0) {
                            localSearchDueToError = YES;
                            [self searchForFoodWithName:filter].then(^(NSArray *res){
                                for (NSArray* i in res) {
                                    for (FoodItem* j in i) {
                                        j.fromLocalDB = YES;
                                        [canadianFoods addObject:j];
                                    }
                                }
                                if(canadianFoods.count > 0) {
                                    [results insertObject:canadianFoods atIndex:0];
                                }
                                fulfill(results);
                            });
                            return;
                        }
                        break;
                    }
                    default:
                        break;
                }
            }
            else{
                FoodItem *food = [[FoodItem alloc] init];
                food.name = [[tempArray objectAtIndex:1] objectForKey:@"Name"];
                food.category = [[tempArray objectAtIndex:1] objectForKey:@"Category"];
                food.providerItemID = [[tempArray objectAtIndex:1] objectForKey:@"ItemID"];
                food.providerID = providerID;
                
                [canadianFoods addObject:food];
            }
      
          
            
            if(canadianFoods.count > 0) {
                [results insertObject:canadianFoods atIndex:0];
            }
            if (page == 0 && !localSearchDueToError) {
                [CustomizedFoodItem searchForFoodWithName:filter].then(^(NSArray *res){
                    if ([res count]>0) {
                        [results insertObject:res atIndex:0];
                    }
                }).finally(^(){
                    fulfill(results);
                });
            }
            else {
                fulfill(results);
            }
            
        }];
        
}


////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
///////////////////////// OLD METHOD BELOW FOR FOOD SEARCH
+(PMKPromise *)  searchForFoodWithName:(NSString*) filter {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {

        
        NSArray* filters = [filter componentsSeparatedByString:@" "];
        
        NSString* bonus = [FoodItem getBonusStr: filters];
        NSString* whereStatement = [FoodItem getWhereStr: filters];
        
        //NSMutableDictionary* namekeys = [[NSMutableDictionary alloc] init];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        
        NSMutableArray* canadianFoods = [[NSMutableArray alloc] init];

        NSBundle* bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"cnf" ofType:@"db" inDirectory:@"assets"];
        
        FMDatabase *database = [FMDatabase databaseWithPath:path];
        [database open];
        
        NSString *query = [NSString stringWithFormat:QUERY_FOOD_FORMAT, [self dbFields], bonus, whereStatement];
        
        FMResultSet *resultSet = [database executeQuery:query];
        sqlite3_stmt *stmt = [[resultSet statement] statement];
        
        
        if(stmt != NULL) {
            
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                FoodItem* food = [FoodItem createFoodWithDBBuffer:stmt];
                food.category = [LocalizationManager getStringFromStrId:@"Standard Foods"];
                [canadianFoods addObject:food];
                
//                if([food.category isEqualToString: FoodCategoryCanadianNutrition]) {
//                    [canadianFoods addObject:food];
//                } else {
//                    
//                    NSNumber* index = [namekeys objectForKey:food.category];
//                    
//                    if(index == nil) {
//                        
//                        NSMutableArray* foods = [[NSMutableArray alloc] init];
//                        [foods addObject:food];
//                        [results addObject:foods];
//                        [namekeys setObject:[NSNumber numberWithUnsignedInteger:(results.count - 1)] forKey:food.category];
//                    } else {
//                        NSMutableArray* foods = [results objectAtIndex: [index unsignedIntegerValue] ];
//                        [foods addObject:food];
//                    }
//                }
            }
            

            if(canadianFoods.count > 0) {
                [results insertObject:canadianFoods atIndex:0];
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [database close];
        }];
        
        [CustomizedFoodItem searchForFoodWithName:filter].then(^(NSArray *res){
            if ([res count]>0) {
                [results insertObject:res atIndex:0];
            }
        }).finally(^(){
            fulfill(results);
        });
        
    }];
         
    
}
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////

+(PMKPromise *)  searchRecentFoodWithType:(MealType) type {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        NSString* query = [NSString stringWithFormat:@"select b.foodId, b.mealId, b.name, `b.providerID`, `b.providerItemID` ,b.portionSize, b.servingSizeId, b.digest, b.imageName, b.creationType, `b.calories`, `b.total_fat`, `b.sat_fat`, `b.trans_fat`, `b.sodium`, `b.total_carbs`, `b.diet_fiber`, `b.sugars`, `b.protein` from mealrecord a, selectedfood b where a.id = b.mealId and a.type = %u  group by b.foodId order by count(foodId) desc", type];
        
        NSMutableArray* results = [[NSMutableArray alloc] init];
        sqlite3_stmt* stmt = [DBHelper queryGGRecord:[query UTF8String]];
        
        
        if(stmt != NULL) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                
                SelectedFood* record = [SelectedFood createWithDBBuffer:stmt];
                FoodItem* food = [self createWithSelectedFood:record ];
                
                
                [results addObject:food];
            }
            
            sqlite3_finalize(stmt);
        }
        
        fulfill(results);
        
    }];
    
}

//return type NSArray<FoodItem>
+(NSArray *)  searchRecentFood:(NSString*) filter {
    
    NSString* query = [SelectedFood sqlForQuery:filter];
    
    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    FMResultSet *resultSet = [database executeQuery:query];
    sqlite3_stmt *stmt = [[resultSet statement] statement];
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    if(stmt != NULL) {
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            
            SelectedFood* record = [SelectedFood createWithDBBuffer:stmt];
            FoodItem* food = [self createWithSelectedFood:record ];
            
            if(food != nil) {
                [results addObject:food];
            } else {
                NSLog(@"unexpect error for selectedFood, food is nil: %@", record);
            }
        }
    }

    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [database close];
    }];
    
    return [[results reverseObjectEnumerator] allObjects];
}

+(PMKPromise *)searchRecentFoodWithFilter:(NSString *)filter {
    NSString *newfilter = (filter==nil ? @"*": [NSString stringWithFormat:@"name LIKE '%%%@%%' ", filter]);
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject){
        
        NSString* query = [SelectedFood sqlForQuery:newfilter];
        
        User *user = [User sharedModel];
        FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
        
        if(![database open])
        {
            [database open];
        }
        
        FMResultSet *resultSet = [database executeQuery:query];

        NSMutableArray* results = [[NSMutableArray alloc] init];
        sqlite3_stmt* stmt = [[resultSet statement] statement];
        
        if(stmt != NULL) {
            while (sqlite3_step(stmt) == SQLITE_ROW) {
                if ([results count]>SEARCH_FOOD_RECENT_LIST_MAX_COUNT) {
                    [database close];
                    break;
                }
                SelectedFood* record = [SelectedFood createWithDBBuffer:stmt];
                FoodItem* food = [self createWithSelectedFood:record ];
                
                if(food != nil) {
                    BOOL dupli = NO;
                    for (FoodItem *e in results) {
                        if ([e.name isEqualToString:food.name])
                            dupli = YES;
                    }
                    if (!dupli)
                        [results addObject:food];
                } else {
                    NSLog(@"unexpect error for selectedFood, food is nil: %@", record);
                }
                record  = nil;
                food = nil;
            }
    }
        
        fulfill([[results reverseObjectEnumerator] allObjects]);
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
            [database close];
        }];
    }];
}

+(FoodItem*)createFoodWithDBBuffer:(void*) source {
    
    FoodItem* food = [[FoodItem alloc] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    //    @"name,id,total_carbs, protein, total_fat, serving_size, label , hierarchy as category, sugars, diet_fiber, sat_fat, trans_fat, sodium, calories"
    
    food.name = [NSString stringWithUTF8String:(char*) sqlite3_column_text(stmt, 0)];
    food.foodId = sqlite3_column_int64(stmt, 1);
    food.carbs_ = sqlite3_column_double(stmt,2);
    food.protein_ = sqlite3_column_double(stmt,3);
    food.fat_ = sqlite3_column_double(stmt,4);
    food.defaultServingSize = [NSString stringWithUTF8String:(char*) sqlite3_column_text(stmt, 5)];
    food.label = sqlite3_column_int(stmt, 6);
    food.category = [NSString stringWithUTF8String:(char*) sqlite3_column_text(stmt, 7)];
    food.sugar_ = sqlite3_column_double(stmt,8);
    food.fibre_ = sqlite3_column_double(stmt,9);
    food.saturatedFat_ = sqlite3_column_double(stmt,10);
    food.transFat_ = sqlite3_column_double(stmt,11);
    food.sodium_ = sqlite3_column_double(stmt,12);
    food.calories_ = sqlite3_column_double(stmt,13);
    food.creationType = FoodItemCreationTypeSearch;
    
    return food;
}



@end

@interface SelectedFood ()

@property (nonatomic) NSString* digest;

@property (nonatomic, readwrite) NSString* name;
@property (nonatomic, readwrite) int providerID;
@property (nonatomic, readwrite) NSString *providerItemID;
@property (nonatomic, readwrite) long long foodId;
@property (nonatomic, readwrite) ObjectId* mealId;
@property (nonatomic, readwrite) float portionSize;
//@property (nonatomic, readonly) NSString* description;
@property (nonatomic, readwrite) NSUInteger servingSizeId;
@property (nonatomic, readwrite) FoodItemCreationType creationType;
@property (nonatomic, readwrite) NSString *imageName;

@property (nonatomic, readwrite) float transFat;
@property (nonatomic, readwrite) float saturatedFat;
@property (nonatomic, readwrite) float protein; //g
@property (nonatomic, readwrite) float fat; //g
@property (nonatomic, readwrite) float sugar;
@property (nonatomic, readwrite) float carbs; //g
@property (nonatomic, readwrite) float sodium;//mg
@property (nonatomic, readwrite) float fibre;//???
@property (nonatomic, readwrite) float calories;//???
//@property (nonatomic, readwrite) float iron; //mg

@end

@implementation SelectedFood

//BOOL
+(PMKPromise *)  saveToDB:(ObjectId*) mealId foods:(NSArray*) foods {
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        //delete old data first
        NSString* delSql = [NSString stringWithFormat:@"delete from %@ where mealId = %@",[self class],
            [GGUtils toSQLString:mealId.str]];
        
        //ignore all false return for example table does not exist, 
        [DBHelper executeSql:delSql];
        
        //insert new one
        for(FoodItem* food in foods) {
            SelectedFood *record = [[SelectedFood alloc ] init];
            
            record.foodId = food.foodId;
            record.providerID = food.providerID;
            record.providerItemID = food.providerItemID;
            record.name = food.name;
            record.mealId = mealId;
            record.portionSize = food.portionSize;
            record.servingSizeId = food.servingSize.ssId;
            record.digest = food.description;
            record.creationType = food.creationType;
            
            record.transFat = food.transFat_;
            record.saturatedFat = food.saturatedFat_;
            record.protein = food.protein_;
            record.fat = food.fat_;
            record.sugar = food.sugar_;
            record.carbs = food.carbs_;
            record.sodium = food.sodium_;
            record.fibre = food.fibre_;
            record.calories = food.calories_;
            
            if (food.imageData) {
                record.imageName = food.imageData.imageName;
            }
            
            [DBHelper insertToDB: record];
            
            // only saving quick input serving sizes because for
            // food items via search, we have the bundled (built-in) DB
            // that contains serving size data
            if (record.creationType == FoodItemCreationTypeQuickInput || record.creationType == FoodItemCreationTypeBarcode || record.creationType == FoodItemCreationTypeManualInput || record.creationType == FoodItemCreationTypeOnlineSearch)
            {
                NSString* delServingSizeSql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE `FD_ID` = %lld;",
                                               [ServingSize class], record.foodId];
                [DBHelper executeSql:delServingSizeSql];
                
                for (ServingSize *servingSize in food.options_) {
                    [DBHelper insertToDB:servingSize];
                }
            }
        }
        
        
        fulfill(@YES);
    }];
}


-(NSString*) description {
    return self.digest;
}

/////////////////////////
//DBProtocol

- (NSString*) sqlForCreateTable {
    
    return [NSString stringWithFormat:@"create table if not exists %@ (foodId integer, mealId integer, name text, portionSize double, servingSizeId integer, digest text, imageName TEXT, creationType INTEGER DEFAULT 1, `calories` REAL, `total_fat` REAL, `sat_fat` REAL, `trans_fat` REAL, `sodium` REAL, `total_carbs` REAL, `diet_fiber` REAL, `sugars` REAL, `protein` REAL, `iron` REAL, providerID integer, providerItemID text);", //disabled index CREATE UNIQUE INDEX index_selectedfood ON SelectedFood (foodId, mealId);
            [self class]];
}

- (NSString*) sqlForInsert {
    //INSERT OR REPLACE INTO data VALUES (NULL, 1, 2, 3);
    NSString* sql = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ \
                     (foodId, mealId, name, portionSize, servingSizeId, digest, imageName, creationType, \
                     `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, `diet_fiber`, `sugars`, `protein`, providerID, providerItemID) \
                     VALUES (%lld, %@, %@, %f, %lu, %@, %@, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, \"%@\")",
                     [self class],
                     self.foodId,
                     [GGUtils toSQLString:self.mealId.str],
                     [GGUtils toSQLString:[self.name stringByReplacingOccurrencesOfString:@"\"" withString:@"''"]],
                     self.portionSize,
                     (unsigned long)self.servingSizeId,
                     [GGUtils toSQLString:self.digest],
                     [GGUtils toSQLString:self.imageName],
                     self.creationType,
                     self.calories, self.fat, self.saturatedFat, self.transFat,
                     self.sodium, self.carbs, self.fibre, self.sugar, self.protein, self.providerID, self.providerItemID];
    
    return sql;
}

+(instancetype) createWithDBBuffer:(void*) source {

    SelectedFood* record = [[SelectedFood alloc ] init];
    
    sqlite3_stmt* stmt = (sqlite3_stmt*) source;
    
    record.foodId = sqlite3_column_int64(stmt, 0);
    record.mealId = [[ObjectId alloc] initWithString: [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,1)]];
    
    record.name = [GGUtils stringWithCString:(const char*) sqlite3_column_text(stmt, 2)];
    record.portionSize = sqlite3_column_double(stmt, 3);
    record.servingSizeId = sqlite3_column_int(stmt, 4);
    record.digest = [GGUtils stringWithCString:(const char*) sqlite3_column_text(stmt, 5)];
    record.imageName = [GGUtils stringWithCString:(const char*) sqlite3_column_text(stmt, 6)];
    record.creationType = sqlite3_column_int(stmt, 7);
    
    record.calories = sqlite3_column_double(stmt, 8);
    record.fat = sqlite3_column_double(stmt, 9);
    record.saturatedFat = sqlite3_column_double(stmt, 10);
    record.transFat = sqlite3_column_double(stmt, 11);
    record.sodium = sqlite3_column_double(stmt, 12);
    record.carbs = sqlite3_column_double(stmt, 13);
    record.fibre = sqlite3_column_double(stmt, 14);
    record.sugar = sqlite3_column_double(stmt, 15);
    record.protein = sqlite3_column_double(stmt, 16);
    record.providerID = sqlite3_column_int(stmt, 17);
    record.providerItemID = [GGUtils stringWithCString:(const char*) sqlite3_column_text(stmt, 18)];
    
    if (record.creationType == FoodItemCreationTypeBarcode) {

    
        User *user = [User sharedModel];
        FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
        
        if(![database open])
        {
            [database open];
        }
        
        NSString *tempQuery = [NSString stringWithFormat:@"select foodId from SelectedFood where mealId = '%@'", [GGUtils stringWithCString:(char*) sqlite3_column_text(stmt,1)]];

        FMResultSet *results = [database executeQuery:tempQuery];
        
        while([results next])
        {
           record.foodId = [[results stringForColumn:@"foodId"] longLongValue];
        }
    
        [database close];
    
    }
    
    
    
    return record;
}


+ (NSString*) sqlForQuery:(NSString*)filter {
    
    NSString* whereStatement = @"";
    if(filter !=nil && ![filter isEqualToString:@"*"]) {
        whereStatement = [NSString stringWithFormat:@"where %@", filter];
    }
    
    return [NSString stringWithFormat:@"select foodId, mealId, name, portionSize, servingSizeId, digest, imageName, creationType, `calories`, `total_fat`, `sat_fat`, `trans_fat`, `sodium`, `total_carbs`, `diet_fiber`, `sugars`, `protein`, providerID, providerItemID from %@ %@ ",
            [self class], whereStatement];
}

+(PMKPromise *) queryFromDB:(NSString*)filter {
    return [DBHelper queryFromDB:[self class] : filter];
}

/////////////////////////

@end
