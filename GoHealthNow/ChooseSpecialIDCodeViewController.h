//
//  ChooseSpecialIDCodeViewController.h
//  GlucoGuide
//
//
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetupPageViewControllerProtocol.h"

static NSUInteger const ACCESS_CODE_TAG_ACCESS_CODE2 = 2;

@interface ChooseSpecialIDCodeViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) NSString *initialSpecialIDCode;
@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;
@property (nonatomic) BOOL initialSetupFromRegistration;


@end
