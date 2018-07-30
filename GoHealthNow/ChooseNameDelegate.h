//
//  ChooseNameDelegate.h
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-02-04.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChooseNameDelegate <NSObject>

- (void)didChoosefirstName:(NSString *)firstName lastName:(NSString *)lastName sender:(id)sender;

@end
