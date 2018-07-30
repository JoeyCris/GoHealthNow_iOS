//
//  ServingSizeView.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2015-05-27.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ServingSizeView.h"
#import "UIColor+Extensions.h"
#import "StyleManager.h"


@interface ServingSizeView () <UIPickerViewDataSource, UIPickerViewDelegate>

@end

@implementation ServingSizeView

static NSUInteger const SERVINGSIZE_TAG_NUMBER_PICKER = 1;
static NSUInteger const SERVINGSIZE_TAG_DECIMAL_PICKER = 2;
static NSUInteger const SERVINGSIZE_TAG_DECIMAL_DOT = 3;

#pragma mark - Setters/Getters
- (void)setValue:(float)value {
    _value = value;
    
    NSUInteger firstSizePickerSelectedRow = floor(value);
    NSUInteger secondSizePickerSelectedRow = [self secondServingSizePickerViewRowWithNumber:value - firstSizePickerSelectedRow];
    
    UIPickerView *sizeNumberPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_NUMBER_PICKER];
    UIPickerView *sizeDecimalPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_DECIMAL_PICKER];
    
    [sizeNumberPicker selectRow:firstSizePickerSelectedRow inComponent:0 animated:NO];
    [sizeDecimalPicker selectRow:secondSizePickerSelectedRow inComponent:0 animated:NO];
}

#pragma mark - View life cycle

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        UIPickerView *servingSizeNumberPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_NUMBER_PICKER];
        UIPickerView *servingSizeDecimalPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_DECIMAL_PICKER];
        UILabel *servingSizeDecimalDot = (UILabel *)[self viewWithTag:SERVINGSIZE_TAG_DECIMAL_DOT];
        
        [StyleManager stylelabel:servingSizeDecimalDot];
        
        servingSizeNumberPicker.delegate = self;
        servingSizeNumberPicker.dataSource = self;
        servingSizeDecimalPicker.delegate = self;
        servingSizeDecimalPicker.dataSource = self;
    }
    
    return self;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    if (pickerView.tag == SERVINGSIZE_TAG_NUMBER_PICKER)
        return 10;
    else
        return 4;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    UIPickerView *servingSizeNumberPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_NUMBER_PICKER];
    UIPickerView *servingSizeDecimalPicker = (UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_DECIMAL_PICKER];
    
    NSString *title = nil;
    
    if (pickerView == servingSizeNumberPicker) {
        // set the border color of the selection indicator
        [[servingSizeNumberPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[servingSizeNumberPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
        
        title = [NSString stringWithFormat:@"%ld", (long)row];
    }
    else {
        // set the border color of the selection indicator
        [[servingSizeDecimalPicker.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
        [[servingSizeDecimalPicker.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
        
        title = [self secondServingSizePickerViewInfoAtRow:row][@"title"];
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger firstServingSizePickerViewValue = [((UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_NUMBER_PICKER]) selectedRowInComponent:0];
    NSUInteger secondServingSizePickerViewRow = [((UIPickerView *)[self viewWithTag:SERVINGSIZE_TAG_DECIMAL_PICKER]) selectedRowInComponent:0];
    float secondServingSizePickerViewValue = [[self secondServingSizePickerViewInfoAtRow:secondServingSizePickerViewRow][@"value"] floatValue];
    
    self.value = firstServingSizePickerViewValue + secondServingSizePickerViewValue;
}

#pragma mark - Methods

- (NSUInteger)secondServingSizePickerViewRowWithNumber:(float)number {
    if (number == 0) {
        return 0;
    }
    else if (number == 0.25) {
        return 1;
    }
    else if (number == 0.5) {
        return 2;
    }
    else if (number == 0.75) {
        return 3;
    }
    else {
        return 0;
    }
}

- (NSDictionary *)secondServingSizePickerViewInfoAtRow:(NSUInteger)row {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"title": [NSNull null], @"value": @0.0}];
    
    switch (row) {
        case 0:
            info[@"title"] = @"0";
            info[@"value"] = @0.0;
            break;
        case 1:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00bc];
            info[@"value"] = @0.25;
            break;
        case 2:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00bd];
            info[@"value"] = @0.5;
            break;
        case 3:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00be];
            info[@"value"] = @0.75;
            break;
    }
    
    return info;
}


@end
