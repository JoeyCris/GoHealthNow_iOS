//
//  FoodLabelSelectionViewController.h
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-07.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FoodLabelSelectionViewController : UIViewController

- (void)loadFoodWithArray:(NSArray *)foodItems andSrcImage:(UIImage *)image andImageName:(NSString *)name;

@end
