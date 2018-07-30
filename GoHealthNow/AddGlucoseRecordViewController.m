//
//  AddGlucoseRecordViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-15.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "AddGlucoseRecordViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeViewController.h"
#import "ChooseDateTimeDelegate.h"
#import "Constants.h"
#import "GlucoseRecord.h"
#import "UIView+Extensions.h"
#import "User.h"
#import "GGWebBrowserProxy.h"
#import "NotificationBloodGlucoseClass.h"

@interface AddGlucoseRecordViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ChooseDateTimeDelegate>

@property (nonatomic) NSArray *glucoseTypePickerValues;
@property (nonatomic) NSDate *currentDate;

@property (nonatomic) BOOL didDisplayMoreInfoWebView;
@property (nonatomic) BOOL didModify;

@property (nonatomic) UITextView *noteText;
@property (nonatomic) NSString *noteTextString;

@end

@implementation AddGlucoseRecordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.alwaysBounceVertical = NO;
    
    self.glucoseTypePickerValues = [GlucoseRecord getBGTypeOptions];
    self.currentDate = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.didDisplayMoreInfoWebView) {
        // this means the the view is being loaded after the 'more info'
        // web view has been closed by the user. In this case, we want to dismiss the
        // view controller as the user would have already recorded their glucose level
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    self.noteTextString = nil;
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
                cell = [tableView dequeueReusableCellWithIdentifier:@"glucoseTypeCell" forIndexPath:indexPath];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIPickerView *glucoseTypePicker = (UIPickerView *)[cell viewWithTag:ADD_GLUCOSE_TAG_TYPE_CELL_PICKER];
                glucoseTypePicker.dataSource = self;
                glucoseTypePicker.delegate = self;
                
                // See GlucoGuide-Common issue #33
                NSCalendar *cal = [NSCalendar currentCalendar];
                NSDateComponents *dateComponents = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond )
                                                      fromDate:[NSDate date]];
                if (dateComponents.hour >= 5 && dateComponents.hour < 8) {
                    [glucoseTypePicker selectRow:0 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 8 && dateComponents.hour < 10) {
                    [glucoseTypePicker selectRow:1 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 10 && dateComponents.hour < 12) {
                    [glucoseTypePicker selectRow:2 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 12 && dateComponents.hour < 16) {
                    [glucoseTypePicker selectRow:3 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 16 && dateComponents.hour < 18) {
                    [glucoseTypePicker selectRow:4 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 18 && dateComponents.hour < 21) {
                    [glucoseTypePicker selectRow:5 inComponent:0 animated:NO];
                }
                else if (dateComponents.hour >= 21 || dateComponents.hour < 5) {
                    [glucoseTypePicker selectRow:6 inComponent:0 animated:NO];
                }
                else {
                    [glucoseTypePicker selectRow:7 inComponent:0 animated:NO];
                }
                
                if ([NotificationBloodGlucoseClass getInstance].stringNotificationMealType) {
                    NSString *meal = [NotificationBloodGlucoseClass getInstance].stringNotificationMealType;
                    
                    if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_BREAKFAST]]) {
                        [glucoseTypePicker selectRow:0 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_BREAKFAST]]) {
                        [glucoseTypePicker selectRow:1 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_LUNCH]]) {
                        [glucoseTypePicker selectRow:2 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_LUNCH]]) {
                        [glucoseTypePicker selectRow:3 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEFORE_DINNER]]) {
                        [glucoseTypePicker selectRow:4 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_AFTER_DINNER]]) {
                        [glucoseTypePicker selectRow:5 inComponent:0 animated:NO];
                    }
                    else if ([meal isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_MEAL_TYPE_BEDTIME]]) {
                        [glucoseTypePicker selectRow:6 inComponent:0 animated:NO];
                    }
                    else {
                        [glucoseTypePicker selectRow:7 inComponent:0 animated:NO];
                    }
                    
                    [NotificationBloodGlucoseClass getInstance].stringNotificationMealType = nil;
                }
                
            }
            else {
                NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
                outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
                NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"glucoseRecordTimeCell" forIndexPath:indexPath];

                UIView *timeCellTopBorder = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_TIME_CELL_TOP_BORDER];
                UIView *timeCellBottomBorder = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_TIME_CELL_BOTTOM_BORDER];
                UILabel *timeCellLabel = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_TIME_CELL_LABEL];
                UILabel *timeCellValueLabel = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_TIME_CELL_VALUE_LABEL];
                
                timeCellTopBorder.backgroundColor = [UIColor buttonColor];
                timeCellBottomBorder.backgroundColor = [UIColor buttonColor];
                
                timeCellLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_RECORDING_TIME_TITLE];
                timeCellValueLabel.text = nowString;
                
                [StyleManager stylelabel:timeCellLabel];
                [StyleManager stylelabel:timeCellValueLabel];
                
                cell.tintColor = [UIColor whiteColor];
            }
        }
            break;
        case 1: {
            if (indexPath.row == 0) {
                BGUnit bgUnit = ((User *)[User sharedModel]).bgUnit;
                
                if (bgUnit == BGUnitMMOL) {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"glucoseLevelMmolLPickerCell" forIndexPath:indexPath];
                    
                    UIPickerView *glucoseLevelNumberPicker = (UIPickerView *)[cell viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER];
                    UIPickerView *glucoseLevelDecimalPicker = (UIPickerView *)[cell viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER];
                    UILabel *glucoseLevelDecimalDot = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_DOT];
                    
                    glucoseLevelNumberPicker.dataSource = self;
                    glucoseLevelNumberPicker.delegate = self;
                    glucoseLevelDecimalPicker.dataSource = self;
                    glucoseLevelDecimalPicker.delegate = self;
                    
                    [StyleManager stylelabel:glucoseLevelDecimalDot];
                    
                    // select the 5.5 blood glucose level
                    [glucoseLevelNumberPicker selectRow:5 inComponent:0 animated:NO];
                    [glucoseLevelDecimalPicker selectRow:5 inComponent:0 animated:NO];

                }
                else {
                    // MGDL
                    cell = [tableView dequeueReusableCellWithIdentifier:@"glucoseLevelMgDLPickerCell" forIndexPath:indexPath];
                    
                    UIPickerView *glucoseLevelNumberPicker = (UIPickerView *)[cell viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER];
                    glucoseLevelNumberPicker.dataSource = self;
                    glucoseLevelNumberPicker.delegate = self;

                    // select the 5.5 blood glucose level
                    [glucoseLevelNumberPicker selectRow:1 inComponent:0 animated:NO];
                    [glucoseLevelNumberPicker selectRow:1 inComponent:1 animated:NO];
                    [glucoseLevelNumberPicker selectRow:0 inComponent:2 animated:NO];
                }
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
                return ADD_GLUCOSE_PICKER_ROW_HEIGHT;
            }
            else {
                return 44.0;
            }
        case 1: {
            if (indexPath.row == 0) {
                return ADD_GLUCOSE_PICKER_ROW_HEIGHT;
            }
            else {
                float calculatedRowHeight = self.tableView.frame.size.height-
                                            (2 * ADD_GLUCOSE_PICKER_ROW_HEIGHT + 44.0
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
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"glucoseSectionHeader"];
    
    NSString *sectionHeaderText = nil;
    
    switch (section) {
        case 0:
            sectionHeaderText = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_SECTION_ENTER_BLOOD_GLUCOSE_TYPE_HEADER_TITLE];
            break;
        case 1: {
            NSString *bgUnitStr = ((User *)[User sharedModel]).bgUnit == BGUnitMMOL ? [LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MMOL] : [LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MG];
            sectionHeaderText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_SECTION_ENTER_BLOOD_GLUCOSE_LEVEL_HEADER_TITLE], bgUnitStr];
            break;
        }
    }
    
    UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:ADD_GLUCOSE_TAG_SECTION_HEADER_LABEL];
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
    switch (pickerView.tag) {
        case ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER:
            return 3;
        default:
            return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (pickerView.tag) {
        case ADD_GLUCOSE_TAG_TYPE_CELL_PICKER:
            return self.glucoseTypePickerValues.count;
        case ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER:
            return 30;
        case ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER:
            return 10;
        case ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER:
            return 10;
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
        case ADD_GLUCOSE_TAG_TYPE_CELL_PICKER:
            title = self.glucoseTypePickerValues[row];
            break;
        case ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER:
        case ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER:
            title = [NSString stringWithFormat:@"%ld", (long)row];
            break;
        case ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER:
            title = [NSString stringWithFormat:@"%ld", (long)row];
            break;
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.didModify = YES;
    
    if (pickerView.tag == ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER || pickerView.tag == ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER ||
        pickerView.tag == ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER)
    {
        CGFloat currentGlucoseLevel = [self currentlySelectedGlucoseLevel];
        self.navigationItem.rightBarButtonItem.enabled = currentGlucoseLevel == 0.0 ? NO : YES;
    }
}

#pragma mark - ChooseDateTimeDelegate Methods
- (void)didChooseDateTime:(NSDate *)dateTime sender:(id)sender {
    self.didModify = YES;
    self.currentDate = dateTime;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
    NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
    
    UILabel *timeCellValueLabel = (UILabel *)[cell viewWithTag:ADD_GLUCOSE_TAG_TIME_CELL_VALUE_LABEL];
    [timeCellValueLabel setText:nowString];

}


#pragma mark - Event Handlers
- (IBAction)btnNotes:(id)sender {
    
    self.noteText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    
    self.noteText.backgroundColor = [UIColor whiteColor];
    self.noteText.textColor = [UIColor blackColor];
    self.noteText.font = [UIFont systemFontOfSize:14];
    self.noteText.delegate = self;
    
    self.noteText.text = self.noteTextString;
    
    [self.view.superview slideInPopupForNotesWithTitle:@"Notes"
                                         withComponent:self.noteText
                                          withDelegate:(id)self];
    
    [self.noteText becomeFirstResponder];
}



- (IBAction)recordButtonTapped:(id)sender {
    
    if (self.noteText.text) {
        [self saveRecordWithNote:self.noteText.text];
    }else{
        [self saveRecordWithNote:@""];
    }
}

- (IBAction)didTapCancelButton:(id)sender {
    if (self.didModify) {
        // show confirmation alert
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_TITLE]
                                                                                   message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_MESSAGE], [LocalizationManager getStringFromStrId:MSG_GLUCOSE]]
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
    NSDictionary *userInfo = (NSDictionary *)[theTimer userInfo];
    
    UIAlertView *promptAlert = userInfo[ADD_GLUCOSE_KEY_PROMPT_ALERT];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
    
    UIAlertController *warningAlert = userInfo[ADD_GLUCOSE_KEY_WARNING_ALERT];
    if (warningAlert) {
        UIAlertAction *dismissAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *moreInfoAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_MORE_INFO] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            self.didDisplayMoreInfoWebView = YES;
            
            UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:@"http://www.diabetes.ca/diabetes-and-you/healthy-living-resources/blood-glucose-insulin/lows-highs-blood-glucose-levels"];
            [self presentViewController:browser animated:YES completion:nil];
        }];
        
        [warningAlert addAction:dismissAction];
        [warningAlert addAction:moreInfoAction];
        
        [self presentViewController:warningAlert animated:YES completion:nil];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"pickDateTime"]) {
        ChooseDateTimeViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.mode = UIDatePickerModeDateAndTime;
        destVC.initialDate = self.currentDate;
    }
}

