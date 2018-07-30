//
//  GGImagePickerController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-03-06.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGImagePickerControllerDelegate <NSObject>
- (void)ggImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info withProcessingView:(UIView *)view;
@end

@interface GGImagePickerController : UIViewController

@property (nonatomic) UIImagePickerControllerSourceType sourceType;
@property (nonatomic) id<GGImagePickerControllerDelegate> delegate;

@end
