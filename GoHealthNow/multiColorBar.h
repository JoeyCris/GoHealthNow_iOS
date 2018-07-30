//
//  multiColorBar.h
//  multiColorBar
//
//  Created by Haoyu Gu on 2015-05-20.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface multiColorBar : UIView

//Example
//     showValueNColors:{float, UIColor}
//          The maximum value for first para is 1.00
//
- (void)showValueNColors:(id)valueNcolor, ...;
- (void)clearBar;
- (void)redrawBar;

@end
