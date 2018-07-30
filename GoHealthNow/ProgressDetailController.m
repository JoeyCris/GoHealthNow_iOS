//
//  ProgressDetailController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ProgressDetailController.h"
#import "StyleManager.h"

#pragma mark - OnlyLandscapeNavigationController

@interface OnlyLandscapeNavigationController : UINavigationController

@end

// Used in the Storyboard by the NavigationController that holds
// ProgressDetailController
@implementation OnlyLandscapeNavigationController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end

#pragma mark - ProgressDetailController

@interface ProgressDetailController ()

@property (strong, nonatomic) IBOutlet GGPlot *graph;
@property (nonatomic) NSDictionary *graphInfo;
@property (nonatomic) BOOL graphLoaded;
@property (nonatomic) BOOL isDateGraph;

@end

@implementation ProgressDetailController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
}

- (void)didReceiveMemoryWarning {
    self.graph = nil;
    self.graphLoaded = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.graph) {
        self.graph = [[GGPlot alloc] init];
    }
    
    [self.graph updateFrameWithFrame:self.graph.frame];
    
    if (self.graphLoaded)
    {
        if (self.isDateGraph) {
            [self.graph reloadCorePlotWithData:self.graphInfo[PROG_KEY_DATA]
                                     forType:(GraphType)[self.graphInfo[PROG_KEY_TYPE] integerValue]
                                    graphTitle:self.graphInfo[PROG_KEY_TITLE]
                              graphDisplayMode:GraphModeLandscape
                                 xRangeDateMin:self.graphInfo[PROG_KEY_X_RANGE_DATE_MIN]
                                 xRangeDateMax:self.graphInfo[PROG_KEY_X_RANGE_DATE_MAX]
                                  dateInterval:[self.graphInfo[PROG_KEY_DATE_INTERVAL] doubleValue]
                             xAxisDateInterval:[self.graphInfo[PROG_KEY_X_DATE_INTERVAL] doubleValue]
                                     yRangeMin:[self.graphInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                     yRangeMax:[self.graphInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                                 yAxisInterval:[self.graphInfo[PROG_KEY_Y_INTERVAL] floatValue]
                                     reloadNow:YES];
            
        }
        else {
            [self.graph reloadCorePlotWithData:self.graphInfo[PROG_KEY_DATA]
                                       forType:(GraphType)[self.graphInfo[PROG_KEY_TYPE] integerValue]
                                    graphTitle:self.graphInfo[PROG_KEY_TITLE]
                              graphDisplayMode:GraphModeLandscape
                                     xRangeMin:[self.graphInfo[PROG_KEY_X_RANGE_MIN] floatValue]
                                     xRangeMax:[self.graphInfo[PROG_KEY_X_RANGE_MAX] floatValue]
                                 xAxisInterval:[self.graphInfo[PROG_KEY_X_INTERVAL] floatValue]
                                     yRangeMin:[self.graphInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                     yRangeMax:[self.graphInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                                 yAxisInterval:[self.graphInfo[PROG_KEY_Y_INTERVAL] floatValue]
                                     reloadNow:YES];
        }
    }
    else {
        if (self.isDateGraph) {
            [self.graph initCorePlotWithData:self.graphInfo[PROG_KEY_DATA]
                                     forType:(GraphType)[self.graphInfo[PROG_KEY_TYPE] integerValue]
                                  graphTitle:self.graphInfo[PROG_KEY_TITLE]
                            graphDisplayMode:GraphModeLandscape
                               xRangeDateMin:self.graphInfo[PROG_KEY_X_RANGE_DATE_MIN]
                               xRangeDateMax:self.graphInfo[PROG_KEY_X_RANGE_DATE_MAX]
                                dateInterval:[self.graphInfo[PROG_KEY_DATE_INTERVAL] doubleValue]
                           xAxisDateInterval:[self.graphInfo[PROG_KEY_X_DATE_INTERVAL] doubleValue]
                                   yRangeMin:[self.graphInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                   yRangeMax:[self.graphInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                               yAxisInterval:[self.graphInfo[PROG_KEY_Y_INTERVAL] floatValue]];
            
        }
        else {
            [self.graph initCorePlotWithData:self.graphInfo[PROG_KEY_DATA]
                                     forType:(GraphType)[self.graphInfo[PROG_KEY_TYPE] integerValue]
                                  graphTitle:self.graphInfo[PROG_KEY_TITLE]
                            graphDisplayMode:GraphModeLandscape
                                   xRangeMin:[self.graphInfo[PROG_KEY_X_RANGE_MIN] floatValue]
                                   xRangeMax:[self.graphInfo[PROG_KEY_X_RANGE_MAX] floatValue]
                               xAxisInterval:[self.graphInfo[PROG_KEY_X_INTERVAL] floatValue]
                                   yRangeMin:[self.graphInfo[PROG_KEY_Y_RANGE_MIN] floatValue]
                                   yRangeMax:[self.graphInfo[PROG_KEY_Y_RANGE_MAX] floatValue]
                               yAxisInterval:[self.graphInfo[PROG_KEY_Y_INTERVAL] floatValue]];
        }
        
    }

    
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (void)plotWithInfo:(NSDictionary *)graphInfo intervalType:(TimeIntervalType)timeInterval {
    self.isDateGraph = [graphInfo objectForKey:PROG_KEY_X_RANGE_DATE_MIN] != nil;
    
    if (self.isDateGraph) {
        if (timeInterval == TimeIntervalTypeWeek) {
            self.navigationController.navigationBar.topItem.title = [LocalizationManager getStringFromStrId:@"Weekly Breakdown"];
        }
        else {
            self.navigationController.navigationBar.topItem.title = [LocalizationManager getStringFromStrId:@"Monthly Breakdown"];
        }
    }
    
    self.graphInfo = graphInfo;
}

@end
