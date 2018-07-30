#import "PedometerClass.h"
#import "User.h"
#import "ExerciseRecord.h"
#import "FMDatabaseAdditions.h"
#import "GGUtils.h"
#import "UIView+Extensions.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@implementation PedometerClass

@synthesize database, queue, results, setOfStartDates;
@synthesize pedometer, arrayDates, arrayPedDate, arrayPedSteps, first, second, stepCounting, intensity;
@synthesize arrayFinalIntensity, arrayFinalSteps, arrayFinalMinutes, arrayFinalDate, datesCount, tempArrayMins;
@synthesize lightAuto, moderateAuto, vigorousAuto, lightMan, moderateMan, vigorousMan, calories, arrayReturnStats;
@synthesize arrayStepsSaveStart, arrayStepsSaveEnd, arrayStepsSaveSteps;

static PedometerClass *singletonInstance;

+(PedometerClass *)getInstance
    {
        static dispatch_once_t once;
        static id singletonInstance;
        dispatch_once(&once, ^{
            singletonInstance = [[self alloc] init];
        });
        return singletonInstance;
    }

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)getExerciseData{

    if ([self isPedometerCapable]){

        if ([CMPedometer isStepCountingAvailable]) {
            NSLog(@"Pedometer - Start");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Pedometer-Start" object:@"Start"];
            [self checkForError];
            
        }
    }else{
         [[NSNotificationCenter defaultCenter] postNotificationName:@"Pedometer-Done" object:@"Done"];
    }
}

-(void)checkForError{
    
    pedometer = [[CMPedometer alloc]init];
    
    [pedometer queryPedometerDataFromDate:[NSDate date]  toDate:[NSDate date] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        
        if (error) {
            self.isMotionDenied = YES;
            NSLog(@"Motion Denied");
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"Pedometer-Done" object:@"Done"];
            });
            
           
            
            
        }else{
            self.isMotionDenied = NO;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
               [self getDatesAndTimes];
            });
        }
        
    }];
    
}

-(void)getDatesAndTimes{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userAndDates = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"usersAndDates"]];
    
    User *user = [User sharedModel];
   
    if ([userAndDates objectForKey:user.userId]) {
        //old user
        //old date
        
        NSDate *storedDateForUser = [userAndDates objectForKey:user.userId];
        NSDate *nowDate = [NSDate date];
        NSTimeInterval secondsBetween = [nowDate timeIntervalSinceDate:storedDateForUser];
        
        int minutesInWeek = secondsBetween / 60;
        
        arrayDates = [[NSMutableArray alloc]initWithCapacity:minutesInWeek];
        
        for (int i = 0; i <= minutesInWeek; i++) {
            
            NSDate *tempDate = [storedDateForUser dateByAddingTimeInterval:(60.0 * i)];
            [arrayDates addObject:tempDate];
            
        }
        
        [userAndDates removeObjectForKey:user.userId];
        [userAndDates setObject:[arrayDates lastObject] forKey:user.userId];
        
        [prefs setObject:userAndDates forKey:@"usersAndDates"];
        
    }else{
        //new user
        //new date
        
        //create exerciseRecord table
        
        database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
        [database open];
        
        if (![database tableExists:@"ExerciseRecord"]) {
                    [database executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS ExerciseRecord (minutes double, calories double, type integer, recordedTime double UNIQUE, recordEntryTime double, entryType integer, steps int, note text, uuid text);"];
        }
        
        [database close];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-7];
        NSDate *sevenDaysAgo = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        
        NSDate *nowDate = [NSDate date];
        NSTimeInterval secondsBetween = [nowDate timeIntervalSinceDate:sevenDaysAgo];
        
        int minutesInWeek = secondsBetween / 60;
        
        arrayDates = [[NSMutableArray alloc]initWithCapacity:minutesInWeek];
        
        for (int i = 0; i <= minutesInWeek; i++) {
            
            NSDate *tempDate = [sevenDaysAgo dateByAddingTimeInterval:(60.0 * i)];
            [arrayDates addObject:tempDate];
            
        }
        
        [userAndDates removeObjectForKey:user.userId];
        [userAndDates setObject:[arrayDates lastObject] forKey:user.userId];
        
        [prefs setObject:userAndDates forKey:@"usersAndDates"];

    }
    
    if ([arrayDates count] > 1) {
        [self getPedometerData];
    }else{
        
        NSLog(@"Pedometer - Not Enough Time Elapse");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Pedometer-Done" object:@"Done"];
        
        
        if (self.isMotionDenied == YES) {
            NSLog(@"Pedometer - Motion Denied");
        }
    }
    
    
}

