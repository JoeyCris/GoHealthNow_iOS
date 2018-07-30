//
//  GGImagePickerController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-03-06.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "GGImagePickerController.h"
#import "UIView+Extensions.h"
#import "Constants.h"

@interface GGImagePickerController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIImagePickerController *imagePicker;

@end

@implementation GGImagePickerController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    
    self.imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.imagePicker.sourceType = self.sourceType;
    self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.sourceType];
    self.imagePicker.delegate = self;
    self.imagePicker.allowsEditing = YES;
    
    [self.view addSubview:self.imagePicker.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIImagePickerControllerDelegate Methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIView * topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    [topView showActivityIndicatorWithMessage:[LocalizationManager getStringFromStrId:@"Processing"]];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
        [self dismissViewControllerAnimated:YES completion:^{
            [self.delegate ggImagePickerController:picker didFinishPickingMediaWithInfo:info withProcessingView:topView];
        }];
    
    

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
