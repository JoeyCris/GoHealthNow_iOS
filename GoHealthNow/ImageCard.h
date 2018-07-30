//
//  imageCard.h
//  imageCard
//
//  Created by Haoyu Gu on 2015-06-01.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCard : UIView

- (void)loadCardTypeAWithImage:(UIImage *)image titleString:(NSString *)titleString descriptString:(NSString *)descriptionString scoreString:(NSString *)scoreString indicatorColor:(UIColor*)idcColor;

- (void)loadCardTypeAWithImage:(UIImage *)image titleString:(NSString *)titleString descriptString:(NSString *)descriptionString indicatorColor:(UIColor*)idcColor;

- (void)loadCardTypeHomeNewsWithImage:(UIImage *)image titleString:(NSString *)titleString contentString:(NSString *)contentString date:(NSDate *)date;

- (void)updateImage:(UIImage *)image;

- (void)updateTitle:(NSString *)title;

- (void)updateContent:(NSString *)content;

- (void)updateDate:(NSDate *)date;

- (void)redrawCard;

- (BOOL)loaded;

@end
