//
//  ExerciseSummaryViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-02-04.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

@interface ExerciseSummaryViewController : UIViewController

+ (void)totalWeeklyMinutesInfoWithCompletionBlock:(void (^)(NSDictionary *weeklyMinutesInfo))completionBlock;

@property (strong, nonatomic) CMPedometer *pedometer0;
@property (strong, nonatomic) CMPedometer *pedometer1;

@end
