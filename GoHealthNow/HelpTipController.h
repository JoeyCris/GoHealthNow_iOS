//
//  HelpTipController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-08-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    HelpTipArrowTailPositionLeftMiddle = 0,
    HelpTipArrowTailPositionRightMiddle,
    HelpTipArrowTailPositionTopMiddle,
    HelpTipArrowTailPositionBottomMiddle,
    HelpTipArrowTailPositionBottomRight,
    HelpTipArrowTailPositionBottomRightWithMargin, // adds a slight margin so that start pos isn't at the very bottom right edge
    HelpTipArrowTailPositionBottomLeft,
    HelpTipArrowTailPositionBottomLeftWithMargin // adds a slight margin so that start pos isn't at the very bottom left edge
};
typedef NSUInteger HelpTipArrowTailPosition;

enum {
    HelpTipArrowCurveLeft = 0,
    HelpTipArrowCurveRight
};
typedef NSUInteger HelpTipArrowCurve;

@interface HelpTipController : UIViewController

@property (nonatomic) CGFloat titleFontPointSize; // default is 14.0

- (void)addTipWithTitle:(NSString *)title
                atPoint:(CGPoint)point
      arrowTailPosition:(HelpTipArrowTailPosition)arrowPosition
             arrowCurve:(HelpTipArrowCurve)arrowCurve
   withArrowHeadAtPoint:(CGPoint)arrowHeadPoint;

- (void)addTipWithTitle:(NSString *)title
                atPoint:(CGPoint)point
      arrowTailPosition:(HelpTipArrowTailPosition)arrowPosition
             arrowCurve:(HelpTipArrowCurve)arrowCurve
       arrowCurveRadius:(CGFloat)arrowCurveRadius
   withArrowHeadAtPoint:(CGPoint)arrowHeadPoint;

- (void)addTipTitle:(NSString*)title atPoint:(CGPoint)point;

@end
