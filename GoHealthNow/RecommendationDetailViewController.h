//
//  RecommendationDetailViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RecommendationRecord.h"
#import "Constants.h"

@interface RecommendationDetailViewController : UIViewController

@property (nonatomic) RecommendationRecord *recommendation;
@property (nonatomic) UIImage *image;

@end
