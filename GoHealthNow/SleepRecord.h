//
//  SleepRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-29.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_SleepRecord_h
#define GlucoGuide_SleepRecord_h


#import "GGRecord.h"
#import "DBHelper.h"

@interface SleepRecord : NSObject<GGRecord, DBProtocol>

//+ (BOOL) save:(NSArray*) records;
//+ (PMKPromise *)save:(NSArray*) records;

//- (BOOL) save;
//-(PMKPromise *)save;
////-(NSDictionary*)toDictionary;

-(NSString*) toXML;

@property (nonatomic)     NSNumber* minutes;
@property (nonatomic)     NSNumber* sick;
@property (nonatomic)     NSNumber* stressed;
@property (nonatomic)           NSDate* recordedTime;
@property (nonatomic)   NSString *uuid;
@property (nonatomic)   NSString *note;

@end

#endif
