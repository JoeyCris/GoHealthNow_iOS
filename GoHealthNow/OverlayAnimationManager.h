//
//  OverlayAnimationManager.h
//  GlucoGuide
//
//  Created by Crul on 2015-08-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

enum {
    OverlayAnimationModePresent = 0,
    OverlayAnimationModeDismiss
};
typedef NSUInteger OverlayAnimationMode;

@interface OverlayAnimationManager : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithMode:(OverlayAnimationMode)mode;
- (instancetype)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options mode:(OverlayAnimationMode)mode;

// The duration of the transition. 0.5 by default
@property (nonatomic) NSTimeInterval duration;

// The options for the transition animation. Use this to change the type of animation. 0 by default
@property (nonatomic) UIViewAnimationOptions options;

@property (nonatomic) OverlayAnimationMode animationMode;

@end
