//
//  ChooseGenderViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseGenderDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseGenderViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseGenderDelegate> delegate;
@property (nonatomic) GenderType initialGender;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end
