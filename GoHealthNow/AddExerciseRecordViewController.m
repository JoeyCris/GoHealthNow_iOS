//
//  AddExerciseRecordViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-28.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "AddExerciseRecordViewController.h"
#import "Constants.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeDelegate.h"
#import "ChooseDateTimeViewController.h"
#import "ExerciseRecord.h"
#import "UIView+Extensions.h"
#import "User.h"
#import "XMLUpdateClass.h"
#import "LastEnteredExerciseClass.h"
#import "NotificationExerciseClass.h"
#import "AppDelegate.h"

@interface AddExerciseRecordViewController() <UIPickerViewDataSource, UIPickerViewDelegate, ChooseDateTimeDelegate, UIAlertViewDelegate>

@property (nonatomic) NSDate *currentDate;
@property (nonatomic) BOOL didModify;
@property (nonatomic) NSString *noteTextString;

@end

@implementation AddExerciseRecordViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.alwaysBounceVertical = NO;
    
    self.currentDate = [NSDate date];
}

-(void)viewDidDisappear:(BOOL)animated{
    
    self.noteTextString = nil;
    
    if ([[NotificationExerciseClass getInstance].stringComingFromWhere isEqualToString:@"logFromNotification"]){
        [NotificationExerciseClass getInstance].stringComingFromWhere = nil;
    }
    
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseDatetimeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIPickerView *exerciseHourPicker = (UIPickerView *)[cell viewWithTag:ADD_EXERCISE_TAG_HOUR_CELL_PICKER];
        UIPickerView *exerciseMinPicker = (UIPickerView *)[cell viewWithTag:ADD_EXERCISE_TAG_MIN_CELL_PICKER];
        
        exerciseHourPicker.dataSource = self;
        exerciseHourPicker.delegate = self;
        exerciseMinPicker.dataSource = self;
        exerciseMinPicker.delegate = self;
        
        if ([[NotificationExerciseClass getInstance].stringComingFromWhere isEqualToString:@"logFromNotification"]){
            [exerciseMinPicker selectRow:[[[[LastEnteredExerciseClass getInstance] getUserExerciseLastEntry] objectForKey:@"minutes"] integerValue] inComponent:0 animated:NO];
            [exerciseHourPicker selectRow:[[[[LastEnteredExerciseClass getInstance] getUserExerciseLastEntry] objectForKey:@"hours"] integerValue] inComponent:0 animated:NO];
        }else{
            [exerciseMinPicker selectRow:30 inComponent:0 animated:NO];
            [exerciseHourPicker selectRow:0 inComponent:0 animated:NO];
        }
        
        UILabel *exerciseHourLabel = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_HOUR_LABEL];
        UILabel *exerciseMinLabel = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_MIN_LABEL];
        
        [StyleManager stylelabel:exerciseHourLabel];
        [StyleManager stylelabel:exerciseMinLabel];
    }
    else if (indexPath.row == 1) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseRecordTimeCell" forIndexPath:indexPath];
        
        UIView *timeCellTopBorder = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_TIME_CELL_TOP_BORDER];
        UIView *timeCellBottomBorder = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_TIME_CELL_BOTTOM_BORDER];
        UILabel *timeCellLabel = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_TIME_CELL_LABEL];
        UILabel *timeCellValueLabel = (UILabel *)[cell viewWithTag:ADD_EXERCISE_TAG_TIME_CELL_VALUE_LABEL];
        
        timeCellTopBorder.backgroundColor = [UIColor buttonColor];
        timeCellBottomBorder.backgroundColor = [UIColor buttonColor];
        
        timeCellLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_EXERCISE_TIME_CELL_TITLE];
        timeCellValueLabel.text = nowString;
        
        [StyleManager stylelabel:timeCellLabel];
        [StyleManager stylelabel:timeCellValueLabel];
        
        cell.tintColor = [UIColor whiteColor];
    }
    
    [StyleManager styleTableCell:cell];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return ADD_RECORD_PICKER_ROW_HEIGHT;
    }
    else {
        return 44.0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"exerciseSectionHeader"];
    
    ExerciseType currentExerciseType = [(NSNumber *)self.exerciseInfo[EXERCISE_INFO_TYPE] intValue];
    NSString *exerciseTypeStr = [LocalizationManager getStringFromStrId:MSG_ADD_EXERCISE_HEADER_TYPE_UNKNOWN];
    
    if ([[NotificationExerciseClass getInstance].stringComingFromWhere isEqualToString:@"logFromNotification"]){

        switch ([[[[LastEnteredExerciseClass getInstance] getUserExerciseLastEntry] objectForKey:@"type"] integerValue]) {
            case ExerciseTypeLight:
                exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_LIGHT];
                break;
            case ExerciseTypeModerate:
                exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_MODERATE];
                break;
            case ExerciseTypeVigorous:
                exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_VIGOROUS];
                break;
        }
        
    }else{

        switch (currentExerciseType) {
            case ExerciseTypeLight:
                exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_LIGHT];
                break;
            case ExerciseTypeModerate:
            exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_MODERATE];
                break;
            case ExerciseTypeVigorous:
                exerciseTypeStr = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_VIGOROUS];
                break;
        }
        
    }
    
    NSString *sectionHeaderText = [NSString stringWithFormat:MSG_ADD_EXERCISE_HEADER_TYPE_EXERCISE_DURATION, exerciseTypeStr];
    
    UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:ADD_EXERCISE_TAG_SECTION_HEADER_LABEL];
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
    if (indexPath.row == 1) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // only allow selection of the "Record Time" row
    if (indexPath.row == 1) {
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
        case ADD_EXERCISE_TAG_HOUR_CELL_PICKER:
            return 10;
        case ADD_EXERCISE_TAG_MIN_CELL_PICKER:
            return 60;
        default:
            return 0;
    }
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
    self.didModify = YES;
    
    NSUInteger totalMins = [self currentlySelectedTotalExerciseMins];
    self.navigationItem.rightBarButtonItem.enabled = totalMins == 0 ? NO : YES;
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
- (IBAction)addNote:(id)sender {
    
    self.noteText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    
    self.noteText.backgroundColor = [UIColor whiteColor];
    self.noteText.textColor = [UIColor blackColor];
    self.noteText.font = [UIFont systemFontOfSize:14];
    self.noteText.delegate = self;
    
    if (self.noteTextString) {
        self.noteText.text = self.noteTextString;
    }
    
    [self.view.superview slideInPopupForNotesWithTitle:@"Notes"
                                         withComponent:self.noteText
                                          withDelegate:(id)self];
    
    [self.noteText becomeFirstResponder];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // 'YES' button was selected
    if (buttonIndex == 1) {
        if (self.noteText.text) {
            [self saveRecordWithNote:self.noteText.text];
        }else{
            [self saveRecordWithNote:@""];
        }

    }
}

