//
//  ChooseWeightDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeightRecord.h"

@protocol ChooseWeightDelegate <NSObject>

- (void)didChooseWeight:(WeightUnit *)weight sender:(id)sender;

- (void)doWeightViewReverse;

@end
