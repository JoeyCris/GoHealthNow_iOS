//
//  NutritionFactsGaugeController.h
//  GlucoGuide
//
//  Created by QuQi on 2016-06-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MealRecord.h"


@interface NutritionFactsGaugeController : UIViewController

-(void)loadViewWithData:(NSArray *)data andMealType:(MealType)mt userEditAllowed:(BOOL)userEditEnabled;
-(void)loadViewWithFibre:(float)fibre andSugar:(float)sugar;
@end
