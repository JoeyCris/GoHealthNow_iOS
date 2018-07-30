//
//  ChooseBMIAndWaistDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeightRecord.h"

@protocol ChooseBMIAndWaistDelegate <NSObject>

- (void)didChooseWaistSize:(LengthUnit *)waistSize sender:(id)sender;

@end
