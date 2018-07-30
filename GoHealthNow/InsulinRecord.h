//
//  InsulinRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-04-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_InsulinRecord_h
#define GlucoGuide_InsulinRecord_h

#import <UIKit/UIKit.h>

#import "GGRecord.h"
#import "DBHelper.h"

#import "ServicesConstants.h"

//typedef enum {
//    InsulinTypeLongActing,
//    InsulinTypeShortActing,
//    InsulinTypeMix,
//} InsulinType;

//typedef enum {
//    InsulinTimeTypeAtBreakfast,
//    InsulinTimeTypeAtLunch,
//    InsulinTimeTypeAtDinner,
//    InsulinTimeTypeAtBedtime
//} InsulinTimeType;

//@interface InsulinItem : NSObject
//
//@property (nonatomic)     NSUInteger itemId;
//@property (nonatomic)     NSUInteger name;
//@property (nonatomic)     InsulinType type;
//
////NSArray<@{InsulinTimeType:"", description:""}>
////@property (nonatomic)     NSArray* timeOptions;
//
//-(NSDictionary*) toDictionary;
//-(instancetype) initWithDictionary:(NSDictionary*) dict;
//
//
////NSArray<InsulinItem>
//+(NSArray*) getAllInsulins;
//
////NSArray<InsulinItem>
//+(NSArray*) getCustomizedInsulins;
//
////NSArray<InsulinItem>
//+(void) setCustomizedInsulins:(NSArray*) items;
//
//@end

@interface InsulinRecord : NSObject<GGRecord, DBProtocol>

//+ (BOOL) save:(NSArray*) records;
//+ (PMKPromise *)save:(NSArray*) records;

//- (BOOL) save;
//-(PMKPromise *)save;
////-(NSDictionary*)toDictionary;

+(NSArray*) getAllInsulins; //NSArray<{MACRO_INSULIN_XML_ID_ATTR:xxx, MACRO_INSULIN_XML_NAME_ATTR:yyy}>


//return type InsulinRecord
+ (PMKPromise *)searchLastInsulin;

-(NSString*) toXML;

@property (nonatomic)    NSUInteger dose;
@property (nonatomic)    NSString* insulinId;
@property (nonatomic)    NSDate* recordedTime;



@end

#endif
