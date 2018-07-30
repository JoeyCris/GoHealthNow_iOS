//
//  ProgressViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ProgressViewController.h"
#import "GGPlot.h"
#import "StyleManager.h"
#import "MealRecord.h"
#import "GlucoseRecord.h"
#import "ExerciseRecord.h"
#import "ProgressDetailController.h"
#import "User.h"
#import "UIColor+Extensions.h"
#import "SWRevealViewController.h"
#import "GGWebBrowserProxy.h"

@interface ProgressViewController() <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *progressScollView;
@property (weak, nonatomic) IBOutlet UIView *segmentedControlView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *dateSegmentedControl;
@property (weak, nonatomic) IBOutlet GGPlot *averageMealScoreGraph;
@property (weak, nonatomic) IBOutlet GGPlot *exerciseMinutesGraph;
@property (weak, nonatomic) IBOutlet GGPlot *dailyCaloriesGraph;
@property (weak, nonatomic) IBOutlet GGPlot *bloodGlucoseGraph;
@property (weak, nonatomic) IBOutlet GGPlot *weightGraph;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnShare;

@property (nonatomic) NSMutableDictionary *dataDictForAverageMealScore;
@property (nonatomic) NSMutableDictionary *dataDictForExerciesMinutes;
@property (nonatomic) NSMutableDictionary *dataDictForDailyCalories;
@property (nonatomic) NSMutableDictionary *dataDictForBloodGlucose;
@property (nonatomic) NSMutableDictionary *dataDictForWeight;

@property (weak, nonatomic) IBOutlet UILabel *labelLogBookLink;


@property (nonatomic) BOOL graphLoaded;

@end

@implementation ProgressViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.graphLoaded = NO;
    
    self.dataDictForAverageMealScore = [[NSMutableDictionary alloc] init];
    self.dataDictForExerciesMinutes = [[NSMutableDictionary alloc] init];
    self.dataDictForDailyCalories = [[NSMutableDictionary alloc] init];
    self.dataDictForBloodGlucose = [[NSMutableDictionary alloc] init];
    self.dataDictForWeight = [[NSMutableDictionary alloc] init];
    
    UITapGestureRecognizer *tapGesForAverageMealScoreGraph = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAverageMealScoreGraph:)];
    tapGesForAverageMealScoreGraph.delegate = self;
    [self.averageMealScoreGraph addGestureRecognizer:tapGesForAverageMealScoreGraph];
    UITapGestureRecognizer *tapGesForExerciseMinutesGraph = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapExerciseMinutesGraph:)];
    [self.exerciseMinutesGraph addGestureRecognizer:tapGesForExerciseMinutesGraph];
    tapGesForExerciseMinutesGraph.delegate = self;
    UITapGestureRecognizer *tapGesForDailyCaloriesGraph = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapDailyCaloriesGraph:)];
    [self.dailyCaloriesGraph addGestureRecognizer:tapGesForDailyCaloriesGraph];
    tapGesForDailyCaloriesGraph.delegate = self;
    UITapGestureRecognizer *tapGesForBloodGlucoseGraph = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapBloodGlucoseGraph:)];
    [self.bloodGlucoseGraph addGestureRecognizer:tapGesForBloodGlucoseGraph];
    tapGesForBloodGlucoseGraph.delegate = self;
    UITapGestureRecognizer *tapGesForWeightGraph = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWeightGraph:)];
    [self.weightGraph addGestureRecognizer:tapGesForWeightGraph];
    tapGesForWeightGraph.delegate = self;
    
    [self.averageMealScoreGraph setBackgroundColor:[UIColor clearColor]];
    [self.exerciseMinutesGraph setBackgroundColor:[UIColor clearColor]];
    [self.dailyCaloriesGraph setBackgroundColor:[UIColor clearColor]];
    [self.bloodGlucoseGraph setBackgroundColor:[UIColor clearColor]];
    [self.weightGraph setBackgroundColor:[UIColor clearColor]];
    
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.segmentedControlView.backgroundColor = self.navigationController.navigationBar.barTintColor;
    self.dateSegmentedControl.tintColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(popOnLineLogBook)];
    singleTap.numberOfTapsRequired = 1;
    [self.labelLogBookLink addGestureRecognizer:singleTap];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateFrame];
    
    [self loadAllData];
    
    if (!self.graphLoaded) {
        self.graphLoaded = YES;
    }
    else {
        //should reload the data and call the ggplot to redraw it
        
    }
}

#pragma mark - Methods

