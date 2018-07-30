//
//  HelpTipController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-08-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "HelpTipController.h"
#import "OverlayAnimationManager.h"
#import "Constants.h"

@interface HelpTipController()<UIViewControllerTransitioningDelegate>

@property (nonatomic) NSMutableSet *tipLayers;

@end

@implementation HelpTipController

#pragma mark - Initialize

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.transitioningDelegate = self;
        self.modalPresentationStyle = UIModalPresentationCustom;
    }
    
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *cancelButton = [[UIButton alloc] init];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton setImage:[UIImage imageNamed:@"cancelIcon"] forState:UIControlStateNormal];
    cancelButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [cancelButton addTarget:self
                     action:@selector(didTapCancelButton:)
           forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self.view addSubview:cancelButton];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:2.0]];
     [self.view addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                           attribute:NSLayoutAttributeTop
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.view
                                                           attribute:NSLayoutAttributeTop
                                                          multiplier:1.0
                                                            constant:12.0]];
    [cancelButton addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:35.0]];
    [cancelButton addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:35.0]];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(didTapView:)]];
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self didTapCancelButton:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    for (CALayer *layer in self.tipLayers) {
        [self.view.layer addSublayer:layer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.tipLayers = nil;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source
{
    return [[OverlayAnimationManager alloc] initWithMode:OverlayAnimationModePresent];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return [[OverlayAnimationManager alloc] initWithMode:OverlayAnimationModeDismiss];
}

#pragma mark - Event Handlers

- (void)didTapCancelButton:(UIButton *)cancelButton {
    [self dismissViewControllerAnimated:YES completion:^{
        self.tipLayers = nil;
    }];
}

- (void)didTapView:(UITapGestureRecognizer *)gestureRecognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

- (void)addTipWithTitle:(NSString *)title
                atPoint:(CGPoint)point
      arrowTailPosition:(HelpTipArrowTailPosition)arrowPosition
             arrowCurve:(HelpTipArrowCurve)arrowCurve
   withArrowHeadAtPoint:(CGPoint)arrowHeadPoint
{
    [self addTipWithTitle:title
                  atPoint:point
        arrowTailPosition:arrowPosition
               arrowCurve:arrowCurve
         arrowCurveRadius:HELP_TIP_CTRL_POINT_RADIUS
     withArrowHeadAtPoint:arrowHeadPoint];
}

- (void)addTipWithTitle:(NSString *)title
                atPoint:(CGPoint)point
      arrowTailPosition:(HelpTipArrowTailPosition)arrowPosition
             arrowCurve:(HelpTipArrowCurve)arrowCurve
       arrowCurveRadius:(CGFloat)arrowCurveRadius
   withArrowHeadAtPoint:(CGPoint)arrowHeadPoint
{
    if (!self.tipLayers) {
        self.tipLayers = [[NSMutableSet alloc] init];
    }
    
    CATextLayer *labelTitle = [self addTitle:title atPoint:point];
    
    CGPoint arrowFromPoint = CGPointZero;
    switch (arrowPosition) {
        case HelpTipArrowTailPositionLeftMiddle:
            arrowFromPoint.x = labelTitle.frame.origin.x;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height / 2.0;
            break;
        case HelpTipArrowTailPositionRightMiddle:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height / 2.0;
            break;
        case HelpTipArrowTailPositionTopMiddle:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width / 2.0;
            arrowFromPoint.y = labelTitle.frame.origin.y;
            break;
        case HelpTipArrowTailPositionBottomMiddle:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width / 2.0;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height;
            break;
        case HelpTipArrowTailPositionBottomLeft:
            arrowFromPoint.x = labelTitle.frame.origin.x;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height;
            break;
        case HelpTipArrowTailPositionBottomLeftWithMargin:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width / HELP_TIP_ARROW_TAIL_MARGIN_MULTIPLIER;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height;
            break;
        case HelpTipArrowTailPositionBottomRight:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height;
            break;
        case HelpTipArrowTailPositionBottomRightWithMargin:
            arrowFromPoint.x = labelTitle.frame.origin.x + labelTitle.frame.size.width - labelTitle.frame.size.width / HELP_TIP_ARROW_TAIL_MARGIN_MULTIPLIER;
            arrowFromPoint.y = labelTitle.frame.origin.y + labelTitle.frame.size.height;
            break;
        default:
            break;
    }

    CGFloat controlMidPointX = cosf(HELP_TIP_CTRL_POINT_LEFT_ANGLE * M_PI / 180.0) * arrowCurveRadius + arrowFromPoint.x;
    CGFloat controlMidPointY = sinf(HELP_TIP_CTRL_POINT_LEFT_ANGLE * M_PI / 180.0) * arrowCurveRadius + arrowFromPoint.y;
    
    if (arrowCurve == HelpTipArrowCurveRight) {
        controlMidPointX = cosf(HELP_TIP_CTRL_POINT_RIGHT_ANGLE * M_PI / 180.0) * arrowCurveRadius + arrowFromPoint.x;
        controlMidPointY = sinf(HELP_TIP_CTRL_POINT_RIGHT_ANGLE * M_PI / 180.0) * arrowCurveRadius + arrowFromPoint.y;
    }
    
    [self addArrowFromPoint:arrowFromPoint
                    toPoint:arrowHeadPoint
           withControlPoint:CGPointMake(controlMidPointX, controlMidPointY)];
}

- (void)addTipTitle:(NSString*)title atPoint:(CGPoint)point {
    if (!self.tipLayers) {
        self.tipLayers = [[NSMutableSet alloc] init];
    }
    
    [self addTitle:title atPoint:point];
}

- (CATextLayer *)addTitle:(NSString*)title atPoint:(CGPoint)point {
    if (self.titleFontPointSize == 0.0) {
        self.titleFontPointSize = 14.0;
    }
    
    UIFont *titleFont = [UIFont systemFontOfSize:self.titleFontPointSize];
    
    CATextLayer *labelTitle = [[CATextLayer alloc] init];
    [labelTitle setFont:(__bridge CFTypeRef)(@".SFUIText-Regular")];
    [labelTitle setFontSize:titleFont.pointSize];
    [labelTitle setString:title];
    [labelTitle setWrapped:YES]; // same as the lineBreakMode property below
    [labelTitle setForegroundColor:[[UIColor whiteColor] CGColor]];
    [labelTitle setContentsScale:[[UIScreen mainScreen] scale]];
    
    // Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(HELP_TIP_DEFAULT_TITLE_WIDTH, FLT_MAX);
    // reduce the width of the title if it will go beyonds the frame
    // of the superview
    if (point.x + HELP_TIP_DEFAULT_TITLE_WIDTH > self.view.frame.size.width) {
        maximumLabelSize.width -= point.x;
    }
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    CGRect labelTitleTempFrame = [labelTitle.string boundingRectWithSize:maximumLabelSize
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{
                                                                           NSFontAttributeName: titleFont,
                                                                           NSParagraphStyleAttributeName: paraStyle
                                                                           }
                                                                 context:nil];
    [labelTitle setFrame:CGRectMake(point.x, point.y, ceilf(labelTitleTempFrame.size.width), ceilf(labelTitleTempFrame.size.height))];
    [self.tipLayers addObject:labelTitle];
    
    return labelTitle;
}

- (void)addArrowFromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint withControlPoint:(CGPoint)controlPoint {
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:fromPoint];
    [path addQuadCurveToPoint:toPoint controlPoint:controlPoint];
    
    CAShapeLayer *curvedLine = [CAShapeLayer layer];
    curvedLine.path = path.CGPath;
    curvedLine.lineWidth = 2;
    curvedLine.strokeColor = [UIColor whiteColor].CGColor;
    curvedLine.fillColor = [UIColor clearColor].CGColor;
    curvedLine.frame = self.view.bounds;
    [self.tipLayers addObject:curvedLine];
    
    CGFloat angle = atan2f(toPoint.y - controlPoint.y, toPoint.x - controlPoint.x);
    
    CGFloat distance = 5.0;
    path = [UIBezierPath bezierPath];
    [path moveToPoint:toPoint];
    [path addLineToPoint:[self calculatePointFromPoint:toPoint angle:angle + M_PI_2 distance:distance]]; // to the right
    [path addLineToPoint:[self calculatePointFromPoint:toPoint angle:angle          distance:distance]]; // straight ahead
    [path addLineToPoint:[self calculatePointFromPoint:toPoint angle:angle - M_PI_2 distance:distance]]; // to the left
    [path closePath];
    
    CAShapeLayer *arrowHead = [CAShapeLayer layer];
    arrowHead.path = path.CGPath;
    arrowHead.lineWidth = 1;
    arrowHead.strokeColor = [UIColor whiteColor].CGColor;
    arrowHead.fillColor = [UIColor whiteColor].CGColor;
    arrowHead.frame = self.view.bounds;
    [self.tipLayers addObject:arrowHead];
}

- (CGPoint)calculatePointFromPoint:(CGPoint)point angle:(CGFloat)angle distance:(CGFloat)distance {
    return CGPointMake(point.x + cosf(angle) * distance, point.y + sinf(angle) * distance);
}

@end
