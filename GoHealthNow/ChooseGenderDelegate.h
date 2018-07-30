//
//  ChooseGenderDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol ChooseGenderDelegate <NSObject>

- (void)didChooseGender:(GenderType)gender sender:(id)sender;

@end
