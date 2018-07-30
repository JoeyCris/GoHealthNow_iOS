//
//  UIColor+Extensions.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-05.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "UIColor+Extensions.h"

@implementation UIColor (Extensions)

+ (UIColor *)backgroundColor {
    return [UIColor whiteColor];
}

+ (UIColor *)grayBackgroundColor {
    return [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1];
}

+ (UIColor *)buttonColor {
    // #0099C9
    return [UIColor colorWithRed:68.0/255.0 green:108.0/255.0 blue:179.0/255.0 alpha:1.0];
}

+ (UIColor *)textColor {
    return [UIColor blackColor];
}

+ (UIColor *)blueTextColor {
    // #1E8BC3
    return [UIColor colorWithRed:30.0/255.0 green:139.0/255.0 blue:195.0/255.0 alpha:1.0];
}

+ (UIColor *)lessOftenFoodColor {
    // #96281B
    return [UIColor colorWithRed:150.0/255.0 green:40.0/255.0 blue:27.0/255.0 alpha:1.0];
}

+ (UIColor *)inModerationFoodColor {
    // #D35400
    return [UIColor colorWithRed:211.0/255.0 green:84.0/255.0 blue:0.0/255.0 alpha:1.0];
}

+ (UIColor *)moreOftenFoodColor {
    // #1E824C
    return [UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:76.0/255.0 alpha:1.0];
}

+ (UIColor *)notGoodMealColor {
    // #D50F25
    return [UIColor colorWithRed:213.0/255.0 green:15.0/255.0 blue:37.0/255.0 alpha:1.0];
}

+ (UIColor *)goodMealColor {
    // #EEB211
    return [UIColor colorWithRed:238.0/255.0 green:178.0/255.0 blue:17.0/255.0 alpha:1.0];
}

+ (UIColor *)excellentMealColor {
    // #009925
    return [UIColor colorWithRed:0.0/255.0 green:153.0/255.0 blue:137.0/255.0 alpha:1.0];
}

+ (UIColor *)lightExerciseColor {
    // #34B62F
    return [UIColor colorWithRed:52.0/255.0 green:182.0/255.0 blue:47.0/255.0 alpha:1.0];
}

+ (UIColor *)moderateExerciseColor {
    // #B6B12F
    return [UIColor colorWithRed:182.0/255.0 green:177.0/255.0 blue:47.0/255.0 alpha:1.0];
}

+ (UIColor *)vigrousExerciseColor {
    // #B66E2F
    return [UIColor colorWithRed:182.0/255.0 green:110.0/255.0 blue:47.0/255.0 alpha:1.0];
}

+ (UIColor *)GGRedColor {
    // #D50F25
    return [UIColor colorWithRed:213.0/255.0 green:15.0/255.0 blue:37.0/255.0 alpha:1.0];
}

+ (UIColor *)GGGreenColor {
    // #009925
    return [UIColor colorWithRed:0.0/255.0 green:153.0/255.0 blue:37.0/255.0 alpha:1.0];
}

+ (UIColor *)GGBlueColor {
    // #3369E8
    return [UIColor colorWithRed:51.0/255.0 green:105.0/255.0 blue:232.0/255.0 alpha:1.0];
}

+ (UIColor *)GGYellowColor {
    // #EEB211
    return [UIColor colorWithRed:238.0/255.0 green:178.0/255.0 blue:17.0/255.0 alpha:1.0];
}

+ (UIColor *)GGGrayColor {
    // #666666
    return [UIColor colorWithRed:102.0/255.0 green:102.0/255.0 blue:102.0/255.0 alpha:1.0];
}

+ (UIColor *)GGOrangeColor {
    return [UIColor colorWithRed:235.0/255.0 green:121.0/255.0 blue:40/255.0 alpha:1.0];
}

@end
