//
//  UserSetupFirstControllerProtocol.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-04.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UserSetupFirstControllerDelegate <NSObject>

- (void)firstControllerDidContinue:(id)sender;
- (void)firstControllerDidSkip:(id)sender;

@end
