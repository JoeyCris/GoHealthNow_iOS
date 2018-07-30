//
//  GGProgressView.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-02-10.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGProgressView : UIView

@property (nonatomic) NSString *text;
@property (nonatomic) UIColor *progressTintColor;
@property (nonatomic) float progress; // 0.0 .. 1.0, default is 0.0

- (void)updateTintColor:(UIColor *)color;
- (void)updateProgressTintColor:(UIColor *)color;

@end
