//
//  imageCard.m
//  imageCard
//
//  Created by Haoyu Gu on 2015-06-01.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import "ImageCard.h"
#import "GGUtils.h"

@interface ImageCard()

@property (nonatomic) UIView *scoreIndicator;
@property (nonatomic) UILabel *titleLabel;
@property (nonatomic) UILabel *descriptionLabel;
@property (nonatomic) UILabel *contentLabel;
@property (nonatomic) UILabel *dateLabel;
@property (nonatomic) UILabel *scoreLabel;
@property (nonatomic) UILabel *scoreValueLabel;
@property (nonatomic) UIImageView *titleImage;
@property (nonatomic) UIImageView *bkgndImage;
@property (nonatomic) UIImageView *indicatorImage;
@property (nonatomic) UIVisualEffect *blurEffect;
@property (nonatomic) UIVisualEffectView *topBlurView;
@property (nonatomic) UIVisualEffectView *bottomBlurView;

@property (nonatomic) CAGradientLayer *gradientLayer;

@property (nonatomic) NSUInteger typeIdentifier;

@end

@implementation ImageCard

- (void)doClear {
    [self.scoreIndicator removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.descriptionLabel removeFromSuperview];
    [self.contentLabel removeFromSuperview];
    [self.dateLabel removeFromSuperview];
    [self.scoreLabel removeFromSuperview];
    [self.scoreValueLabel removeFromSuperview];
    [self.titleImage removeFromSuperview];
    [self.bkgndImage removeFromSuperview];
    [self.indicatorImage removeFromSuperview];
    [self.topBlurView removeFromSuperview];
    [self.bottomBlurView removeFromSuperview];
    
    //self.blurEffect = nil;
    self.scoreIndicator = nil;
    self.titleLabel = nil;
    self.descriptionLabel = nil;
    self.contentLabel = nil;
    self.dateLabel = nil;
    self.scoreLabel = nil;
    self.scoreValueLabel = nil;
    self.titleImage = nil;
    self.bkgndImage = nil;
    self.indicatorImage = nil;
    self.topBlurView = nil;
    self.bottomBlurView = nil;
}

- (void)loadCardTypeAWithImage:(UIImage *)image titleString:(NSString *)titleString descriptString:(NSString *)descriptionString indicatorColor:(UIColor*)idcColor {
    self.typeIdentifier = 0;
    
    [self doClear];
    
    self.bkgndImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.bkgndImage.contentMode = UIViewContentModeScaleAspectFill;
    self.bkgndImage.clipsToBounds = YES;
    [self.bkgndImage setImage:image];
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    UIColor *avgColor = [self averageColorWithImage:image];
    [avgColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int threshold = 105;
    //luminance = (red * 0.299) + (green * 0.587) + (blue * 0.114).
    float bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114))*255;
    UIColor *textColor = (bgDelta > threshold) ? [UIColor blackColor] : [UIColor whiteColor];
    
    self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.bottomBlurView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
    self.bottomBlurView.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40);
    
    //if (self.gradientLayer == nil) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bottomBlurView.bounds;
        
        self.gradientLayer.colors = @[(id)[[UIColor clearColor] colorWithAlphaComponent:0.0f].CGColor,
                                      (id)[[UIColor darkGrayColor] colorWithAlphaComponent:0.8f].CGColor];
        self.gradientLayer.locations = @[[NSNumber numberWithFloat:0.05f],
                                         [NSNumber numberWithFloat:1.0f]];
        [self.bottomBlurView.layer addSublayer:self.gradientLayer];
    //}
    
    self.scoreIndicator = [[UIView alloc] initWithFrame:CGRectMake(8, 15, 10, 10)];
    [self.scoreIndicator setBackgroundColor:idcColor];
    self.scoreIndicator.clipsToBounds = YES;
    self.scoreIndicator.layer.cornerRadius = self.scoreIndicator.frame.size.width/2;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, self.bottomBlurView.frame.size.width-8, 30)];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.titleLabel setText:titleString];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 25, self.bottomBlurView.frame.size.width-8, 10)];
    [self.descriptionLabel setTextColor:[UIColor whiteColor]];
    [self.descriptionLabel setTextAlignment:NSTextAlignmentLeft];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [self.descriptionLabel setText:descriptionString];
    
    self.indicatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.bottomBlurView.frame.size.width - 20, 10, 20, 20)];
    [self.indicatorImage setImage:[UIImage imageNamed:@"disclosureIndicatorIcon"]];
    
    [self.bottomBlurView.contentView addSubview:self.scoreIndicator];
    [self.bottomBlurView.contentView addSubview:self.titleLabel];
    [self.bottomBlurView.contentView addSubview:self.descriptionLabel];
    [self.bottomBlurView.contentView addSubview:self.indicatorImage];
    
    [self addSubview:self.bkgndImage];
    [self addSubview:self.bottomBlurView];
}

