//
//  CalorieDistributionController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserSetupPageViewControllerProtocol.h"

@protocol CalorieDistributionDelegate <NSObject>

- (void)didUpdateMealCalculator:(id)sender;

@end

@interface CalorieDistributionController : UIViewController<UserSetupPageViewControllerProtocol>

@property (nonatomic) id<CalorieDistributionDelegate> delegate;
@property (nonatomic) BOOL isUserSetupModeEnabled;
@property (nonatomic) NSUInteger userSetupPageIndex;

@end
