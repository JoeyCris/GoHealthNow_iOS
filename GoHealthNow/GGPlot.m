//
//  GGPlot.m
//  plotDemo
//
//  Created by HoriKu on 2015-04-29.
//  Copyright (c) 2015 HoriKu. All rights reserved.
//

#import "GGPlot.h"
#import "GGPlotTheme.h"
#import "Constants.h"

@interface GGPlot ()

@property (nonatomic)   CPTXYGraph *graph;
@property (nonatomic)   NSMutableArray *dataArrayForLine;
@property (nonatomic)   NSMutableArray *dataArrayForBar;
@property (nonatomic)   UILabel *titleLable;
@property (nonatomic)   UILabel *emptyDataLabel;

@property (nonatomic)   NSString *titleString;
@property (nonatomic)   NSArray *graphData;
@property (nonatomic)   NSDictionary *baseLines;
@property (nonatomic)   NSUInteger graphType;
@property (nonatomic)   float xRangeMin;
@property (nonatomic)   float xRangeMax;
@property (nonatomic)   float yRangeMin;
@property (nonatomic)   float yRangeMax;
@property (nonatomic)   float xAxisInterval;
@property (nonatomic)   float yAxisInterval;
@property (nonatomic)   NSDate *xRangeDateMin;
@property (nonatomic)   NSDate *xRangeDateMax;
@property (nonatomic)   NSTimeInterval dateInterval;
@property (nonatomic)   NSTimeInterval xAxisDateInterval;
@property (nonatomic)   NSMutableDictionary *plotIdentifiers;
@property (nonatomic)   NSMutableDictionary *baselineIdentifiers;
@property (nonatomic)   BOOL isDrawingBaselines;
@property (nonatomic)   GraphMode currDisplayMode;

@end

@implementation GGPlot

#pragma mark - Initialization && Methods

- (void)initCorePlotWithData:(NSDictionary *) data
                     forType:(GraphType) graphType
                  graphTitle:(NSString *)graphTitle
            graphDisplayMode:(GraphMode) graphMode
                   xRangeMin:(float)xRangeMin
                   xRangeMax:(float)xRangeMax
               xAxisInterval:(float)xInterval
                   yRangeMin:(float)yRangeMin
                   yRangeMax:(float)yRangeMax
               yAxisInterval:(float)yInterval{
    if (data == nil) {
        [self initializeEmptyPlotWithTitle:graphTitle];
        return;
    }
    
    self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    
    self.currDisplayMode = graphMode;
    
    self.plotIdentifiers = [[NSMutableDictionary alloc] init];
    self.baselineIdentifiers = [[NSMutableDictionary alloc] init];
    
    self.baseLines = [[NSDictionary alloc] init];
    self.baseLines = [[NSDictionary alloc] initWithDictionary:[data objectForKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES]];
    self.graphData = [data objectForKey:GRAPH_DATA_DICT_ID_SERIES];
    self.graphType = [[data objectForKey:GRAPH_DATA_DICT_ID_TYPE] integerValue];
    if (self.graphType != GraphTypePie) { //bar / line type
        self.xRangeMin = xRangeMin+0.5;
        self.xRangeMax = xRangeMax-0.5;
        self.xAxisInterval = xInterval;
        self.yRangeMin = yRangeMin;
        self.yRangeMax = yRangeMax;
        self.yAxisInterval = yInterval;
        
        self.titleString = graphTitle;
    }
    else {  // pie type
        
    }
    
    if ([self.graphData count] == 0) {
        [self initializeEmptyPlotWithTitle:graphTitle];
    }
    else {
        [self addSubview:self.hostingView];
        [self initializePlot];
    }
}

