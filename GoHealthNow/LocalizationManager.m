//
//  LocalizationManager.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-12-24.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "LocalizationManager.h"

@implementation LocalizationManager

+(NSString *)getStringFromStrId:(NSString *)strid {
    //if we need to add manual-language-switcher, implement the code here
    return NSLocalizedString(strid, nil);
}

@end
