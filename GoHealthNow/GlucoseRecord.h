//
//  Glucose.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-29.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_Glucose_h
#define GlucoGuide_Glucose_h

#import "GGRecord.h"
#import "DBHelper.h"

//typedef enum {
//    BGUnitMMOL= 0,//mmol/l
//    BGUnitMG mg/dl
//} BGUnit;

@interface BGValue : NSObject

-(id) initWithMMOL:(float) value;
-(id) initWithMG:(float) value;// 1 mg/dl = 18 * mmol/l

-(BOOL) setValueWithMMOL:(float) valueMmol;
-(BOOL) setValueWithMG:(float) valueMg;


-(float) valueWithMMOL;
-(float) valueWithMG;

@end

@interface GlucoseRecord : NSObject<GGRecord, DBProtocol>

//+ (BOOL) save:(NSArray*) records;
//+ (PMKPromise *)save:(NSArray*) records;

//+(PMKPromise *) queryFromDB:(NSString*) filter;

//- (BOOL) save;
//-(PMKPromise *)save;

-(NSString*) toXML;

+(NSArray*) getBGTypeOptions;

-(void)deleteGlucoseRecordWithID:(NSString *)uuid;

//static NSString * const MACRO_FASTBG_NAME_ATTR = @"fastBG";
//static NSString * const MACRO_FASTBG_RECORDEDDAY_ATTR = @"recordedDay";
//return type NSArrary<f@{@"fastBG": BGValue*, @"recordedDay": NSDate* }>
+ (PMKPromise *)searchDailyFastBG:(NSDate*)fromDate toDate:(NSDate*)toDate;

//static NSString * const MACRO_BG_CATEGORY_ATTR = @"category";
//static NSString * const MACRO_BG_ROWS_ATTR = @"rows";
/*return type NSArray < @{
 @"category":  NSString
 @"rows": NSArray<
 GlucoseRecord
 }
 >
 
 */
+ (PMKPromise *)searchRecentBGWithFilter:(NSString *)filter;

@property (nonatomic)     BGValue* level;
@property (nonatomic)     NSNumber* type;
//@property (nonatomic, copy)     NSString* uploadingVersion;
@property (nonatomic)           NSDate* recordedTime;
@property (nonatomic)   NSString *uuid;
@property (nonatomic)   NSString *note;

@end

#endif
