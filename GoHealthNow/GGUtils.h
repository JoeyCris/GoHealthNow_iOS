//
//  GGUtils.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_GGUtils_h
#define GlucoGuide_GGUtils_h
#import "ServicesConstants.h"

@interface GGUtils : NSObject

+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSDate *)dateFromSQLString:(NSString *)string;
+ (NSString *)stringOfYear:(NSDate *)date;
+ (NSDate *)dateOfYear:(NSString *)string;
+ (NSDate *)dateOfDay:(NSString *)string;

+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateOfMidNight;
+ (NSDictionary *)weekDateRangeWithDate:(NSDate *)date;

+ (NSNumber *)daysBetweenTwoDate:(NSDate *) date1 andDate2:(NSDate *) date2;
+ (bool)isSameDayOfDate:(NSDate *) date1 andDate2:(NSDate *) date2;

+ (NSString *)toSQLString:(NSString *)string;
+ (NSString *)stringWithCString:(const char *)string;
+ (NSString*)getCachedPhotoPath;
+ (NSString *)getCachedAudioPath;
+ (NSString*)getCachedBrandPath;

+ (NSString*)genPeroidTimeByType:(NSString*) fieldName peroid: (SummaryPeroidType) peroid;
//+ (NSDate*)getStartTimeByType:(NSDate*) endDate peroid: (SummaryPeroidType) peroid;

+ (AppLanguage)getSystemLanguageSetting;
+ (AppType)getAppType;

@end

static inline NSString* ggString(NSString* s) {
    return s ? s : @"";
}

static inline NSString* toSQLStr(NSString* string) {
    if(string == nil) {
        return @"\"\"";
    } else {
        return [NSString stringWithFormat:@"\"%@\"", string];
    }
}

static inline NSString* stringWithCString(const char* s) {
    if(s == NULL || strcmp(s, "(null)") == 0) {
        return nil;
    } else {
        return [NSString stringWithUTF8String:s];
    }
}





#endif
