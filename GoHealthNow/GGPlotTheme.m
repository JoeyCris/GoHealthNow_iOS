//
//  GGPlotTheme.m
//  plotDemo
//
//  Created by HoriKu on 2015-04-28.
//  Copyright (c) 2015 HoriKu. All rights reserved.
//

#import "GGPlotTheme.h"

@implementation GGPlotTheme

#pragma mark -

- (void)applyThemeToBackground:(CPTGraph *)graph {
    
    //
    //  Using "kCPTPlainWhiteTheme" and filling the background with the clear color
    //  for customizing.
    //
    //
    //
    CPTTheme *theme                         = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [graph applyTheme:theme];
    
    graph.fill                              = [CPTFill fillWithColor:[CPTColor clearColor]];
    graph.plotAreaFrame.fill                = [CPTFill fillWithColor:[CPTColor clearColor]];
    
    //
    //  Set the border style and size
    //
    //
    //
    //
    CPTMutableLineStyle *borderLineStyle    = [CPTMutableLineStyle lineStyle];
    borderLineStyle.lineColor               = [CPTColor grayColor];
    borderLineStyle.lineWidth               = 0.0;
    graph.plotAreaFrame.borderLineStyle     = borderLineStyle;
    
    //
    //  Now we could customize the background view.
    //
    //
    //
    //
    //
    CPTGradient *graphGradient              = [CPTGradient gradientWithBeginningColor:[CPTColor colorWithComponentRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0] endingColor:[CPTColor colorWithComponentRed:240.0/255.0 green:240/255.0 blue:255/255.0 alpha:1.0]];
    graphGradient.angle                     = 90.0f;
    
    graph.fill                              = [CPTFill fillWithGradient:graphGradient];
    
    //
    //   Codes for controlling the margin
    //
    //
    //
    //
    graph.paddingRight                      = 20.0;
    graph.paddingLeft                       = 50.0;
    graph.paddingTop                        = 90.0;
    graph.paddingBottom                     = 50.0;
    graph.plotAreaFrame.masksToBorder       = NO;
    graph.cornerRadius                      = 10.0f;
}

- (void)applyThemeToAxisSet:(CPTXYAxisSet *)axisSet {
    //
    // Create a text style that we will use for the axis labels.
    //
    //
    //
    //
    CPTMutableTextStyle *textStyle          = [CPTMutableTextStyle textStyle];
    textStyle.fontName                      = @"Helvetica";
    textStyle.fontSize                      = 14;
    textStyle.color                         = [CPTColor darkGrayColor]; //Font color
    
    axisSet.xAxis.titleTextStyle            = textStyle;
    axisSet.xAxis.titleOffset               = 30;
    axisSet.xAxis.labelOffset               = 3;
    axisSet.xAxis.labelTextStyle            = textStyle;
    axisSet.xAxis.minorTicksPerInterval     = 1;
    axisSet.xAxis.minorTickLength           = 0;
    axisSet.xAxis.majorTickLength           = 7;
    
    axisSet.xAxis.axisConstraints           = [CPTConstraints constraintWithLowerOffset:0];
    
    
    axisSet.yAxis.orthogonalCoordinateDecimal  = CPTDecimalFromFloat(50);
    axisSet.yAxis.titleTextStyle            = textStyle;
    axisSet.yAxis.titleOffset               = 10;
    axisSet.yAxis.labelOffset               = 3;
    axisSet.yAxis.labelTextStyle            = textStyle;
    axisSet.yAxis.minorTicksPerInterval     = 1;
    axisSet.yAxis.minorTickLength           = 5;
    axisSet.yAxis.majorTickLength           = 7;
    axisSet.yAxis.axisConstraints           = [CPTConstraints constraintWithLowerOffset:0];
    
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth            = 1.0f;
    majorGridLineStyle.lineColor            = [CPTColor darkGrayColor];
    axisSet.yAxis.tickDirection             = CPTSignNegative;
    axisSet.yAxis.majorGridLineStyle        = majorGridLineStyle;
}

@end






