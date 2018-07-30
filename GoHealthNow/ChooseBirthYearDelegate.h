//
//  ChooseBirthYearDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChooseBirthYearDelegate <NSObject>

- (void)didChooseBirthYear:(NSDate *)date sender:(id)sender;

@end
