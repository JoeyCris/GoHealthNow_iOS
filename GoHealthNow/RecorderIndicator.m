//
//  RecorderIndicator.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2017-02-01.
//  Copyright © 2017 GlucoGuide. All rights reserved.
//

#import "RecorderIndicator.h"
#import "GGUtils.h"

@interface RecorderIndicator()

@property (nonatomic) UIImageView *micImageView;

@property (nonatomic) UILabel *recordingLabel;
@property (nonatomic) UILabel *timeLabel;
@property (nonatomic) UILabel *tipsLabel;

@property (nonatomic) UIBlurEffect *blur;
@property (nonatomic) UIVisualEffectView *blurView;

@property (nonatomic) UIView* parent;

@property (nonatomic) UIView* baseView;

@end

static float const VIEW_ALPHA = 0.95f;

@implementation RecorderIndicator

- (id)init {
    if (self = [super init]) {
        [self initElements];
    }
    return self;
}

-(id)initWithRecordingLabelString:(NSString*)rlString andTimeLabelStr:(NSString*)tlString andTipsLabelStr:(NSString*)tipStr andImageName:(NSString*)imageName andParentView:(UIView *)view{
    if (self = [super init]) {
        self.alpha = VIEW_ALPHA;
        [self initElements];
        [self.recordingLabel setText:rlString];
        [self.timeLabel setText:tlString];
        [self.tipsLabel setText:tipStr];
        [self.micImageView setImage:[UIImage imageNamed:imageName]];
        self.parent = view;
        self.baseView = [[UIView alloc] initWithFrame:CGRectMake(self.parent.frame.size.width - 300,
                                                                40, 280, 100)];
        [self draw];
    }
    return self;
}

-(void)show {
    [self.parent addSubview:self.baseView];
}

-(void)hide {
    [self.baseView removeFromSuperview];
}

-(void)setParentView:(UIView*)view {
    self.parent = view;
}


-(void)initElements {
    self.recordingLabel = [[UILabel alloc] init];
    self.timeLabel = [[UILabel alloc] init];
    self.tipsLabel = [[UILabel alloc] init];
    self.blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:self.blur];
    self.micImageView = [[UIImageView alloc] init];
}

-(void)draw {
    [self.blurView setFrame:CGRectMake(0, 0, self.baseView.frame.size.width, self.baseView.frame.size.height)];
    
    [self.micImageView setFrame:CGRectMake(10, 16, 40, 40)];
    [self.blurView.contentView addSubview:self.micImageView];
    
    [self.recordingLabel setFrame:CGRectMake(self.micImageView.frame.origin.x + self.micImageView.frame.size.width + 8,
                                             self.micImageView.frame.origin.y,
                                             self.baseView.frame.size.width * 0.65 - self.micImageView.frame.origin.x - self.micImageView.frame.size.width - 8,
                                             self.micImageView.frame.size.height)];
    [self.recordingLabel setTextColor:[UIColor whiteColor]];
    if ([GGUtils getSystemLanguageSetting] == AppLanguageFr)
        [self.recordingLabel setFont:[UIFont systemFontOfSize:16]];
    [self.blurView.contentView addSubview:self.recordingLabel];
    
    [self.timeLabel setFrame:CGRectMake(self.recordingLabel.frame.origin.x + self.recordingLabel.frame.size.width + 8,
                                        self.micImageView.frame.origin.y,
                                        self.baseView.frame.size.width - self.recordingLabel.frame.origin.x - self.recordingLabel.frame.size.width - 8,
                                        self.micImageView.frame.size.height)];
    [self.timeLabel setTextColor:[UIColor whiteColor]];
    [self.blurView.contentView addSubview:self.timeLabel];
    
    [self.tipsLabel setFrame:CGRectMake(self.recordingLabel.frame.origin.x,
                                        self.recordingLabel.frame.origin.y + self.recordingLabel.frame.size.height + 8,
                                        self.baseView.frame.size.width * 0.7,
                                        20)];
    [self.tipsLabel setFont:[UIFont systemFontOfSize:12]];
    [self.tipsLabel setTextColor:[UIColor whiteColor]];
    [self.blurView.contentView addSubview:self.tipsLabel];
    
    
    self.baseView.alpha = VIEW_ALPHA;
    self.blurView.alpha = VIEW_ALPHA;

    self.baseView.layer.cornerRadius = 8.0f;
    
    [self.baseView addSubview:self.blurView];
    
    self.baseView.clipsToBounds = YES;
}

-(void)setRecordingLabelWithString:(NSString*)string {
    [self.recordingLabel setText:string];
}

-(void)setTimeLabelWithString:(NSString*)string {
    [self.timeLabel setText:string];
}

-(void)setTipsLabelWithString:(NSString*)string {
    [self.tipsLabel setText:string];
}

-(void)setImageWithImageName:(NSString*)string {
    [self.micImageView setImage:[UIImage imageNamed:string]];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
