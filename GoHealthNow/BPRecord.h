//
//  BPRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-04-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_BPRecord_h
#define GlucoGuide_BPRecord_h

#import "GGRecord.h"
#import "DBHelper.h"

@interface BPRecord : NSObject<GGRecord, DBProtocol>

//+ (BOOL) save:(NSArray*) records;
//+ (PMKPromise *)save:(NSArray*) records;

//- (BOOL) save;
//-(PMKPromise *)save;
////-(NSDictionary*)toDictionary;

-(NSString*) toXML;
+ (PMKPromise *)searchRecentBPWithFilter:(NSString *)filter;
-(void)deleteBPRecordWithID:(NSString *)uuid;

@property (nonatomic)     NSNumber* systolic;
@property (nonatomic)     NSNumber* diastolic;
@property (nonatomic)     NSNumber* pulse;
@property (nonatomic)     NSDate* recordedTime;
@property (nonatomic)   NSString *note;
@property (nonatomic)   NSString *uuid;

@end

#endif