-(void)getLast7StartDates{
    
    self.sevenStartDates = [[NSMutableArray alloc]initWithCapacity:7];
    
    for (int i = 7; i >= -1; i--) {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-i];
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        NSLog(@"start: %@", date);
        
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        NSDate *end = [gregorian dateFromComponents:components];
        
        [self.sevenStartDates addObject:end];
    }
    
    [self getLast7EndDates];
}

-(void)getLast7EndDates{
    
    self.sevenEndDates = [[NSMutableArray alloc]initWithCapacity:7];
    
    for (int i = 7; i >= -1; i--) {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:-i];
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
        NSLog(@"end: %@", date);
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        
        components.hour = 23;
        components.minute = 59;
        components.second = 59;
        NSDate *end = [gregorian dateFromComponents:components];
        
        [self.sevenEndDates addObject:end];
    }
    
    [self getStepsFromLastSevenDays];
}


-(void)getStepsFromLastSevenDays{
    
    pedometer = [[CMPedometer alloc]init];
    
    arrayStepsSaveStart = [[NSMutableArray alloc]init];
    arrayStepsSaveEnd = [[NSMutableArray alloc]init];
    arrayStepsSaveSteps = [[NSMutableArray alloc]init];
    self.arrayDummy = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [self.sevenEndDates count]; ++i) {
        
        [pedometer queryPedometerDataFromDate:[self.sevenStartDates objectAtIndex:i]  toDate:[self.sevenEndDates objectAtIndex:i] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
        
            [arrayStepsSaveStart addObject:pedometerData.startDate];
            [arrayStepsSaveEnd addObject:pedometerData.endDate];
            [arrayStepsSaveSteps addObject:pedometerData.numberOfSteps];
            
            //Used to check if async for pedometerData is done.
            [self.arrayDummy addObject:pedometerData.startDate];
            if ([self.arrayDummy count] == [self.sevenEndDates count]-1) {
                self.arrayDummy = nil;
                [self saveStepsToDatabase];
            }
            
        }];
    }
    
    
}



#pragma Database Creation and Insert

-(void)saveStepsToDatabase{
    
    User *user = [User sharedModel];
    queue = [FMDatabaseQueue databaseQueueWithPath:[DBHelper getDBPath:user.userId]];
    
    [queue inDatabase:^(FMDatabase *db) {
        
       [db executeUpdateWithFormat:@"CREATE TABLE IF NOT EXISTS ExerciseStepCount (steps integer(10) NOT NULL, startDateEpoch integer(11) UNIQUE, endDateEpoch integer(11) UNIQUE, uuid char(65));"];

        for (int i = 0; i < [arrayStepsSaveStart count]; i++) {
            
            int steps = [[arrayStepsSaveSteps objectAtIndex:i] intValue];
            NSDate *startDate = [arrayStepsSaveStart objectAtIndex:i];
            NSDate *endDate =   [arrayStepsSaveEnd objectAtIndex:i];
            
            //NSLog(@"ExerciseStepCount Table - steps: %d - startdate: %@ - endDate: %@", steps, startDate, endDate);
            
            [db executeUpdateWithFormat:@"INSERT OR REPLACE INTO ExerciseStepCount (steps, startDateEpoch, endDateEpoch, uuid) VALUES (%d,%f, %f, COALESCE((SELECT uuid FROM ExerciseStepCount WHERE startDateEpoch = %f), %@))", steps, [startDate timeIntervalSince1970], [endDate timeIntervalSince1970], [startDate timeIntervalSince1970], [[NSUUID UUID] UUIDString]];
        }
        
    }];
    
    [queue close];
}