- (IBAction)recordButtonTapped:(id)sender {
    NSUInteger totalMins = [self currentlySelectedTotalExerciseMins];
    ExerciseType currentExerciseType = [(NSNumber *)self.exerciseInfo[EXERCISE_INFO_TYPE] intValue];
    
    if ((totalMins > ADD_EXERCISE_ABNORMAL_MODERATE_MINS && currentExerciseType == ExerciseTypeModerate) ||
        (totalMins > ADD_EXERCISE_ABNORMAL_VIGOROUS_MINS && currentExerciseType == ExerciseTypeVigorous))
    {
        NSString *currentExerciseTypeStr = currentExerciseType == ExerciseTypeModerate ? [LocalizationManager getStringFromStrId:EXERCISE_TYPE_MODERATE] : [LocalizationManager getStringFromStrId:EXERCISE_TYPE_VIGOROUS];
        NSString *moderateExerciseAlertTitle = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:ADD_EXERCISE_ABNORMAL_ALERT_TITLE], currentExerciseTypeStr];
        NSString *moderateExerciseAlertBody = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:ADD_EXERCISE_ABNORMAL_ALERT_BODY], currentExerciseTypeStr, [currentExerciseTypeStr lowercaseString], (long)totalMins];
        
        UIAlertView *moderateExerciseAlert = [[UIAlertView alloc] initWithTitle:moderateExerciseAlertTitle
                                                                        message:moderateExerciseAlertBody
                                                                       delegate:self
                                                              cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_NO]
                                                              otherButtonTitles:[LocalizationManager getStringFromStrId:MSG_YES], nil];
        [moderateExerciseAlert show];
    
    }else{
        
        if (self.noteText.text) {
            [self saveRecordWithNote:self.noteText.text];
        }else{
           [self saveRecordWithNote:@""];
        }
        
    }
}

