//
//  GGTabBar.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2015-10-23.
//  Copyright © 2015 GlucoGuide. All rights reserved.
//

#import "GGTabBar.h"
#import "UIColor+Extensions.h"

#import "AddGlucoseRecordViewController.h"
#import "DosageInputViewController.h"
#import "RecentMealsController.h"
#import "NotificationMedicationClass.h"
#import "AddBloodPressureViewController.h"
#import "User.h"
#import "GGUtils.h"

#import "Constants.h"

@interface GGTabBar()

@property (nonatomic, weak) UIButton *addButton;
@property (nonatomic) BOOL isListShown;
@property (nonatomic) UIView *maskView;

@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) NSArray *res;

@property (nonatomic) UILabel *titleLabel;

@property (nonatomic) CGFloat boundWidth;
@property (nonatomic) CGFloat boundHeight;

@end

@implementation GGTabBar

#pragma mark - Methods


-(UIButton *)addButton
{
    if (_addButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [btn setImage:[UIImage imageNamed:@"plusIcon"] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor buttonColor]];

        _addButton = btn;
        
        btn.frame = CGRectMake(self.boundWidth/5*2, -self.boundHeight*0.1, self.boundWidth/5, self.boundHeight);
        
        [self addButtonShadow];

        [self addSubview:_addButton];
        
        _isListShown = NO;
        
    }
    return _addButton;
}

-(void)layoutSubviews
{
    self.boundWidth = self.bounds.size.width;
    self.boundHeight = self.bounds.size.height - (IS_IPHONE_X ? 32: 0);
    
    [super layoutSubviews];
    
    CGFloat w = self.boundWidth;
    CGFloat h = self.boundHeight;
    
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = w / 5;
    CGFloat btnH = h;
    
    int i = 0;
    
    for (UIView *tabBarBtn in self.subviews) {
        if ([tabBarBtn isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            btnX = i * btnW;
            tabBarBtn.frame = CGRectMake(btnX, btnY, btnW/2, btnH);
            tabBarBtn.center = CGPointMake(btnX+btnW/2, btnY+btnH/2);
            i==1?i++:i; // if 2nd button, then jump, to give center btn space
            i++;
        }
    }
    self.addButton.center = CGPointMake(w * 0.5, h * 0.45);
    
    [self.addButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
}

-(void)addButtonShadow {
    _addButton.clipsToBounds = NO;
    _addButton.layer.shadowColor = [[UIColor buttonColor] CGColor];
    _addButton.layer.shadowOffset = CGSizeMake(1.5,1.5);
    _addButton.layer.shadowOpacity = 0.85;
    _addButton.layer.shadowRadius = 5;
}

-(void)removeButtonShadow {
    _addButton.layer.shadowOffset = CGSizeMake(0,0);
    _addButton.layer.shadowOpacity = 0;
    _addButton.layer.shadowRadius = 0;
}

-(void)toggleMaskView:(BOOL)show {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (show) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height)];
        _maskView.alpha = 0.8;
        _maskView.backgroundColor = [UIColor blackColor];
        [window.rootViewController.view addSubview:_maskView];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonTapped)];
        [_maskView addGestureRecognizer:tap];
    }
    else {
        [_maskView removeFromSuperview];
    }
}


#pragma mark - Event Handlers

-(void)logButtonTapped:(UIButton *)sender {
    long tag = sender.tag - 100;
    tag = tag==100? 200:tag;
    if (tag != 200) {
        UIViewController *myViewController;
        UIStoryboard *storyboard                     = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        myViewController = [storyboard  instantiateViewControllerWithIdentifier:_res[tag][2]];
        
//        if (tag == 0) {
//            ((RecentMealsController *)myViewController).isQuickAccess = YES;
//        }
        
        if ([_res[tag][2] isEqualToString:@"MedicationInputViewController"]) {
            [NotificationMedicationClass getInstance].stringComingFromWhere = @"logMedication";
        }

        UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];

        [topRootViewController presentViewController:navigationController
                                            animated:YES
                                          completion:nil];
    }
    [self buttonTapped];
}

-(NSArray *)getSelectedInputs{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    User *user = [User sharedModel];
    NSArray *preNamesArray = [[NSArray alloc] initWithArray: [NSMutableArray arrayWithArray:[[prefs objectForKey:@"userAndSelectedInputs"] objectForKey:user.userId]]];

    NSMutableArray *displayArray = [[NSMutableArray alloc]initWithCapacity:8];
    
    if ([[preNamesArray objectAtIndex:0]  isEqual:@YES]){
        [displayArray addObject:@[@"dietInputIcon", [LocalizationManager getStringFromStrId:@"Diet"], @"ID_MEAL_CAMERA_VIEW"]];
    }
    if ([[preNamesArray objectAtIndex:1]  isEqual:@YES]){
        [displayArray addObject: @[@"exerciseInputIcon", [LocalizationManager getStringFromStrId:@"Exercise"], @"exerciseViewController"]];
    }
    if ([[preNamesArray objectAtIndex:2]  isEqual:@YES]){
        [displayArray addObject:@[@"glucoseInputIcon", [LocalizationManager getStringFromStrId:@"Blood Glucose"], @"AddGlucoseRecordViewController"]];
    }
    if ([[preNamesArray objectAtIndex:3]  isEqual:@YES]){
        [displayArray addObject:@[@"bloodPressureInputIcon", [LocalizationManager getStringFromStrId:@"Blood Pressure"], @"AddBloodPressureViewController"]];
    }
    if ([[preNamesArray objectAtIndex:4]  isEqual:@YES]){
        [displayArray addObject:@[@"insulinInputIcon", [LocalizationManager getStringFromStrId:@"Medication"], @"MedicationInputViewController"]];
    }
    
    [displayArray addObject:@[@"cancelIconBold", @"", @""]];

    return displayArray;
    
}