- (void)loadCardTypeAWithImage:(UIImage *)image titleString:(NSString *)titleString descriptString:(NSString *)descriptionString scoreString:(NSString *)scoreString indicatorColor:(UIColor*)idcColor {
    self.typeIdentifier = 0;
    
    [self doClear];
    
    self.bkgndImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.bkgndImage.contentMode = UIViewContentModeScaleAspectFill;
    self.bkgndImage.clipsToBounds = YES;
    [self.bkgndImage setImage:image];
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    UIColor *avgColor = [self averageColorWithImage:image];
    [avgColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int threshold = 105;
    //luminance = (red * 0.299) + (green * 0.587) + (blue * 0.114).
    float bgDelta = ((red * 0.299) + (green * 0.587) + (blue * 0.114))*255;
    UIColor *textColor = (bgDelta > threshold) ? [UIColor blackColor] : [UIColor whiteColor];
    
    self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    self.topBlurView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
    self.topBlurView.frame = CGRectMake(self.frame.size.width - 60, 10, 50, 50);
    self.topBlurView.clipsToBounds = YES;
    self.topBlurView.layer.cornerRadius = 25.0f;
    
    self.scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 28, 50, 20)];
    [self.scoreLabel setTextColor:textColor];
    [self.scoreLabel setTextAlignment:NSTextAlignmentCenter];
    [self.scoreLabel setFont:[UIFont fontWithName:@"Helvetica" size:8]];
    [self.scoreLabel setText:@"SCORE"];
    
    self.scoreValueLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 50, 35)];
    [self.scoreValueLabel setTextColor:textColor];
    [self.scoreValueLabel setTextAlignment:NSTextAlignmentCenter];
    [self.scoreValueLabel setFont:[UIFont fontWithName:@"Helvetica-Light" size:24]];
    [self.scoreValueLabel setText:scoreString];
    
    [self.topBlurView.contentView addSubview:self.scoreLabel];
    [self.topBlurView.contentView addSubview:self.scoreValueLabel];
    
    self.bottomBlurView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
    self.bottomBlurView.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40);
    
    if (self.gradientLayer == nil) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bottomBlurView.bounds;
        
        self.gradientLayer.colors = @[(id)[[UIColor clearColor] colorWithAlphaComponent:0.0f].CGColor,
                                      (id)[[UIColor darkGrayColor] colorWithAlphaComponent:0.8f].CGColor];
        self.gradientLayer.locations = @[[NSNumber numberWithFloat:0.05f],
                                         [NSNumber numberWithFloat:1.0f]];
        [self.bottomBlurView.layer addSublayer:self.gradientLayer];
    }
    
    self.scoreIndicator = [[UIView alloc] initWithFrame:CGRectMake(8, 15, 10, 10)];
    [self.scoreIndicator setBackgroundColor:idcColor];
    self.scoreIndicator.clipsToBounds = YES;
    self.scoreIndicator.layer.cornerRadius = self.scoreIndicator.frame.size.width/2;
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 0, self.bottomBlurView.frame.size.width-8, 30)];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.titleLabel setText:titleString];
    
    self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(26, 25, self.bottomBlurView.frame.size.width-8, 10)];
    [self.descriptionLabel setTextColor:[UIColor whiteColor]];
    [self.descriptionLabel setTextAlignment:NSTextAlignmentLeft];
    [self.descriptionLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [self.descriptionLabel setText:descriptionString];
    
    self.indicatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(self.bottomBlurView.frame.size.width - 20, 10, 20, 20)];
    [self.indicatorImage setImage:[UIImage imageNamed:@"disclosureIndicatorIcon"]];
    
    [self.bottomBlurView.contentView addSubview:self.scoreIndicator];
    [self.bottomBlurView.contentView addSubview:self.titleLabel];
    [self.bottomBlurView.contentView addSubview:self.descriptionLabel];
    [self.bottomBlurView.contentView addSubview:self.indicatorImage];
    
    [self addSubview:self.bkgndImage];
    [self addSubview:self.topBlurView];
    [self addSubview:self.bottomBlurView];

}

