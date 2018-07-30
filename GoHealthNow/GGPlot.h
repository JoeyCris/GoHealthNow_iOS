//
//  GGPlot.h
//  plotDemo
//
//  Created by HoriKu on 2015-04-29.
//  Copyright (c) 2015 HoriKu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "GraphConstants.h"

@class CPTGraphHostingView;
@class CPTXYGraph;

@interface GGPlot : UIView<CPTPlotDataSource>

@property (nonatomic) CPTGraphHostingView *hostingView;
/*
{
 
{
 @"type": "bar/line",  <--- Enum (barLine, trendBarLine, pie)
 @"seriesBaseLines": {
    @"SeriesName": {
        @"Name" : NSString //Please make sure the Name is different with SeriesName(Key of this dict)
        @"Color" : UIColor
        @"Value" : Float
    }
 }
 @"series": [
    0: {
        "name": NSString
        "data": NSArray (2D),
         "style": {
            "seriesColor": UIColor,
            "seriesPointColor: UIColor
         },
        "type": "bar" <--- Enum (bar, line)
 
    },
    1:{
        "name": NSString
        "data": NSArray (2D),
        "style": "",
        "type": "line"
    },
  ]
 }


- (void)initCorePlotWithData:(NSDictionary *) data
                     forType:(ChartType) charType
                  graphTitle:(NSString *)graphTitle
                      xRange:(NSRange) xRange
               xAxisInterval:(float) xInterval
                      yRange:(NSRange) yRange
               yAxisInterval:(float) yInterval;
*/

- (void)initCorePlotWithData:(NSDictionary *) data
                     forType:(GraphType) graphType
                  graphTitle:(NSString *)graphTitle
            graphDisplayMode:(GraphMode) graphMode
                   xRangeMin:(float)xRangeMin
                   xRangeMax:(float)xRangeMax
               xAxisInterval:(float)xInterval
                   yRangeMin:(float)yRangeMin
                   yRangeMax:(float)yRangeMax
               yAxisInterval:(float)yInterval;

- (void)initCorePlotWithData:(NSDictionary *) data
                     forType:(GraphType) graphType
                  graphTitle:(NSString *)graphTitle
            graphDisplayMode:(GraphMode) graphMode
               xRangeDateMin:(NSDate *)xRangeMin
               xRangeDateMax:(NSDate *)xRangeMax
                dateInterval:(double)dateInterval
           xAxisDateInterval:(double)xInterval
                   yRangeMin:(float)yRangeMin
                   yRangeMax:(float)yRangeMax
               yAxisInterval:(float)yInterval;

- (void)reloadCorePlotWithData:(NSDictionary *) data
                     forType:(GraphType) graphType
                  graphTitle:(NSString *)graphTitle
            graphDisplayMode:(GraphMode) graphMode
                   xRangeMin:(float)xRangeMin
                   xRangeMax:(float)xRangeMax
               xAxisInterval:(float)xInterval
                   yRangeMin:(float)yRangeMin
                   yRangeMax:(float)yRangeMax
               yAxisInterval:(float)yInterval
                   reloadNow:(BOOL)reloadNow;

- (void)reloadCorePlotWithData:(NSDictionary *) data
                       forType:(GraphType) graphType
                    graphTitle:(NSString *)graphTitle
              graphDisplayMode:(GraphMode) graphMode
                 xRangeDateMin:(NSDate *)xRangeMin
                 xRangeDateMax:(NSDate *)xRangeMax
                  dateInterval:(double)dateInterval
             xAxisDateInterval:(double)xInterval
                     yRangeMin:(float)yRangeMin
                     yRangeMax:(float)yRangeMax
                 yAxisInterval:(float)yInterval
                     reloadNow:(BOOL)reloadNow;

- (void)reloadCorePlot;
- (void)updateFrameWithFrame:(CGRect)newFrame;
- (UIImage *)graphImage;


@property (nonatomic, readonly)   CPTXYGraph *graph;
@end