- (void)initCorePlotWithData:(NSDictionary *)data
                     forType:(GraphType) graphType
                  graphTitle:(NSString *)graphTitle
            graphDisplayMode:(GraphMode) graphMode
               xRangeDateMin:(NSDate *)xRangeMin
               xRangeDateMax:(NSDate *)xRangeMax
                dateInterval:(double)dateInterval
           xAxisDateInterval:(double)xInterval
                   yRangeMin:(float)yRangeMin
                   yRangeMax:(float)yRangeMax
               yAxisInterval:(float)yInterval{
    if (data == nil) {
        [self initializeEmptyPlotWithTitle:graphTitle];
        return;
    }
    
    self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
    
    self.currDisplayMode = graphMode;
    
    self.plotIdentifiers = [[NSMutableDictionary alloc] init];
    self.baselineIdentifiers = [[NSMutableDictionary alloc] init];
    
    self.baseLines = [[NSDictionary alloc] init];
    self.baseLines = [[NSDictionary alloc] initWithDictionary:[data objectForKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES]];
    self.graphData = [data objectForKey:GRAPH_DATA_DICT_ID_SERIES];
    self.graphType = [[data objectForKey:GRAPH_DATA_DICT_ID_TYPE] integerValue];

        self.xRangeDateMin = xRangeMin;
        self.xRangeDateMax = xRangeMax;
        self.xAxisDateInterval = xInterval;
        self.dateInterval = dateInterval;
        self.yRangeMin = yRangeMin;
        self.yRangeMax = yRangeMax;
        self.yAxisInterval = yInterval;
        
        self.titleString = graphTitle;

    [self timeFilter];
    
    if ([self.graphData count] == 0) {
        [self initializeEmptyPlotWithTitle:graphTitle];
    }
    else {
        [self addSubview:self.hostingView];
        [self initializePlot];
    }
}

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
                     reloadNow:(BOOL)reloadNow {
    BOOL redrawFlag = NO;
    if (self.xRangeMin!=xRangeMin || self.xRangeMax!=xRangeMax || self.xAxisInterval!=xInterval || self.yRangeMin!=yRangeMin || self.yRangeMax!=yRangeMax || self.yAxisInterval!=yInterval) {
        redrawFlag = YES;
    }
    
    [self.emptyDataLabel removeFromSuperview];
    if (self.titleLable.superview == self) {
        [self.titleLable removeFromSuperview];
        self.titleLable = nil;
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.hostingView.frame.size.height-30, self.hostingView.frame.size.width, 20.0)];
        [self.titleLable setTextColor:[UIColor darkGrayColor]];
        [self.titleLable setTextAlignment:NSTextAlignmentCenter];
        [self.titleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [self.titleLable setText:self.titleString];
        //   Reverse the label to make it suitbale for core-plot view
        self.titleLable.transform = CGAffineTransformMakeScale(1,-1);
        [self.hostingView addSubview:self.titleLable];
    }
    
    if (self.graphType == GraphTypeBarLine) {
        self.xRangeMin = xRangeMin+0.5;
        self.xRangeMax = xRangeMax-0.5;
        self.xAxisInterval = xInterval;
        
        self.yRangeMin = yRangeMin;
        self.yRangeMax = yRangeMax;
        self.yAxisInterval = yInterval;
    }
    else if (self.graphType == GraphTypePie) {
        
    }
    
    self.currDisplayMode = graphMode;
    
    self.titleString = graphTitle;
    
    self.plotIdentifiers = nil;
    self.baselineIdentifiers = nil;
    self.plotIdentifiers = [[NSMutableDictionary alloc] init];
    self.baselineIdentifiers = [[NSMutableDictionary alloc] init];
    
    self.graphData = [data objectForKey:GRAPH_DATA_DICT_ID_SERIES];
    self.graphType = [[data objectForKey:GRAPH_DATA_DICT_ID_TYPE] integerValue];
    
    self.baseLines = nil;
    self.baseLines = [[NSDictionary alloc] init];
    self.baseLines = [[NSDictionary alloc] initWithDictionary:[data objectForKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES]];
    
    for (int i=0;i<[self.graphData count];i++) {
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:self.graphData[i]];
        [self.plotIdentifiers setObject:[NSNumber numberWithInt:i] forKey:[tempDict objectForKey:SERIES_DATA_DICT_ID_NAME]];
    }
    //loop all the baselines of series first
    for (NSString *key in self.baseLines) {
        [self.baselineIdentifiers setObject:key forKey:[[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_NAME]];
    }
    
    if (self.graph == nil || redrawFlag) { //not initialized
        if (redrawFlag) {
            [self.hostingView removeFromSuperview];
            self.hostingView = nil;
        }
        self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
        [self addSubview:self.hostingView];
        [self initializePlot];
    }
    if (reloadNow){
        [self.titleLable setText:self.titleString];
        [self.graph reloadData];
    }
}

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
                     reloadNow:(BOOL)reloadNow
{
    BOOL redrawFlag = NO;
    if (![self.xRangeDateMax isEqual:xRangeMax] || ![self.xRangeDateMin isEqual:xRangeMin] || self.dateInterval!=dateInterval || self.xAxisDateInterval!=xInterval || self.yRangeMin!=yRangeMin || self.yRangeMax!=yRangeMax || self.yAxisInterval!=yInterval) {
        redrawFlag = YES;
    }
    
    [self.emptyDataLabel removeFromSuperview];
    if (self.titleLable.superview == self) {
        [self.titleLable removeFromSuperview];
        self.titleLable = nil;
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.hostingView.frame.size.height-30, self.hostingView.frame.size.width, 20.0)];
        [self.titleLable setTextColor:[UIColor darkGrayColor]];
        [self.titleLable setTextAlignment:NSTextAlignmentCenter];
        [self.titleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [self.titleLable setText:self.titleString];
        //   Reverse the label to make it suitbale for core-plot view
        self.titleLable.transform = CGAffineTransformMakeScale(1,-1);
        [self.hostingView addSubview:self.titleLable];
    }
    self.currDisplayMode = graphMode;

    self.xRangeDateMin = xRangeMin;
    self.xRangeDateMax = xRangeMax;
    self.xAxisDateInterval = xInterval;
    self.dateInterval = dateInterval;
    
    self.yRangeMin = yRangeMin;
    self.yRangeMax = yRangeMax;
    self.yAxisInterval = yInterval;
    
    self.titleString = graphTitle;
    
    [self timeFilter];
    
    self.plotIdentifiers = nil;
    self.baselineIdentifiers = nil;
    self.plotIdentifiers = [[NSMutableDictionary alloc] init];
    self.baselineIdentifiers = [[NSMutableDictionary alloc] init];
    
    self.graphData = [data objectForKey:GRAPH_DATA_DICT_ID_SERIES];
    self.graphType = [[data objectForKey:GRAPH_DATA_DICT_ID_TYPE] integerValue];
    
    self.baseLines = nil;
    self.baseLines = [[NSDictionary alloc] init];
    self.baseLines = [[NSDictionary alloc] initWithDictionary:[data objectForKey:GRAPH_DATA_DICT_ID_SERIES_BASELINES]];
    
    for (int i=0;i<[self.graphData count];i++) {
        NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:self.graphData[i]];
        [self.plotIdentifiers setObject:[NSNumber numberWithInt:i] forKey:[tempDict objectForKey:SERIES_DATA_DICT_ID_NAME]];
    }
    //loop all the baselines of series first
    for (NSString *key in self.baseLines) {
        [self.baselineIdentifiers setObject:key forKey:[[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_NAME]];
    }
    
    if (self.graph == nil || redrawFlag) { //not initialized
        if (redrawFlag) {
            [self.hostingView removeFromSuperview];
            self.hostingView = nil;
        }
        self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
        [self addSubview:self.hostingView];
        [self initializePlot];
    }
    if (reloadNow){
        [self.titleLable setText:self.titleString];
        [self.graph reloadData];
    }
}

