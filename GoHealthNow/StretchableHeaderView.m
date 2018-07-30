//
//  StretchableHeaderView.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "StretchableHeaderView.h"

@interface UIPassThroughScrollView : UIScrollView
@end

@interface StretchableHeaderView()

@property (nonatomic, assign) CGFloat totalHeaderHeight;

@property (nonatomic) NSLayoutConstraint *stretchableHeaderLeadingContraint;
@property (nonatomic) NSLayoutConstraint *stretchableHeaderTrailingContraint;
@property (nonatomic) NSLayoutConstraint *stretchableHeaderHeightContraint;

@property (nonatomic) NSLayoutConstraint *scrollContentViewTopContraint;

@end

@implementation StretchableHeaderView

// TODO -- implement with TableView
//- (StretchableHeaderView *)initWithTableViewWithHeaderImage:(UIImage*)headerImage withOTCoverHeight:(CGFloat)height withTableViewStyle:(UITableViewStyle)TableViewStyle {
//    
//    CGRect bounds = [[UIScreen mainScreen] bounds];
//    self = [[StretchableHeaderView alloc] initWithFrame:bounds];
//    
//    self.headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
//    [self.headerImageView setImage:headerImage];
//    [self addSubview:self.headerImageView];
//    
//    self.OTCoverHeight = height;
//    
//    self.tableView = [[UITableView alloc] initWithFrame:self.frame style:TableViewStyle];
//    self.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
//    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)];
//    self.tableView.backgroundColor = [UIColor clearColor];
//    [self addSubview:self.tableView];
//    
//    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
//    
//    self.blurImages = [[NSMutableArray alloc] init];
//    [self prepareForBlurImages];
//    
//    return self;
//}

- (StretchableHeaderView *)initWithScrollViewWithView:(UIView *)header
                                            withHeight:(CGFloat)height
                           withScrollContentViewHeight:(CGFloat)contentViewHeight
                                     withTopViewHeight:(CGFloat)topViewHeight
{
    self = [[StretchableHeaderView alloc] init];
    
    if (topViewHeight > 0.0) {
        self.topView = [[UIView alloc] init];
        self.topView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.topView];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self.topView addConstraint:[NSLayoutConstraint constraintWithItem:self.topView
                                                            attribute:NSLayoutAttributeHeight
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:nil
                                                            attribute:NSLayoutAttributeHeight
                                                           multiplier:1.0
                                                             constant:topViewHeight]];
    }
    
    self.stretchableHeader = header;
    self.stretchableHeader.clipsToBounds = YES;
    self.stretchableHeader.contentMode = UIViewContentModeScaleAspectFill;
    self.stretchableHeader.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addSubview:self.stretchableHeader];
    
    self.stretchableHeaderLeadingContraint = [NSLayoutConstraint constraintWithItem:self.stretchableHeader
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1.0
                                                                         constant:0.0];
    self.stretchableHeaderTrailingContraint = [NSLayoutConstraint constraintWithItem:self.stretchableHeader
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:0.0];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.stretchableHeader
                                                    attribute:NSLayoutAttributeTop
                                                    relatedBy:NSLayoutRelationEqual
                                                       toItem:self
                                                    attribute:NSLayoutAttributeTop
                                                   multiplier:1.0
                                                      constant:topViewHeight]];

    self.stretchableHeaderHeightContraint = [NSLayoutConstraint constraintWithItem:self.stretchableHeader
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:height + topViewHeight];
    
    [self addConstraint:self.stretchableHeaderLeadingContraint];
    [self addConstraint:self.stretchableHeaderTrailingContraint];
    [self.stretchableHeader addConstraint:self.stretchableHeaderHeightContraint];
    
    self.totalHeaderHeight = height + topViewHeight;
    
    self.scrollView = [[UIPassThroughScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeLeading
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTrailing
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollView
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    
    self.scrollContentView = [[UIView alloc] init];
    self.scrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollContentView.backgroundColor = [UIColor whiteColor];
    self.scrollView.contentSize = self.scrollContentView.frame.size;
    [self.scrollView addSubview:self.scrollContentView];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0]];
    self.scrollContentViewTopContraint = [NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.scrollView
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1.0
                                                                       constant:0.0];
    [self.scrollView addConstraint:self.scrollContentViewTopContraint];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    _scrollContentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeHeight
                                                                     multiplier:1.0
                                                                       constant:contentViewHeight + topViewHeight];
    [self.scrollContentView addConstraint:_scrollContentViewHeightConstraint];
    
    [self.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:self.scrollContentView
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.scrollView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [self.scrollView addObserver:self
                      forKeyPath:@"contentOffset"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.scrollContentViewTopContraint.constant == 0.0) {
        self.scrollContentViewTopContraint.constant = self.stretchableHeader.frame.size.height + 1.0;
    }
}

