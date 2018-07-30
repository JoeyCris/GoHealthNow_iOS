//
//  UIView+Extensions.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "UIView+Extensions.h"
#import "UIColor+Extensions.h"

@implementation UIView (Extensions)

#pragma mark - Activity Indicator

const NSUInteger ACTIVITY_VIEW_WITH_MESSAGE_TAG = 333;
const NSUInteger POPUP_VIEW_FROM_BOTTOM_TAG = 334;
const NSUInteger BACKGROUND_MASK_TAG = 335;
const float POPUP_VIEW_HEIGHT = 300.0;
const float POPUP_TOP_BAR_VIEW_HEIGHT = 44.0;

- (void)showActivityIndicatorWithMessage:(NSString *)message
{
    UIView *activityViewWithMessage = [[UIView alloc] init];
    activityViewWithMessage.tag = ACTIVITY_VIEW_WITH_MESSAGE_TAG;
    activityViewWithMessage.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    activityViewWithMessage.clipsToBounds = YES;
    activityViewWithMessage.layer.cornerRadius = 10.0;
    activityViewWithMessage.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width, activityView.bounds.size.height);
    
    [activityViewWithMessage addSubview:activityView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 130, 22)];
    
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.text = message;
    
    [activityViewWithMessage addSubview:messageLabel];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:activityViewWithMessage];
    
    [activityViewWithMessage addConstraint:[NSLayoutConstraint
                                            constraintWithItem:activityViewWithMessage
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:NSLayoutRelationEqual
                                            toItem: nil
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                            constant:170]];
    
    [activityViewWithMessage addConstraint:[NSLayoutConstraint
                                            constraintWithItem:activityViewWithMessage
                                            attribute:NSLayoutAttributeHeight
                                            relatedBy:NSLayoutRelationEqual
                                            toItem: nil
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                            constant:170]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:activityViewWithMessage
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:window
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:activityViewWithMessage
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:window
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [activityView startAnimating];
}

- (void)hideActivityIndicator
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    
    for (UIWindow *window in windows) {
        UIView *activityViewWithMessage = [window viewWithTag:ACTIVITY_VIEW_WITH_MESSAGE_TAG];
        if (activityViewWithMessage) {
            [activityViewWithMessage removeFromSuperview];
            break;
        }
    }
}

- (void)showActivityIndicatorWithNetworkIndicatorOnWithMessage:(NSString *)message
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showActivityIndicatorWithMessage:message];
}

- (void)hideActivityIndicatorWithNetworkIndicatorOff
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideActivityIndicator];
}

#pragma mark - Background Mask

- (void)toggleBackgroundMaskDisplayBelowSubview:(UIView *)subview
{
    UIView *mask = [self viewWithTag:BACKGROUND_MASK_TAG];
    
    if (mask && !mask.isHidden) {
        // This is done because there seems to be a bug when using this with
        // UITableViewController and UITabBarController. Just calling removeFromSuperView
        // causes remenants of the mask to remain positioned just over the tab bar. Hiding it
        // and then removing it seems to work better.
        mask.hidden = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.05
                                         target:mask
                                       selector:@selector(removeFromSuperview)
                                       userInfo:nil
                                        repeats:NO];
    }
    else {
        UIView *mask = [[UIView alloc] init];
        mask.tag = BACKGROUND_MASK_TAG;
        mask.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
        mask.translatesAutoresizingMaskIntoConstraints = NO;
        mask.clipsToBounds = YES;
        
        if (subview) {
            [self insertSubview:mask belowSubview:subview];
        }
        else {
            [self addSubview:mask];
        }
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mask
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1.0
                                                          constant:0.0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:mask
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:0.0]];
    }
}

