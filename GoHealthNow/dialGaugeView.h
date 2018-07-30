//
//  DialGaugeView.h
//  GlucoGuide
//
//  Created by QuQi on 2016-06-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialGaugeView : UIView

@property (nonatomic) float minValue;
@property (nonatomic) float maxValue;
@property (nonatomic) float value;
@property (nonatomic) NSString *leftLabelString;
@property (nonatomic) NSString *rightLabelString;

@end