//- (void)animationForTableView{
//    CGFloat offset = self.tableView.contentOffset.y;
//    
//    if (self.tableView.contentOffset.y > 0) {
//        
//        NSInteger index = offset / 10;
//        if (index < 0) {
//            index = 0;
//        }
//        else if(index >= self.blurImages.count) {
//            index = self.blurImages.count - 1;
//        }
//        UIImage *image = self.blurImages[index];
//        if (self.headerImageView.image != image) {
//            [self.headerImageView setImage:image];
//            
//        }
//        self.tableView.backgroundColor = [UIColor clearColor];
//        
//    }
//    else {
//        self.headerImageView.frame = CGRectMake(offset,0, self.frame.size.width+ (-offset) * 2, self.OTCoverHeight + (-offset));
//    }
//}

- (void)animationForScrollView {
    CGFloat offset = self.scrollView.contentOffset.y;
    
    if (self.scrollView.contentOffset.y > 0) {
        //        NSLog(@"y positive");
        //        NSInteger index = offset / 10;
        //        if (index < 0) {
        //            index = 0;
        //        }
        //        else if(index >= self.blurImages.count) {
        //            index = self.blurImages.count - 1;
        //        }
        //        UIImage *image = self.blurImages[index];
        //        if (self.headerImageView.image != image) {
        //            [self.headerImageView setImage:image];
        //
        //        }
        self.scrollView.backgroundColor = [UIColor clearColor];
        
    }
    else {
        self.stretchableHeaderLeadingContraint.constant = offset;
        self.stretchableHeaderTrailingContraint.constant = -offset;
        self.stretchableHeaderHeightContraint.constant = self.totalHeaderHeight + (-offset);
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (self.tableView) {
        //[self animationForTableView];
    }
    else {
        [self animationForScrollView];
    }
}

- (void)dealloc
{
    if (self.tableView) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
    else{
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

@end

@implementation UIPassThroughScrollView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    StretchableHeaderView *superView = (StretchableHeaderView *)self.superview;
    
    if (hitView == self) {
        // loop through the subviews of topView and stretchableHeader to see where the hit/gesture occurred.
        // if the hit/gesture occurred within one of these views then return nil so that the gesture recognizers of
        // these views can handle the hit/gesture instead of having the scroll view consume the hit/gesture
        for (UIView *topViewSubView in superView.topView.subviews) {
            if (topViewSubView.isUserInteractionEnabled &&
                [topViewSubView pointInside:[self convertPoint:point toView:topViewSubView] withEvent:event])
            {
                return nil;
            }
        }
        
        for (UIView *stretchableHeaderSubView in superView.stretchableHeader.subviews) {
            if (stretchableHeaderSubView.isUserInteractionEnabled &&
                [stretchableHeaderSubView pointInside:[self convertPoint:point toView:stretchableHeaderSubView] withEvent:event])
            {
                return nil;
            }
        }
    }
    
    return hitView;
}

@end