//
//  AddInsulinController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "AddInsulinController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeDelegate.h"
#import "ChooseDateTimeViewController.h"
#import "UIView+Extensions.h"
#import "User.h"
#import "InsulinRecord.h"

@interface AddInsulinController () <UIPickerViewDataSource, UIPickerViewDelegate, ChooseDateTimeDelegate>

@property (nonatomic) NSArray *insulins;
@property (nonatomic) NSDate *currentDate;

@property (nonatomic) BOOL didModify;

@end

#pragma mark - View Lifecyle

@implementation AddInsulinController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.insulins = ((User *)[User sharedModel]).insulins;
    self.currentDate = [NSDate date];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.alwaysBounceVertical = NO;
}

- (BOOL)hidesBottomBarWhenPushed {
    return IS_IPHONE_4_OR_LESS ? YES : NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 1;
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0: {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"insulinPickerCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIPickerView *insulinTypePicker = (UIPickerView *)[cell viewWithTag:ADD_INSULIN_TAG_PICKER];
                insulinTypePicker.dataSource = self;
                insulinTypePicker.delegate = self;
                insulinTypePicker.tag = ADD_INSULIN_TAG_TYPE_CELL_PICKER;
            }
            else {
                NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                outputFormatter.dateFormat = @"hh:mm a";
                NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"insulinRecordTimeCell" forIndexPath:indexPath];
                
                UIView *timeCellTopBorder = (UILabel *)[cell viewWithTag:ADD_INSULIN_TAG_TIME_CELL_TOP_BORDER];
                UIView *timeCellBottomBorder = (UILabel *)[cell viewWithTag:ADD_INSULIN_TAG_TIME_CELL_BOTTOM_BORDER];
                UILabel *timeCellLabel = (UILabel *)[cell viewWithTag:ADD_INSULIN_TAG_TIME_CELL_LABEL];
                UILabel *timeCellValueLabel = (UILabel *)[cell viewWithTag:ADD_INSULIN_TAG_TIME_CELL_VALUE_LABEL];
                
                timeCellTopBorder.backgroundColor = [UIColor buttonColor];
                timeCellBottomBorder.backgroundColor = [UIColor buttonColor];
                
                timeCellLabel.text = @"Recording time";
                timeCellValueLabel.text = nowString;
                
                [StyleManager stylelabel:timeCellLabel];
                [StyleManager stylelabel:timeCellValueLabel];
                
                cell.tintColor = [UIColor whiteColor];
            }
        }
            break;
        case 1: {
            if (indexPath.row == 0) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"insulinPickerCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIPickerView *insulinValuePicker = (UIPickerView *)[cell viewWithTag:ADD_INSULIN_TAG_PICKER];
                insulinValuePicker.dataSource = self;
                insulinValuePicker.delegate = self;
                insulinValuePicker.tag = ADD_INSULIN_TAG_VALUE_CELL_PICKER;
                
                [insulinValuePicker selectRow:ADD_INSULIN_DEFAULT_VALUE inComponent:0 animated:NO];
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
            if (indexPath.row == 0) {
                return ADD_INSULIN_PICKER_ROW_HEIGHT;
            }
            else {
                return 44.0;
            }
        case 1: {
            if (indexPath.row == 0) {
                return ADD_INSULIN_PICKER_ROW_HEIGHT;
            }
            else {
                float calculatedRowHeight = self.tableView.frame.size.height -
                    (2 * ADD_INSULIN_PICKER_ROW_HEIGHT + 44.0
                     + 3.075 * ADD_RECORD_TABLE_SECTION_HEADER_HEIGHT);
                
                // for the 4S the calculated height is negative, so we use a default value
                return calculatedRowHeight < ADD_RECORD_BUTTON_ROW_HEIGHT ? ADD_RECORD_BUTTON_ROW_HEIGHT : calculatedRowHeight;
            }
        }
        default:
            return 44.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"insulinSectionHeader"];
    
    NSString *sectionHeaderText = nil;
    
    switch (section) {
        case 0:
            sectionHeaderText = @"Choose your insulin:";
            break;
        case 1:
            sectionHeaderText = @"Enter the dose:";
            break;
    }
    
    UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:ADD_INSULIN_TAG_SECTION_HEADER_LABEL];
    sectionHeaderLabel.text = sectionHeaderText;
    
    [StyleManager stylelabel:sectionHeaderLabel];
    [StyleManager styleTableCell:sectionHeader];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ADD_RECORD_TABLE_SECTION_HEADER_HEIGHT;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only allow selection of the "Record Time" row
    if (indexPath.section == 0 && indexPath.row == 1) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only allow selection of the "Record Time" row
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self performSegueWithIdentifier:@"pickDateTime" sender:self];
    }
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (pickerView.tag) {
        case ADD_INSULIN_TAG_TYPE_CELL_PICKER:
            return [self.insulins count];
        case ADD_INSULIN_TAG_VALUE_CELL_PICKER:
            return 100;
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
        case ADD_INSULIN_TAG_TYPE_CELL_PICKER:
            title = self.insulins[row][@"_Name"];
            break;
        case ADD_INSULIN_TAG_VALUE_CELL_PICKER:
            title = [NSString stringWithFormat:@"%ld", (long)row];
            break;
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.didModify = YES;
    
    if (pickerView.tag == ADD_INSULIN_TAG_VALUE_CELL_PICKER) {
        UIPickerView *insulinValuePicker = (UIPickerView *)[self.tableView viewWithTag:ADD_INSULIN_TAG_VALUE_CELL_PICKER];
        NSUInteger currentInsulinLevel = (NSUInteger)[insulinValuePicker selectedRowInComponent:0];
        
        self.navigationItem.rightBarButtonItem.enabled = currentInsulinLevel == 0 ? NO : YES;
    }
}