-(void)getPedometerData{
   
    pedometer = [[CMPedometer alloc]init];
    arrayPedDate = [[NSMutableArray alloc]init];
    arrayPedSteps = [[NSMutableArray alloc]init];
    self.arrayDummy = [[NSMutableArray alloc]init];
    
    self.recordNumberCount = [arrayDates count];
    
    for (int i = 0; i < [arrayDates count]-1; i++) {
        
        [pedometer queryPedometerDataFromDate:[arrayDates objectAtIndex:i]  toDate:[arrayDates objectAtIndex: i+1] withHandler:^(CMPedometerData * _Nullable pedometerData, NSError * _Nullable error) {
            
            if (pedometerData.numberOfSteps > [NSNumber numberWithInt:30]) {
                [arrayPedDate addObject:pedometerData.startDate];
                [arrayPedSteps addObject:pedometerData.numberOfSteps];
            }
            
            //Used to check if async for pedometerData is done.
            
            if (pedometerData.numberOfSteps) {
                [self.arrayDummy addObject:pedometerData.startDate];
            }
            
            
            if ([self.arrayDummy count] == [arrayDates count]-1) {
                self.arrayDummy = nil;
                [self joinDates];
           }

        }];
        
         self.recordNumber = i;
    }
}

-(void)joinDates{
    
    arrayFinalDate = [[NSMutableArray alloc]init];
    arrayFinalMinutes = [[NSMutableArray alloc]init];
    arrayFinalSteps = [[NSMutableArray alloc]init];
    arrayFinalIntensity = [[NSMutableArray alloc]init];
    
    int recordCounter = 0;
    
    for (int i = 0; i < [arrayPedDate count]; i++) {
        
        first = [[arrayPedDate objectAtIndex:i] timeIntervalSince1970];
        
        if (i + 1 < [arrayPedDate count]) {
            second = [[arrayPedDate objectAtIndex:i+1] timeIntervalSince1970];
        }
        
        if (first + 60 != second) {
            
            stepCounting = stepCounting + [[arrayPedSteps objectAtIndex:i]intValue];
            recordCounter = recordCounter + 1;
            
            int stepsInOneMinute = stepCounting / recordCounter;
            
            if (stepsInOneMinute < 87) {
                intensity = 0;
            }else if (stepsInOneMinute >= 87 && stepsInOneMinute <= 133){
                intensity = 1;
            }else{
                intensity = 2;
            }
            
            //NSLog(@"Date: %f - Mins: %d - Steps: %d - intensity: %d", [[arrayPedDate objectAtIndex: i - (recordCounter -1)] timeIntervalSince1970], recordCounter, stepCounting, intensity);

            [arrayFinalDate addObject:[NSNumber numberWithDouble:[[arrayPedDate objectAtIndex: i - (recordCounter -1)] timeIntervalSince1970]]];
            [arrayFinalMinutes addObject:[NSNumber numberWithInt:recordCounter]];
            [arrayFinalSteps addObject:[NSNumber numberWithInt:stepCounting]];
            [arrayFinalIntensity addObject:[NSNumber numberWithInt:intensity]];
            
            stepCounting = 0;
            recordCounter = 0;
            
        }else{
            stepCounting = stepCounting + [[arrayPedSteps objectAtIndex:i]intValue];
            recordCounter = recordCounter + 1;
        }
    }
    
    arrayPedSteps = nil;
    arrayPedDate = nil;
    
   [self cycleThroughRecordsToEnter];
    
}

