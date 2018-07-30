//
//  WeightRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_WeightRecord_h
#define GlucoGuide_WeightRecord_h

#import "ServicesConstants.h"
#import "GGRecord.h"
#import "DBHelper.h"

//@interface Height : NSObject
//
//
//
//-(id) initWithMetric:(int) value; //cm
//-(id) initWithImperial:(char) feet :(char) inches; // 1 feet = 12 inches; 1 inch = 2.54 cm
//
//-(BOOL) setValueWithMetric:(int) value; //cm
//-(BOOL) setValueWithImperial:(char) feet :(char) inches;
//
//
//-(int) valueWithMetric;
//
////{"feet": 5, "inches": 7}
//-(NSDictionary*) valueWithImperial;
//
//
//@end

@interface LengthUnit : NSObject



-(instancetype) initWithMetric:(float) value; //cm
-(instancetype) initWithImperial:(char) feet :(char) inches; // 1 feet = 12 inches; 1 inch = 2.54 cm

-(BOOL) setValueWithMetric:(float) value; //cm
-(BOOL) setValueWithImperial:(char) feet :(char) inches;
- (BOOL)setValueWithImperialWithInches:(float)inches;


-(float) valueWithMetric;

//{"feet": 5, "inches": 7}
-(NSDictionary*) valueWithImperial;
-(float) valueWithImperialInchesOnly;


@end

@interface WeightUnit : NSObject

+(float) convertToMetric:(float) imperialValue;

-(id) initWithMetric:(float) value;
-(id) initWithImperial:(float) value;// 1lb = 0.4536 kg

-(BOOL) setValueWithMetric:(float) valueKG; //kg
-(BOOL) setValueWithImperial:(float) valueLB;


-(float) valueWithMetric;
-(float) valueWithImperial;

@end


@interface WeightRecord : NSObject<GGRecord,DBProtocol>

@property (nonatomic, retain) WeightUnit* value;
@property (nonatomic, copy) NSDate* recordedTime;
@property (nonatomic, copy) NSString *note;
@property (nonatomic, copy) NSString *uuid;

-(NSDictionary*) toDictionary;
-(id) initWithDictionary:(NSDictionary*) dict;

+ (PMKPromise *)searchWeight:(NSDate*)fromDate toDate:(NSDate*)toDate;


//+ (NSArray<WeightRecord>) queryFromDB;
//+(PMKPromise *) queryFromDB:(NSString*) filter;

@end

#endif
