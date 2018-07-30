//
//  ChooseBirthYearViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseBirthYearViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"

@interface ChooseBirthYearViewController () <UINavigationBarDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *birthYearPicker;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@end

@implementation ChooseBirthYearViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    [StyleManager stylelabel:self.noteLabel];
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.navBar.delegate = self;
    
    self.birthYearPicker.delegate = self;
    self.birthYearPicker.dataSource = self;
    self.birthYearPicker.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.birthYearPicker addConstraint:[NSLayoutConstraint constraintWithItem:self.birthYearPicker
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1.0
                                                           constant:100.0]];
    
    if (!self.initialDob || [self.initialDob isKindOfClass:[NSNull class]]) {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setYear:1960];
        self.initialDob = [[NSCalendar currentCalendar] dateFromComponents:comps];
    }
    
    NSUInteger initialBirthYear = [ChooseBirthYearViewController yearFromDate:self.initialDob];
    [self.birthYearPicker selectRow:initialBirthYear - FIRST_AVAILABLE_BIRTH_YEAR inComponent:0 animated:NO];
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CONTINUE] forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    NSUInteger currentYear = [ChooseBirthYearViewController yearFromDate:[NSDate date]] + 1;
    return currentYear - FIRST_AVAILABLE_BIRTH_YEAR;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row + FIRST_AVAILABLE_BIRTH_YEAR];
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
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
    NSUInteger selectedRow = [self.birthYearPicker selectedRowInComponent:0];
    
    [self.delegate didChooseBirthYear:[ChooseBirthYearViewController dateFromYearComponent:selectedRow + FIRST_AVAILABLE_BIRTH_YEAR] sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Methods

+ (NSUInteger)yearFromDate:(NSDate *)date {
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date]; // Get necessary date components
    
    return [components year];
}

+(NSUInteger)ageFromDate:(NSDate*)birthDay
{
    NSDateComponents *components1;
    NSInteger birthDateYear;
    if (birthDay == nil) {
        components1 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:birthDay];
        birthDateYear  = [components1 year];
    }
    else {
        birthDateYear  = 1975;
    }
    
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    NSInteger currentDateYear  = [components2 year];

    return currentDateYear - birthDateYear;
}

+ (NSDate *)dateFromYearComponent:(NSUInteger) year {
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    dateComps.year = year;
    
    return [cal dateFromComponents:dateComps];
}

@end
