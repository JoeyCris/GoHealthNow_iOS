//
//  RecorderIndicator.h
//  GlucoGuide
//
//  Created by Haoyu Gu on 2017-02-01.
//  Copyright © 2017 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecorderIndicator : UIView

-(id)init;
-(id)initWithRecordingLabelString:(NSString*)rlString andTimeLabelStr:(NSString*)tlString andTipsLabelStr:(NSString*)tipStr andImageName:(NSString*)imageName andParentView:(UIView *)view;


-(void)show;
-(void)hide;

-(void)setParentView:(UIView*)view;

-(void)setRecordingLabelWithString:(NSString*)string;
-(void)setTimeLabelWithString:(NSString*)string;
-(void)setTipsLabelWithString:(NSString*)string;

-(void)setImageWithImageName:(NSString*)string;

@end
