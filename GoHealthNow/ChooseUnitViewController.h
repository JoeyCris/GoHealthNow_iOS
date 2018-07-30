//
//  ChooseGlucoseUnitViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseUnitDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseUnitViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseUnitDelegate> delegate;
@property (nonatomic) NSUInteger initialUnit; // the enum int value of BGUnit or MeasureUnit
@property (nonatomic) UnitViewControllerDisplayMode displayMode;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end
