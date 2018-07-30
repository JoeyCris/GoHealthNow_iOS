//
//  SlideInCardBaseView.h
//  Reminder
//
//  Created by Haoyu Gu on 2015-07-17.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlideInCardBaseDelegate <NSObject>

@optional
- (void)slideInCardBaseDidChooseLeftButton;
- (void)slideInCardBaseDidChooseRightButton;

@end

@interface SlideInCardView : UIView

- (void)loadCardWithTitle:(NSString *)title
                withFrame:(CGRect)frame
      withLeftButtonImage:(UIImage *)leftButtonImage
     withRightButtonImage:(UIImage *)rightButtonImage
 withBackgroundColorArray:(NSArray *)colorArray
             withEndTitle:(NSString *)endTitle
            withComponent:(UIView *)componentView
             withDelegate:(id<SlideInCardBaseDelegate>)delegate;

- (void)done;
- (void)cancel;



@end
