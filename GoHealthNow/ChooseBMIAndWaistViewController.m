//
//  ChooseBMIAndWaistViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseBMIAndWaistViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "User.h"
#import "GGWebBrowserProxy.h"

@interface ChooseBMIAndWaistViewController () <UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIPickerView *waistSizePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *waistSizeDecimalPickerView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiNoteLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiValueDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiCategoryDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bmiCategoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *waistSizeDecimalLabel;

@end

@implementation ChooseBMIAndWaistViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    [StyleManager stylelabel:self.noteLabel];
    [StyleManager stylelabel:self.bmiNoteLabel];
    [StyleManager stylelabel:self.bmiValueDescriptionLabel];
    [StyleManager stylelabel:self.bmiCategoryDescriptionLabel];
    [StyleManager stylelabel:self.waistSizeDecimalLabel];
    
    self.bmiValueLabel.textColor = [UIColor blueTextColor];
    self.bmiCategoryLabel.textColor = [UIColor blueTextColor];
    
    self.bmiNoteLabel.numberOfLines = 0;
    self.bmiNoteLabel.lineBreakMode = NSLineBreakByWordWrapping;

    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // for some reason, using size classes in Interface Builder means
    // that setting fonts programmatically doesn't work. So, we have to do
    // everything programmatically
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.bmiValueDescriptionLabel.font = [UIFont systemFontOfSize:14.0];
        self.bmiCategoryDescriptionLabel.font = [UIFont systemFontOfSize:14.0];
        self.bmiValueLabel.font = [UIFont systemFontOfSize:13.0];
        self.bmiCategoryLabel.font = [UIFont systemFontOfSize:13.0];
        
        if (IS_IPHONE_4_OR_LESS) {
            self.bmiNoteLabel.font = [UIFont systemFontOfSize:15.0];
        }
    }
    else if (IS_IPAD) {
        self.bmiValueDescriptionLabel.font = [UIFont systemFontOfSize:19.0];
        self.bmiCategoryDescriptionLabel.font = [UIFont systemFontOfSize:19.0];
        self.bmiValueLabel.font = [UIFont systemFontOfSize:19.0];
        self.bmiCategoryLabel.font = [UIFont systemFontOfSize:19.0];
        
        self.bmiNoteLabel.font = [UIFont systemFontOfSize:19.0];
        self.noteLabel.font = [UIFont systemFontOfSize:13.0];
    }
    
    self.navBar.delegate = self;
    
    self.waistSizePickerView.delegate = self;
    self.waistSizePickerView.dataSource = self;
    self.waistSizeDecimalPickerView.delegate = self;
    self.waistSizeDecimalPickerView.dataSource = self;
    
    if (!self.initialWaistSize) {
        self.initialWaistSize = [[LengthUnit alloc] initWithMetric:80.0];
    }
    
    float waistSizeValue = 0;
    
    if (self.unitMode == MUnitMetric) {
        waistSizeValue = [self.initialWaistSize valueWithMetric];
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:BMI_WAIST_DISPLAY_METRIC];
    }
    else {
        waistSizeValue = [self.initialWaistSize valueWithImperialInchesOnly];
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:BMI_WAIST_DISPLAY_IMPERIAL];
    }
    
    // can't handle a bigger waist than 299.9
    if (waistSizeValue >= 300) {
        waistSizeValue = 0;
    }
    
    NSUInteger waistSizeValueFloored = floor(waistSizeValue);
    NSUInteger waistSizeComponent0Row = waistSizeValueFloored / 100 % 10;
    NSUInteger waistSizeComponent1Row = waistSizeValueFloored / 10 % 10;
    NSUInteger waistSizeComponent2Row = waistSizeValueFloored % 10;
    
    float waistSizeDelta = waistSizeValue - waistSizeValueFloored;
    NSUInteger waistSizeDecimalComponent0Row =  (roundf(10 * (waistSizeDelta)) / 10.0) * 10;
    
    [self.waistSizePickerView selectRow:waistSizeComponent0Row inComponent:0 animated:NO];
    [self.waistSizePickerView selectRow:waistSizeComponent1Row inComponent:1 animated:NO];
    [self.waistSizePickerView selectRow:waistSizeComponent2Row inComponent:2 animated:NO];
    [self.waistSizeDecimalPickerView selectRow:waistSizeDecimalComponent0Row inComponent:0 animated:NO];
    
    User *user = [User sharedModel];
    self.bmiValueLabel.text = [NSString stringWithFormat:@"%.1f", [user.bmi getValue]];
    self.bmiCategoryLabel.text = [user.bmi categoryDescription];
    
    UIButton *bmiInfoLinkButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [bmiInfoLinkButton addTarget:self action:@selector(didTapWHOInfoButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navBar.topItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:bmiInfoLinkButton];
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CONTINUE] forState:UIControlStateNormal];
    }
    
    [self setupOrientationSpecificViews];
    
    // http://stackoverflow.com/questions/9767234/why-wont-uipickerview-resize-the-first-time-i-change-device-orientation-on-its
    [[NSNotificationCenter defaultCenter] addObserver:self.waistSizePickerView
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.waistSizeDecimalPickerView
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.waistSizePickerView];
    [[NSNotificationCenter defaultCenter] removeObserver:self.waistSizeDecimalPickerView];
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.waistSizePickerView) {
        return 3;
    }
    else if (pickerView == self.waistSizeDecimalPickerView) {
        return 1;
    }
    else {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView == self.waistSizePickerView && component == 0) {
        return 3;
    }
    
    return 10;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == self.waistSizePickerView) {
        // set the border color of the selection indicator
        [[self.waistSizePickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[self.waistSizePickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    }
    else if (pickerView == self.waistSizeDecimalPickerView) {
        // set the border color of the selection indicator
        [[self.waistSizeDecimalPickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[self.waistSizeDecimalPickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    }
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (roundf([self waistSizeValue]) == 0.0) {
        self.recordButton.enabled = NO;
    }
    else {
        self.recordButton.enabled = YES;
    }
}

#pragma mark - User Setup Protocol

- (void)didFlipForwardToNextPageWithGesture:(id)sender {
    [self didTapRecordButton:sender];
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    LengthUnit *waistSize = [[LengthUnit alloc] init];
    float waistSizeValue = [self waistSizeValue];
    
    if (self.unitMode == MUnitMetric) {
        [waistSize setValueWithMetric:waistSizeValue];
    }
    else {
        [waistSize setValueWithImperialWithInches:waistSizeValue];
    }
    
    [self.delegate didChooseWaistSize:waistSize sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapWHOInfoButton:(id)sender {
    UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:@"http://www.cdc.gov/healthyweight/assessing/bmi/adult_bmi/"];
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark - Methods

- (float)waistSizeValue {
    NSUInteger selectedWaistComponent0Row = [self.waistSizePickerView selectedRowInComponent:0];
    NSUInteger selectedWaistComponent1Row = [self.waistSizePickerView selectedRowInComponent:1];
    NSUInteger selectedWaistComponent2Row = [self.waistSizePickerView selectedRowInComponent:2];
    
    NSUInteger selectedWaistDecimalComponent0Row = [self.waistSizeDecimalPickerView selectedRowInComponent:0];
    
    float waistSizeValue = [[NSString stringWithFormat:@"%ld%ld%ld.%ld", (unsigned long)selectedWaistComponent0Row,
                             (unsigned long)selectedWaistComponent1Row,
                             (unsigned long)selectedWaistComponent2Row,
                             (unsigned long)selectedWaistDecimalComponent0Row] floatValue];
    
    return waistSizeValue;
}

- (void)setupOrientationSpecificViews {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            if (IS_IPHONE) {
                self.bmiValueDescriptionLabel.hidden = YES;
                self.bmiCategoryDescriptionLabel.hidden = YES;
                self.bmiValueLabel.hidden = YES;
                self.bmiCategoryLabel.hidden = YES;
                self.noteLabel.hidden = YES;
            }
            break;
        default:
            self.bmiValueDescriptionLabel.hidden = NO;
            self.bmiCategoryDescriptionLabel.hidden = NO;
            self.bmiValueLabel.hidden = NO;
            self.bmiCategoryLabel.hidden = NO;
            self.noteLabel.hidden = NO;
            break;
    }
}

@end
