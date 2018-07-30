//
//  ChooseHeightViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-19.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseHeightViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"

@interface ChooseHeightViewController () <UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIPickerView *feetPicker;
@property (weak, nonatomic) IBOutlet UIPickerView *inchesPicker;
@property (weak, nonatomic) IBOutlet UILabel *feetLabel;
@property (weak, nonatomic) IBOutlet UILabel *inchesLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@property (nonatomic) UIPickerView *cmPicker;
@property (nonatomic) NSLayoutConstraint *cmPickerProportionalHeightConstraint;

@end

@implementation ChooseHeightViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    [StyleManager stylelabel:self.noteLabel];
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.navBar.delegate = self;
    
    if (!self.initialHeight) {
        self.initialHeight = [[LengthUnit alloc] initWithMetric:170.0];
    }
    
    if (self.unitMode == MUnitMetric) {
        self.cmPicker = [[UIPickerView alloc] init];
        self.cmPicker.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.cmPicker.delegate = self;
        self.cmPicker.dataSource = self;
        
        // set contraints
        self.inchesPicker.hidden = YES;
        self.feetPicker.hidden = YES;
        self.feetLabel.hidden = YES;
        self.inchesLabel.hidden = YES;
        
        [self.view addSubview:self.cmPicker];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.cmPicker addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:168.0]];
        
        NSUInteger heightValue = (NSUInteger)[self.initialHeight valueWithMetric];
        
        NSUInteger component0Row = heightValue % 1000 / 100;
        NSUInteger component1Row = heightValue % 100 / 10;
        NSUInteger component2Row =  heightValue % 10;
        
        [self.cmPicker selectRow:component0Row inComponent:0 animated:NO];
        [self.cmPicker selectRow:component1Row inComponent:1 animated:NO];
        [self.cmPicker selectRow:component2Row inComponent:2 animated:NO];
        
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:HEIGHT_DISPLAY_METRIC];
    }
    else {
        // set contraints
        self.inchesPicker.hidden = NO;
        self.feetPicker.hidden = NO;
        self.feetLabel.hidden = NO;
        self.inchesLabel.hidden = NO;
        
        [StyleManager stylelabel:self.feetLabel];
        [StyleManager stylelabel:self.inchesLabel];
        
        self.feetPicker.delegate = self;
        self.feetPicker.dataSource = self;
        
        self.inchesPicker.delegate = self;
        self.inchesPicker.dataSource = self;
        
        NSDictionary *feetInchesDict = [self.initialHeight valueWithImperial];
        
        [self.feetPicker selectRow:[feetInchesDict[IMPERIAL_UNIT_HEIGHT_FEET] integerValue] inComponent:0 animated:NO];
        [self.inchesPicker selectRow:[feetInchesDict[IMPERIAL_UNIT_HEIGHT_INCHES] integerValue] inComponent:0 animated:NO];
        
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:HEIGHT_DISPLAY_IMPERIAL];
    }
    
    [self setupOrientationSpecificViews];
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [self.recordButton setTitle:MSG_CONTINUE forState:UIControlStateNormal];
    }
    
    // http://stackoverflow.com/questions/9767234/why-wont-uipickerview-resize-the-first-time-i-change-device-orientation-on-its
    [[NSNotificationCenter defaultCenter] addObserver:self.feetPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.inchesPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.cmPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.unitMode == MUnitMetric && !self.feetLabel.hidden) {
        self.cmPicker = [[UIPickerView alloc] init];
        self.cmPicker.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.cmPicker.delegate = self;
        self.cmPicker.dataSource = self;
        
        // set contraints
        self.inchesPicker.hidden = YES;
        self.feetPicker.hidden = YES;
        self.feetLabel.hidden = YES;
        self.inchesLabel.hidden = YES;
        
        [self.view addSubview:self.cmPicker];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [self.cmPicker addConstraint:[NSLayoutConstraint constraintWithItem:self.cmPicker
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:168.0]];
        
        NSUInteger heightValue = (NSUInteger)[self.initialHeight valueWithMetric];
        
        NSUInteger component0Row = heightValue % 1000 / 100;
        NSUInteger component1Row = heightValue % 100 / 10;
        NSUInteger component2Row =  heightValue % 10;
        
        [self.cmPicker selectRow:component0Row inComponent:0 animated:NO];
        [self.cmPicker selectRow:component1Row inComponent:1 animated:NO];
        [self.cmPicker selectRow:component2Row inComponent:2 animated:NO];
        
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:HEIGHT_DISPLAY_METRIC];
    }
    
    if (self.unitMode == MUnitImperial && self.feetLabel.hidden) {
        // set contraints
        self.inchesPicker.hidden = NO;
        self.feetPicker.hidden = NO;
        self.feetLabel.hidden = NO;
        self.inchesLabel.hidden = NO;
        
        //remove
        
        [self.cmPicker removeFromSuperview];
        
        [StyleManager stylelabel:self.feetLabel];
        [StyleManager stylelabel:self.inchesLabel];
        
        self.feetPicker.delegate = self;
        self.feetPicker.dataSource = self;
        
        self.inchesPicker.delegate = self;
        self.inchesPicker.dataSource = self;
        
        NSDictionary *feetInchesDict = [self.initialHeight valueWithImperial];
        
        [self.feetPicker selectRow:[feetInchesDict[IMPERIAL_UNIT_HEIGHT_FEET] integerValue] inComponent:0 animated:NO];
        [self.inchesPicker selectRow:[feetInchesDict[IMPERIAL_UNIT_HEIGHT_INCHES] integerValue] inComponent:0 animated:NO];
        
        self.navBar.topItem.title = [LocalizationManager getStringFromStrId:HEIGHT_DISPLAY_IMPERIAL];
    }
    
    [self setupOrientationSpecificViews];
    
    // http://stackoverflow.com/questions/9767234/why-wont-uipickerview-resize-the-first-time-i-change-device-orientation-on-its
    [[NSNotificationCenter defaultCenter] addObserver:self.feetPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.inchesPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self.cmPicker
                                             selector:@selector(setNeedsLayout)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [super viewWillAppear:animated];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self.feetPicker];
    [[NSNotificationCenter defaultCenter] removeObserver:self.inchesPicker];
    [[NSNotificationCenter defaultCenter] removeObserver:self.cmPicker];
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.unitMode == MUnitMetric ? 3 : 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (self.unitMode == MUnitMetric) {
        return component == 0 ? 3 : 10;
    }
    else { // imperial
        return pickerView == self.feetPicker ? 10 : 12;
    }
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if (pickerView == self.feetPicker) {
        // set the border color of the selection indicator
        [[self.feetPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[self.feetPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    }
    else if (pickerView == self.inchesPicker) {
        // set the border color of the selection indicator
        [[self.inchesPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[self.inchesPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    }
    else if (pickerView == self.cmPicker) {
        // set the border color of the selection indicator
        [[self.cmPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[self.cmPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    }
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - Methods
- (LengthUnit*)getPickerValue {
    LengthUnit *height = [[LengthUnit alloc] init];
    
    if (self.unitMode == MUnitMetric) {
        NSUInteger selectedComponent0Row = [self.cmPicker selectedRowInComponent:0];
        NSUInteger selectedComponent1Row = [self.cmPicker selectedRowInComponent:1];
        NSUInteger selectedComponent2Row = [self.cmPicker selectedRowInComponent:2];
        
        NSUInteger selectedHeight = [[NSString stringWithFormat:@"%ld%ld%ld", (unsigned long)selectedComponent0Row, (unsigned long)selectedComponent1Row, (unsigned long)selectedComponent2Row] integerValue];
        [height setValueWithMetric:(int)selectedHeight];
    }
    else {
        NSUInteger feetPickerSelectedRow = [self.feetPicker selectedRowInComponent:0];
        NSUInteger inchesPickerSelectedRow = [self.inchesPicker selectedRowInComponent:0];
        
        [height setValueWithImperial:(char)feetPickerSelectedRow :(char)inchesPickerSelectedRow];
    }
    return height;
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self.delegate doHeightViewReverse];
    }
}

#pragma mark - User Setup Protocol

- (void)didFlipForwardToNextPageWithGesture:(id)sender {
    LengthUnit *height = [self getPickerValue];

    if (height.valueWithMetric < CHOOSE_HEIGHT_LOWER_HEIGHT_BOUND) {  //check the height is legal or not
        UIAlertView *heightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_HEIGHT_WARNING_MSG] message:nil delegate:self cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [heightAlert show];
    }
    else {
        [self didTapRecordButton:sender];
    }
}

#pragma mark - Event Handlers

- (BOOL)verifyHeight {
    if ([self getPickerValue].valueWithMetric < CHOOSE_HEIGHT_LOWER_HEIGHT_BOUND)
        return NO;
    return YES;
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    LengthUnit *height = [self getPickerValue];
    
    if (height.valueWithMetric < CHOOSE_HEIGHT_LOWER_HEIGHT_BOUND) {  //check the height is legal or not
        UIAlertView *heightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_HEIGHT_WARNING_MSG] message:nil delegate:nil cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [heightAlert show];
    }
    else {
        self.initialHeight = height;
        
        [self.delegate didChooseHeight:height sender:sender];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)setupOrientationSpecificViews {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            if (self.cmPicker) {
                self.cmPickerProportionalHeightConstraint = [NSLayoutConstraint constraintWithItem:self.cmPicker
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                         relatedBy:NSLayoutRelationEqual
                                                                                            toItem:self.view
                                                                                         attribute:NSLayoutAttributeHeight
                                                                                        multiplier:0.5
                                                                                          constant:0.0];
                [self.view addConstraint:self.cmPickerProportionalHeightConstraint];
            }
            break;
        default:
            if (self.cmPicker && self.cmPickerProportionalHeightConstraint) {
                [self.view removeConstraint:self.cmPickerProportionalHeightConstraint];
            }
            break;
    }
}

@end
