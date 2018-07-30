//
//  AddSleepRecordViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-24.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "AddSleepRecordViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "SleepRecord.h"
#import "UIView+Extensions.h"

@interface AddSleepRecordViewController() <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSArray *sleepMinsPickerValues;
@property (nonatomic) BOOL didModify;

@end

@implementation AddSleepRecordViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.allowsSelection = NO;
    self.tableView.alwaysBounceVertical = NO;
    
    self.sleepMinsPickerValues = @[@"0", @"15", @"30", @"45"];
}

- (BOOL)hidesBottomBarWhenPushed {
    return IS_IPHONE_4_OR_LESS ? YES : NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sleepHoursSleptCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIPickerView *sleepHourPicker = (UIPickerView *)[cell viewWithTag:ADD_SLEEP_TAG_HOUR_CELL_PICKER];
            UIPickerView *sleepMinPicker = (UIPickerView *)[cell viewWithTag:ADD_SLEEP_TAG_MIN_CELL_PICKER];
            
            sleepHourPicker.dataSource = self;
            sleepHourPicker.delegate = self;
            sleepMinPicker.dataSource = self;
            sleepMinPicker.delegate = self;
            
            [sleepHourPicker selectRow:8 inComponent:0 animated:NO];
            [sleepMinPicker selectRow:0 inComponent:0 animated:NO];
            
            UILabel *sleepHourLabel = (UILabel *)[cell viewWithTag:ADD_SLEEP_TAG_HOUR_LABEL];
            UILabel *sleepMinLabel = (UILabel *)[cell viewWithTag:ADD_SLEEP_TAG_MIN_LABEL];

            [StyleManager stylelabel:sleepHourLabel];
            [StyleManager stylelabel:sleepMinLabel];
        }
            break;
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"sleepQuestionCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *questionLabel = (UILabel *)[cell viewWithTag:ADD_SLEEP_TAG_QUESTION_LABEL];
            UISwitch *questionSwitch = (UISwitch *)[cell viewWithTag:ADD_SLEEP_TAG_QUESTION_SWITCH];
            
            [StyleManager stylelabel:questionLabel];
            [StyleManager styleSwitch:questionSwitch];
            
            [questionSwitch setOn:NO];
            
            [questionSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            
            switch (indexPath.row) {
                case 0:
                    questionLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_SLEEP_RECORD_QUESTION_ARE_YOU_SICK];
                    break;
                case 1:
                    questionLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_SLEEP_RECORD_QUESTION_ARE_YOU_STRESSED_OUT];
                    break;
                default:
                    break;
            }
        }
            break;
    }
    
    [StyleManager styleTableCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return IS_IPHONE_4_OR_LESS || IS_IPHONE_5 ? ADD_RECORD_PICKER_ROW_HEIGHT - 60.0 : ADD_RECORD_PICKER_ROW_HEIGHT;
        case 1:
            if (indexPath.row == 2) {
                float delta = IS_IPHONE_4_OR_LESS || IS_IPHONE_5 ? 5.75 : 4.19;
                float calculatedRowHeight = self.tableView.frame.size.height -
                                            (ADD_RECORD_PICKER_ROW_HEIGHT + ADD_SLEEP_QUESTION_ROW_HEIGHT
                                             + delta * ADD_RECORD_TABLE_SECTION_HEADER_HEIGHT);
                
                // for the 4S the calculated height is negative, so we use a default value
                return calculatedRowHeight < ADD_RECORD_BUTTON_ROW_HEIGHT ? ADD_RECORD_BUTTON_ROW_HEIGHT : calculatedRowHeight;
            }
            else {
                return ADD_SLEEP_QUESTION_ROW_HEIGHT;
            }
        default:
            return 44.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"sleepSectionHeader"];
    
    NSString *sectionHeaderText = nil;
    
    switch (section) {
        case 0:
            sectionHeaderText = [LocalizationManager getStringFromStrId:MSG_ADD_SLEEP_RECORD_QUESTION_HOW_LONG_DID_YOU_SLEEP_LAST_NIGHT];
            break;
        case 1:
            sectionHeaderText = [LocalizationManager getStringFromStrId:MSG_ADD_SLEEP_RECORD_QUESTION_ABOUT_TODAY];
            break;
    }
    
    UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:ADD_SLEEP_TAG_SECTION_HEADER_LABEL];
    sectionHeaderLabel.text = sectionHeaderText;
    
    [StyleManager stylelabel:sectionHeaderLabel];
    [StyleManager styleTableCell:sectionHeader];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ADD_RECORD_TABLE_SECTION_HEADER_HEIGHT;
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (pickerView.tag) {
        case ADD_SLEEP_TAG_HOUR_CELL_PICKER:
            return 10;
        case ADD_SLEEP_TAG_MIN_CELL_PICKER:
            return 4;
        default:
            return 0;
    }
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = nil;
    
    switch (pickerView.tag) {
        case ADD_SLEEP_TAG_HOUR_CELL_PICKER:
            title = [NSString stringWithFormat:@"%ld", (long)row];
            break;
        case ADD_SLEEP_TAG_MIN_CELL_PICKER:
            title = self.sleepMinsPickerValues[row];
            break;
        default:
            break;
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger currentSleepMins = [self currentlySelectedSleepMinutes];
    self.navigationItem.rightBarButtonItem.enabled = currentSleepMins == 0 ? NO : YES;
    
    self.didModify = YES;
}

#pragma mark - Event Handlers

- (IBAction)recordButtonTapped:(id)sender {
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
    
    dispatch_promise(^{
        SleepRecord* record = [[SleepRecord alloc] init];
        
        record.minutes = [NSNumber numberWithInteger:[self currentlySelectedSleepMinutes]];
        record.sick = [NSNumber numberWithBool:[self switchOn:0 inSection:1]];
        record.stressed = [NSNumber numberWithBool:[self switchOn:1 inSection:1]];
        record.recordedTime = [NSDate date];
        record.uuid = (NSString *)[[NSUUID UUID] UUIDString];

        [record save].then(^(BOOL success) {
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
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    });
}

- (IBAction)didTapCancelButton:(id)sender {
    if (self.didModify) {
        // show confirmation alert
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_TITLE]
                                                                                   message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_MESSAGE], [LocalizationManager getStringFromStrId:MSG_OTHER]]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_YES_BTN] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_NO_BTN] style:UIAlertActionStyleDefault handler:nil];
        
        [confirmationAlert addAction:okAction];
        [confirmationAlert addAction:cancelAction];
        
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(BOOL)switchOn:(NSInteger)row inSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UISwitch *questionSwitch = (UISwitch *)[cell viewWithTag:ADD_SLEEP_TAG_QUESTION_SWITCH];
    
    return questionSwitch.on;
}

- (void)switchToggled:(id)sender
{
    if ([sender isOn]) {
        self.didModify = YES;
    }
}

#pragma mark - Methods

- (NSUInteger)currentlySelectedSleepMinutes {
    UIPickerView *hourPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_SLEEP_TAG_HOUR_CELL_PICKER];
    UIPickerView *minPicker = (UIPickerView *)[self.tableView  viewWithTag:ADD_SLEEP_TAG_MIN_CELL_PICKER];
    NSUInteger minutes = [hourPicker selectedRowInComponent:0] * 60 +
        [self.sleepMinsPickerValues[[minPicker selectedRowInComponent:0]] intValue];
    
    return minutes;
}

@end
