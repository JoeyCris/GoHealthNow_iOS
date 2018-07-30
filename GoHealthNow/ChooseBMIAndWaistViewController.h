//
//  ChooseBMIAndWaistViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseBMIAndWaistDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"
#import "WeightRecord.h"
#import "Constants.h"

@interface ChooseBMIAndWaistViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseBMIAndWaistDelegate> delegate;
@property (nonatomic) LengthUnit *initialWaistSize;
@property (nonatomic) MeasureUnit unitMode;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end
