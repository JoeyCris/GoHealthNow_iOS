//
//  UIView+Extensions.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReminderCard.h"
#import "SlideInCardBaseView.h"

@protocol SlideInPopupDelegate <NSObject>

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer;
@optional
- (void)slideInPopupDidChooseCancel;

@end

@interface UIView (Extensions)

#pragma mark - Activity Indicator

- (void)showActivityIndicatorWithMessage:(NSString *)message;
- (void)hideActivityIndicator;

-(void)showActivityIndicatorForExerciseUpdateWithMessage:(NSString *)message;
-(void)hideActivityIndicatorExerciseUpdate;

- (void)showActivityIndicatorWithNetworkIndicatorOnWithMessage:(NSString *)message;
- (void)hideActivityIndicatorWithNetworkIndicatorOff;

#pragma mark - Background Mask

- (void)toggleBackgroundMaskDisplayBelowSubview:(UIView *)subview;

#pragma mark - Slide In Popup

// slides in popup from the bottom
- (void)slideInPopupWithTitle:(NSString *)title
                withComponent:(UIView *)componentView
                 withDelegate:(id<SlideInPopupDelegate>)delegate;
- (void)slideOutPopup;
// This static method finds the component view within the popup's view hierarchy.
// This is meant for use in tandem with the slideInPopupDidChooseDone: delegate method
+ (UIView *)slideInPopupComponentViewWithTag:(NSUInteger)tag
                       withGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

///

// slides in popup from bottom but above the keyboard
- (void)slideInPopupForNotesWithTitle:(NSString *)title
                withComponent:(UIView *)componentView
                 withDelegate:(id<SlideInPopupDelegate>)delegate;


#pragma mark - Help Tips

@end