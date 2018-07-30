//
//  ChooseWeightViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseWeightDelegate.h"
#import "Constants.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseWeightViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseWeightDelegate> delegate;
@property (nonatomic) WeightUnit *initialWeight;
@property (nonatomic) MeasureUnit unitMode;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@property (nonatomic) BOOL verifyWeight;

@end