- (void)reloadCorePlot {
    if (self.graph == nil) { //not initialized
//        if (redrawFlag) {
          //  [self.hostingView removeFromSuperview];
           // self.hostingView = nil;
//        }
      //  self.hostingView = [[CPTGraphHostingView alloc] initWithFrame:self.bounds];
        //[self addSubview:self.hostingView];
        [self initializePlot];
    }
    //if (reloadNow){
        //[self.titleLable setText:self.titleString];
        [self.graph reloadData];
    //}
}


- (void)updateFrameWithFrame:(CGRect)newFrame {
    self.hostingView.frame = CGRectMake(self.hostingView.frame.origin.x, self.hostingView.frame.origin.y, newFrame.size.width, newFrame.size.height);
    [self.emptyDataLabel setFrame:CGRectMake(0, self.hostingView.frame.size.height / 2 - 10, self.hostingView.frame.size.width, 20.0)];
    if (self.titleLable.superview == self) {
        [self.titleLable setFrame:CGRectMake(0, 30, self.hostingView.frame.size.width, 20.0)];
    }
    else {
        [self.titleLable setFrame:CGRectMake(0, self.hostingView.frame.size.height-30, self.hostingView.frame.size.width, 20.0)];
    }
}

- (void)timeFilter {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *dcXMax = [cal components:( NSCalendarUnitYear |
                                                NSCalendarUnitMonth |
                                                NSCalendarUnitDay |
                                                NSCalendarUnitHour |
                                                NSCalendarUnitMinute |
                                                NSCalendarUnitSecond )
                                      fromDate:self.xRangeDateMax];
    NSDateComponents *dcXMin = [cal components:( NSCalendarUnitYear |
                                                NSCalendarUnitMonth |
                                                NSCalendarUnitDay |
                                                NSCalendarUnitHour |
                                                NSCalendarUnitMinute |
                                                NSCalendarUnitSecond )
                                      fromDate:self.xRangeDateMin];
    [dcXMax setSecond:0];
    [dcXMax setMinute:0];
    [dcXMax setHour:18];
    
    [dcXMin setSecond:0];
    [dcXMin setMinute:0];
    [dcXMin setHour:18];
    
    self.xRangeDateMax = [cal dateFromComponents:dcXMax];
    self.xRangeDateMin = [cal dateFromComponents:dcXMin];
}


