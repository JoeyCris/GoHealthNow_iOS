//
//  ChooseOrganizationCodeViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseOrganizationCodeDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

static NSUInteger const ACCESS_CODE_TAG_ACCESS_CODE = 2;

@interface ChooseOrganizationCodeViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseOrganizationCodeDelegate> delegate;
@property (nonatomic) NSString *initialOrganizationCode;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@property (nonatomic) BOOL initialSetupFromRegistration;


@end
