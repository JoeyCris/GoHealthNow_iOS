//
//  CustomizedFoodItem.h
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "FoodItem.h"
#import "GGRecord.h"
#import "DBHelper.h"

@interface CustomizedFoodItem : FoodItem <GGRecord, DBProtocol>

+(CustomizedFoodItem *)createFoodWithManualInputName:(NSString *)name Cals:(float)cals andCarbs:(float)carbs andProtein:(float)protein andFat:(float)fat andFibre:(float)fibre andImageData:(FoodImageData *)imageData;
+(PMKPromise *)addFoodItemPhoto: (UIImage *)photo;

-(PMKPromise *)save;

@property (nonatomic) NSDate *recordedTime;
@property (nonatomic) NSString *uuid;

@property (nonatomic) NSString *hierarchy;
@property (nonatomic) NSString *subHierarchy;

@property (nonatomic) NSString *userDefaultServingSize;

@property (nonatomic) NSInteger userLabel;
@property (nonatomic, readonly) float iron;

//GGRecord
-(NSString*) toXML;
+ (PMKPromise *)save:(NSArray*) records;


@end
