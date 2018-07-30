//
//  ChooseNameViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseNameDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

static NSUInteger const CHOOSE_NAME_TAG_FIRST_NAME = 1;
static NSUInteger const CHOOSE_NAME_TAG_LAST_NAME = 2;

@interface ChooseNameViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseNameDelegate> delegate;
@property (nonatomic) NSString *initialFirstName;
@property (nonatomic) NSString *initialLastName;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end