-(void)cycleThroughRecordsToEnter{
    
    User *user = [User sharedModel];
    queue = [FMDatabaseQueue databaseQueueWithPath:[DBHelper getDBPath:user.userId]];
    
   for (int i = 0; i < [arrayFinalDate count]; i++) {
    
        int type = [[arrayFinalIntensity objectAtIndex:i]  intValue];
        
        self.insertMinutes = [NSNumber numberWithInteger:[[arrayFinalMinutes objectAtIndex:i] intValue]];
       
        if (type == 1) {
            self.insertCalories = [NSNumber numberWithFloat:[((User *)[User sharedModel]).weight valueWithMetric] * 4.5 * ([self.insertMinutes intValue] / 60.0)];
        }else{
            self.insertCalories = [NSNumber numberWithFloat:[((User *)[User sharedModel]).weight valueWithMetric] * 8.5 * ([self.insertMinutes intValue] / 60.0)];
        }
        
        float recordedTime = [[arrayFinalDate objectAtIndex:i] floatValue];
        NSNumber *entryType = [NSNumber numberWithInteger:1];
        float recordEntryTime = [[NSDate date] timeIntervalSince1970];
        int steps = [[arrayFinalSteps objectAtIndex:i] intValue];
        NSString *uuid = (NSString *)[[NSUUID UUID] UUIDString];
        
        [queue inDatabase:^(FMDatabase *db) {

            [db executeUpdateWithFormat:@"INSERT OR REPLACE INTO ExerciseRecord (minutes, calories, type, recordedTime, entryType, recordEntryTime, steps, uuid) values (%@, %@, %d, %f, %@, %f, %d, %@)", self.insertMinutes, self.insertCalories, type, recordedTime, entryType, recordEntryTime, steps, uuid];
            
        }];

            [self insertRecordsWithStartDate:[arrayFinalDate objectAtIndex:i]
                             numberOfMinutes:[[arrayFinalMinutes objectAtIndex:i] intValue]
                             numberOfSteps:[[arrayFinalSteps objectAtIndex:i]  intValue]
                             withIntensity:[[arrayFinalIntensity objectAtIndex:i]  intValue]
                             uuid: uuid];
    }
    
    [queue close];
    
    //For Day History Exercise
    [self getLast7StartDates];
    
    NSLog(@"Pedometer - Done");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Pedometer-Done" object:@"Done"];
}


-(void)insertRecordsWithStartDate:(NSDate *)startDate numberOfMinutes:(int)minutes numberOfSteps:(int)steps withIntensity:(int)intensityRecord uuid:(NSString *)uuid{
  
    NSString *tempString = (NSString *)startDate;
    NSTimeInterval seconds = [tempString doubleValue];
    
    dispatch_promise(^{
        
        ExerciseRecord *record = [[ExerciseRecord alloc] init];
        record.type = intensityRecord;
        record.minutes = [NSNumber numberWithInteger:minutes];
        record.entryType = [NSNumber numberWithInteger:1];
        record.recordedTime = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        record.recordEntryTime = [NSDate date];
        record.steps = [NSNumber numberWithInteger:steps];
        record.uuid = uuid;
                
        if (intensityRecord == 1) {
            record.calories = [NSNumber numberWithFloat:[((User *)[User sharedModel]).weight valueWithMetric] * 4.5 * (minutes / 60.0)];
           }else{
            record.calories = [NSNumber numberWithFloat:[((User *)[User sharedModel]).weight valueWithMetric] * 8.5 * (minutes / 60.0)];
           }
        
       [record saveToServer];
    });
}

