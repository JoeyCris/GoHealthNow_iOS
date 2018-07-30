//
//  StretchableHeaderView.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StretchableHeaderView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView* scrollContentView;
@property (nonatomic, strong) UITableView* tableView;

@property (nonatomic, strong) UIView *stretchableHeader;
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, readonly) NSLayoutConstraint *scrollContentViewHeightConstraint;

- (StretchableHeaderView *)initWithScrollViewWithView:(UIView *)header
                                            withHeight:(CGFloat)height
                           withScrollContentViewHeight:(CGFloat)contentViewHeight
                                     withTopViewHeight:(CGFloat)topViewHeight;

@end
