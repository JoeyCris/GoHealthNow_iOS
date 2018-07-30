//
//  ChooseInsulinController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-03.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChooseInsulinDelegate <NSObject>

- (void)didUpdateUserProfileWithInsulin:(NSDictionary *)insulin sender:(id)sender;

@end

@interface ChooseInsulinController : UITableViewController

@property (nonatomic) id<ChooseInsulinDelegate> delegate;

@end
