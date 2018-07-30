//
//  FoodSummaryDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FoodItem.h"

@protocol FoodSummaryDelegate <NSObject>

- (void)didAddFoodItem:(FoodItem *)foodItem sender:(id)sender;
- (void)didUpdateFoodItem:(FoodItem *)foodItem atIndex:(NSUInteger)index sender:(id)sender;
- (void)didDeleteFoodItem:(FoodItem *)foodItem atIndex:(NSUInteger)index sender:(id)sender;

@end