- (void)composeDataForAverageMealScore:(NSMutableArray*)results {
    NSMutableArray *tempArrForNotGoodMeal = [[NSMutableArray alloc] init];
    //NSMutableArray *tempArrForOKMeal = [[NSMutableArray alloc] initWithObjects:nil];
    NSMutableArray *tempArrForGoodMeal = [[NSMutableArray alloc] init];
    NSMutableArray *tempArrForExcellentMeal = [[NSMutableArray alloc] init];
    
    NSInteger scoreResults = [results count];
    
    [self addNoDataOverlayWithTag:PROG_NO_DATA_MEAL_SCORE_TAG
                           toView:self.averageMealScoreGraph
                        withTitle:[LocalizationManager getStringFromStrId:PROG_NO_DATA_MEAL_SCORE_TITLE]
                  withResultCount:scoreResults];
    
    for (int i=0; i < scoreResults; i++) {
        MealScore *record = [[MealScore alloc] init];
        record = results[i];
        if (record.type == 1) {
            NSArray *temp = [NSArray arrayWithObjects:record.recordedDay, [NSNumber numberWithFloat:record.score], nil];
            if (record.score >= 80.0) {
                [tempArrForExcellentMeal addObject:temp];
            }
            else if (record.score >= 60.0 && record.score < 80) {
                [tempArrForGoodMeal addObject:temp];
            }
            else { // < 60.0
                [tempArrForNotGoodMeal addObject:temp];
            }
        }
        else {
            //Snack
            
        }
    }
    
    NSMutableDictionary *tempSeriesForBadMeal = [[NSMutableDictionary alloc] init];
    [tempSeriesForBadMeal setObject:tempArrForNotGoodMeal forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeriesForBadMeal setObject:[LocalizationManager getStringFromStrId:@"Not good"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeriesForBadMeal setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeBar] forKey:SERIES_DATA_DICT_ID_TYPE];
    NSMutableDictionary * tempStyleForBadMeal = [[NSMutableDictionary alloc] init];
    [tempStyleForBadMeal setObject:[UIColor notGoodMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyleForBadMeal setObject:[UIColor notGoodMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    [tempSeriesForBadMeal setObject:tempStyleForBadMeal forKey:SERIES_DATA_DICT_ID_STYLE];

    NSMutableDictionary *tempSeriesForGoodMeal = [[NSMutableDictionary alloc] init];
    [tempSeriesForGoodMeal setObject:tempArrForGoodMeal forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeriesForGoodMeal setObject:[LocalizationManager getStringFromStrId:@"Good"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeriesForGoodMeal setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeBar] forKey:SERIES_DATA_DICT_ID_TYPE];
    NSMutableDictionary * tempStyleForGoodMeal = [[NSMutableDictionary alloc] init];
    [tempStyleForGoodMeal setObject:[UIColor goodMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyleForGoodMeal setObject:[UIColor goodMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    [tempSeriesForGoodMeal setObject:tempStyleForGoodMeal forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableDictionary *tempSeriesForExcellentMeal = [[NSMutableDictionary alloc] init];
    [tempSeriesForExcellentMeal setObject:tempArrForExcellentMeal forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeriesForExcellentMeal setObject:[LocalizationManager getStringFromStrId:@"Excellent"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeriesForExcellentMeal setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeBar] forKey:SERIES_DATA_DICT_ID_TYPE];
    NSMutableDictionary * tempStyleForExcellentMeal = [[NSMutableDictionary alloc] init];
    [tempStyleForExcellentMeal setObject:[UIColor excellentMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyleForExcellentMeal setObject:[UIColor excellentMealColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    [tempSeriesForExcellentMeal setObject:tempStyleForExcellentMeal forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForSeries = [[NSMutableArray alloc] init];
    [tempArrForSeries addObject:tempSeriesForBadMeal];
    [tempArrForSeries addObject:tempSeriesForGoodMeal];
    [tempArrForSeries addObject:tempSeriesForExcellentMeal];
    
    [self.dataDictForAverageMealScore setObject:tempArrForSeries forKey:GRAPH_DATA_DICT_ID_SERIES];
    
    NSMutableDictionary *baseLines = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *oneBaseline = [[NSMutableDictionary alloc] init];
    [oneBaseline setObject:[LocalizationManager getStringFromStrId:@"Target"] forKey:SERIES_BASELINE_NAME];
    [oneBaseline setObject:[UIColor greenColor] forKey:SERIES_BASELINE_COLOR];
    [oneBaseline setObject:[NSNumber numberWithInt:80] forKey:SERIES_BASELINE_VALUE];
    
    [baseLines setObject:oneBaseline forKey:@"TargetBaseLine"];
    
    [self.dataDictForAverageMealScore setObject:baseLines forKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES];
    [self.dataDictForAverageMealScore setObject:[NSNumber numberWithUnsignedInteger:GraphTypeTrendBarLine] forKey:GRAPH_DATA_DICT_ID_TYPE];
}

- (void)displayDataOnAverageMealScoreWithTimeInterval:(TimeIntervalType)timeInterval andFromDate:(NSDate *)fromDate {
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:timeInterval];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    if (self.graphLoaded){
        [self.averageMealScoreGraph reloadCorePlotWithData:self.dataDictForAverageMealScore
                                                   forType:PROG_AVG_MEAL_SCORE_TYPE
                                                graphTitle:[LocalizationManager getStringFromStrId:PROG_AVG_MEAL_SCORE_TITLE]
                                          graphDisplayMode:GraphModePortrait
                                             xRangeDateMin:fromDate
                                             xRangeDateMax:[NSDate date]
                                              dateInterval:timeIntervalForGraph
                                         xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                                 yRangeMin:PROG_AVG_MEAL_SCORE_Y_RANGE_MIN
                                                 yRangeMax:PROG_AVG_MEAL_SCORE_Y_RANGE_MAX
                                             yAxisInterval:PROG_AVG_MEAL_SCORE_Y_INTERVAL
                                                 reloadNow:YES];
    }
    else {
        [self.averageMealScoreGraph initCorePlotWithData:self.dataDictForAverageMealScore
                                                 forType:PROG_AVG_MEAL_SCORE_TYPE
                                              graphTitle:[LocalizationManager getStringFromStrId:PROG_AVG_MEAL_SCORE_TITLE]
                                        graphDisplayMode:GraphModePortrait
                                           xRangeDateMin:fromDate
                                           xRangeDateMax:[NSDate date]
                                            dateInterval:timeIntervalForGraph
                                       xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                               yRangeMin:PROG_AVG_MEAL_SCORE_Y_RANGE_MIN
                                               yRangeMax:PROG_AVG_MEAL_SCORE_Y_RANGE_MAX
                                           yAxisInterval:PROG_AVG_MEAL_SCORE_Y_INTERVAL];
    }
}

- (void)composeDataForExerciesMinutes:(NSMutableArray*)results {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSInteger exerciseResults = [results count];
    
    [self addNoDataOverlayWithTag:PROG_NO_DATA_EXERCISE_TAG
                           toView:self.exerciseMinutesGraph
                        withTitle:PROG_NO_DATA_EXERCISE_TITLE
                  withResultCount:exerciseResults];
    
    for (int i = 0; i < exerciseResults; i++) {
        NSArray *temp = [NSArray arrayWithObjects:[results[i] objectForKey:@"recordedDay"], [results[i] objectForKey:@"minutes"], nil];
        [tempArr addObject:temp];
    }
    NSMutableDictionary *tempSeries = [[NSMutableDictionary alloc] init];
    [tempSeries setObject:tempArr forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeries setObject:[LocalizationManager getStringFromStrId:@"Minutes"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeries setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeBar] forKey:SERIES_DATA_DICT_ID_TYPE];
    
    NSMutableDictionary * tempStyle = [[NSMutableDictionary alloc] init];
    [tempStyle setObject:[UIColor blueColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyle setObject:[UIColor blueColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    
    [tempSeries setObject:tempStyle forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForTotal = [[NSMutableArray alloc] init];
    float totalMinute = 0;
    for (int i=0;i<[results count];i++) {
        totalMinute += [[results[i] objectForKey:@"minutes"] floatValue];
        NSArray *temp = [NSArray arrayWithObjects:[results[i] objectForKey:@"recordedDay"], [NSNumber numberWithFloat:totalMinute], nil];
        [tempArrForTotal addObject:temp];
    }
    NSMutableDictionary *tempSeriesForTotal = [[NSMutableDictionary alloc] init];
    [tempSeriesForTotal setObject:tempArrForTotal forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeriesForTotal setObject:[LocalizationManager getStringFromStrId:@"Total minutes"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeriesForTotal setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeLine] forKey:SERIES_DATA_DICT_ID_TYPE];
    
    NSMutableDictionary * tempStyleForTotal = [[NSMutableDictionary alloc] init];
    [tempStyleForTotal setObject:[UIColor orangeColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyleForTotal setObject:[UIColor orangeColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    
    [tempSeriesForTotal setObject:tempStyleForTotal forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForSeries = [[NSMutableArray alloc] init];
    [tempArrForSeries addObject:tempSeries];
    [tempArrForSeries addObject:tempSeriesForTotal];
    
    NSMutableDictionary *baseLines = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *oneBaseline = [[NSMutableDictionary alloc] init];
    [oneBaseline setObject:[LocalizationManager getStringFromStrId:@"Target(week)"] forKey:SERIES_BASELINE_NAME];
    [oneBaseline setObject:[UIColor greenColor] forKey:SERIES_BASELINE_COLOR];
    [oneBaseline setObject:[NSNumber numberWithInt:150] forKey:SERIES_BASELINE_VALUE];
    
    [baseLines setObject:oneBaseline forKey:@"baseLine"];
    
    [self.dataDictForExerciesMinutes setObject:baseLines forKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES];
    
    [self.dataDictForExerciesMinutes setObject:tempArrForSeries forKey:GRAPH_DATA_DICT_ID_SERIES];
    [self.dataDictForExerciesMinutes setObject:[NSNumber numberWithUnsignedInteger:GraphTypeTrendBarLine] forKey:GRAPH_DATA_DICT_ID_TYPE];
}

- (void)displayDataOnExerciesMinutesWithTimeInterval:(TimeIntervalType)timeInterval andFromDate:(NSDate *)fromDate {
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:timeInterval];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    if (self.graphLoaded) {
        [self.exerciseMinutesGraph reloadCorePlotWithData:self.dataDictForExerciesMinutes
                                                  forType:PROG_EXERCISE_MINS_TYPE
                                               graphTitle:[LocalizationManager getStringFromStrId:PROG_EXERCISE_MINS_TITLE]
                                         graphDisplayMode:GraphModePortrait
                                            xRangeDateMin:fromDate
                                            xRangeDateMax:[NSDate date]
                                             dateInterval:timeIntervalForGraph
                                        xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                                yRangeMin:PROG_EXERCISE_MINS_Y_RANGE_MIN
                                                yRangeMax:PROG_EXERCISE_MINS_Y_RANGE_MAX
                                            yAxisInterval:PROG_EXERCISE_MINS_Y_INTERVAL
                                                reloadNow:YES];
    }
    else {
        [self.exerciseMinutesGraph initCorePlotWithData:self.dataDictForExerciesMinutes
                                                forType:PROG_EXERCISE_MINS_TYPE
                                             graphTitle:[LocalizationManager getStringFromStrId:PROG_EXERCISE_MINS_TITLE]
                                       graphDisplayMode:GraphModePortrait
                                          xRangeDateMin:fromDate
                                          xRangeDateMax:[NSDate date]
                                           dateInterval:timeIntervalForGraph
                                      xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                              yRangeMin:PROG_EXERCISE_MINS_Y_RANGE_MIN
                                              yRangeMax:PROG_EXERCISE_MINS_Y_RANGE_MAX
                                          yAxisInterval:PROG_EXERCISE_MINS_Y_INTERVAL];
    }
}

- (void)composeDataForDailyCalories:(NSMutableArray*)results {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSInteger calorieResults = [results count];
    
    [self addNoDataOverlayWithTag:PROG_NO_DATA_DAILY_CALS_TAG
                           toView:self.dailyCaloriesGraph
                        withTitle:[LocalizationManager getStringFromStrId:PROG_NO_DATA_DAILY_CALS_TITLE]
                  withResultCount:calorieResults];
    
    NSNumber *lastCal = 0;
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSDate *lastDate = nil;
    for (int i=0; i < calorieResults; i++) {
        if (lastDate == nil) {
            lastDate = [results[i] objectForKey:@"recordedDay"];
            lastCal = [results[i] objectForKey:@"calories"];
            continue;
        }
        if ([[df stringFromDate:[results[i] objectForKey:@"recordedDay"]] isEqualToString:[df stringFromDate:lastDate]]) {
            lastCal = [NSNumber numberWithInteger:[lastCal integerValue] + [[results[i] objectForKey:@"calories"] integerValue]];
        }
        else {
            NSArray *temp = [NSArray arrayWithObjects:lastDate, lastCal, nil];
            [tempArr addObject:temp];
            NSLog(@"Day:%@\nCal:%@\n\n", lastDate, lastCal);
            lastDate = [results[i] objectForKey:@"recordedDay"];
            lastCal = [results[i] objectForKey:@"calories"];
        }
    }
    NSLog(@"Day:%@\nCal:%@\n\n", lastDate, lastCal);
    NSArray *temp = [NSArray arrayWithObjects:lastDate, lastCal, nil];
    [tempArr addObject:temp];
    
    NSMutableDictionary *tempSeries = [[NSMutableDictionary alloc] init];
    [tempSeries setObject:tempArr forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeries setObject:[LocalizationManager getStringFromStrId:@"Calories"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeries setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeBar] forKey:SERIES_DATA_DICT_ID_TYPE];
    
    NSMutableDictionary * tempStyle = [[NSMutableDictionary alloc] init];
    [tempStyle setObject:[UIColor purpleColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyle setObject:[UIColor purpleColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    
    [tempSeries setObject:tempStyle forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForSeries = [[NSMutableArray alloc] init];
    [tempArrForSeries addObject:tempSeries];
    
    NSMutableDictionary *baseLines = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *oneBaseline = [[NSMutableDictionary alloc] init];
    [oneBaseline setObject:[LocalizationManager getStringFromStrId:@"Target"] forKey:SERIES_BASELINE_NAME];
    [oneBaseline setObject:[UIColor greenColor] forKey:SERIES_BASELINE_COLOR];
    [oneBaseline setObject:[NSNumber numberWithInt:[[User sharedModel] getTargetCalories]] forKey:SERIES_BASELINE_VALUE];
    
    if ([[User sharedModel] getTargetCalories] >= 0) {
        [baseLines setObject:oneBaseline forKey:@"baseLine"];
        [self.dataDictForDailyCalories setObject:baseLines forKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES];
    }
    
    [self.dataDictForDailyCalories setObject:tempArrForSeries forKey:GRAPH_DATA_DICT_ID_SERIES];
    [self.dataDictForDailyCalories setObject:[NSNumber numberWithUnsignedInteger:GraphTypeTrendBarLine] forKey:GRAPH_DATA_DICT_ID_TYPE];
}

- (void)displayDataOnDailyCaloriesWithTimeInterval:(TimeIntervalType)timeInterval andFromDate:(NSDate *)fromDate {
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:timeInterval];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *dailyCaloriesYAxisInfo = [self dailyCaloriesYAxisInfo];
    
    if (self.graphLoaded) {
        [self.dailyCaloriesGraph reloadCorePlotWithData:self.dataDictForDailyCalories
                                                forType:PROG_DAILY_CALS_TYPE
                                             graphTitle:[LocalizationManager getStringFromStrId:PROG_DAILY_CALS_TITLE]
                                       graphDisplayMode:GraphModePortrait
                                          xRangeDateMin:fromDate
                                          xRangeDateMax:[NSDate date]
                                           dateInterval:timeIntervalForGraph
                                      xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                              yRangeMin:[dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                              yRangeMax:[dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MAX] intValue]
                                          yAxisInterval:[dailyCaloriesYAxisInfo[PROG_KEY_Y_INTERVAL] intValue]
                                              reloadNow:YES];
    }
    else {
        [self.dailyCaloriesGraph initCorePlotWithData:self.dataDictForDailyCalories
                                              forType:PROG_DAILY_CALS_TYPE
                                           graphTitle:[LocalizationManager getStringFromStrId:PROG_DAILY_CALS_TITLE]
                                     graphDisplayMode:GraphModePortrait
                                        xRangeDateMin:fromDate
                                        xRangeDateMax:[NSDate date]
                                         dateInterval:timeIntervalForGraph
                                    xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                            yRangeMin:[dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                            yRangeMax:[dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MAX] intValue]
                                        yAxisInterval:[dailyCaloriesYAxisInfo[PROG_KEY_Y_INTERVAL] intValue]];
    }
}

- (void)composeDataForBloodGlucose:(NSMutableArray*)results {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSInteger bloodGlucoseResults = [results count];
    
    [self addNoDataOverlayWithTag:PROG_NO_DATA_BG_FAST_TAG
                           toView:self.bloodGlucoseGraph
                        withTitle:[LocalizationManager getStringFromStrId:PROG_NO_DATA_BG_FAST_TITLE]
                  withResultCount:bloodGlucoseResults];
    
    for (int i = 0; i < bloodGlucoseResults; i++) {
        NSArray *temp = [NSArray arrayWithObjects:[results[i] objectForKey:MACRO_FASTBG_RECORDEDDAY_ATTR], ((User *)[User sharedModel]).bgUnit == BGUnitMMOL ? [NSNumber numberWithFloat:[(BGValue *)[results[i] objectForKey:MACRO_FASTBG_NAME_ATTR] valueWithMMOL]] : [NSNumber numberWithFloat:[(BGValue *)[results[i] objectForKey:MACRO_FASTBG_NAME_ATTR] valueWithMG]], nil];
        [tempArr addObject:temp];
    }
    NSMutableDictionary *tempSeries = [[NSMutableDictionary alloc] init];
    [tempSeries setObject:tempArr forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeries setObject:[LocalizationManager getStringFromStrId:@"Blood glucose"] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeries setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeLine] forKey:SERIES_DATA_DICT_ID_TYPE];
    
    NSMutableDictionary * tempStyle = [[NSMutableDictionary alloc] init];
    [tempStyle setObject:[UIColor GGRedColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyle setObject:[UIColor GGRedColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    
    [tempSeries setObject:tempStyle forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForSeries = [[NSMutableArray alloc] init];
    [tempArrForSeries addObject:tempSeries];
    
    [self.dataDictForBloodGlucose setObject:tempArrForSeries forKey:GRAPH_DATA_DICT_ID_SERIES];
    [self.dataDictForBloodGlucose setObject:[NSNumber numberWithUnsignedInteger:GraphTypeTrendBarLine] forKey:GRAPH_DATA_DICT_ID_TYPE];
}

- (void)displayDataOnBloodGlucoseWithTimeInterval:(TimeIntervalType)timeInterval andFromDate:(NSDate *)fromDate {
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:timeInterval];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *dailyFastBGYAxisInfo = [self dailyFastBGYAxisInfo];
    
    if (self.graphLoaded) {
        [self.bloodGlucoseGraph reloadCorePlotWithData:self.dataDictForBloodGlucose
                                               forType:PROG_BG_FAST_TYPE
                                            graphTitle:[LocalizationManager getStringFromStrId:PROG_BG_FAST_TITLE]
                                      graphDisplayMode:GraphModePortrait
                                         xRangeDateMin:fromDate
                                         xRangeDateMax:[NSDate date]
                                          dateInterval:timeIntervalForGraph
                                     xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                             yRangeMin:[dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                             yRangeMax:[dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                                         yAxisInterval:[dailyFastBGYAxisInfo[PROG_KEY_Y_INTERVAL] floatValue]
                                             reloadNow:YES];
    }
    else {
        [self.bloodGlucoseGraph initCorePlotWithData:self.dataDictForBloodGlucose
                                             forType:PROG_BG_FAST_TYPE
                                          graphTitle:[LocalizationManager getStringFromStrId:PROG_BG_FAST_TITLE]
                                    graphDisplayMode:GraphModePortrait
                                       xRangeDateMin:fromDate
                                       xRangeDateMax:[NSDate date]
                                        dateInterval:timeIntervalForGraph
                                   xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                           yRangeMin:[dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                           yRangeMax:[dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                                       yAxisInterval:[dailyFastBGYAxisInfo[PROG_KEY_Y_INTERVAL] floatValue]];
    }
}

- (void)composeDataForWeight:(NSMutableArray*)results {
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    NSInteger weightResults = [results count];
    
    [self addNoDataOverlayWithTag:PROG_NO_DATA_WEIGHT_TAG
                           toView:self.weightGraph
                        withTitle:[LocalizationManager getStringFromStrId:PROG_NO_DATA_WEIGHT_TITLE]
                  withResultCount:weightResults];
    
    for (int i = 0; i < weightResults; i++) {
        NSArray *temp = [NSArray arrayWithObjects:[results[i] objectForKey:MACRO_WEIGHT_RECORDEDDAY_ATTR], ((User *)[User sharedModel]).measureUnit == MUnitMetric ? [NSNumber numberWithFloat:[(WeightUnit *)[results[i] objectForKey:MACRO_WEIGHT_NAME_ATTR] valueWithMetric]] : [NSNumber numberWithFloat:[(WeightUnit *)[results[i] objectForKey:MACRO_WEIGHT_NAME_ATTR] valueWithImperial]], nil];
        [tempArr addObject:temp];
    }
    NSMutableDictionary *tempSeries = [[NSMutableDictionary alloc] init];
    [tempSeries setObject:tempArr forKey:SERIES_DATA_DICT_ID_DATA];
    [tempSeries setObject:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight(%@)"], ((User *)[User sharedModel]).measureUnit == MUnitMetric ? [LocalizationManager getStringFromStrId:@"kgs"] : [LocalizationManager getStringFromStrId:@"lbs"]] forKey:SERIES_DATA_DICT_ID_NAME];
    [tempSeries setObject:[NSNumber numberWithUnsignedInteger:SeriesTypeLine] forKey:SERIES_DATA_DICT_ID_TYPE];
    
    NSMutableDictionary * tempStyle = [[NSMutableDictionary alloc] init];
    [tempStyle setObject:[UIColor GGBlueColor] forKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
    [tempStyle setObject:[UIColor GGBlueColor] forKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
    
    [tempSeries setObject:tempStyle forKey:SERIES_DATA_DICT_ID_STYLE];
    
    NSMutableArray *tempArrForSeries = [[NSMutableArray alloc] init];
    [tempArrForSeries addObject:tempSeries];
    
    [self.dataDictForWeight setObject:tempArrForSeries forKey:GRAPH_DATA_DICT_ID_SERIES];
    [self.dataDictForWeight setObject:[NSNumber numberWithUnsignedInteger:GraphTypeTrendBarLine] forKey:GRAPH_DATA_DICT_ID_TYPE];
}

- (void)displayDataOnWeightWithTimeInterval:(TimeIntervalType)timeInterval andFromDate:(NSDate *)fromDate {
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:timeInterval];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *weightYAxisInfo = [self weightYAxisInfo];
    
    if (self.graphLoaded) {
        [self.weightGraph reloadCorePlotWithData:self.dataDictForWeight
                                         forType:PROG_WEIGHT_TYPE
                                      graphTitle:[LocalizationManager getStringFromStrId:PROG_WEIGHT_TITLE]
                                graphDisplayMode:GraphModePortrait
                                   xRangeDateMin:fromDate
                                   xRangeDateMax:[NSDate date]
                                    dateInterval:timeIntervalForGraph
                               xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                       yRangeMin:[weightYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                       yRangeMax:[weightYAxisInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                                   yAxisInterval:[weightYAxisInfo[PROG_KEY_Y_INTERVAL] floatValue]
                                       reloadNow:YES];
    }
    else {
        [self.weightGraph initCorePlotWithData:self.dataDictForWeight
                                       forType:PROG_WEIGHT_TYPE
                                    graphTitle:[LocalizationManager getStringFromStrId:PROG_WEIGHT_TITLE]
                              graphDisplayMode:GraphModePortrait
                                 xRangeDateMin:fromDate
                                 xRangeDateMax:[NSDate date]
                                  dateInterval:timeIntervalForGraph
                             xAxisDateInterval:timeIntervalForGraph * intervalCtl
                                     yRangeMin:[weightYAxisInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                     yRangeMax:[weightYAxisInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
         
                                 yAxisInterval:[weightYAxisInfo[PROG_KEY_Y_INTERVAL] floatValue]];
    }
}

- (void)addNoDataOverlayWithTag:(NSUInteger)tag toView:(UIView *)view withTitle:(NSString *)title withResultCount:(NSInteger)resultCount
{
    UIView *origNoDataOverlay = [self.progressScollView viewWithTag:tag];
    if (origNoDataOverlay) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             origNoDataOverlay.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [origNoDataOverlay removeFromSuperview];
                         }];
    }

    if (resultCount == 0) {
        UIView *noDataOverlay = [[UIView alloc] initWithFrame:view.frame];
        noDataOverlay.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        noDataOverlay.tag = tag;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        titleLabel.text = [title uppercaseString];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:22.0];
        titleLabel.transform = CGAffineTransformMakeRotation(-M_PI_4); // rotate 45 degrees
        titleLabel.numberOfLines = 0;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [noDataOverlay addSubview:titleLabel];
        [self.progressScollView addSubview:noDataOverlay];
        
        [noDataOverlay addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:noDataOverlay
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        [noDataOverlay addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:noDataOverlay
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        [noDataOverlay addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:noDataOverlay
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    }
}

- (NSDictionary *)dateIntervalsWithTimeInterval:(TimeIntervalType)timeInterval {
    double timeIntervalForGraph = TIME_INTERVAL_DAY;
    NSInteger intervalCtl = 1.0;
    if (timeInterval == TimeIntervalTypeWeek) {
        timeIntervalForGraph = TIME_INTERVAL_DAY;
        intervalCtl = 1;
    }
    else if (timeInterval == TimeIntervalTypeMonth) {
        timeIntervalForGraph = TIME_INTERVAL_DAY;
        intervalCtl = 2;
    }
    else if (timeInterval == TimeIntervalType3Months) {
        timeIntervalForGraph = TIME_INTERVAL_MONTH;
        intervalCtl = 1;
    }
    else if (timeInterval == TimeIntervalType6Months) {
        timeIntervalForGraph = TIME_INTERVAL_MONTH;
        intervalCtl = 1;
    }
    
    return @{PROG_KEY_TIME_INTV_FOR_GRAPH: [NSNumber numberWithDouble:timeIntervalForGraph],
             PROG_KEY_INTV_CTL: [NSNumber numberWithInteger:intervalCtl]};
}

- (NSDate *)fromDateWithTimeInterval:(TimeIntervalType)timeInterval {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                          fromDate:[[NSDate alloc] init]];
    
    if (timeInterval == TimeIntervalTypeWeek) {
        [components setDay:([components day] - 7)];
    }
    else if (timeInterval == TimeIntervalTypeMonth) {
        [components setMonth:[components month] - 1];
    }
    else if (timeInterval == TimeIntervalType3Months) {
        [components setMonth:([components month] - 3)];
    }
    else if (timeInterval == TimeIntervalType6Months) {
        [components setMonth:([components month] - 6)];
    }
    
    NSDate *fromDate = [cal dateFromComponents:components];
    return fromDate;
}

- (NSDictionary *)dailyCaloriesYAxisInfo {
    float targetCalories = [[User sharedModel] getTargetCalories];
    
    return @{PROG_KEY_Y_RANGE_MIN: [NSNumber numberWithFloat:PROG_DAILY_CALS_Y_RANGE_MIN],
             PROG_KEY_Y_RANGE_MAX: [NSNumber numberWithInt:(int)(targetCalories/1000)*1000+2000],
             PROG_KEY_Y_INTERVAL: [NSNumber numberWithInt:((int)(targetCalories/1000)*1000+2000) >= 3000 ? 1000 : 500]
             };
}

- (NSDictionary *)dailyFastBGYAxisInfo {
    BGUnit bgUnit = ((User *)[User sharedModel]).bgUnit;
    
    return @{PROG_KEY_Y_RANGE_MIN: [NSNumber numberWithFloat:PROG_BG_FAST_Y_RANGE_MIN],
             PROG_KEY_Y_RANGE_MAX: [NSNumber numberWithFloat:bgUnit == BGUnitMMOL ? 30 : 600],
             PROG_KEY_Y_INTERVAL: [NSNumber numberWithFloat:bgUnit == BGUnitMMOL ? 5 : 100]
             };
}

- (NSDictionary *)weightYAxisInfo {
    float yRangeMin = ((User *)[User sharedModel]).measureUnit == MUnitMetric ? 300 : 700;
    
    return @{PROG_KEY_Y_RANGE_MIN: [NSNumber numberWithFloat:PROG_WEIGHT_Y_RANGE_MIN],
             PROG_KEY_Y_RANGE_MAX: [NSNumber numberWithFloat:yRangeMin],
             PROG_KEY_Y_INTERVAL: [NSNumber numberWithFloat:100]
             };
}

- (void)loadAllData {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    
    [self loadDataWithDataType:GraphDataTypeAverageMealScore intervalType:intervalType];
    [self loadDataWithDataType:GraphDataTypeExerciesMinutes intervalType:intervalType];
    [self loadDataWithDataType:GraphDataTypeDailyCalories intervalType:intervalType];
    [self loadDataWithDataType:GraphDataTypeBloodGlucose intervalType:intervalType];
    [self loadDataWithDataType:GraphDataTypeWeight intervalType:intervalType];
}

- (void)loadDataWithDataType:(GraphDataType)dataType intervalType:(TimeIntervalType)timeInterval {
    NSDate *fromDate = [self fromDateWithTimeInterval:timeInterval];
    
    if (dataType == GraphDataTypeAverageMealScore) {
        [self.dataDictForAverageMealScore removeAllObjects];
        if (timeInterval == TimeIntervalType3Months || timeInterval == TimeIntervalType6Months) {
            [MealRecord searchAverageScore:SummaryPeroidMonthly fromDate:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results) {
                [self composeDataForAverageMealScore:results];
            }).finally(^{
                [self displayDataOnAverageMealScoreWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
        else {
            [MealRecord searchDailyScore:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results) {
                [self composeDataForAverageMealScore:results];
            }).finally(^{
                [self displayDataOnAverageMealScoreWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
    }
    else if (dataType == GraphDataTypeExerciesMinutes) {
        [self.dataDictForExerciesMinutes removeAllObjects];
        if (timeInterval == TimeIntervalType3Months || timeInterval == TimeIntervalType6Months) {
            [ExerciseRecord searchSummaryMinutes:SummaryPeroidMonthly fromDate:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForExerciesMinutes:results];
            }).finally(^{
                [self displayDataOnExerciesMinutesWithTimeInterval:timeInterval andFromDate:fromDate];
            });
            
        }
        else {
            [ExerciseRecord searchDailyMinutes:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForExerciesMinutes:results];
            }).finally(^{
                [self displayDataOnExerciesMinutesWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
        
    }
    else if (dataType == GraphDataTypeDailyCalories) {
        [self.dataDictForDailyCalories removeAllObjects];
        if (timeInterval == TimeIntervalType3Months || timeInterval == TimeIntervalType6Months) {
            [MealRecord searchSummaryCalories:SummaryPeroidMonthly fromDate:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForDailyCalories:results];
            }).finally(^{
                [self displayDataOnDailyCaloriesWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
        else {
            [MealRecord searchDailyCalories:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForDailyCalories:results];
            }).finally(^{
                [self displayDataOnDailyCaloriesWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
    }
    else if (dataType == GraphDataTypeBloodGlucose) {
        if (timeInterval == TimeIntervalType3Months || timeInterval == TimeIntervalType6Months) {
            //TODO
        }
        else {
            [GlucoseRecord searchDailyFastBG:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForBloodGlucose:results];
            }).finally(^{
                [self displayDataOnBloodGlucoseWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
    }
    else if (dataType == GraphDataTypeWeight) {
        if (timeInterval == TimeIntervalType3Months || timeInterval == TimeIntervalType6Months) {
            //TODO
        }
        else {
            [WeightRecord searchWeight:fromDate toDate:[NSDate date]].then(^(NSMutableArray* results){
                [self composeDataForWeight:results];
            }).finally(^{
                [self displayDataOnWeightWithTimeInterval:timeInterval andFromDate:fromDate];
            });
        }
    }
}

- (void)updateFrame {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.averageMealScoreGraph updateFrameWithFrame:self.averageMealScoreGraph.frame];
        [self.exerciseMinutesGraph updateFrameWithFrame:self.exerciseMinutesGraph.frame];
        [self.dailyCaloriesGraph updateFrameWithFrame:self.dailyCaloriesGraph.frame];
        [self.bloodGlucoseGraph updateFrameWithFrame:self.bloodGlucoseGraph.frame];
        [self.weightGraph updateFrameWithFrame:self.weightGraph.frame];
    });
}

#pragma mark - Event Handlers

- (IBAction)settingsButtonTapped:(id)sender {
    [self.revealViewController revealToggle:self];
}

- (IBAction)didChangeDateInterval:(id)sender {
    [self loadAllData];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self updateFrame];
}

- (void)didTapAverageMealScoreGraph:(UITapGestureRecognizer *)sender {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    NSDate *fromDate = [self fromDateWithTimeInterval:intervalType];
    
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:intervalType];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *graphInfo = @{PROG_KEY_DATA: self.dataDictForAverageMealScore,
                                PROG_KEY_TYPE: [NSNumber numberWithInteger:PROG_AVG_MEAL_SCORE_TYPE],
                                PROG_KEY_TITLE: [LocalizationManager getStringFromStrId:PROG_AVG_MEAL_SCORE_TITLE],
                                PROG_KEY_X_RANGE_DATE_MIN:fromDate,
                                PROG_KEY_X_RANGE_DATE_MAX:[NSDate date],
                                PROG_KEY_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph],
                                PROG_KEY_X_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph * intervalCtl],
                                PROG_KEY_Y_RANGE_MIN:[NSNumber numberWithFloat:PROG_AVG_MEAL_SCORE_Y_RANGE_MIN],
                                PROG_KEY_Y_RANGE_MAX:[NSNumber numberWithFloat:PROG_AVG_MEAL_SCORE_Y_RANGE_MAX],
                                PROG_KEY_Y_INTERVAL:[NSNumber numberWithFloat:PROG_AVG_MEAL_SCORE_Y_INTERVAL]
                                };
    
    [self performSegueWithIdentifier:@"progressDetailSegue" sender:graphInfo];
}

- (void)didTapExerciseMinutesGraph:(UITapGestureRecognizer *)sender {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    NSDate *fromDate = [self fromDateWithTimeInterval:intervalType];
    
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:intervalType];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *graphInfo = @{PROG_KEY_DATA: self.dataDictForExerciesMinutes,
                                PROG_KEY_TYPE: [NSNumber numberWithInteger:PROG_EXERCISE_MINS_TYPE],
                                PROG_KEY_TITLE: [LocalizationManager getStringFromStrId:PROG_EXERCISE_MINS_TITLE],
                                PROG_KEY_X_RANGE_DATE_MIN:fromDate,
                                PROG_KEY_X_RANGE_DATE_MAX:[NSDate date],
                                PROG_KEY_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph],
                                PROG_KEY_X_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph * intervalCtl],
                                PROG_KEY_Y_RANGE_MIN:[NSNumber numberWithFloat:PROG_EXERCISE_MINS_Y_RANGE_MIN],
                                PROG_KEY_Y_RANGE_MAX:[NSNumber numberWithFloat:PROG_EXERCISE_MINS_Y_RANGE_MAX],
                                PROG_KEY_Y_INTERVAL:[NSNumber numberWithFloat:PROG_EXERCISE_MINS_Y_INTERVAL]
                                };
    
    [self performSegueWithIdentifier:@"progressDetailSegue" sender:graphInfo];
}

- (void)didTapDailyCaloriesGraph:(UITapGestureRecognizer *)sender {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    NSDate *fromDate = [self fromDateWithTimeInterval:intervalType];
    
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:intervalType];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *dailyCaloriesYAxisInfo = [self dailyCaloriesYAxisInfo];
    
    NSDictionary *graphInfo = @{PROG_KEY_DATA: self.dataDictForDailyCalories,
                                PROG_KEY_TYPE: [NSNumber numberWithInteger:PROG_DAILY_CALS_TYPE],
                                PROG_KEY_TITLE: [LocalizationManager getStringFromStrId:PROG_DAILY_CALS_TITLE],
                                PROG_KEY_X_RANGE_DATE_MIN:fromDate,
                                PROG_KEY_X_RANGE_DATE_MAX:[NSDate date],
                                PROG_KEY_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph],
                                PROG_KEY_X_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph * intervalCtl],
                                PROG_KEY_Y_RANGE_MIN:dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MIN],
                                PROG_KEY_Y_RANGE_MAX:dailyCaloriesYAxisInfo[PROG_KEY_Y_RANGE_MAX],
                                PROG_KEY_Y_INTERVAL:dailyCaloriesYAxisInfo[PROG_KEY_Y_INTERVAL]
                                };
    
    [self performSegueWithIdentifier:@"progressDetailSegue" sender:graphInfo];
}

- (void)didTapBloodGlucoseGraph:(UITapGestureRecognizer *)sender {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    NSDate *fromDate = [self fromDateWithTimeInterval:intervalType];
    
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:intervalType];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *dailyFastBGYAxisInfo = [self dailyFastBGYAxisInfo];
    
    NSDictionary *graphInfo = @{PROG_KEY_DATA: self.dataDictForBloodGlucose,
                                PROG_KEY_TYPE: [NSNumber numberWithInteger:PROG_BG_FAST_TYPE],
                                PROG_KEY_TITLE: [LocalizationManager getStringFromStrId:PROG_BG_FAST_TITLE],
                                PROG_KEY_X_RANGE_DATE_MIN:fromDate,
                                PROG_KEY_X_RANGE_DATE_MAX:[NSDate date],
                                PROG_KEY_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph],
                                PROG_KEY_X_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph * intervalCtl],
                                PROG_KEY_Y_RANGE_MIN:dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MIN],
                                PROG_KEY_Y_RANGE_MAX:dailyFastBGYAxisInfo[PROG_KEY_Y_RANGE_MAX],
                                PROG_KEY_Y_INTERVAL:dailyFastBGYAxisInfo[PROG_KEY_Y_INTERVAL]
                                };
    
    [self performSegueWithIdentifier:@"progressDetailSegue" sender:graphInfo];
}

- (void)didTapWeightGraph:(UITapGestureRecognizer *)sender {
    TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
    NSDate *fromDate = [self fromDateWithTimeInterval:intervalType];
    
    NSDictionary *dateIntervals = [self dateIntervalsWithTimeInterval:intervalType];
    double timeIntervalForGraph = [dateIntervals[PROG_KEY_TIME_INTV_FOR_GRAPH] doubleValue];
    NSInteger intervalCtl = [dateIntervals[PROG_KEY_INTV_CTL] integerValue];
    
    NSDictionary *weightYAxisInfo = [self weightYAxisInfo];
    
    NSDictionary *graphInfo = @{PROG_KEY_DATA: self.dataDictForWeight,
                                PROG_KEY_TYPE: [NSNumber numberWithInteger:PROG_WEIGHT_TYPE],
                                PROG_KEY_TITLE: [LocalizationManager getStringFromStrId:PROG_WEIGHT_TITLE],
                                PROG_KEY_X_RANGE_DATE_MIN:fromDate,
                                PROG_KEY_X_RANGE_DATE_MAX:[NSDate date],
                                PROG_KEY_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph],
                                PROG_KEY_X_DATE_INTERVAL:[NSNumber numberWithDouble:timeIntervalForGraph * intervalCtl],
                                PROG_KEY_Y_RANGE_MIN:weightYAxisInfo[PROG_KEY_Y_RANGE_MIN],
                                PROG_KEY_Y_RANGE_MAX:weightYAxisInfo[PROG_KEY_Y_RANGE_MAX],
                                PROG_KEY_Y_INTERVAL:weightYAxisInfo[PROG_KEY_Y_INTERVAL]
                                };
    
    [self performSegueWithIdentifier:@"progressDetailSegue" sender:graphInfo];
}

#pragma mark - UIGestureRecognizerDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // if the Menu is being shown then the gesture recognizers in this VC should
    // not handle any touches
    if (self.revealViewController.frontViewPosition == FrontViewPositionLeft) {
        return YES;
    }
    return NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"progressDetailSegue"]) {
        UINavigationController *destVC = [segue destinationViewController];
        ProgressDetailController *progressDetailVC = (ProgressDetailController *)destVC.viewControllers.firstObject;
        TimeIntervalType intervalType = (TimeIntervalType)self.dateSegmentedControl.selectedSegmentIndex;
        
        [progressDetailVC plotWithInfo:(NSDictionary *)sender intervalType:intervalType];
    }
}

-(void)popOnLineLogBook{
    UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:([GGUtils getAppType] == AppTypeGlucoGuide ? @"https://myaccount.glucoguide.com" : @"https://myaccount.glucoguide.com/#!/signin_ghn")];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - Social Share Button
- (IBAction)btnShare:(id)sender {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Share"]
                                                          message:[LocalizationManager getStringFromStrId:@"Graph to Share?"]
                                                   preferredStyle:UIAlertControllerStyleActionSheet];
   
    UIAlertAction *calories = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Daily Calories Balance"]
                                             style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action) {
                                               if (self.dailyCaloriesGraph) {
                                                   [self getScreenShot:[LocalizationManager getStringFromStrId:@"Daily Calories Balance"] usingGraph:self.dailyCaloriesGraph];
                                               }
                                           }];
    
    UIAlertAction *mealScore = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Average Meal Score"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (self.averageMealScoreGraph) {
                                                             [self getScreenShot:[LocalizationManager getStringFromStrId:@"Average Meal Score"] usingGraph:self.averageMealScoreGraph];
                                                         }
                                                     }];
    
    UIAlertAction *exercise = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Exercise Minutes"]
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          if (self.exerciseMinutesGraph) {
                                                              [self getScreenShot:[LocalizationManager getStringFromStrId:@"Exercise Minutes"] usingGraph:self.exerciseMinutesGraph];
                                                          }
                                                      }];
    
    UIAlertAction *bg = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:@"Blood Glucose"]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (self.bloodGlucoseGraph) {
                                                             [self getScreenShot:[LocalizationManager getStringFromStrId:@"Blood Glucose"] usingGraph:self.bloodGlucoseGraph];
                                                         }
                                                     }];
    
    UIAlertAction *weight = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_WEIGHT]
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action) {
                                                         if (self.weightGraph != nil) {
                                                             [self getScreenShot:[LocalizationManager getStringFromStrId:MSG_WEIGHT] usingGraph:self.weightGraph];
                                                         }
                                                     }];
    
    
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             // do something here
                                         }];
    
    [alertController addAction:calories];
    [alertController addAction:mealScore];
    [alertController addAction:exercise];
    [alertController addAction:bg];
    [alertController addAction:weight];
    [alertController addAction:otherAction];
    
    [alertController setModalPresentationStyle:UIModalPresentationPopover];
    
    alertController.popoverPresentationController.barButtonItem = self.btnShare;
    alertController.popoverPresentationController.sourceView = self.view;
 
    [self presentViewController:alertController animated:YES completion:nil];
    
}

#pragma mark - Social Post Methods / activityViewController
-(void)activityViewController:(UIImage *)image{
    
    UIViewController *topViewController = [self topViewController];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[ image ] applicationActivities:nil];
    [topViewController presentViewController:controller animated:YES completion:nil];
    
}

-(UIViewController *)topViewController
{
    // Returns the currently visible ViewController, including active modal ViewControllers.
    NSAssert([UIApplication sharedApplication].keyWindow, @"Application should have a key window");
    NSAssert([UIApplication sharedApplication].keyWindow.rootViewController, @"Window should have a root view controller");
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

-(UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    }
    return rootViewController;
}


-(void)getScreenShot:(NSString *)graphTitle usingGraph:(GGPlot*)graph {
    
    UIImage *backgroundImage = [graph graphImage];
    UIImage *watermarkImage = [UIImage imageNamed:@"socialLogo"];
    
    UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, backgroundImage.size.width, 40)];
    myLabel.font = [UIFont systemFontOfSize:20];
    myLabel.text = graphTitle;
    myLabel.textAlignment = NSTextAlignmentCenter;
    myLabel.minimumScaleFactor = 0.5;
    myLabel.adjustsFontSizeToFitWidth = YES;
    myLabel.backgroundColor = [UIColor clearColor];

    UIGraphicsBeginImageContext(backgroundImage.size);
    [backgroundImage drawInRect:CGRectMake(0, 0, backgroundImage.size.width, backgroundImage.size.height)];
    [watermarkImage drawInRect:CGRectMake((backgroundImage.size.width + 10 - watermarkImage.size.width/2) / 2, (backgroundImage.size.height - watermarkImage.size.height/2) /2, watermarkImage.size.width/2, watermarkImage.size.height/2)];
    [[myLabel layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self activityViewController:finalImage];
}


@end
