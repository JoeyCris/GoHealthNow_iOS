//
//  ChooseOrganizationCodeDelegate.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChooseOrganizationCodeDelegate <NSObject>

- (void)didChooseOrganizationCode:(NSString *)code sender:(id)sender;

@end
