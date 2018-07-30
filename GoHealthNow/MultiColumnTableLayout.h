//
//  MultiColumnTableLayout.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-29.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiColumnTableLayout : UICollectionViewFlowLayout

@property (nonatomic) NSArray *columnWidths;
@property (nonatomic) CGFloat columnHeight;

@end
