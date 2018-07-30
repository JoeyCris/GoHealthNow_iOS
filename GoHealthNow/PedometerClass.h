
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import <UIKit/UIKit.h>

@interface PedometerClass : NSObject
{
    
}

@property (strong, nonatomic) CMMotionActivityManager *activityManager;
@property (strong, nonatomic) NSOperationQueue *motionActivityQueue;
@property (strong, nonatomic) CMPedometer *pedometer;

////
@property NSMutableArray *sevenStartDates;
@property NSMutableArray *sevenEndDates;
///

@property (strong, nonatomic) FMDatabase *database;
@property (strong, nonatomic) FMDatabaseQueue *queue;
@property FMResultSet *results;

@property (nonatomic) NSMutableSet *setOfStartDates;

@property (nonatomic) NSMutableArray *arrayDates;
@property (nonatomic) NSMutableArray *arrayPedDate;
@property (nonatomic) NSMutableArray *arrayPedSteps;
@property (nonatomic) NSMutableArray *arrayFinalDate;
@property (nonatomic) NSMutableArray *arrayFinalMinutes;
@property (nonatomic) NSMutableArray *arrayFinalSteps;
@property (nonatomic) NSMutableArray *arrayFinalIntensity;
@property (nonatomic) NSMutableArray *tempArrayMins;
@property (nonatomic) NSArray *arrayReturnStats;

@property (nonatomic) NSMutableArray *arrayStepsSaveStart;
@property (nonatomic) NSMutableArray *arrayStepsSaveEnd;
@property (nonatomic) NSMutableArray *arrayStepsSaveSteps;

@property (nonatomic) NSMutableArray *arrayDummy;


@property int second;
@property int first;
@property int stepCounting;
@property int intensity;

@property int lightAuto;
@property int moderateAuto;
@property int vigorousAuto;
@property int lightMan;
@property int moderateMan;
@property int vigorousMan;
@property int calories;

@property int datesCount;

@property double recordNumber;
@property double recordNumberCount;

@property NSNumber *insertCalories;
@property NSNumber *insertMinutes;

@property UIAlertController *alert;
@property (nonatomic) BOOL isMotionDenied;

+(PedometerClass *)getInstance;

-(void)getExerciseData;

-(NSMutableArray *)getTodayMintues;

-(void)getLast7StartDates;
-(BOOL)isPedometerCapable;

-(NSArray *)getAllManuallyAddedDates;
-(NSDictionary *)getStepsFromDatabaseDaysWorth;
-(NSArray *)getAutomaticLightModerateVigorousWithStartDate:(int)startDate andEndDate:(int)endDate;
-(int)getAvgStepsPerMin;

@end
