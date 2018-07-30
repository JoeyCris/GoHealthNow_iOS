//
//  ShowPhotoController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-05-12.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "ShowPhotoController.h"
#define Width self.view.frame.size.width
#define Height self.view.frame.size.height

@interface ShowPhotoController ()

@end

@implementation ShowPhotoController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    imageView.image = self.imageToShow;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.view.backgroundColor = [UIColor blackColor];
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [imageView addGestureRecognizer:tap];
    [self.view addSubview:imageView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    self.view.alpha = .2;
    [UIView animateWithDuration:1 animations:^{
        self.view.alpha = 1;
    }];
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)tapAction
{
    [UIView animateWithDuration:0.6 animations:^{
        self.view.alpha = .2;
    } completion:^
     (BOOL finished) {
         [self.navigationController popViewControllerAnimated:NO];
         //         [self.navigationController popToRootViewControllerAnimated:NO];
     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



@end