#pragma TodayMinutes
-(NSMutableArray *)getTodayMintues{
    
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* dateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    NSDate *dayBegin = [gregorian dateFromComponents:dateComponents];
    
    [dateComponents setHour:23];
    [dateComponents setMinute:59];
    [dateComponents setSecond:59];
    
    NSDate *dayEnd = [[NSCalendar currentCalendar] dateFromComponents:dateComponents];
    
    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    if ([database tableExists:@"ExerciseRecord"]){
       
        results = [database executeQueryWithFormat:@"SELECT * FROM ((SELECT sum(minutes) AS lightMins FROM ExerciseRecord WHERE type = 0 AND recordedTime >= %f AND recordedTime <= %f), (SELECT sum(minutes) AS modMins FROM ExerciseRecord WHERE type = 1 AND recordedTime >= %f AND recordedTime <= %f), (SELECT sum(minutes) AS vigMins FROM ExerciseRecord WHERE type = 2 AND recordedTime >= %f AND recordedTime <= %f))",[dayBegin timeIntervalSince1970],  [dayEnd timeIntervalSince1970], [dayBegin timeIntervalSince1970],  [dayEnd timeIntervalSince1970], [dayBegin timeIntervalSince1970],  [dayEnd timeIntervalSince1970]];
    
        tempArrayMins = [[NSMutableArray alloc] initWithCapacity:3];
    
        while([results next])
        {
            [tempArrayMins addObject:[NSNumber numberWithInt:[results intForColumn:@"lightMins"]]];
            [tempArrayMins addObject:[NSNumber numberWithInt:[results intForColumn:@"modMins"]]];
            [tempArrayMins addObject:[NSNumber numberWithInt:[results intForColumn:@"vigMins"]]];
        }
    }else{
        
        tempArrayMins = [[NSMutableArray alloc] initWithCapacity:3];
        
        [tempArrayMins addObject:[NSNumber numberWithInt:0]];
        [tempArrayMins addObject:[NSNumber numberWithInt:0]];
        [tempArrayMins addObject:[NSNumber numberWithInt:0]];
        
    }
    
    [database close];
    
    return tempArrayMins;
    
}

#pragma Methods For Database

-(int)getAvgStepsPerMin{
    
    int stepsPerMin = 0;

    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];


    [database open];

    
    if ([database tableExists:@"ExerciseRecord"]){
    
        results = [database executeQueryWithFormat:@"SELECT ROUND((SUM(steps) / SUM(minutes)),0) as stepsPerMin FROM ExerciseRecord WHERE entryType = 1"];
        
        while([results next])
        {
            stepsPerMin = [results intForColumn:@"stepsPerMin"];
        }
    }
    
    [database close];

    
    
    return stepsPerMin;
}


-(NSDictionary *)getStepsFromDatabaseDaysWorth{
    
    NSMutableArray *arrayDaySteps = [[NSMutableArray alloc]init];
    NSMutableArray *arrayDayStart = [[NSMutableArray alloc]init];
    NSMutableArray *arrayDayEnd = [[NSMutableArray alloc]init];
    
    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    results = [database executeQueryWithFormat:@"SELECT steps, startDateEpoch, endDateEpoch FROM ExerciseStepCount ORDER BY startDateEpoch ASC"];
    
    while([results next])
    {
        [arrayDaySteps addObject:[results stringForColumn:@"steps"]];
        [arrayDayStart addObject:[results stringForColumn:@"startDateEpoch"]];
        [arrayDayEnd addObject:[results stringForColumn:@"endDateEpoch"]];
    }
    
    NSArray *reverseSteps = [[NSArray alloc]initWithArray:[[arrayDaySteps reverseObjectEnumerator] allObjects]];
    NSArray *reverseStart = [[NSArray alloc]initWithArray:[[arrayDayStart reverseObjectEnumerator] allObjects]];
    NSArray *reverseEnd = [[NSArray alloc]initWithArray:[[arrayDayEnd reverseObjectEnumerator] allObjects]];
    
    [database close];
    
    NSDictionary *returnDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:reverseSteps,@"steps", reverseStart, @"startDate", reverseEnd, @"endDate", nil];
    
    return returnDictionary;
    
}

