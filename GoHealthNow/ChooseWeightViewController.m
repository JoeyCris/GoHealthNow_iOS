//
//  ChooseWeightViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-18.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseWeightViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "User.h"
#import "UIView+Extensions.h"
#import "Constants.h"

@interface ChooseWeightViewController () <UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *weightPickerView;

@property (nonatomic) WeightUnit *weight;
@end

@implementation ChooseWeightViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    [StyleManager stylelabel:self.noteLabel];

    self.navBar.delegate = self;
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (IS_IPHONE){
        self.noteLabel.font = [UIFont systemFontOfSize:11.0];
    }
    else {
        self.noteLabel.font = [UIFont systemFontOfSize:13.0];
        self.noteLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    self.noteLabel.clipsToBounds = YES;
    self.weightPickerView.clipsToBounds = YES;
    
    self.weight = [[WeightUnit alloc] initWithMetric:75.0];
    [self updatePickerWithWeight:self.weight];
    [[NSNotificationCenter defaultCenter] addObserver:self.weightPickerView
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *navBarTitleMetric = nil;
    
    if (!self.isUserSetupModeEnabled) {
        User *user = [User sharedModel];
        
        self.unitMode = user.measureUnit;
        self.initialWeight = user.weight;
    }

    if ([self.initialWeight valueWithMetric] != 0.0) {
        self.weight = self.initialWeight;
    }
    
    [self updatePickerWithWeight:self.weight];
    if (self.unitMode == MUnitMetric) {
        navBarTitleMetric = [NSString stringWithFormat:@"(%@)", [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_METRIC]];
    }
    else {
        navBarTitleMetric = [NSString stringWithFormat:@"(%@)", [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_IMPERIAL]];
    }
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.title = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight %@"], navBarTitleMetric];
        self.navBar.topItem.leftBarButtonItem = nil;
        self.navBar.topItem.rightBarButtonItem = nil;
        [self.recordButton setTitle:MSG_CONTINUE forState:UIControlStateNormal];
    }
    else {
        [self.navBar removeFromSuperview];
        self.navigationItem.title = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"New Weight Record %@"], navBarTitleMetric];
        
        self.noteLabel.text = [LocalizationManager getStringFromStrId:@"Weigh yourself on the same scale and at the same time of day to accurately track your weight"];
    }
    
    [self setupOrientationSpecificViews];
    [self.weightPickerView reloadAllComponents];

}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self setupOrientationSpecificViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.delegate doWeightViewReverse];
    }
}

#pragma mark - User Setup Protocol

- (void)didFlipForwardToNextPageWithGesture:(id)sender {
    if (self.verifyWeight) {
        [self didTapRecordButton:sender];
    }
    else {
        UIAlertView *weightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_WEIGHT_WARNING_MSG] message:nil delegate:self cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [weightAlert show];
    }
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    if ([self verifyWeight]) {
        if (self.delegate && self.isUserSetupModeEnabled) {
            [self.delegate didChooseWeight:self.weight sender:sender];
        }
        else {
            [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
            
            dispatch_promise(^{
                // we are using the weight screen from the main tab bar
                User *user = [User sharedModel];
                [user addWeightRecord:self.weight :[NSDate date]].then(^(BOOL success)
                                                                       {
                                                                           UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                                                                                 message:[LocalizationManager getStringFromStrId:ADD_RECORD_SUCESS_MSG]
                                                                                                                                delegate:nil
                                                                                                                       cancelButtonTitle:nil
                                                                                                                       otherButtonTitles:nil];
                                                                           [promptAlert show];
                                                                           
                                                                           [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                                            target:self
                                                                                                          selector:@selector(dismissRecordPromptAlert:)
                                                                                                          userInfo:promptAlert
                                                                                                           repeats:NO];
                                                                       }).catch(^(BOOL success) {
                                                                           UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                                                                                 message:[LocalizationManager getStringFromStrId:ADD_RECORD_FAILURE_MSG]
                                                                                                                                delegate:nil
                                                                                                                       cancelButtonTitle:nil
                                                                                                                       otherButtonTitles:nil];
                                                                           [promptAlert show];
                                                                           
                                                                           [NSTimer scheduledTimerWithTimeInterval:1.0
                                                                                                            target:self
                                                                                                          selector:@selector(dismissRecordPromptAlert:)
                                                                                                          userInfo:promptAlert
                                                                                                           repeats:NO];
                                                                       }).finally(^{
                                                                           [self.view hideActivityIndicatorWithNetworkIndicatorOff];
                                                                       });
            });
        }
    }
    else {
        UIAlertView *weightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_WEIGHT_WARNING_MSG] message:nil delegate:nil cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [weightAlert show];
    }
    
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

#pragma mark - Methods

- (BOOL)verifyWeight {
    if (self.weight.valueWithMetric < CHOOSE_WEIGHT_LOWER_WEIGHT_BOUND) {
        return NO;
    }
    return YES;
}

- (void)setupOrientationSpecificViews
{
    if (!self.isUserSetupModeEnabled) {
        // TODO: temp hack to deal with the following UI quirk:
        // for some reason, autolayout doesn't vertically centre the wieght picker
        // properly so we have to hide it and manually set the constant below.
        // Note that this only happens when the view is encapsulated within the
        // UINavigationController
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
            case UIDeviceOrientationLandscapeRight:
                if (IS_IPHONE) {
                    self.noteLabel.hidden = YES;
                }
                break;
            default:
                self.noteLabel.hidden = NO;
                break;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.weightPickerView];
}


#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (component) {
        case 0:
            if (self.unitMode == MUnitMetric) {
                return 3;
            }
            else {
                return 4;
            }
        default:
            return 10;
    }
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[self.weightPickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[self.weightPickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger selectedComponent0Row = [self.weightPickerView selectedRowInComponent:0];
    NSUInteger selectedComponent1Row = [self.weightPickerView selectedRowInComponent:1];
    NSUInteger selectedComponent2Row = [self.weightPickerView selectedRowInComponent:2];
    
    NSUInteger weightValue = [[NSString stringWithFormat:@"%ld%ld%ld", (long)selectedComponent0Row, (long)selectedComponent1Row, (long)selectedComponent2Row] integerValue];
    
    if (self.unitMode == MUnitMetric) {
        [self.weight setValueWithMetric:weightValue];
    }
    else {
        [self.weight setValueWithImperial:weightValue];
    }
}

#pragma mark - Methods

- (void)updatePickerWithWeight:(WeightUnit *)weight {
    NSUInteger weightValue = self.unitMode == MUnitMetric ? [weight valueWithMetric] : [weight valueWithImperial];
    
    NSUInteger component0Row = weightValue % 1000 / 100;
    NSUInteger component1Row = weightValue % 100 / 10;
    NSUInteger component2Row =  weightValue % 10;
    
    [self.weightPickerView selectRow:component0Row inComponent:0 animated:NO];
    [self.weightPickerView selectRow:component1Row inComponent:1 animated:NO];
    [self.weightPickerView selectRow:component2Row inComponent:2 animated:NO];
}


@end
