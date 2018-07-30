//
//  MealPhotoViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-15.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "MealPhotoViewController.h"

@interface MealPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) UIImage *image;
@end

@implementation MealPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.imageView setBackgroundColor:[UIColor blackColor]];
    [self.imageView setImage:self.image];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImage:(UIImage *)image {
    self.image = image;
}

- (IBAction)dismissMe:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
