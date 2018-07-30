//
//  UserSetupFirstViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetupPageViewControllerProtocol.h"
#import "UserSetupFirstControllerDelegate.h"

@interface UserSetupFirstViewController : UIViewController<UserSetupPageViewControllerProtocol, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) id<UserSetupFirstControllerDelegate> delegate;
@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end