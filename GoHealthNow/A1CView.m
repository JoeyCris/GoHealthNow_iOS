//
//  A1CView.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-03.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "A1CView.h"
#import "UIColor+Extensions.h"
#import "StyleManager.h"

@interface A1CView() <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation A1CView

static NSUInteger const A1CLEVEL_TAG_NUMBER_PICKER = 1;
static NSUInteger const A1CLEVEL_TAG_DECIMAL_PICKER = 2;
static NSUInteger const A1CLEVEL_TAG_DECIMAL_DOT = 3;

#pragma mark - Setters/Getters
- (void)setValue:(float)value {
    _value = value;
    
    NSUInteger firstA1cPickerSelectedRow = floor(value);
    NSUInteger secondA1cPickerSelectedRow = (value - firstA1cPickerSelectedRow) * 10;
    
    UIPickerView *a1cLevelNumberPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER];
    UIPickerView *a1cLevelDecimalPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_DECIMAL_PICKER];
    
    [a1cLevelNumberPicker selectRow:firstA1cPickerSelectedRow inComponent:0 animated:NO];
    [a1cLevelDecimalPicker selectRow:secondA1cPickerSelectedRow inComponent:0 animated:NO];
}

#pragma mark - View life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIPickerView *a1cLevelNumberPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER];
        UIPickerView *a1cLevelDecimalPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_DECIMAL_PICKER];
        UILabel *a1cLevelDecimalDot = (UILabel *)[self viewWithTag:A1CLEVEL_TAG_DECIMAL_DOT];
        
        [StyleManager stylelabel:a1cLevelDecimalDot];
        
        a1cLevelNumberPicker.delegate = self;
        a1cLevelNumberPicker.dataSource = self;
        a1cLevelDecimalPicker.delegate = self;
        a1cLevelDecimalPicker.dataSource = self;
        
        self.value = 5.5;
    }
    
    return self;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView == (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER])
        return 20;
    return 10;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UIPickerView *levelNumberPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER];
    UIPickerView *levelDecimalPicker = (UIPickerView *)[self viewWithTag:A1CLEVEL_TAG_DECIMAL_PICKER];
    
    NSString* level = [NSString stringWithFormat:@"%ld.%ld",
                       (long)[levelNumberPicker selectedRowInComponent:0],
                       (long)[levelDecimalPicker selectedRowInComponent:0]];
    
    _value = [level floatValue];
}

@end
