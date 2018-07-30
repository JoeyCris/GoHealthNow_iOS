//
//  StyleManager.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-05.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface StyleManager : NSObject

+ (void)styleMainView:(UIView *)view;
+ (void)styleButton:(UIButton *)button;
+ (void)styleButton:(UIButton *)button withContentEdgeInsets:(UIEdgeInsets)edgeInsets;
+ (void)styleButtonWithoutContentEdgeInsets:(UIButton *)button;
+ (void)styleTable:(UITableView *)table;
+ (void)stylelabel:(UILabel *)label;
+ (void)styleTextView:(UITextView *)textView;
+ (void)addBorderToTextView:(UITextView *)textView;
+ (void)styleSwitch:(UISwitch *)uiswitch;
+ (void)styleSegmentedControl:(UISegmentedControl *)segmentedControl;
+ (void)styleNavigationBar:(UINavigationBar *)navBar;
+ (void)styleTabBar:(UITabBar *)tabBar;
+ (void)styleTableCell:(UITableViewCell *)tableCell;
+ (void)styleProgressView:(UIView *)progressView;

@end
