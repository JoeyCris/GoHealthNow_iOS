//
//  WeightHelper.h
//  GlucoGuide
//
//  Created by Crul on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"
#import "WeightRecord.h"

@interface WeightHelper : NSObject

@property (nonatomic) MeasureUnit unitMode;
@property (nonatomic, readonly) UIPickerView *weightPickerView;
@property (nonatomic) WeightUnit *weight;

@end
