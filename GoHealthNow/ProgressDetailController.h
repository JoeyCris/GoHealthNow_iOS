//
//  ProgressDetailController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGPlot.h"
#import "Constants.h"

@interface ProgressDetailController : UIViewController

- (void)plotWithInfo:(NSDictionary *)graphInfo intervalType:(TimeIntervalType)timeInterval;

@end