- (void)loadCardTypeHomeNewsWithImage:(UIImage *)image titleString:(NSString *)titleString contentString:(NSString *)contentString date:(NSDate *)date; {
    self.typeIdentifier = 1;
    
    [self doClear];
    
    self.bkgndImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.bkgndImage.contentMode = UIViewContentModeScaleAspectFill;
    self.bkgndImage.clipsToBounds = YES;
    
    [self.bkgndImage setImage:image];
    
    
    [self addSubview:self.bkgndImage];
    
    self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    if (self.bottomBlurView == nil) {
        self.bottomBlurView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
        self.bottomBlurView.frame = CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 70);
        self.bottomBlurView.clipsToBounds = YES;
        //self.bottomBlurView.alpha = 0.85f;
    }
    /*
    if (self.gradientLayer == nil) {
        self.gradientLayer = [CAGradientLayer layer];
        self.gradientLayer.frame = self.bottomBlurView.bounds;
        
        self.gradientLayer.colors = @[(id)[[UIColor clearColor] colorWithAlphaComponent:0.0f].CGColor,
                                      (id)[[UIColor blackColor] colorWithAlphaComponent:0.6f].CGColor];
        self.gradientLayer.locations = @[[NSNumber numberWithFloat:0.0f],
                                         [NSNumber numberWithFloat:1.0f]];
        [self.bottomBlurView.layer addSublayer:self.gradientLayer];
    }
    */
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bottomBlurView.frame.size.width - 80, self.bottomBlurView.frame.size.height/2.2 - 10)];
    [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.titleLabel setTextColor:[UIColor blackColor]];
    [self.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:18]];
    [self.titleLabel setText:titleString];
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height-2, self.titleLabel.frame.size.width, self.bottomBlurView.frame.size.height - self.titleLabel.frame.origin.y - self.titleLabel.frame.size.height - 5)];
    [self.contentLabel setTextAlignment:NSTextAlignmentLeft];
    [self.contentLabel setTextColor:[UIColor blackColor]];
    [self.contentLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    [self.contentLabel setLineBreakMode:NSLineBreakByWordWrapping|NSLineBreakByTruncatingTail];
    [self.contentLabel setNumberOfLines:2];
    [self.contentLabel setText:contentString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd"];
    
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width+5, 0, self.bottomBlurView.frame.size.width - (self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width+10), self.bottomBlurView.frame.size.height)];
    [self.dateLabel setTextAlignment:NSTextAlignmentCenter];
    [self.dateLabel setTextColor:[UIColor blackColor]];
    [self.dateLabel setText:[formatter stringFromDate:date]];
    [self.dateLabel setFont:[UIFont fontWithName:@"Helvetica" size:([GGUtils getSystemLanguageSetting] == AppLanguageEn) ? 18: 15]];  //18
    
    [self.bottomBlurView.contentView addSubview:self.dateLabel];
    [self.bottomBlurView.contentView addSubview:self.titleLabel];
    [self.bottomBlurView.contentView addSubview:self.contentLabel];
    
    [self addSubview:self.bottomBlurView];
}

- (void)redrawCard {
    if (self.typeIdentifier == 0) {
        self.bkgndImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.topBlurView.frame = CGRectMake(self.frame.size.width - 60, 10, 50, 50);
        self.bottomBlurView.frame = CGRectMake(0, self.frame.size.height-40, self.frame.size.width, 40);
        self.titleLabel.frame = CGRectMake(8, 0, self.bottomBlurView.frame.size.width-8, self.bottomBlurView.frame.size.height);
        self.descriptionLabel.frame = CGRectMake(26, 25, self.bottomBlurView.frame.size.width-8, 10);
        self.indicatorImage.frame = CGRectMake(self.bottomBlurView.frame.size.width - 20, 10, 20, 20);
        self.gradientLayer.frame = self.bottomBlurView.bounds;
    }
    else if (self.typeIdentifier == 1) {
        self.bkgndImage.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        self.bottomBlurView.frame = CGRectMake(0, self.frame.size.height - 70, self.frame.size.width, 70);
        self.titleLabel.frame = CGRectMake(10, 10, self.bottomBlurView.frame.size.width - 80, self.bottomBlurView.frame.size.height/2.2 - 10);
        self.contentLabel.frame = CGRectMake(10, self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height-2, self.titleLabel.frame.size.width, self.bottomBlurView.frame.size.height - self.titleLabel.frame.origin.y - self.titleLabel.frame.size.height - 5);
        self.dateLabel.frame = CGRectMake(self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width+5, 0, self.bottomBlurView.frame.size.width - (self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width+10), self.bottomBlurView.frame.size.height);
        self.gradientLayer.frame = self.bottomBlurView.bounds;
    }
}

- (void)updateImage:(UIImage *)image {
    [self.titleImage setImage:image];
    [self.bkgndImage setImage:image];
}

- (void)updateTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)updateContent:(NSString *)content{
    self.contentLabel.text = content;
}

- (void)updateDate:(NSDate *)date {
    if (self.typeIdentifier == 1) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd"];
        self.dateLabel.text = [formatter stringFromDate:date];
    }
}

- (BOOL)loaded {
    if (self.titleLabel != nil | self.bkgndImage != nil)
        return true;
    else
        return false;
}

- (UIColor *)averageColorWithImage:(UIImage *)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if(rgba[3] > 0) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    }
    else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
}

@end
