//
//  MultiColumnTableLayout.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-29.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "MultiColumnTableLayout.h"

#pragma mark - UICollectionViewFlowLayout Subclass

@interface MultiColumnTableLayout()

@property (nonatomic) NSMutableArray *columnEndingXValues;

@end

static const CGFloat CELL_SPACING = 2.0;

@implementation MultiColumnTableLayout

- (CGSize)collectionViewContentSize {
    CGFloat xSize = 0;
    NSUInteger columnCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger i = 0; i < columnCount; i++) {
        xSize += [self.columnWidths[i] floatValue] + CELL_SPACING;
    }
    
    CGFloat ySize = [self.collectionView numberOfSections] * (self.columnHeight + CELL_SPACING);
    
    return CGSizeMake(xSize, ySize);
}

// table row    -> indexPath.section
// table column -> indexPath.row
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    NSUInteger columnCount = [self.collectionView numberOfItemsInSection:0];
    if (!self.columnEndingXValues) {
        self.columnEndingXValues = [[NSMutableArray alloc] initWithCapacity:columnCount];
    }
    
    CGFloat columnWidth = [self.columnWidths[indexPath.row] floatValue];
    CGFloat prevColumnEndingXValue = indexPath.row == 0 ? 0.0 : [self.columnEndingXValues[indexPath.row - 1] floatValue];
    
    CGFloat xValue = prevColumnEndingXValue + CELL_SPACING;
    CGFloat yValue = indexPath.section * self.columnHeight + CELL_SPACING;
    
    attributes.frame = CGRectMake(xValue, yValue, columnWidth, self.columnHeight);
    
    if (indexPath.section == 0) {
        [self.columnEndingXValues addObject:[NSNumber numberWithFloat:xValue + columnWidth]];
    }
    
    return attributes;
}

- (NSArray*)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* attributes = [NSMutableArray array];
    
    for (NSInteger i = 0; i < self.collectionView.numberOfSections; i++) {
        NSInteger columnsInSection = [self.collectionView numberOfItemsInSection:i];
        
        for (NSInteger j = 0; j < columnsInSection; j++) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForItem:j inSection:i];
            UICollectionViewLayoutAttributes *layout = [self layoutAttributesForItemAtIndexPath:indexPath];
            
            if (CGRectIntersectsRect(rect, layout.frame)) {
                [attributes addObject:layout];
            }
        }
    }
    
    return attributes;
}

@end
