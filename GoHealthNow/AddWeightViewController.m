//
//  AddWeightViewController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-08-20.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "AddWeightViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeViewController.h"
#import "ChooseDateTimeDelegate.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "User.h"
#import "WeightRecord.h"

@interface AddWeightViewController () <UIPickerViewDataSource, UIPickerViewDelegate, ChooseDateTimeDelegate, UITextViewDelegate>
@property (nonatomic) NSString *weightUnit;
@property (nonatomic) NSUInteger weightValue;
@property (nonatomic) NSDate *currentDate;
@property (nonatomic) UITextView *noteText;
@property (nonatomic) NSString *noteTextString;
@property (nonatomic) UIAlertView *weightAlert;

@property (nonatomic) MeasureUnit unitMode;
@property (nonatomic) WeightUnit *weight;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnNavSave;
@end

@implementation AddWeightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentDate = [NSDate date];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    User *user = [User sharedModel];
    
    if (!self.weight){
        self.weight = [[WeightUnit alloc] init];
    }
    
    if (user.measureUnit == MUnitMetric) {
        self.weightUnit = [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_METRIC];
        self.weightValue = [user.weight valueWithMetric];
        [self.weight setValueWithMetric:self.weightValue];
    }
    else {
        self.weightUnit = [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_IMPERIAL];
        self.weightValue = [user.weight valueWithImperial];
        [self.weight setValueWithImperial:self.weightValue];

    }
        
    self.navigationItem.title = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight (%@)"], self.weightUnit];
    
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"weightPickerCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIPickerView *weightPicker = (UIPickerView *)[cell viewWithTag:WEIGHT_TAG_PICKER];
       
        weightPicker.delegate = self;
        weightPicker.dataSource = self;
        
        NSUInteger component0Row = self.weightValue % 1000 / 100;
        NSUInteger component1Row = self.weightValue % 100 / 10;
        NSUInteger component2Row =  self.weightValue % 10;
        
        [weightPicker selectRow:component0Row inComponent:0 animated:NO];
        [weightPicker selectRow:component1Row inComponent:1 animated:NO];
        [weightPicker selectRow:component2Row inComponent:2 animated:NO];

    }
    else if (indexPath.row == 1){
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"weightRecordTimeCell" forIndexPath:indexPath];
        
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:WEIGHT_TAG_RECORDINGTIME_LABEL];
        timeLabel.text = nowString;
    }
    
    [StyleManager styleTableCell:cell];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return ADD_WEIGHT_PICKER_ROW_HEIGHT;
    }
    else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [tableView dequeueReusableCellWithIdentifier:@"weightSectionHeader"];
    
    NSString *sectionHeaderText = [LocalizationManager getStringFromStrId:@"Weigh yourself on the same scale and at same time of day to accurately track your weight."];
    UITextView *sectionHeaderTextView = (UITextView *)[sectionHeader viewWithTag:WEIGHT_TAG_SECTION_HEADER_TEXTVIEW];
    sectionHeaderTextView.text = sectionHeaderText;
    
    [StyleManager styleTableCell:sectionHeader];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 80;
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
    return 5;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    User *user = [User sharedModel];
    switch (component) {
        case 0:
        {
            if (user.measureUnit == MUnitMetric) {
                return 3;
            }
            else {
                return 4;
            }
        }
        case 3:
            {
                return 1;
            }
        default:
            return 10;
    }
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = [NSString stringWithFormat:@"%ld", (long)row];
    
    if (component == 3) {
        return [[NSAttributedString alloc] initWithString:@"." attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
    }else{
        return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSUInteger selectedComponent0Row = [pickerView selectedRowInComponent:0];
    NSUInteger selectedComponent1Row = [pickerView selectedRowInComponent:1];
    NSUInteger selectedComponent2Row = [pickerView selectedRowInComponent:2];
    NSUInteger selectedComponent4Row = [pickerView selectedRowInComponent:4];
    
    double weightValue = [[NSString stringWithFormat:@"%ld%ld%ld.%ld", (long)selectedComponent0Row, (long)selectedComponent1Row, (long)selectedComponent2Row, (long)selectedComponent4Row] doubleValue];
    User *user = [User sharedModel];
    
    if (user.measureUnit == MUnitMetric) {
        [self.weight setValueWithMetric:weightValue];
    }
    else {
        [self.weight setValueWithImperial:weightValue];
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
    //    self.noteTextString = nil;
    //    self.noteText = nil;
}


#pragma mark - Event Handlers
- (void)showWeightAlert {
    [self.weightAlert show];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)didTapRecordButton:(id)sender {
    if (self.weight.valueWithMetric < CHOOSE_WEIGHT_LOWER_WEIGHT_BOUND) {
        self.weightAlert = [[UIAlertView alloc] initWithTitle:CHOOSE_WEIGHT_WARNING_MSG message:nil delegate:self cancelButtonTitle:MSG_OK otherButtonTitles:nil];
        [self performSelector:@selector(showWeightAlert) withObject:nil afterDelay:0.1];
    }
    else {
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:ADD_RECORD_SAVING_MSG];
        
        dispatch_promise(^{
            User *user = [User sharedModel];
            [user addWeightRecord:self.weight :self.currentDate :self.noteTextString? self.noteTextString : @""].then(^(BOOL success){
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

}


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
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:WEIGHT_TAG_RECORDINGTIME_LABEL];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