-(void)buttonTapped {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    
    /*
    if (_res == nil) { //RecentMealsController
        
        _res = @[@[@"dietInputIcon", @"Diet", @"ID_MEAL_CAMERA_VIEW"],
                 @[@"exerciseInputIcon", @"Exercise", @"exerciseViewController"],
                 @[@"glucoseInputIcon", @"Blood Glucose", @"AddGlucoseRecordViewController"],
                 @[@"bloodPressureInputIcon", @"Blood Pressure", @"AddBloodPressureViewController"],
                 @[@"insulinInputIcon", @"Medication", @"MedicationInputViewController"],
                 @[@"cancelIconBold", @"", @""]];
    }
     */
    
    _res = [[NSArray alloc] initWithArray:[self getSelectedInputs]];
    
    if (_buttons == nil) {
        _buttons = [[NSMutableArray alloc] init];
        for (int i=(int)[_res count]-1;i>=0;i--) {
            UIButton *t = [[UIButton alloc] init];
            t.frame = CGRectMake(_addButton.frame.origin.x+_addButton.frame.size.width/2-self.boundHeight/2, window.frame.size.height + 20, self.boundHeight, self.boundHeight);
            [t setImage:[UIImage imageNamed:_res[i][0]] forState:UIControlStateNormal];
            t.tag = i+100;
            [t addTarget:self action:@selector(logButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            if ((i == [_res count]-1) && [_res[i][0] isEqualToString:@"cancelIconBold"]) {
                t.backgroundColor = [UIColor buttonColor];
                [t setImage:[UIImage imageNamed:@"cancelIconBold"] forState:UIControlStateNormal];
                t.clipsToBounds = YES;
                t.layer.cornerRadius = self.boundHeight/2;
                t.frame = CGRectMake(t.frame.origin.x, window.frame.size.height - self.boundHeight*0.07, t.frame.size.width, t.frame.size.height);
                t.tag = 200;
            }
            
            UIButton *l = [[UIButton alloc] init];
            l.frame = CGRectMake(t.frame.origin.x + t.frame.size.width + 15, window.frame.size.height + 20, 200, self.boundHeight);
            [l setTitle:_res[i][1] forState:UIControlStateNormal];
            l.titleLabel.textColor = [UIColor whiteColor];
            [l setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            [l addTarget:self action:@selector(logButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            l.tag = i+100;
            
            if ((i == [_res count]-1) && [_res[i][0] isEqualToString:@"cancelIconBold"]) {
                l.tag = 200;
            }
            
            [_buttons addObject:@[t, l]];
        }
    }
    else if (!_isListShown) {
        for (int i=(int)[_buttons count]-1;i>=0;i--) {
            UIButton *t = (UIButton *)_buttons[i][0];
            UIButton *l = (UIButton *)_buttons[i][1];
            t.frame = CGRectMake(_addButton.frame.origin.x+_addButton.frame.size.width/2-self.boundHeight/2, window.frame.size.height + 20, self.boundHeight, self.boundHeight);
            l.frame = CGRectMake(t.frame.origin.x + t.frame.size.width + 15, window.frame.size.height + 20, 200, self.boundHeight);
        }
    }
    
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-200, window.frame.size.height - ([_res count]*(10+self.boundHeight)), 200, 50)];
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel setText:[LocalizationManager getStringFromStrId:@"Quick log"]];
        _titleLabel.font = [UIFont systemFontOfSize:(IS_IPHONE_4_OR_LESS||IS_IPHONE_5 ? 25:30) - ([GGUtils getSystemLanguageSetting] == AppLanguageFr ? 18:0)];
    }
    
    if (_isListShown) {
        [UIView animateWithDuration:0.2 animations:^{
            _titleLabel.frame = CGRectMake(-200, window.frame.size.height - ([_res count]*(10+self.boundHeight)), 200, 50);
            for (int i=0;i<[_buttons count];i++) {
                UIButton *t = (UIButton *)_buttons[i][0];
                UIButton *l = (UIButton *) _buttons[i][1];
                t.frame = CGRectMake(_addButton.frame.origin.x+_addButton.frame.size.width/2-self.boundHeight/2,
                                     window.frame.size.height + 20,
                                     self.boundHeight,
                                     self.boundHeight);
                l.frame = CGRectMake(t.frame.origin.x + t.frame.size.width + 15,
                                     window.frame.size.height + 20,
                                     200,
                                     self.boundHeight);
                if (i>0) {
                    _addButton.hidden = NO;
                }
            }
        }
                         completion:^(BOOL finish) {
                             _addButton.hidden = NO;
                             [self toggleMaskView:NO];
                             [UIView animateWithDuration:0.2 animations:^{
                                 CGAffineTransform transform = _addButton.transform;
                                 transform = CGAffineTransformRotate(transform, -M_PI/4);
                                 _addButton.transform = transform;
                             }
                                              completion:^(BOOL finish){
                                                  [UIView animateWithDuration:0.2 animations:^{
                                                      _addButton.layer.cornerRadius = 0;
                                                  }
                                                                   completion:^(BOOL finish){
                                                                       [UIView animateWithDuration:0.2 animations:^{
                                                                           _addButton.frame = CGRectMake(self.boundWidth/5*2,
                                                                                                         -self.boundHeight*0.1,
                                                                                                         self.boundWidth/5,
                                                                                                         self.boundHeight);
                                                                       }
                                                                                        completion:^(BOOL finish){
                                                                                            [self addSubview:_addButton];
                                                                                            [self addButtonShadow];
                                                                                            
                                                                                            for (int i=0;i<[_buttons count];i++) {
                                                                                                ((UIButton *)_buttons[i][0]).hidden = YES;
                                                                                                ((UIButton *)_buttons[i][1]).hidden = YES;
                                                                                            }
                                                                                        }];
                                                                       
                                                                   }];
                                              }];
                         }];
        
        _isListShown = NO;
    }
    else {
        _isListShown = YES;
        _addButton.clipsToBounds = YES;
        [self toggleMaskView:YES];
        for (int i=0;i<[_buttons count];i++) {
            [window addSubview:_buttons[i][0]];
            [window addSubview:_buttons[i][1]];
            ((UIButton *)_buttons[i][0]).hidden = NO;
            ((UIButton *)_buttons[i][1]).hidden = NO;
        }
        _titleLabel.frame = CGRectMake(-200, window.frame.size.height - ([_res count]*(10+self.boundHeight)) - (IS_IPHONE_X ? 32:0), 200, 50);
        [window addSubview:_titleLabel];
        _addButton.frame = CGRectMake(_addButton.frame.origin.x, _addButton.frame.origin.y, self.boundHeight, self.boundHeight);
        _addButton.layer.cornerRadius = self.boundHeight / 2;
        [UIView animateWithDuration:0.2 animations:^{
            [self removeButtonShadow];
            for (int i=0;i<[_buttons count];i++) {
                UIButton *t = (UIButton *)_buttons[i][0];
                UIButton *l = (UIButton *) _buttons[i][1];
                t.frame = CGRectMake(t.frame.origin.x, window.frame.size.height - (i+1)*(t.frame.size.height+(i==0? self.boundHeight*0.07 : 10)) - (IS_IPHONE_X ? 32:0), t.frame.size.width, t.frame.size.height);
                l.frame = CGRectMake(l.frame.origin.x, window.frame.size.height - (i+1)*(t.frame.size.height+(i==0? self.boundHeight*0.07 : 10)) - (IS_IPHONE_X ? 32:0), l.frame.size.width, l.frame.size.height);
            }
        }
                         completion:^(BOOL finish){
                             _addButton.hidden = YES;
                            [UIView animateWithDuration:0.2 animations:^{
                                _titleLabel.frame = CGRectMake(_addButton.frame.origin.x - (IS_IPHONE_4_OR_LESS||IS_IPHONE_5 ? 130 : 155), _titleLabel.frame.origin.y, _titleLabel.frame.size.width, _titleLabel.frame.size.height);
                            }
                                                     completion:^(BOOL finish){
                                                         [UIView animateWithDuration:0.2 animations:^{
                                                             CGAffineTransform transform = _addButton.transform;
                                                             transform = CGAffineTransformRotate(transform, M_PI/4);
                                                             _addButton.transform = transform;
                                                         }];
                                                     }];
                         }];
        
        
    }
    
}

- (void)reDrawWithScreenSize:(CGSize)size {
    if (_isListShown) {
        for (int i=0;i<[_buttons count];i++) {
            UIButton *t = (UIButton *)_buttons[i][0];
            UIButton *l = (UIButton *) _buttons[i][1];
            t.center = CGPointMake(size.width / 2, (size.height - (i+1)*(t.frame.size.height+(i==0? self.boundHeight*0.07 : 10))) + t.frame.size.height / 2);
            l.frame = CGRectMake(t.frame.origin.x + t.frame.size.width + 15,
                                 t.frame.origin.y,
                                 200,
                                 self.boundHeight);
        }
        _titleLabel.frame = CGRectMake(size.width*0.45 - (IS_IPHONE_4_OR_LESS||IS_IPHONE_5 ? 130 : 155), size.height - ([_res count]*(10+self.boundHeight)), 200, 50);
    }
    _maskView.frame = CGRectMake(0, 0, size.width, size.height);
}

@end