-(NSArray *)getAllManuallyAddedDates{
    
    User *user = [User sharedModel];
    database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
    
    if(![database open])
    {
        [database open];
    }
    
    NSMutableArray *datesArray = [[NSMutableArray alloc]init];
    
    if ([database tableExists:@"ExerciseRecord"]){
        
        results = [database executeQueryWithFormat:@"SELECT recordedTime FROM ExerciseRecord"];
        
        while([results next])
        {
            [datesArray addObject:[NSDate dateWithTimeIntervalSince1970:[results intForColumn:@"recordedTime"]]];
            
        }
    }
    
    [database close];
    
    NSMutableArray *startDates = [[NSMutableArray alloc] initWithCapacity:[datesArray count]];
    
    for (int i = (int)[datesArray count] -1; i >= 0; i--) {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
         NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[datesArray objectAtIndex:i] options:0];
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        
        components.hour = 0;
        components.minute = 0;
        components.second = 0;
        NSDate *start = [gregorian dateFromComponents:components];
        
        [startDates addObject: [NSNumber numberWithInt:[start timeIntervalSince1970]]];
    }
    
    
    NSMutableArray *endDates = [[NSMutableArray alloc] initWithCapacity:[datesArray count]];
    
    for (int i = (int)[datesArray count] -1; i >= 0; i--) {
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[datesArray objectAtIndex:i] options:0];
        
        
        NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [gregorian components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
        
        components.hour = 23;
        components.minute = 59;
        components.second = 59;
        NSDate *end = [gregorian dateFromComponents:components];
        
        [endDates addObject:[NSNumber numberWithInt:[end timeIntervalSince1970]]];
    }
    
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:startDates];
    NSArray *startDatesNoDups = [orderedSet array];
    
    NSOrderedSet *orderedSet1 = [NSOrderedSet orderedSetWithArray:endDates];
    NSArray *endDatesNoDups = [orderedSet1 array];
    
    NSArray *returnArray = [[NSArray alloc]initWithObjects:startDatesNoDups, endDatesNoDups,nil];
    
    startDates = nil;
    endDates = nil;
    datesArray = nil;
    orderedSet = nil;
    orderedSet1 = nil;
    startDatesNoDups = nil;
    endDatesNoDups = nil;
    
    return returnArray;
}

-(NSArray *)getAutomaticLightModerateVigorousWithStartDate:(int)startDate andEndDate:(int)endDate{
    
    User *user = [User sharedModel];
    FMDatabase *database1 = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
   
    [database1 open];
    
    
    if ([database1 tableExists:@"ExerciseRecord"]){
    
        results = [database1 executeQueryWithFormat:@"SELECT * FROM ((SELECT SUM(minutes) as lightAuto FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 0 AND entryType = 1), (SELECT SUM(minutes) as moderateAuto FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 1 AND entryType = 1), (SELECT SUM(minutes) as vigorousAuto FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 2 AND entryType = 1), (SELECT SUM(minutes) as lightMan FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 0 AND entryType = 0), (SELECT SUM(minutes) as moderateMan FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 1 AND entryType = 0), (SELECT SUM(minutes) as vigorousMan FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d AND type = 2 AND entryType = 0), (SELECT ROUND(SUM(calories),0) as calories FROM ExerciseRecord WHERE recordedTime >= %d AND recordedTime < %d))", startDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate, startDate, endDate];
    
            lightAuto = 0;
            moderateAuto = 0;
            vigorousAuto = 0;
    
            lightMan = 0;
            moderateMan = 0;
            vigorousMan = 0;
    
            calories = 0;
    
        while([results next])
        {
            lightAuto = [results intForColumn:@"lightAuto"];
            moderateAuto = [results intForColumn:@"moderateAuto"];
            vigorousAuto = [results intForColumn:@"vigorousAuto"];
        
            lightMan = [results intForColumn:@"lightMan"];
            moderateMan = [results intForColumn:@"moderateMan"];
            vigorousMan = [results intForColumn:@"vigorousMan"];
        
            calories = [results intForColumn:@"calories"];
            
        }
        
    }else{
        
       arrayReturnStats = [[NSArray alloc]initWithObjects:[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], [NSNumber numberWithInteger:0], nil];
        
    }
    
    [database1 close];
    
    arrayReturnStats = [[NSArray alloc]initWithObjects:[NSNumber numberWithInteger:lightAuto], [NSNumber numberWithInteger:moderateAuto], [NSNumber numberWithInteger:vigorousAuto], [NSNumber numberWithInteger:lightMan], [NSNumber numberWithInteger:moderateMan], [NSNumber numberWithInteger:vigorousMan], [NSNumber numberWithInteger:calories], nil];
    
    
    return arrayReturnStats;
    
}

