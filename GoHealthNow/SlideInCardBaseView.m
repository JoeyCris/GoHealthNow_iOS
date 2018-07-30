//
//  SlideInCardBaseView.m
//  Reminder
//
//  Created by Haoyu Gu on 2015-07-17.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import "SlideInCardBaseView.h"

#define VIEW_TOP_Y_CONTROL 0

@interface SlideInCardView()

@property (nonatomic) UIView *baseView;

@property (nonatomic) UIView *componentView;

@property (nonatomic) NSArray *colorArray;

@property (nonatomic) UILabel *cardTitleLabel;
@property (nonatomic) UIButton *leftButton;
@property (nonatomic) UIButton *rightButton;

@property (nonatomic) NSString *cardTitle;
@property (nonatomic) UIImage *leftButtonImage;
@property (nonatomic) UIImage *rightButtonImage;

@property (nonatomic) NSString *endTitle;
@property (nonatomic) UILabel *endLabel;

@property (nonatomic) UIView *maskView;

@property (nonatomic) id<SlideInCardBaseDelegate> delegate;

@end

@implementation SlideInCardView

- (void)loadCardWithTitle:(NSString *)title withFrame:(CGRect)frame withLeftButtonImage:(UIImage *)leftButtonImage withRightButtonImage:(UIImage *)rightButtonImage withBackgroundColorArray:(NSArray *)colorArray withEndTitle:(NSString *)endTitle withComponent:(UIView *)componentView withDelegate:(id<SlideInCardBaseDelegate>)delegate {
    self.cardTitle = title;
    self.leftButtonImage = leftButtonImage;
    self.rightButtonImage = rightButtonImage;
    self.colorArray = colorArray;
    self.endTitle = endTitle;
    self.componentView = componentView;
    self.delegate = delegate;
    
    //init baseview
    self.frame = CGRectMake(frame.origin.x, [UIScreen mainScreen].bounds.size.height, frame.size.width, frame.size.height);
    
    self.baseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:self.baseView];
    [self drawBase];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.maskView = [[UIView alloc] initWithFrame:window.frame];
    self.maskView.backgroundColor = [UIColor blackColor];
    self.maskView.alpha = 0.6f;
    
    [window addSubview:self.maskView];
    [window addSubview:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(maskViewTapped)];
    tap.numberOfTapsRequired = 2;
    [self.maskView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(frame.origin.x, frame.origin.y-15, frame.size.width, frame.size.height);
    }
                     completion:^(BOOL finish){
                         [UIView animateWithDuration:0.1 animations:^{
                             self.frame = CGRectMake(frame.origin.x, frame.origin.y+10, frame.size.width, frame.size.height);
                         }
                                          completion:^(BOOL finish){
                                              [UIView animateWithDuration:0.05 animations:^{
                                                  self.frame = CGRectMake(frame.origin.x, frame.origin.y-5, frame.size.width, frame.size.height);
                                              }
                                                               completion:^(BOOL finish){
                                                                   [UIView animateWithDuration:0.05 animations:^{
                                                                       self.frame = frame;
                                                                   }];
                                                               }];
                                          }];
                     }];

}

- (void)drawBase {
    //Background Color
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(0, 0, self.baseView.frame.size.width, self.baseView.frame.size.height);
    //Default style
    if (self.colorArray == nil) {
        self.colorArray = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:55.0/255.0 green:65.0/255.0 blue:150.0/255.0 alpha:1.0].CGColor, (id)[UIColor colorWithRed:142.0/255.0 green:150.0/255.0 blue:209.0/255.0 alpha:1.0].CGColor, nil];
    }
    gradient.colors = self.colorArray;
    [self.baseView.layer addSublayer:gradient];
    
    //corner
    self.baseView.layer.cornerRadius = 10.0f;
    self.baseView.clipsToBounds = YES;
    
    //top
    self.cardTitleLabel = [[UILabel alloc] init];
    [self.cardTitleLabel setFrame:CGRectMake(10, 10+VIEW_TOP_Y_CONTROL, self.baseView.frame.size.width - 90, 44)];
    [self.cardTitleLabel setFont:[UIFont systemFontOfSize:25.0f]];
    [self.cardTitleLabel setText:self.cardTitle];
    [self.cardTitleLabel setTextColor:[UIColor whiteColor]];
    
    if (self.leftButtonImage != nil) {
        self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.leftButton setBackgroundImage:self.leftButtonImage forState:UIControlStateNormal];
        [self.leftButton setFrame:CGRectMake(self.baseView.frame.size.width - 90, 18+VIEW_TOP_Y_CONTROL, 30, 30)];
        
        [self.leftButton addTarget:self action:@selector(leftButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.baseView addSubview:self.leftButton];
    }
    
    if (self.rightButtonImage != nil) {
        self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rightButton setBackgroundImage:self.rightButtonImage forState:UIControlStateNormal];
        [self.rightButton setFrame:CGRectMake(self.baseView.frame.size.width - 90 + 30 + 15, 18+VIEW_TOP_Y_CONTROL, 30, 30)];
        
        [self.rightButton addTarget:self action:@selector(rightButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.baseView addSubview:self.rightButton];
    }
    
    [self.baseView addSubview:self.cardTitleLabel];
    
    //body
    
    [self.baseView addSubview:self.componentView];
    
}

- (void)done {
    [self.maskView removeFromSuperview];
    if (self.endTitle == nil) {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-(self.frame.origin.y + self.frame.size.height+20), self.frame.size.width, self.frame.size.height);
        }
                         completion:^(BOOL finish){
                             [self removeFromSuperview];
                         }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-(self.frame.origin.y + self.frame.size.height)+60, self.frame.size.width, self.frame.size.height);
            self.componentView.alpha = 0.1f;
        }
                         completion:^(BOOL finish){
                             [self.componentView removeFromSuperview];
                             self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height-60, self.frame.size.width, 60)];
                             [self.endLabel setText:self.endTitle];
                             [self.endLabel setTextAlignment:NSTextAlignmentCenter];
                             [self.endLabel setTextColor:[UIColor whiteColor]];
                             [self.baseView addSubview:self.endLabel];
                             
                             [UIView animateWithDuration:0.2 delay:0.5 options:UIViewAnimationOptionTransitionNone animations:^{
                                 self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y-(self.frame.origin.y + self.frame.size.height+20), self.frame.size.width, self.frame.size.height);
                             }
                                              completion:^(BOOL finished){
                                                  [self doClear];
                                            }];
                         }];
    }
}

- (void)cancel {
    [self.maskView removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, [UIScreen mainScreen].bounds.size.height, self.frame.size.width, self.frame.size.height);
    }
    completion:^(BOOL finish){
        [self doClear];
    }];
}

- (void)leftButtonTapped:(id)sender {
    [self.delegate slideInCardBaseDidChooseLeftButton];
}

- (void)rightButtonTapped:(id)sender {
    [self.delegate slideInCardBaseDidChooseRightButton];
}

- (void)doClear {
    [self removeFromSuperview];
}

- (void)maskViewTapped {
    [self cancel];
}

@end