- (void)toggleBackgroundMaskDisplayForSlideInPopupBelowSubview:(UIView *)subview
                                                  withDelegate:(id<SlideInPopupDelegate>)delegate
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *mask = [window viewWithTag:BACKGROUND_MASK_TAG];
    
    if (mask && !mask.isHidden) {
        // This is done because there seems to be a bug when using this with
        // UITableViewController and UITabBarController. Just calling removeFromSuperView
        // causes remenants of the mask to remain positioned just over the tab bar. Hiding it
        // and then removing it seems to work better.
        mask.hidden = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.05
                                         target:mask
                                       selector:@selector(removeFromSuperview)
                                       userInfo:nil
                                        repeats:NO];
    }
    else {
        UIView *mask = [[UIView alloc] init];
        mask.tag = BACKGROUND_MASK_TAG;
        mask.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.7];
        mask.translatesAutoresizingMaskIntoConstraints = NO;
        mask.clipsToBounds = YES;
        
        [window insertSubview:mask belowSubview:subview];
        
        UITapGestureRecognizer *maskTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(slideOutPopup)];
        
        if ([delegate respondsToSelector:@selector(slideInPopupDidChooseCancel)]) {
            [maskTap addTarget:delegate action:@selector(slideInPopupDidChooseCancel)];
        }
        
        [mask addGestureRecognizer:maskTap];
        
        if (subview) {
            [window addConstraint:[NSLayoutConstraint constraintWithItem:mask
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:window
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1.0
                                                                constant:0.0]];
            [window addConstraint:[NSLayoutConstraint constraintWithItem:mask
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:window
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:1.0
                                                                constant:0.0]];
        }
    }
}

#pragma mark - Popup

- (void)slideInPopupWithTitle:(NSString *)title
                withComponent:(UIView *)componentView
                 withDelegate:(id<SlideInPopupDelegate>)delegate
{
    UIView *popupView = [[UIView alloc] init];
    popupView.tag = POPUP_VIEW_FROM_BOTTOM_TAG;
    popupView.backgroundColor = [UIColor backgroundColor];
    popupView.clipsToBounds = YES;
    popupView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    componentView.translatesAutoresizingMaskIntoConstraints = NO;
    [popupView addSubview:componentView];
    
    [self setupTopBarWithTitle:title forSlideInPopup:popupView withDelegate:delegate];
    [self setConstraintsForSlideInPopup:popupView ForComponent:componentView];
    
    [window addSubview:popupView];
    
    [self toggleBackgroundMaskDisplayForSlideInPopupBelowSubview:popupView withDelegate:delegate];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:popupView
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:window
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:popupView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:POPUP_VIEW_HEIGHT]];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:popupView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:window
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:POPUP_VIEW_HEIGHT];
    
    [window addConstraint:bottomConstraint];
    [window layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        bottomConstraint.constant = 0.0;
        [window layoutIfNeeded];
    }];
}
///
- (void)slideInPopupForNotesWithTitle:(NSString *)title
                withComponent:(UIView *)componentView
                 withDelegate:(id<SlideInPopupDelegate>)delegate
{
    UIView *popupView = [[UIView alloc] init];
    popupView.tag = POPUP_VIEW_FROM_BOTTOM_TAG;
    popupView.backgroundColor = [UIColor backgroundColor];
    popupView.clipsToBounds = YES;
    popupView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    componentView.translatesAutoresizingMaskIntoConstraints = NO;
    [popupView addSubview:componentView];
    
    [self setupTopBarWithTitle:title forSlideInPopup:popupView withDelegate:delegate];
    [self setConstraintsForSlideInNotePopup:popupView ForComponent:componentView];
    
    [window addSubview:popupView];
    
    [self toggleBackgroundMaskDisplayForSlideInPopupBelowSubview:popupView withDelegate:delegate];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:popupView
                                                       attribute:NSLayoutAttributeWidth
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:window
                                                       attribute:NSLayoutAttributeWidth
                                                      multiplier:1.0
                                                        constant:0.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:popupView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:150]];
    
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:popupView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:window
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:150];
    
    [window addConstraint:bottomConstraint];
    [window layoutIfNeeded];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        double keyboardHeight = 271;
        
        bottomConstraint.constant = -keyboardHeight;
        [window layoutIfNeeded];
    }];
}