- (IBAction)didTapCancelButton:(id)sender {
    if (self.didModify) {
        // show confirmation alert
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_TITLE]
                                                                                   message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_MESSAGE], [LocalizationManager getStringFromStrId:MSG_EXERCISE]]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_YES_BTN] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_NO_BTN] style:UIAlertActionStyleDefault handler:nil];
        
        [confirmationAlert addAction:okAction];
        [confirmationAlert addAction:cancelAction];
        
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }else {
        
        if ([[NotificationExerciseClass getInstance].stringComingFromWhere isEqualToString:@"logFromNotification"]){
            [NotificationExerciseClass getInstance].stringComingFromWhere = nil;
            [NotificationExerciseClass getInstance].stringGoingToExerciseType = @"backToType";
            
            AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            [appDelegate setWindowToExerciseSummary];
            
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
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



- (NSUInteger)currentlySelectedTotalExerciseMins {
    UIPickerView *exerciseHourPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_EXERCISE_TAG_HOUR_CELL_PICKER];
    UIPickerView *exerciseMinPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_EXERCISE_TAG_MIN_CELL_PICKER];
    
    NSUInteger hours = [exerciseHourPicker selectedRowInComponent:0]* 60;
    NSUInteger mins = [exerciseMinPicker selectedRowInComponent:0];
    NSUInteger totalMins = hours + mins;
    
    return totalMins;
}


- (void)saveRecordWithNote:(NSString *)note {
    
    UIPickerView *exerciseMinPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_EXERCISE_TAG_MIN_CELL_PICKER];
    UIPickerView *exerciseHourPicker = (UIPickerView *)[self.tableView viewWithTag:ADD_EXERCISE_TAG_HOUR_CELL_PICKER];
    
    NSString *mintues = [NSString stringWithFormat:@"%ld", (long)[exerciseMinPicker selectedRowInComponent:0]];
    NSString *hours = [NSString stringWithFormat:@"%ld" , (long)[exerciseHourPicker selectedRowInComponent:0]];
    NSString *type = [NSString stringWithFormat:@"%d" , [(NSNumber *)self.exerciseInfo[EXERCISE_INFO_TYPE] intValue] * 2];
    
    [[LastEnteredExerciseClass getInstance] saveLastUserExerciseEntryWithType:type withHour:hours withMinutes:mintues];

    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
    
    dispatch_promise(^{
        NSUInteger totalMins = [self currentlySelectedTotalExerciseMins];
        
        ExerciseRecord *record = [[ExerciseRecord alloc] init];
        record.type = [(NSNumber *)self.exerciseInfo[EXERCISE_INFO_TYPE] intValue];
        record.minutes = [NSNumber numberWithInteger:totalMins];
        record.entryType = [NSNumber numberWithInteger:0];
        record.recordedTime = self.currentDate;
        record.recordEntryTime = [NSDate date];
        record.steps = [NSNumber numberWithInteger:0];
        record.uuid = (NSString *)[[NSUUID UUID] UUIDString];
        record.note = note;
        
        record.calories = [NSNumber numberWithFloat:[((User *)[User sharedModel]).weight valueWithMetric] * [(NSNumber *)self.exerciseInfo[EXERCISE_INFO_CALS_PER_UNIT] floatValue] * (totalMins / 60.0)];
        
        //NSLog(@"%lu - %@ - %@ - %@ - %@ - %@ -%@", (unsigned long)record.type, record.minutes, record.entryType, record.recordedTime, record.recordEntryTime, record.steps, record.uuid);
        
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
            
            if ([[NotificationExerciseClass getInstance].stringComingFromWhere isEqualToString:@"logFromNotification"]){
                [NotificationExerciseClass getInstance].stringComingFromWhere = nil;
                
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                [appDelegate setWindowToExerciseSummary];

            }else{
                [self performSegueWithIdentifier:@"unwindToExerciseSummaryViewController" sender:self];
            }
        });
    });
    
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

@end
