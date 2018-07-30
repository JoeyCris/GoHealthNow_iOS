//
//  AddMealRecordController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-10-23.
//  Copyright © 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealRecord.h"

@interface AddMealRecordController : UIViewController <UITextViewDelegate>

@property (nonatomic) MealRecord *meal;
@property (nonatomic, strong) UITextView *noteText;

- (void)addMealRecordForItemNotFound:(MealRecord *)meal;
- (void)addFoodItems:(NSArray *)foodItem;
- (void)didAddFoodItem:(FoodItem *)foodItem sender:(id)sender;

@end
