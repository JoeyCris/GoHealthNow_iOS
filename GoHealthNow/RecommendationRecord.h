//
//  RecommendationRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-11.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_RecommendationRecord_h
#define GlucoGuide_RecommendationRecord_h

#import "GGRecord.h"
#import "DBHelper.h"
#import "ServicesConstants.h"

typedef enum {
    NotificationTypeMessage = 0,
    NotificationTypeHealthTip,
    NotificationTypeAdvice = 10,
} NotificationType;

@interface RecommendationRecord : NSObject<GGRecord, DBProtocol>

+(instancetype) createWithDictionary:(NSDictionary*) dict;

+(NSString *) getTypeDescription:(NotificationType) type;

//+ (BOOL) save:(NSArray*) records;
+ (PMKPromise *)save:(NSArray*) records;

//+ (RecommendationRecord*)retrieve
+(PMKPromise *)retrieve;

//NSArray<DBProtocol> queryFromDB:(NSString*) filter;
+(PMKPromise *) queryFromDB:(NSString*) filter;

//- (BOOL) save;
-(PMKPromise *)save;

-(NSString*) toXML;

@property (nonatomic)           NotificationType type;
@property (nonatomic, copy)     NSString* content;
@property (nonatomic, copy)     NSString* imageURL;
//@property (atomic, copy)     NSString* cachedImagePath;
@property (nonatomic)           NSDate* createdTime;
@property (nonatomic)           ImageLocation imageLocation;
@property (nonatomic, copy)     NSString* link;

@end

#endif
