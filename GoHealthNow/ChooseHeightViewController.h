//
//  ChooseHeightViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseHeightDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseHeightViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseHeightDelegate> delegate;
@property (nonatomic) LengthUnit *initialHeight;
@property (nonatomic) MeasureUnit unitMode;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@property (nonatomic) BOOL verifyHeight;

@end
