//
//  QuickEstimateController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealRecord.h"

@protocol QuickEstimateDelegate <NSObject>

- (void)didCreateQuickEstimateMeal:(MealRecord *)quickEstimateMeal;

@end

@interface QuickEstimateController : UITableViewController

@property (nonatomic) id<QuickEstimateDelegate> delegate;

-(void)loadViewWithData:(NSArray *)data andMealType:(MealType)mt userEditAllowed:(BOOL)userEditEnabled;

@end