- (void)setConstraintsForSlideInNotePopup:(UIView *)popupView ForComponent:(UIView *)componentView
{
    [componentView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:90]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:8.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-8.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:POPUP_TOP_BAR_VIEW_HEIGHT + 8.0]];
}

///

- (void)slideOutPopup {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UIView *popupView = [window viewWithTag:POPUP_VIEW_FROM_BOTTOM_TAG];
    NSLayoutConstraint *bottomConstraint = popupView.constraints.lastObject;
    
    [self toggleBackgroundMaskDisplayForSlideInPopupBelowSubview:popupView withDelegate:nil];
    [window layoutIfNeeded];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         bottomConstraint.constant = 0.0;
                         [window layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [popupView removeFromSuperview];
                     }];
}

- (void)setupTopBarWithTitle:(NSString *)title
             forSlideInPopup:(UIView *)popupView
                withDelegate:(id<SlideInPopupDelegate>)delegate
{
    UIView *popupTopBarView = [[UIView alloc] init];
    popupTopBarView.backgroundColor = [UIColor buttonColor];
    popupTopBarView.clipsToBounds = YES;
    popupTopBarView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILabel *topBarTitle = [[UILabel alloc] init];
    topBarTitle.text = title;
    topBarTitle.textColor = [UIColor whiteColor];
    topBarTitle.clipsToBounds = YES;
    topBarTitle.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *cancelButtonBackground = [[UIView alloc] init];
    cancelButtonBackground.userInteractionEnabled = YES;
    cancelButtonBackground.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIView *doneButtonBackground = [[UIView alloc] init];
    doneButtonBackground.userInteractionEnabled = YES;
    doneButtonBackground.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *cancelButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cancelIcon"]];
    cancelButton.clipsToBounds = YES;
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;

    UIImageView *doneButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
    doneButton.clipsToBounds = YES;
    doneButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    UITapGestureRecognizer *cancelButtonTap = [[UITapGestureRecognizer alloc] init];
    
    if ([delegate respondsToSelector:@selector(slideInPopupDidChooseCancel)]) {
        [cancelButtonTap addTarget:delegate action:@selector(slideInPopupDidChooseCancel)];
    }
    
    [cancelButtonTap addTarget:self action:@selector(slideOutPopup)];
    [cancelButtonBackground addGestureRecognizer:cancelButtonTap];
    
    UITapGestureRecognizer *doneButtonTap = [[UITapGestureRecognizer alloc]
                                             initWithTarget:delegate
                                             action:@selector(slideInPopupDidChooseDone:)];
    [doneButtonTap addTarget:self action:@selector(slideOutPopup)];
    [doneButtonBackground addGestureRecognizer:doneButtonTap];
    
    [popupTopBarView addSubview:cancelButtonBackground];
    [popupTopBarView addSubview:cancelButton];
    [popupTopBarView addSubview:topBarTitle];
    [popupTopBarView addSubview:doneButtonBackground];
    [popupTopBarView addSubview:doneButton];
    
    // cancel button background
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButtonBackground
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButtonBackground
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButtonBackground
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [cancelButtonBackground addConstraint:[NSLayoutConstraint constraintWithItem:cancelButtonBackground
                                                                       attribute:NSLayoutAttributeWidth
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeWidth
                                                                      multiplier:1.0
                                                                        constant:45.0]];
    // cancel button
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:cancelButton
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:8.0]];
    
    // top bar title
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:topBarTitle
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];

    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:topBarTitle
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    // done button background
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:doneButtonBackground
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:doneButtonBackground
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:doneButtonBackground
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [doneButtonBackground addConstraint:[NSLayoutConstraint constraintWithItem:doneButtonBackground
                                                                     attribute:NSLayoutAttributeWidth
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:nil
                                                                     attribute:NSLayoutAttributeWidth
                                                                    multiplier:1.0
                                                                      constant:45.0]];
    // done button
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:doneButton
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:doneButton
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:popupTopBarView
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:-8.0]];
    
    [popupView addSubview:popupTopBarView];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:popupView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupTopBarView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [popupTopBarView addConstraint:[NSLayoutConstraint constraintWithItem:popupTopBarView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:POPUP_TOP_BAR_VIEW_HEIGHT]];
}

