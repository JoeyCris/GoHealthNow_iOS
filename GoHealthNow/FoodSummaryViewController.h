//
//  FoodSummaryViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FoodItem.h"
#import "FoodSummaryDelegate.h"

@interface FoodSummaryViewController : UITableViewController

@property (nonatomic) FoodImageData *imageData;
@property (nonatomic, copy) NSArray<FoodItem *> *foodItems;
@property (nonatomic) id<FoodSummaryDelegate> delegate;
@property (nonatomic) NSInteger index;

@end