#pragma mark - Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if (plot.title == plot.identifier)
        return 2;
    
    return [[self.graphData[[[self.plotIdentifiers objectForKey:plot.identifier] intValue]] objectForKey:SERIES_DATA_DICT_ID_DATA] count];
}

- (void)initializeEmptyPlotWithTitle:(NSString *)titleString {
    //
    // Add the title label
    //
    //
    //
    //
    self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.hostingView.frame.size.width, 20.0)];
    [self.titleLable setTextColor:[UIColor darkGrayColor]];
    [self.titleLable setTextAlignment:NSTextAlignmentCenter];
    [self.titleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [self.titleLable setText:self.titleString];
    //   Reverse the label to make it suitbale for core-plot view
    [self addSubview:self.titleLable];
    
    self.emptyDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.hostingView.frame.size.height / 2 - 10, self.hostingView.frame.size.width, 20.0)];
    [self.emptyDataLabel setTextColor:[UIColor darkGrayColor]];
    [self.emptyDataLabel setTextAlignment:NSTextAlignmentCenter];
    [self.emptyDataLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.emptyDataLabel setText:[LocalizationManager getStringFromStrId:@"No Data"]];
    [self addSubview:self.emptyDataLabel];
}

- (void)initializePlot {
    if (self.graphType != GraphTypePie){  //line/bar type
        //
        //  Initialize the graph based on bounds and style
        //
        //
        //
        //
        CPTXYGraph *newGraph = [[CPTXYGraph alloc] initWithFrame:self.bounds];
        CPTTheme *theme = [[GGPlotTheme alloc] init];
        [newGraph applyTheme:theme];
        self.graph = newGraph;
        self.hostingView.hostedGraph = newGraph;
        
        //
        // Axes Set the axes' style
        //
        //
        //
        //
        if (self.graphType == GraphTypeBarLine) {
            float xAxisMin = self.xRangeMin-self.xAxisInterval;
            float xAxisMax = self.xRangeMax+self.xAxisInterval;
            float yAxisMin = self.yRangeMin;
            float yAxisMax = self.yRangeMax;
            
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xAxisMin) length:CPTDecimalFromFloat(xAxisMax - xAxisMin)];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisMin) length:CPTDecimalFromFloat(yAxisMax - yAxisMin)];
            
            //
            // Modify the graph‘s axis with a label, line style, etc.
            //
            //
            //
            //
            CPTXYAxisSet *axisSet                   = (CPTXYAxisSet *)self.graph.axisSet;
            // Set the number style
            NSNumberFormatter *labelFormatter       = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle              = NSNumberFormatterNoStyle;
            axisSet.xAxis.labelFormatter            = labelFormatter;
            axisSet.yAxis.labelFormatter            = labelFormatter;
            // Set the interval
            axisSet.xAxis.majorIntervalLength       = CPTDecimalFromFloat(self.xAxisInterval);
            axisSet.yAxis.majorIntervalLength       = CPTDecimalFromFloat(self.yAxisInterval);
            // Set the title
            axisSet.yAxis.title                     = @"";
            axisSet.xAxis.title                     = @"";
        }
        else{ //trend bar/line
            NSTimeInterval xAxisMin = [self.xRangeDateMin timeIntervalSinceReferenceDate];//-self.dateInterval*0.2;
            NSTimeInterval xAxisMax = [self.xRangeDateMax timeIntervalSinceReferenceDate];//+self.dateInterval*0.8;
            float yAxisMin = self.yRangeMin;
            float yAxisMax = self.yRangeMax;
            
            CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
            plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(xAxisMin) length:CPTDecimalFromDouble(xAxisMax - xAxisMin + self.xAxisDateInterval)];
            plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yAxisMin) length:CPTDecimalFromFloat(yAxisMax - yAxisMin)];
            
            //
            // Modify the graph‘s axis with a label, line style, etc.
            //
            //
            //
            //
            CPTXYAxisSet *axisSet                   = (CPTXYAxisSet *)self.graph.axisSet;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            if (self.dateInterval == TIME_INTERVAL_SECOND) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_SECOND];
            }
            else if (self.dateInterval == TIME_INTERVAL_MINUTE) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_MINUTE];
            }
            else if (self.dateInterval == TIME_INTERVAL_HOUR) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_HOUR];
            }
            else if (self.dateInterval == TIME_INTERVAL_DAY) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_DAY];
            }
            else if (self.dateInterval == TIME_INTERVAL_MONTH) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_MONTH];
            }
            else if (self.dateInterval == TIME_INTERVAL_YEAR) {
                [dateFormatter setDateFormat:TIME_FORMATTOR_YEAR];
            }
            
            CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
            axisSet.xAxis.labelFormatter = timeFormatter;
            CPTMutableTextStyle *textStyle          = [CPTMutableTextStyle textStyle];
            textStyle.fontName                      = @"Helvetica";
            textStyle.fontSize                      = 10;
            textStyle.color                         = [CPTColor darkGrayColor]; //Font color
            axisSet.xAxis.labelTextStyle = textStyle;
            
            // Set the number style
            NSNumberFormatter *labelFormatter       = [[NSNumberFormatter alloc] init];
            labelFormatter.numberStyle              = NSNumberFormatterNoStyle;
            axisSet.yAxis.labelFormatter            = labelFormatter;
            // Set the interval
            axisSet.xAxis.majorIntervalLength       = CPTDecimalFromFloat(self.xAxisDateInterval);
            axisSet.yAxis.majorIntervalLength       = CPTDecimalFromFloat(self.yAxisInterval);
            // Set the title
            axisSet.yAxis.title                     = @"";
            axisSet.xAxis.title                     = @"";
            
            if (self.currDisplayMode == GraphModeLandscape) {
                axisSet.xAxis.labelRotation = 0.6;
            } else if (self.currDisplayMode == GraphModePortrait) {
                axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyEqualDivisions;
                axisSet.xAxis.preferredNumberOfMajorTicks = 5;
                axisSet.xAxis.labelRotation = 0.0;
            }
        }
        
        self.isDrawingBaselines = YES;
        //loop all the baselines of series first
        for (NSString *key in self.baseLines) {
            //
            // Draw baseline
            //
            //
            //
            //
            [self.baselineIdentifiers setObject:key forKey:[[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_NAME]];
            CPTMutableLineStyle *lineStyleForBaseLine= [CPTMutableLineStyle lineStyle];
            lineStyleForBaseLine.lineColor           = [[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_COLOR];
            lineStyleForBaseLine.lineWidth           = 1.0f;
            CPTScatterPlot *baseLine = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
            baseLine.identifier = [[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_NAME];
            baseLine.dataSource = self;
            baseLine.cachePrecision = CPTPlotCachePrecisionDouble;
            baseLine.title = [[self.baseLines objectForKey:key] objectForKey:SERIES_BASELINE_NAME];
            baseLine.dataLineStyle = lineStyleForBaseLine;
            [newGraph addPlot:baseLine];
        }
        
        self.isDrawingBaselines = NO;
        //loop all the series
        for (int i=0;i<[self.graphData count];i++) {
            NSDictionary *tempDict = [[NSDictionary alloc] initWithDictionary:self.graphData[i]];
            [self.plotIdentifiers setObject:[NSNumber numberWithInt:i] forKey:[tempDict objectForKey:SERIES_DATA_DICT_ID_NAME]];
            if ([[tempDict objectForKey:SERIES_DATA_DICT_ID_TYPE] integerValue] == SeriesTypeLine) {
                // Create a line style that we will apply to the axis and data line.
                CPTMutableLineStyle *lineStyleForLinePlot = [CPTMutableLineStyle lineStyle];
                lineStyleForLinePlot.lineColor          = [[tempDict objectForKey:SERIES_DATA_DICT_ID_STYLE] objectForKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
                lineStyleForLinePlot.lineWidth          = 2.0f;
                
                CPTScatterPlot *dataSourceLinePlot      = [[CPTScatterPlot alloc] initWithFrame:newGraph.bounds];
                dataSourceLinePlot.identifier           = [tempDict objectForKey:SERIES_DATA_DICT_ID_NAME];
                dataSourceLinePlot.dataLineStyle        = lineStyleForLinePlot;
                dataSourceLinePlot.delegate             = self;
                dataSourceLinePlot.dataSource           = self;
                dataSourceLinePlot.cachePrecision       = CPTPlotCachePrecisionDouble;
                
                // Put an area gradient under the plot above
                CPTColor *areaColor       = [[tempDict objectForKey:SERIES_DATA_DICT_ID_STYLE] objectForKey:SERIES_STYLE_DICT_ID_SERIESCOLOR];
                CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor colorWithComponentRed:1 green:1 blue:1 alpha:0]];
                areaGradient.angle = -90.0f;
                CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
                dataSourceLinePlot.areaFill      = areaGradientFill;
                dataSourceLinePlot.areaBaseValue = [[NSDecimalNumber zero] decimalValue];
                
                CPTMutableLineStyle *symbolLineStyle    = [CPTMutableLineStyle lineStyle];
                symbolLineStyle.lineColor               = [[tempDict objectForKey:SERIES_DATA_DICT_ID_STYLE] objectForKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR];
                symbolLineStyle.lineWidth               = 2.0f;
                
                CPTPlotSymbol *plotSymbol               = [CPTPlotSymbol ellipsePlotSymbol];
                plotSymbol.fill                         = [CPTFill fillWithColor:[[tempDict objectForKey:SERIES_DATA_DICT_ID_STYLE] objectForKey:SERIES_STYLE_DICT_ID_SERIESPOINTCOLOR]];
                plotSymbol.lineStyle                    = symbolLineStyle;
                plotSymbol.size                         = CGSizeMake(5.0, 5.0);
                dataSourceLinePlot.plotSymbol           = plotSymbol;
                
                [newGraph addPlot:dataSourceLinePlot];
            }
            else if ([[tempDict objectForKey:SERIES_DATA_DICT_ID_TYPE] integerValue] == SeriesTypeBar) {
                CPTMutableLineStyle *lineStyleForBarPlot= [CPTMutableLineStyle lineStyle];
                lineStyleForBarPlot.lineWidth           = 0.0f;
                
                CPTBarPlot *dataSourceBarPlot           = [CPTBarPlot tubularBarPlotWithColor:[CPTColor whiteColor] horizontalBars:NO];
                dataSourceBarPlot.identifier            = [tempDict objectForKey:SERIES_DATA_DICT_ID_NAME];
                dataSourceBarPlot.baseValue             = CPTDecimalFromString(@"0");
                dataSourceBarPlot.dataSource            = self;
                dataSourceBarPlot.lineStyle             = lineStyleForBarPlot;
                dataSourceBarPlot.cornerRadius          = 2.0f;
                dataSourceBarPlot.barWidth              = CPTDecimalFromDouble(0.3*CPTDecimalDoubleValue(((CPTXYAxisSet *)self.graph.axisSet).xAxis.majorIntervalLength));
                dataSourceBarPlot.fill                  = [CPTFill fillWithColor:[[tempDict objectForKey:SERIES_DATA_DICT_ID_STYLE] objectForKey:SERIES_STYLE_DICT_ID_SERIESCOLOR]];
                [newGraph addPlot:dataSourceBarPlot];
            }
        }
        
        //
        // Add the title label
        //
        //
        //
        //
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, self.hostingView.frame.size.height-30, self.hostingView.frame.size.width, 20.0)];
        [self.titleLable setTextColor:[UIColor darkGrayColor]];
        [self.titleLable setTextAlignment:NSTextAlignmentCenter];
        [self.titleLable setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
        [self.titleLable setText:self.titleString];
        //   Reverse the label to make it suitbale for core-plot view
        self.titleLable.transform = CGAffineTransformMakeScale(1,-1);
        [self.hostingView addSubview:self.titleLable];
        
        self.graph.legend = [CPTLegend legendWithGraph:self.graph];
        self.graph.legend.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:1 green:1 blue:1 alpha:0]];
        self.graph.legendAnchor = CPTRectAnchorTop;
        self.graph.legendDisplacement = CGPointMake(0, -1.7*self.titleLable.frame.size.height);
        
    }
    else {  //pie type
        
    }
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    /*
    if (plot.title == plot.identifier && index == 1) {
        CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@              ", [[self.baseLines objectForKey:[self.baselineIdentifiers objectForKey:plot.identifier]] objectForKey:SERIES_BASELINE_VALUE]]];
        CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
        textStyle.textAlignment = NSTextAlignmentLeft;
        textStyle.color = [CPTColor orangeColor];
        label.textStyle = textStyle;
        return label;
    }
     */
    return nil;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if (self.graphType != GraphTypePie) {
        if (plot.title == plot.identifier){
            if (index == 0){
                if ( fieldEnum == CPTScatterPlotFieldX ) {
                    return self.graphType == GraphTypeTrendBarLine ?  [NSNumber numberWithDouble:[self.xRangeDateMin timeIntervalSinceReferenceDate]-CPTDecimalDoubleValue(((CPTXYAxisSet *)self.graph.axisSet).xAxis.majorIntervalLength)] : [NSNumber numberWithFloat:self.xRangeMin-CPTDecimalDoubleValue(((CPTXYAxisSet *)self.graph.axisSet).xAxis.majorIntervalLength)];
                }
                else{
                    return [[self.baseLines objectForKey:[self.baselineIdentifiers objectForKey:plot.identifier]] objectForKey:SERIES_BASELINE_VALUE];
                }
            }
            else {
                if ( fieldEnum == CPTScatterPlotFieldX ) {
                    return self.graphType == GraphTypeTrendBarLine ?  [NSNumber numberWithDouble:[self.xRangeDateMax timeIntervalSinceReferenceDate]+CPTDecimalDoubleValue(((CPTXYAxisSet *)self.graph.axisSet).xAxis.majorIntervalLength)] : [NSNumber numberWithFloat:self.xRangeMax+CPTDecimalDoubleValue(((CPTXYAxisSet *)self.graph.axisSet).xAxis.majorIntervalLength)];
                }
                else{
                    return [[self.baseLines objectForKey:[self.baselineIdentifiers objectForKey:plot.identifier]] objectForKey:SERIES_BASELINE_VALUE];
                }
            }
        }
        else {
            if ([[self.graphData[[[self.plotIdentifiers objectForKey:(NSString *)plot.identifier] integerValue]] objectForKey:SERIES_DATA_DICT_ID_DATA] count] == 0)
                return [NSNumber numberWithInt:0];
            NSArray *value = [[NSArray alloc] initWithArray:[self.graphData[[[self.plotIdentifiers objectForKey:(NSString *)plot.identifier] integerValue]] objectForKey:SERIES_DATA_DICT_ID_DATA][index]];
            CGPoint point;
            if (self.graphType == GraphTypeTrendBarLine) {
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:value[0]];
                
                if (![[components timeZone] isDaylightSavingTime]) {
                    //[components setDay:[components day] + 1];
                }
                
                if (self.dateInterval == TIME_INTERVAL_SECOND) {
                    // do nothing
                }
                else if (self.dateInterval == TIME_INTERVAL_MINUTE) {
                    [components setSecond:0];
                }
                else if (self.dateInterval == TIME_INTERVAL_HOUR) {
                    [components setSecond:0];
                    [components setMinute:0];
                }
                else if (self.dateInterval == TIME_INTERVAL_DAY) {
                    [components setSecond:0];
                    [components setMinute:0];
                    //NSTimeZone *tempTimeZone = [components timeZone];
                    [components setHour:18];// + ([tempTimeZone isDaylightSavingTime])? -1:0];//18
                    //NSLog(@"%d - H:%d", [components day], [components hour]);
                }
                else if (self.dateInterval == TIME_INTERVAL_MONTH) {
                    [components setSecond:0];
                    [components setMinute:0];
                    [components setHour:[[NSTimeZone defaultTimeZone] secondsFromGMT]/3600];
                    [components setDay:15];//15
                }
                else if (self.dateInterval == TIME_INTERVAL_YEAR) {
                    [components setSecond:0];
                    [components setMinute:0];
                    [components setHour:[[NSTimeZone defaultTimeZone] secondsFromGMT]/3600];
                    [components setDay:15];//15
                    [components setMonth:6];
                }
                point = CGPointMake([[cal dateFromComponents:components] timeIntervalSinceReferenceDate], [value[1] floatValue]);
            }
            else {
                point = CGPointMake([value[0] floatValue], [value[1] floatValue]);
            }
            
            // FieldEnum determines if we return an X or Y value.
            if ( fieldEnum == CPTScatterPlotFieldX ) {
                return [NSNumber numberWithDouble:point.x];
            }
            else { // Y-Axis
                //Auto resizing the y asix by maximum data
                {
                    if (point.y > self.yRangeMax) { //data is larger than y max then update it
                        self.yRangeMax = (int)(point.y/1000)*1000+1000;
                        self.yAxisInterval = ((int)(point.y/1000)*1000+1000)>=3000?1000:500;
                        CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)self.graph.defaultPlotSpace;
                        plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(self.yRangeMin) length:CPTDecimalFromFloat(self.yRangeMax - self.yRangeMin)];
                        
                        if (self.yAxisInterval/1000 > 8) {
                            self.yAxisInterval = (int)(self.yRangeMax/1000)*1000 / 5;
                            CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
                            axisSet.yAxis.majorIntervalLength = CPTDecimalFromFloat(self.yAxisInterval);
                        }
                    }
                }
                return [NSNumber numberWithFloat:point.y];
            }
        }
    }
    else {
        
    }
    return [NSNumber numberWithInt:0];
}

-(UIImage *)graphImage{
    UIImage *newImage = [self.graph imageOfLayer];
    return newImage;
}

@end
