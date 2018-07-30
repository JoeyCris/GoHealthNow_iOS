//
//  ChooseHeightDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@protocol ChooseHeightDelegate <NSObject>

- (void)didChooseHeight:(LengthUnit *)height sender:(id)sender;
@optional
- (void)doHeightViewReverse;

@end
