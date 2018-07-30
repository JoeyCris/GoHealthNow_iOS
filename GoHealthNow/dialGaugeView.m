//
//  DialGaugeView.m
//  GlucoGuide
//
//  Created by QuQi on 2016-06-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "DialGaugeView.h"
#import "UIColor+Extensions.h"
#define DEGREES_TO_RADIANS(degrees) (degrees) / 180.0 * M_PI


@implementation DialGaugeView
{
    CGFloat needleWidth;
    CGFloat needleHeight;
    CGFloat arcWidth;
    
    CGRect arcRect;
    CGPoint center;
    
    UILabel *lowLabel;
    UILabel *targetLabel;
    UILabel *hightLabel;
    UILabel *leftLabel;
    UILabel *rightLabel;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

- (void)initialize;
{
    needleWidth = 0.03;
    needleHeight = 0.35;
    arcWidth = 0.04;
    
    [self initDrawingRects];
}

- (void)initDrawingRects
{
    center = CGPointMake(0.5, 0.6);
    arcRect = CGRectMake(0.08, 0.18,  0.68, 0.68);
}

- (void)rotateContext:(CGContextRef)context fromCenter:(CGPoint)center_ withAngle:(CGFloat)angle
{
    CGContextTranslateCTM(context, center_.x, center_.y);
    CGContextRotateCTM(context, angle);
    CGContextTranslateCTM(context, -center_.x, -center_.y);
}

- (void)drawRect:(CGRect)rect
{
    lowLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 95, 50, 20)];
    lowLabel.text = @"Low";
    lowLabel.textColor = [UIColor GGRedColor];
    [self addSubview:lowLabel];
    
    targetLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 50, 20)];
    targetLabel.text = @"Target";
    targetLabel.textColor = [UIColor GGGreenColor];
    [self addSubview:targetLabel];
    
    hightLabel = [[UILabel alloc] initWithFrame:CGRectMake(212, 95, 50, 20)];
    hightLabel.text = @"High";
    hightLabel.textColor = [UIColor GGRedColor];
    [self addSubview:hightLabel];
    
    leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 180, 100, 20)];
    leftLabel.textColor = [UIColor blackColor];
    leftLabel.text = _leftLabelString;
    [self addSubview:leftLabel];
    
    rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(145, 180, 100, 20)];
    rightLabel.textColor = [UIColor blackColor];
    rightLabel.text = _rightLabelString;
    rightLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:rightLabel];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, rect.size.width , rect.size.height);
    [self drawArc:context];
    UIImage *background = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [background drawInRect:rect];
    context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, rect.size.width , rect.size.height);
    [self drawNeedle:context];
}


- (void)drawArc:(CGContextRef)context
{
    CGContextSaveGState(context);
    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(180)];
    CGContextSetShadow(context, CGSizeMake(0.0, 0.0), 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:center radius:arcRect.size.width / 2.0 + 0.01 startAngle:DEGREES_TO_RADIANS(0) endAngle:DEGREES_TO_RADIANS(180) clockwise:YES];
    

    CGFloat colors [] = {
        213.0/255.0, 15.0/255.0, 37.0/255.0, 1.0,
        0.0/255.0, 153.0/255.0, 137.0/255.0, 1.0,
        213.0/255.0, 15.0/255.0, 37.0/255.0, 1.0
    };
    
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 3);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    CGContextSetLineWidth(context, arcWidth);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    CGContextAddPath(context, path.CGPath);
    CGContextReplacePathWithStrokedPath(context);
    
    CGContextClip(context);
    CGPoint startPoint = CGPointMake(0.08, 0.5);
    CGPoint endPoint = CGPointMake(0.92, 0.5);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

- (void)drawNeedle:(CGContextRef)context
{
    [self rotateContext:context fromCenter:center withAngle:DEGREES_TO_RADIANS(270+ (_value - _minValue) / (_maxValue - _minValue) * 180)];
    
    UIBezierPath *needlePath = [UIBezierPath bezierPath];
    [needlePath moveToPoint:CGPointMake(center.x - needleWidth, center.y)];
    [needlePath addLineToPoint:CGPointMake(center.x, center.y + needleWidth)];
    [needlePath addLineToPoint:CGPointMake(center.x + needleWidth, center.y)];
    [needlePath addLineToPoint:CGPointMake(center.x, center.y - needleHeight)];
    [needlePath closePath];
    
    [[UIColor blackColor] setFill];
    [needlePath fill];
}

#pragma mark - Properties

- (void)setValue:(float)value
{
    if (value > _maxValue)
        _value = _maxValue;
    else if (value < _minValue)
        _value = _minValue;
    else
        _value = value;
}

- (void)setMinValue:(float)minValue
{
    _minValue = minValue;
}

- (void)setMaxValue:(float)maxValue
{
    _maxValue = maxValue;
}

@end
