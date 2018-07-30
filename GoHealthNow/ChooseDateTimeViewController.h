//
//  ChooseDateTimeViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-15.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChooseDateTimeDelegate.h"

@interface ChooseDateTimeViewController : UIViewController

@property (nonatomic) NSDate *initialDate;
@property (nonatomic) UIDatePickerMode mode;
@property (nonatomic) id<ChooseDateTimeDelegate> delegate;

@end