#pragma mark - ChooseDateTimeDelegate Methods

- (void)didChooseDateTime:(NSDate *)dateTime sender:(id)sender {
    self.didModify = YES;
    self.currentDate = dateTime;
    
    // TODO: this is inefficient, should use reloadRowsAtIndexPaths instead but that is
    // ruining the layout of the table for some reason. Must investigate later
    [self.tableView reloadData];
}

#pragma mark - Event Handlers

- (IBAction)recordButtonTapped:(id)sender {
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:ADD_RECORD_SAVING_MSG];
    
    dispatch_promise(^{
        UIPickerView *insulinTypePicker = (UIPickerView *)[self.tableView viewWithTag:ADD_INSULIN_TAG_TYPE_CELL_PICKER];
        UIPickerView *insulinValuePicker = (UIPickerView *)[self.tableView viewWithTag:ADD_INSULIN_TAG_VALUE_CELL_PICKER];
        
        InsulinRecord *record = [[InsulinRecord alloc] init];
        record.dose = [insulinValuePicker selectedRowInComponent:0];
        record.insulinId = self.insulins[[insulinTypePicker selectedRowInComponent:0]][@"_ID"];
        record.recordedTime = self.currentDate;
        
        [record save].then(^(BOOL success) {
            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                  message:ADD_RECORD_SUCESS_MSG
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
                                                                  message:ADD_RECORD_FAILURE_MSG
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
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:INPUT_CONFIRM_SAVE_TITLE
                                                                                   message:[NSString stringWithFormat:INPUT_CONFIRM_SAVE_MESSAGE, @"insulin"]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:INPUT_CONFIRM_SAVE_YES_BTN style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:INPUT_CONFIRM_SAVE_NO_BTN style:UIAlertActionStyleDefault handler:nil];
        
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"pickDateTime"]) {
        ChooseDateTimeViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.mode = UIDatePickerModeTime;
        destVC.initialDate = self.currentDate;
    }
}

@end