#pragma TextView Delegates
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.?,()!%+=-/ "] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [text isEqualToString:filtered];
}

#pragma mark - Methods
- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer{
   
    self.noteTextString = self.noteText.text;
}

-(void)slideInPopupDidChooseCancel{
    self.noteTextString = nil;
    self.noteText = nil;
}

-(void)saveRecordWithNote:(NSString *)note{
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
    
    dispatch_promise(^{
        UIPickerView *typePicker = (UIPickerView *)[self.tableView viewWithTag:ADD_GLUCOSE_TAG_TYPE_CELL_PICKER];
        GlucoseRecord* record = [[GlucoseRecord alloc] init];
        
        User *user = [User sharedModel];
        float currentlySelectedGlucoseLevel = [self currentlySelectedGlucoseLevel];
        BGValue *bgLevel = user.bgUnit == BGUnitMG ? [[BGValue alloc] initWithMG:currentlySelectedGlucoseLevel]
        : [[BGValue alloc] initWithMMOL:currentlySelectedGlucoseLevel];
        
        record.level = bgLevel;
        record.type = [NSNumber numberWithInteger:[typePicker selectedRowInComponent:0]];
        record.recordedTime = self.currentDate;
        record.note = note;
        record.uuid = (NSString *)[[NSUUID UUID] UUIDString];
        
        __block BOOL didGlucoseWarningOccur = NO;
        
        [record save].then(^(BOOL success) {
            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                  message:[LocalizationManager getStringFromStrId:ADD_RECORD_SUCESS_MSG]
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:nil];
            [promptAlert show];
            
            NSMutableDictionary *alertInfo = [NSMutableDictionary dictionaryWithDictionary:@{ADD_GLUCOSE_KEY_PROMPT_ALERT: promptAlert}];
            
            NSString *warningAlertMessage = nil;
            NSString *warningAlertTitle = nil;
            float bgLevelMMOL = [bgLevel valueWithMMOL];
            if (bgLevelMMOL > ADD_GLUCOSE_WARNING_MAX_MMOL_VAL) {
                warningAlertMessage = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_HIGH_CONTENT];
                warningAlertTitle = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_HIGH_TITLE];
            }
            else if (bgLevelMMOL < ADD_GLUCOSE_WARNING_MIN_MMOL_VAL) {
                warningAlertMessage = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_LOW_CONTENT];
                warningAlertTitle = [LocalizationManager getStringFromStrId:MSG_ADD_GLUCOSE_RECORD_GLUCOSE_LEVEL_TOO_LOW_TITLE];
            }
            
            if (warningAlertMessage) {
                didGlucoseWarningOccur = YES;
                UIAlertController *warningAlert = [UIAlertController alertControllerWithTitle:warningAlertTitle
                                                                                      message:warningAlertMessage
                                                                               preferredStyle:UIAlertControllerStyleAlert];
                [alertInfo setObject:warningAlert forKey:ADD_GLUCOSE_KEY_WARNING_ALERT];
            }
            
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(dismissRecordPromptAlert:)
                                           userInfo:alertInfo
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
                                           userInfo:@{ADD_GLUCOSE_KEY_PROMPT_ALERT: promptAlert}
                                            repeats:NO];
        }).finally(^{
            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            if (!didGlucoseWarningOccur) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        });
    });
    
    
}


- (float)currentlySelectedGlucoseLevel {
    BGUnit bgUnit = ((User *)[User sharedModel]).bgUnit;
    NSString* level = nil;
    
    if (bgUnit == BGUnitMMOL) {
        UIPickerView *levelNumberPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MMOLL_PICKER];
        UIPickerView *levelDecimalPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_DECIMAL_PICKER];
        level = [NSString stringWithFormat:@"%ld.%ld",
                    (long)[levelNumberPicker selectedRowInComponent:0],
                    (long)[levelDecimalPicker selectedRowInComponent:0]];
    }
    else {
        UIPickerView *levelNumberPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_GLUCOSE_TAG_LEVEL_CELL_NUMBER_MGDL_PICKER];
        level = [NSString stringWithFormat:@"%ld%ld%ld",
                    (long)[levelNumberPicker selectedRowInComponent:0],
                    (long)[levelNumberPicker selectedRowInComponent:1],
                    (long)[levelNumberPicker selectedRowInComponent:2]];
    }
    
    return [level floatValue];
}

@end
