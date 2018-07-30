//
//  ChooseConditionEthnicityViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseConditionEthnicityDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseConditionEthnicityViewController : UIViewController //<UserSetupPageViewControllerProtocol>

//@property (nonatomic) id<ConditionEthnicityYearDelegate> delegate;
@property (nonatomic) BOOL isUserSetupModeEnabled;

@end
