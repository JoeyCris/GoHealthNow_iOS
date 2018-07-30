//
//  SearchFoodController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-04.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodSummaryViewController.h"

@interface SearchFoodController : UITableViewController

@property (nonatomic) id<FoodSummaryDelegate> delegate;

@end
