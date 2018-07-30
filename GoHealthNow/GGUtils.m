//
//  GGUtils.m
//  GlucoGuide
//
//  Created by Robert Wang on 2015-01-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "GGUtils.h"
#import "ServicesConstants.h"



@implementation GGUtils

+ (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:SERVER_DATE_FORMATE];
    
    //NSLog(@"strFromDate: %@\n", [dateFormatter stringFromDate:date]);
    return  [dateFormatter stringFromDate:date];
    
}

+ (NSDate *)dateFromSQLString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [[dateFormatter dateFromString:string] dateByAddingTimeInterval:timeZoneSeconds];
    
    if (dateInLocalTimezone == nil) { //trying the 24hour
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
        dateInLocalTimezone = [[dateFormatter dateFromString:string] dateByAddingTimeInterval:timeZoneSeconds];
    }
    
    [dateInLocalTimezone dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateInLocalTimezone;
}

+ (NSString *)stringOfYear:(NSDate *)date {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)dateOfYear:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    return [dateFormatter dateFromString:string];
    
}

+ (NSDate *)dateOfDay:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *dateInLocalTimezone = [[dateFormatter dateFromString:string] dateByAddingTimeInterval:timeZoneSeconds];
    
    [dateInLocalTimezone dateByAddingTimeInterval:timeZoneSeconds];
    
    return dateInLocalTimezone;
    
}

+ (NSDate *)dateFromString:(NSString *)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:SERVER_DATE_FORMATE];
   
    return [dateFormatter dateFromString:string];
    
}

+ (NSDate *)dateOfMidNight {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    NSDate* now = [NSDate date];
    NSString* todayStr = [dateFormatter stringFromDate:now];
    
    return [dateFormatter dateFromString:todayStr ];
    

}

+ (NSNumber *)daysBetweenTwoDate:(NSDate *) date1 andDate2:(NSDate *) date2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    
    NSDateComponents *d = [cal components:unitFlags fromDate:date1 toDate:date2 options:0];
    
    return [NSNumber numberWithInteger:[d day]];
}

+ (bool)isSameDayOfDate:(NSDate *) date1 andDate2:(NSDate *) date2 {
    NSCalendar *cal = [NSCalendar currentCalendar];
    
    unsigned int unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    
    NSDateComponents *d1 = [cal components:unitFlags fromDate:date1];
    NSDateComponents *d2 = [cal components:unitFlags fromDate:date2];
    
    return [d1 day]==[d2 day] && [d1 month]==[d2 month] && [d1 year]==[d2 year];
}

+ (NSDictionary *)weekDateRangeWithDate:(NSDate *)date {
    NSDate *today = [NSDate date];
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *weekStartDate;
    NSDate *weekEndDate;
    
    NSDateComponents *weekdayComponents = [cal components:NSCalendarUnitWeekday fromDate:today];
    NSDateComponents *componentsForCalc = [[NSDateComponents alloc] init];
    NSInteger weekDay = weekdayComponents.weekday;
    if (weekDay == 1) {
        weekDay = 6;
    }
    else {
        weekDay -= 2;
    }
    [componentsForCalc setDay: - weekDay];
    weekStartDate = [cal dateByAddingComponents:componentsForCalc toDate:today options:0];
    
    // set time to midnight
    NSDateComponents *components = [cal components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:weekStartDate];
    weekStartDate = [cal dateFromComponents:components];
    // holds 23:59:59 of last day in week
    weekEndDate = [weekStartDate dateByAddingTimeInterval:60*60*24*7-1];
    
    return @{
             WEEK_START_DATE_KEY: weekStartDate,
             WEEK_END_DATE_KEY: weekEndDate
             };
}

+ (NSString *)toSQLString:(NSString *)string {
    return toSQLStr(string);
}

+ (NSString *)stringWithCString:(const char *)string {
    return stringWithCString(string);
}

+ (NSString*)genPeroidTimeByType:(NSString*) fieldName peroid: (SummaryPeroidType) peroid {
    NSString* appendStr = @"";
    switch (peroid) {
            break;
        case SummaryPeroidWeekly:
            appendStr = @", 'weekday 0'";
            break;
        case SummaryPeroidMonthly:
            appendStr = @", 'start of month'";
            break;
        default:
            break;
    }
    
    return [NSString stringWithFormat:@"date(%@, 'unixepoch'%@)",
            fieldName, appendStr];
}



+ (NSString*)getCachedPhotoPath {
    
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString* cachesDir=[[documentsPaths objectAtIndex:0]
                         stringByAppendingPathComponent:PHOTO_CACHED_DIR];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:cachesDir isDirectory:&isDir];
    
    
    if(!(isDirExist && isDir))
        
    {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"Create cached message directory failed.");
            
        }
        
    }
    
    return cachesDir;
    
    
}

+ (NSString*)getCachedAudioPath {
    
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString* cachesDir=[[documentsPaths objectAtIndex:0]
                         stringByAppendingPathComponent:AUDIO_CACHED_DIR];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:cachesDir isDirectory:&isDir];
    
    
    if(!(isDirExist && isDir))
        
    {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"Create cached message directory failed.");
            
        }
        
    }
    
    return cachesDir;
    
    
}

+ (NSString*)getCachedBrandPath {
    
    
    NSArray *documentsPaths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory
                                                                , NSUserDomainMask
                                                                , YES);
    NSString* cachesDir=[[documentsPaths objectAtIndex:0]
                         stringByAppendingPathComponent:BRAND_CACHED_DIR];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    
    BOOL isDir = FALSE;
    
    BOOL isDirExist = [fileManager fileExistsAtPath:cachesDir isDirectory:&isDir];
    
    
    if(!(isDirExist && isDir))
        
    {
        
        BOOL bCreateDir = [fileManager createDirectoryAtPath:cachesDir withIntermediateDirectories:YES attributes:nil error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"Create cached message directory failed.");
            
        }
        
    }
    
    return cachesDir;
    
    
}

+ (AppLanguage)getSystemLanguageSetting {
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"fr"] || [language isEqualToString:@"fr-CA"]) {
        return AppLanguageFr;
    }
    else {
        return AppLanguageEn;
    }
}

+ (AppType)getAppType {
    return AppTypeGoHealthNow;
}

@end

