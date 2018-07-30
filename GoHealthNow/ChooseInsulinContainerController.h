//
//  ChooseInsulinContainerController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetupPageViewControllerProtocol.h"
#import "ChooseInsulinController.h"

@interface ChooseInsulinContainerController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseInsulinDelegate> delegate;
@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end