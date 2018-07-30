//
//  ChooseUnitDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol ChooseUnitDelegate <NSObject>

- (void)didChooseUnit:(NSUInteger)unit withUnitMode:(UnitViewControllerDisplayMode)unitMode sender:(id)sender;

@end
