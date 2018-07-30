//
//  StyleManager.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-05.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"

@implementation StyleManager

#pragma mark - Methods

+ (void)styleMainView:(UIView *)view {
    view.backgroundColor = [UIColor backgroundColor];
}

+ (void)styleButton:(UIButton *)button {
    button.contentEdgeInsets = UIEdgeInsetsMake(STYLE_TITLE_PADDING, STYLE_TITLE_PADDING, STYLE_TITLE_PADDING, STYLE_TITLE_PADDING); // padding for the title
    [self styleButtonWithoutContentEdgeInsets:button];
}

+ (void)styleButton:(UIButton *)button withContentEdgeInsets:(UIEdgeInsets)edgeInsets {
    button.contentEdgeInsets = edgeInsets;
    [self styleButtonWithoutContentEdgeInsets:button];
}

+ (void)styleButtonWithoutContentEdgeInsets:(UIButton *)button {
    button.layer.cornerRadius = 2.5;
    button.clipsToBounds = YES;
    button.backgroundColor = [UIColor buttonColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0]
                 forState:UIControlStateDisabled];
}

+ (void)styleTable:(UITableView *)table {
    table.backgroundColor = [UIColor backgroundColor];
    table.backgroundView.backgroundColor = [UIColor backgroundColor];
    table.separatorColor = [UIColor buttonColor];
    
    // hide empty table separators
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    v.backgroundColor = [UIColor clearColor];
    ((UITableView *)table).tableFooterView = v;
}

+ (void)stylelabel:(UILabel *)label {
    label.textColor = [UIColor textColor];
}

+ (void)styleTextView:(UITextView *)textView {
    textView.textColor = [UIColor textColor];
    textView.backgroundColor = [UIColor backgroundColor];
}

+ (void)addBorderToTextView:(UITextView *)textView {
    textView.layer.borderColor = [UIColor colorWithRed:229.0/255.0 green:229.0/255.0 blue:229.0/255.0 alpha:1.0].CGColor;
    textView.layer.borderWidth = 1.0;
    textView.layer.cornerRadius = 5;
}

+ (void)styleSwitch:(UISwitch *)uiswitch {
    uiswitch.onTintColor = [UIColor buttonColor];
}

+ (void)styleSegmentedControl:(UISegmentedControl *)segmentedControl {
    segmentedControl.tintColor = [UIColor buttonColor];
}

+ (void)styleNavigationBar:(UINavigationBar *)navBar {
    navBar.translucent = NO;
    navBar.barTintColor = [UIColor buttonColor];
    navBar.tintColor = [UIColor whiteColor];
    navBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
}

+ (void)styleTabBar:(UITabBar *)tabBar {
    tabBar.tintColor = [UIColor blueTextColor];
}

+ (void)styleTableCell:(UITableViewCell *)tableCell {
    tableCell.backgroundColor = [UIColor backgroundColor];
    tableCell.textLabel.textColor = [UIColor textColor];
    tableCell.detailTextLabel.textColor = [UIColor textColor];
}

+ (void)styleProgressView:(UIView *)progressView {
    progressView.layer.cornerRadius = 5.0;
    progressView.layer.masksToBounds = YES;
}

@end
