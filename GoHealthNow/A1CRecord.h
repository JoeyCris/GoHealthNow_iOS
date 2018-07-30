//
//  A1CRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_A1CRecord_h
#define GlucoGuide_A1CRecord_h

#import "ServicesConstants.h"
#import "GGRecord.h"
#import "DBHelper.h"

@interface A1CRecord : NSObject<GGRecord, DBProtocol>

@property (nonatomic, copy) NSNumber* value;
@property (nonatomic, copy) NSDate* recordedTime;
@property (nonatomic, copy)   NSString *uuid;
@property (nonatomic, copy)   NSString *note;

-(NSDictionary*) toDictionary;
-(id) initWithDictionary:(NSDictionary*) dict;

// ***searchA1C function has not been tested!!
//+ (PMKPromise *)searchA1C:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (PMKPromise *)searchRecentA1CWithFilter:(NSString *)filter;
//+(float) getA1C;
//
////for test
//+(void) setA1C:(float) a1c;

//+(PMKPromise *) queryFromDB:(NSString*) filter;

@end



#endif
