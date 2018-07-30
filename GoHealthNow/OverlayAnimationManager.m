//
//  OverlayAnimationManager.m
//  GlucoGuide
//
//  Created by Crul on 2015-08-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "OverlayAnimationManager.h"

@implementation OverlayAnimationManager

- (instancetype)init
{
    return [self initWithDuration:0.5 options:0 mode:OverlayAnimationModePresent];
}

- (instancetype)initWithMode:(OverlayAnimationMode)mode
{
    return [self initWithDuration:0.5 options:0 mode:mode];
}

- (instancetype)initWithDuration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options mode:(OverlayAnimationMode)mode
{
    self = [super init];
    if (self) {
        _duration = duration;
        _options = options;
        _animationMode = mode;
    }
    
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    if (_animationMode == OverlayAnimationModePresent) {
        //UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
        
        CGRect frame = containerView.bounds;
        //frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(40.0, 40.0, 200.0, 40.0));
        
        toViewController.view.frame = frame;
        
        [containerView addSubview:toViewController.view];
        
        //toViewController.view.alpha = 0.7;
        toViewController.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        toViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:duration / 2.0 animations:^{
            toViewController.view.alpha = 1.0;
        }];
        
        CGFloat damping = 0.55;
        
        [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:damping initialSpringVelocity:1.0 / damping options:0 animations:^{
            toViewController.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        // dismiss mode
        
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        NSTimeInterval duration = [self transitionDuration:transitionContext];
        
        [UIView animateWithDuration:3.0 * duration / 4.0
                              delay:duration / 4.0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             fromViewController.view.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [fromViewController.view removeFromSuperview];
                             [transitionContext completeTransition:YES];
                         }];
        
        [UIView animateWithDuration:2.0 * duration
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:-15.0
                            options:0
                         animations:^{
                             fromViewController.view.transform = CGAffineTransformMakeScale(0.3, 0.3);
                         }
                         completion:nil];
    }
}

@end
