//
//  GraphConstants.h
//  plotDemo
//
//  Created by HoriKu on 2015-05-01.
//  Copyright (c) 2015 HoriKu. All rights reserved.
//

#ifndef plotDemo_GraphConstants_h
#define plotDemo_GraphConstants_h

typedef enum {
    SeriesTypeBar = 0,
    SeriesTypeLine
} SeriesType;
//typedef NSUInteger SeriesType;

typedef enum {
    GraphTypeBarLine = 0,
    GraphTypeTrendBarLine,
    GraphTypePie
} GraphType;
//typedef NSUInteger GraphType;

typedef enum {
    GraphModePortrait = 0,
    GraphModeLandscape
} GraphMode;
//typedef NSUInteger GraphMode;

static NSString *const GRAPH_DATA_DICT_ID_TYPE = @"graphType";
static NSString *const GRAPH_DATA_DICT_ID_SERIES = @"graphSeries";
static NSString *const GRAPH_DATA_DICT_ID_SERIES_BASELINES = @"graphSeriesBaselines";

static NSString *const SERIES_BASELINE_NAME = @"seriesBaselineName";
static NSString *const SERIES_BASELINE_COLOR = @"seriesBaselineColor";
static NSString *const SERIES_BASELINE_VALUE = @"seriesBaselineValue";

static NSString *const SERIES_DATA_DICT_ID_NAME = @"seriesName";
static NSString *const SERIES_DATA_DICT_ID_DATA = @"seriesData";
static NSString *const SERIES_DATA_DICT_ID_STYLE = @"seriesStyle";
static NSString *const SERIES_DATA_DICT_ID_TYPE = @"seriesType";

static NSString *const SERIES_STYLE_DICT_ID_SERIESCOLOR = @"seriesLineColor";
static NSString *const SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR = @"seriesPointColor";

static NSString *const TIME_FORMATTOR_SECOND = @"HH:mm:ss";
static NSString *const TIME_FORMATTOR_MINUTE = @"HH:mm";
static NSString *const TIME_FORMATTOR_HOUR = @"HH:mm";
static NSString *const TIME_FORMATTOR_DAY = @"MMM dd";
static NSString *const TIME_FORMATTOR_MONTH = @"yyyy MMM";
static NSString *const TIME_FORMATTOR_YEAR = @"yyyy";

static double const TIME_INTERVAL_SECOND = 1;
static double const TIME_INTERVAL_MINUTE = 1*60;
static double const TIME_INTERVAL_HOUR = 1*60*60;
static double const TIME_INTERVAL_DAY = 1*60*60*24;
static double const TIME_INTERVAL_MONTH = 1*60*60*24*30;   //Need to identify
static double const TIME_INTERVAL_YEAR = 1*60*60*24*30*12; //Need to identify

#endif
