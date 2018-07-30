//
//  AddA1CViewController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-08-19.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "AddA1CViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeViewController.h"
#import "ChooseDateTimeDelegate.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "A1CRecord.h"
#import "User.h"


@interface AddA1CViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ChooseDateTimeDelegate, UITextViewDelegate>

@property (nonatomic) float value;
@property (nonatomic) NSDate *currentDate;
@property (nonatomic) UITextView *noteText;
@property (nonatomic) NSString *noteTextString;

@end


@implementation AddA1CViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    User *user = [User sharedModel];
    self.value = user.a1c? [user.a1c floatValue]: 5.5;
    self.currentDate = [NSDate date];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"a1cLevelPickerCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIPickerView *a1cLevelNumberPicker = (UIPickerView *)[cell viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER];
        UIPickerView *a1cLevelDecimalPicker = (UIPickerView *)[cell viewWithTag:A1CLEVEL_TAG_DECIMAL_PICKER];
        UILabel *a1cLevelDecimalDot = (UILabel *)[cell viewWithTag:A1CLEVEL_TAG_DECIMAL_DOT];
        UILabel *a1cLevelPerLabel = (UILabel *)[cell viewWithTag:A1CLEVEL_TAG_PER_LABEL];
        
        [StyleManager stylelabel:a1cLevelDecimalDot];
        [StyleManager stylelabel:a1cLevelPerLabel];
        
        a1cLevelNumberPicker.delegate = self;
        a1cLevelNumberPicker.dataSource = self;
        a1cLevelDecimalPicker.delegate = self;
        a1cLevelDecimalPicker.dataSource = self;
        
        
        NSUInteger firstA1cPickerSelectedRow = floor(self.value);
        NSUInteger secondA1cPickerSelectedRow = (self.value - firstA1cPickerSelectedRow) * 10;
        
        [a1cLevelNumberPicker selectRow:firstA1cPickerSelectedRow inComponent:0 animated:NO];
        [a1cLevelDecimalPicker selectRow:secondA1cPickerSelectedRow inComponent:0 animated:NO];
    }
    else if (indexPath.row == 1){
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"a1cRecordTimeCell" forIndexPath:indexPath];
        
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:A1CLEVEL_TAG_RECORDINGTIME_LABEL];
        timeLabel.text = nowString;        
    }
    
    [StyleManager styleTableCell:cell];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return ADD_A1C_PICKER_ROW_HEIGHT;
    }
    else {
        return 44;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"a1cSectionHeader"];
    
    NSString *sectionHeaderText = [LocalizationManager getStringFromStrId:@"Record your A1C:"];
    UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:A1CLEVEL_TAG_SECTION_HEADER_LABEL];
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
    if (indexPath.row == 1) {
        [self performSegueWithIdentifier:@"pickDateTime" sender:self];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25877725#25877725
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch (pickerView.tag) {
        case A1CLEVEL_TAG_NUMBER_PICKER:
            return 20;
        case A1CLEVEL_TAG_DECIMAL_PICKER:
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
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    UIPickerView *levelNumberPicker = (UIPickerView *)[self.tableView viewWithTag:A1CLEVEL_TAG_NUMBER_PICKER];
    UIPickerView *levelDecimalPicker = (UIPickerView *)[self.tableView viewWithTag:A1CLEVEL_TAG_DECIMAL_PICKER];
    
    NSString* level = [NSString stringWithFormat:@"%ld.%ld",
                       (long)[levelNumberPicker selectedRowInComponent:0],
                       (long)[levelDecimalPicker selectedRowInComponent:0]];
    
    self.value = [level floatValue];
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
//    self.noteTextString = nil;
//    self.noteText = nil;
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
    
    [self.view.superview slideInPopupForNotesWithTitle:[LocalizationManager getStringFromStrId:@"Notes"]
                                         withComponent:self.noteText
                                          withDelegate:(id)self];
    
    [self.noteText becomeFirstResponder];
}


- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didTapRecordButton:(id)sender {
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:ADD_RECORD_SAVING_MSG];
    
    User *user = [User sharedModel];
    [user updateA1CToUser:[NSNumber numberWithFloat:self.value]];
    
    dispatch_promise(^{
        A1CRecord* record = [[A1CRecord alloc] init];
        
        record.value = [NSNumber numberWithFloat:self.value];
        record.recordedTime = self.currentDate;
        record.note = self.noteTextString? self.noteTextString : @"";
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
            //[self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popViewControllerAnimated:YES];
        });
    });

}


- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}


#pragma mark - ChooseDateTimeDelegate Methods

- (void)didChooseDateTime:(NSDate *)dateTime sender:(id)sender {
    self.currentDate = dateTime;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
    NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:A1CLEVEL_TAG_RECORDINGTIME_LABEL];
    [timeLabel setText:nowString];
    
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
