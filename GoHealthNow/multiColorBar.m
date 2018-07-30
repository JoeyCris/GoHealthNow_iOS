//
//  multiColorBar.m
//  multiColorBar
//
//  Created by Haoyu Gu on 2015-05-20.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import "multiColorBar.h"

@interface multiColorBar()

@property (nonatomic) NSMutableArray *progressViewArray;
@property (nonatomic) NSMutableArray *animValueArray;

@end

@implementation multiColorBar

- (void)clearBar {
    for (int i=0;i<[self.progressViewArray count];i++) {
        [self.progressViewArray[i] removeFromSuperview];
    }
    [self.progressViewArray removeAllObjects];
    [self.animValueArray removeAllObjects];
}

- (void)showValueNColors:(id)valueNcolor, ...{  //Example
    self.progressViewArray = nil;
    self.progressViewArray = [[NSMutableArray alloc] init];
    self.animValueArray = nil;
    self.animValueArray = [[NSMutableArray alloc] init];
    [self.progressViewArray removeAllObjects];
    
    [self.animValueArray removeAllObjects];
    id eachObject;
    va_list argList;
    if (valueNcolor) {
        UIView *progView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
        [self.progressViewArray addObject:progView];
        int count = 0;
        UIView *tempView;
        tempView = self.progressViewArray[count];
        tempView.backgroundColor = valueNcolor[1];
        [self.animValueArray addObject:valueNcolor[0]];
        va_start(argList, valueNcolor);
        while ((eachObject = va_arg(argList, id))) {
            UIView *progView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
            [self.progressViewArray addObject:progView1];
            count++;
            tempView = self.progressViewArray[count];
            tempView.backgroundColor = eachObject[1];
            [self.animValueArray addObject:eachObject[0]];
        }
        va_end(argList);
        
        for (int i=(int)[self.progressViewArray count]-1;i>=0;i--) {
            [self addSubview:self.progressViewArray[i]];
        }
        
        [self doAnimation];
    }
}

- (void)redrawBar {
    [self doAnimation];
}

- (void)doAnimation {
    [UIView animateWithDuration:0.01f animations:^{
        for (int i=0;i<[self.progressViewArray count];i++) {
            ((UIView *)self.progressViewArray[i]).frame = CGRectMake(0, 0, 0, self.frame.size.height);
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateWithDuration:1.75f animations:^{
                float totalWidth = 0.0f;
                for (int i=0;i<[self.progressViewArray count];i++) {
                    ((UIView *)self.progressViewArray[i]).frame = CGRectMake(0, 0, totalWidth+[self.animValueArray[i] floatValue]*self.frame.size.width, self.frame.size.height);
                    totalWidth += [self.animValueArray[i] floatValue]*self.frame.size.width;
                }
            }];
        }
    }];
}

@end