-(BOOL)isPedometerCapable{
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"isPedometerCapable"]){
        
        return [defaults boolForKey:@"isPedometerCapable"];
    }else{
    
            size_t size;
            sysctlbyname("hw.machine", NULL, &size, NULL, 0);
            char *machine = malloc(size);
            sysctlbyname("hw.machine", machine, &size, NULL, 0);
            
            
            NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
            
            free(machine);
            
            
            if ([[self platformType:platform] isEqualToString:@"Simulator"] ||
                
                [[self platformType:platform] isEqualToString:@"iPhone 1G"] ||
                
                [[self platformType:platform] isEqualToString:@"iPhone 3G"] ||
                [[self platformType:platform] isEqualToString:@"iPhone 3GS"] ||
                
                [[self platformType:platform] isEqualToString:@"iPhone 4"] ||
                [[self platformType:platform] isEqualToString:@"iPhone 4S"] ||
                [[self platformType:platform] isEqualToString:@"Verizon iPhone 4"] ||
                [[self platformType:platform] isEqualToString:@"Verizon iPhone 4S"] ||
                
                [[self platformType:platform] isEqualToString:@"iPhone 5 (GSM)"] ||
                [[self platformType:platform] isEqualToString:@"iPhone 5 (GSM+CDMA)"] ||
                [[self platformType:platform] isEqualToString:@"iPhone 5c (GSM)"] ||
                [[self platformType:platform] isEqualToString:@"iPhone 5c (GSM+CDMA)"] ||
               
                [[self platformType:platform] isEqualToString:@"iPod Touch 1G"] ||
                [[self platformType:platform] isEqualToString:@"iPod Touch 2G"] ||
                [[self platformType:platform] isEqualToString:@"iPod Touch 3G"] ||
                [[self platformType:platform] isEqualToString:@"iPod Touch 4G"] ||
                [[self platformType:platform] isEqualToString:@"iPod Touch 5G"] ||
                
                [[self platformType:platform] isEqualToString:@"iPad"] ||
                [[self platformType:platform] isEqualToString:@"iPad 2 (WiFi)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 2 (GSM)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 2 (CDMA)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 2 (WiFi)"] ||
                
                [[self platformType:platform] isEqualToString:@"iPad Mini (GSM)"] ||
                [[self platformType:platform] isEqualToString:@"iPad Mini (GSM+CDMA)"] ||
                
                [[self platformType:platform] isEqualToString:@"iPad 3 (WiFi)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 3 (GSM+CDMA)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 3 (GSM)"] ||
                
                [[self platformType:platform] isEqualToString:@"iPad 4 (WiFi)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 4 (GSM)"] ||
                [[self platformType:platform] isEqualToString:@"iPad 4 (GSM+CDMA)"] ||
                
                [[self platformType:platform] isEqualToString:@"iPad Mini 2G (WiFi)"] ||
                [[self platformType:platform] isEqualToString:@"iPad Mini 2G (Cellular)"] ||
                [[self platformType:platform] isEqualToString:@"iPad Mini 2G"])
            {
                [defaults setBool:NO forKey:@"isPedometerCapable"];
                return NO;
            }else{
                [defaults setBool:YES forKey:@"isPedometerCapable"];
                return YES;
            }
    }
    
}

- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (Cellular)";
    
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    
    if ([platform isEqualToString:@"Watch1,1"])      return @"Apple Watch";
    if ([platform isEqualToString:@"Watch1,2"])      return @"Apple Watch";
    
    if ([platform isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4G";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


@end
