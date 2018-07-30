//
//  WeightHelper.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "WeightHelper.h"
#import "UIColor+Extensions.h"

@interface WeightHelper() <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation WeightHelper

#pragma mark - Getters/Setters

- (void)setWeight:(WeightUnit *)weight {
    _weight = weight;
    [self updatePickerWithWeight:weight];
}

- (void)setUnitMode:(MeasureUnit)unitMode {
    _unitMode = unitMode;
    [self updatePickerWithWeight:self.weight];
}

#pragma mark - Object life cycle

- (instancetype)init {
    if ([super init]) {
        _weightPickerView = [[UIPickerView alloc] init];
        _weightPickerView.dataSource = self;
        _weightPickerView.delegate = self;
        
        self.weight = [[WeightUnit alloc] initWithMetric:75.0];
        [self updatePickerWithWeight:self.weight];
        
        // http://stackoverflow.com/questions/9767234/why-wont-uipickerview-resize-the-first-time-i-change-device-orientation-on-its
        [[NSNotificationCenter defaultCenter] addObserver:self.weightPickerView
                                                 selector:@selector(setNeedsLayout)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
        
    }
    
    return self;
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