- (void)setConstraintsForSlideInPopup:(UIView *)popupView ForComponent:(UIView *)componentView
{
    [componentView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:POPUP_VIEW_HEIGHT - POPUP_TOP_BAR_VIEW_HEIGHT - 16.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:8.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-8.0]];
    
    [popupView addConstraint:[NSLayoutConstraint constraintWithItem:componentView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:popupView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:POPUP_TOP_BAR_VIEW_HEIGHT + 8.0]];
}

+ (UIView *)slideInPopupComponentViewWithTag:(NSUInteger)tag
                       withGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    return [[[gestureRecognizer.view superview] superview] viewWithTag:tag];
}
////////////Exercise Popup//////
- (void)showActivityIndicatorForExerciseUpdateWithMessage:(NSString *)message
{
    UIView *activityViewWithMessage = [[UIView alloc] init];
    activityViewWithMessage.tag = ACTIVITY_VIEW_WITH_MESSAGE_TAG;
    activityViewWithMessage.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    activityViewWithMessage.clipsToBounds = YES;
    activityViewWithMessage.layer.cornerRadius = 10.0;
    activityViewWithMessage.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityView.frame = CGRectMake(65, 40, activityView.bounds.size.width + 40, activityView.bounds.size.height + 100);
    
    [activityViewWithMessage addSubview:activityView];
    
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 115, 170, 122)];  //20,115,130,22
    
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor whiteColor];
    messageLabel.adjustsFontSizeToFitWidth = YES;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    messageLabel.numberOfLines = 8;
    messageLabel.text = message;
    
    [activityViewWithMessage addSubview:messageLabel];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:activityViewWithMessage];
    
    [activityViewWithMessage addConstraint:[NSLayoutConstraint
                                            constraintWithItem:activityViewWithMessage
                                            attribute:NSLayoutAttributeWidth
                                            relatedBy:NSLayoutRelationEqual
                                            toItem: nil
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                            constant:210]];
    
    [activityViewWithMessage addConstraint:[NSLayoutConstraint
                                            constraintWithItem:activityViewWithMessage
                                            attribute:NSLayoutAttributeHeight
                                            relatedBy:NSLayoutRelationEqual
                                            toItem: nil
                                            attribute:NSLayoutAttributeWidth
                                            multiplier:1.0
                                            constant:270]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:activityViewWithMessage
                                                       attribute:NSLayoutAttributeCenterX
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:window
                                                       attribute:NSLayoutAttributeCenterX
                                                      multiplier:1.0
                                                        constant:0.0]];
    
    [window addConstraint:[NSLayoutConstraint constraintWithItem:activityViewWithMessage
                                                       attribute:NSLayoutAttributeCenterY
                                                       relatedBy:NSLayoutRelationEqual
                                                          toItem:window
                                                       attribute:NSLayoutAttributeCenterY
                                                      multiplier:1.0
                                                        constant:0.0]];
    
    [activityView startAnimating];
}

- (void)hideActivityIndicatorExerciseUpdate
{
    NSArray *windows = [UIApplication sharedApplication].windows;
    
    for (UIWindow *window in windows) {
        UIView *activityViewWithMessage = [window viewWithTag:ACTIVITY_VIEW_WITH_MESSAGE_TAG];
        if (activityViewWithMessage) {
            [activityViewWithMessage removeFromSuperview];
            break;
        }
    }
}
//////////

@end
