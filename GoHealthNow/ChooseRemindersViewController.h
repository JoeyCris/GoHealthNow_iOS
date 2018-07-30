//
//  ChooseGlucoseUnitViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetupPageViewControllerProtocol.h"

@protocol RemindersDelegate <NSObject>
-(void)didSetReminder:(id)sender;
@end

@interface ChooseRemindersViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<RemindersDelegate> delegate;
@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;



@end
