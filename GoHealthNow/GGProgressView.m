//
//  GGProgressView.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-02-10.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "GGProgressView.h"
#import "Constants.h"

@interface GGProgressView ()

@property (nonatomic) UIColor *trackTintColor;

@end

@implementation GGProgressView

- (void)setText:(NSString *)text {
    _text = text;
    
    if (self.text) {
        [self addText:_text];
    }
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)updateTintColor:(UIColor *)color {
    self.progressTintColor = color;
    self.trackTintColor = color;
    
    [self setNeedsDisplay];
}

- (void)updateProgressTintColor:(UIColor *)color {
    self.progressTintColor = color;
    self.trackTintColor = [UIColor grayColor];
    
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (!self.trackTintColor) {
        self.trackTintColor = [UIColor grayColor];
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill background
    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGContextFillRect(context, CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height));
    
    // fill progress
    if (self.progressTintColor) {
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGContextFillRect(context, CGRectMake(0.0, 0.0, self.frame.size.width * self.progress, self.frame.size.height));
    }
    
    if (self.text) {
        [self addText:self.text];
    }
}

- (void)addText:(NSString *)str {
    UILabel *label = (UILabel *)[self viewWithTag:PROGRESS_VIEW_TAG];
    
    if (!label) {
        label = [[UILabel alloc] init];
        label.tag = PROGRESS_VIEW_TAG;
        label.textColor = [UIColor whiteColor];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        [label sizeToFit];
        
        [self addSubview:label];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    }
    
    label.text = str;
}

@end
