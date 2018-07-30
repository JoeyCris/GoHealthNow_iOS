//
//  ChooseBirthYearViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseBirthYearDelegate.h"
#import "UserSetupPageViewControllerProtocol.h"

@interface ChooseBirthYearViewController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<ChooseBirthYearDelegate> delegate;
@property (nonatomic) NSDate *initialDob;

@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

+ (NSUInteger)yearFromDate:(NSDate *)date;
+ (NSDate *)dateFromYearComponent:(NSUInteger) year;
+(NSUInteger)ageFromDate:(NSDate*)birthDay;

@end
