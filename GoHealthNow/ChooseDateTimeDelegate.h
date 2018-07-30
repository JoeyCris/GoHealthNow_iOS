//
//  ChooseDateTimeDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-15.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChooseDateTimeDelegate <NSObject>

- (void)didChooseDateTime:(NSDate *)dateTime sender:(id)sender;

@end
