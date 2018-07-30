//
//  AddBloodPressureViewController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-08-02.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "AddBloodPressureViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ChooseDateTimeViewController.h"
#import "ChooseDateTimeDelegate.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "BPRecord.h"

static NSUInteger const SYSTOLIC_TEXTFIELD_TAG= 1;
static NSUInteger const DIASTOLIC_TEXTFIELD_TAG= 2;
static NSUInteger const PULSE_TEXTFIELD_TAG= 3;
static NSUInteger const RECORDINGTIME_LABEL_TAG= 4;

@interface AddBloodPressureViewController ()<UITextFieldDelegate, ChooseDateTimeDelegate>
@property (nonatomic) NSDate *currentDate;
@property (nonatomic) UITextField *systolicTextField;
@property (nonatomic) UITextField *diastolicTextField;
@property (nonatomic) UITextField *pulseTextField;

@property (nonatomic) UITextView *noteText;
@property (nonatomic) NSString *noteTextString;

@end

@implementation AddBloodPressureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.currentDate = [NSDate date];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewDidDisappear:(BOOL)animated{
    self.noteTextString = nil;
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.systolicTextField resignFirstResponder];
    [self.diastolicTextField resignFirstResponder];
    [self.pulseTextField resignFirstResponder];
    [self.view becomeFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
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

    if (self.noteText.text) {
        [self saveRecordWithNote:self.noteText.text];
    }else{
        [self saveRecordWithNote:@""];
    }}

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
    if (self.systolicTextField.text.length == 0  && self.diastolicTextField.text.length == 0 && self.pulseTextField.text.length == 0){
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Alert"] message:[LocalizationManager getStringFromStrId:@"Empty record cannot be saved!"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alertController animated:true completion:nil];
        
    }else{
        float systolic;
        float diastolic;
        float pulse;
        
        if(self.systolicTextField.text.length){
            systolic = [self.systolicTextField.text floatValue];
        }else{
            systolic = 0;
        }
        
        if(self.diastolicTextField.text.length){
            diastolic = [self.diastolicTextField.text floatValue];
        }else{
            diastolic = 0;
        }
        
        if(self.pulseTextField.text.length){
            pulse = [self.pulseTextField.text floatValue];
        }else{
            pulse = 0;
        }
        
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
        
        dispatch_promise(^{
            BPRecord* record = [[BPRecord alloc] init];
            
            record.systolic = [NSNumber numberWithFloat:systolic];
            record.diastolic = [NSNumber numberWithFloat:diastolic];
            record.pulse = [NSNumber numberWithFloat:pulse];
            record.recordedTime = self.currentDate;
            record.note = note;
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

}


- (void)dismissRecordPromptAlert:(NSTimer*)theTimer
{
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"systolicCell" forIndexPath:indexPath];
        self.systolicTextField = (UITextField *)[cell viewWithTag:SYSTOLIC_TEXTFIELD_TAG];
        self.systolicTextField.delegate = self;
        self.systolicTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"diastolicCell" forIndexPath:indexPath];
        self.diastolicTextField = (UITextField *)[cell viewWithTag:DIASTOLIC_TEXTFIELD_TAG];
        self.diastolicTextField.delegate = self;
        self.diastolicTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"pulseCell" forIndexPath:indexPath];
        self.pulseTextField = (UITextField *)[cell viewWithTag:PULSE_TEXTFIELD_TAG];
        self.pulseTextField.delegate = self;
        self.pulseTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }
    else if (indexPath.row == 3) {
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"recordingTimeCell" forIndexPath:indexPath];
       
        UILabel *timeLabel = (UILabel *)[cell viewWithTag:RECORDINGTIME_LABEL_TAG];
        timeLabel.text = nowString;
            }    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float height;
    switch (indexPath.row) {
        case 0:
        case 1:
        case 2:
            height = 140;
            break;
        
        default:
            height = 44.0;
            break;
    }
    return height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.systolicTextField becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        [self.diastolicTextField becomeFirstResponder];
    }
    else if (indexPath.row == 2) {
        [self.pulseTextField becomeFirstResponder];
    }
    else if (indexPath.row == 3) {
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

#pragma mark - ChooseDateTimeDelegate Methods
- (void)didChooseDateTime:(NSDate *)dateTime sender:(id)sender {
    //self.didModify = YES;
    self.currentDate = dateTime;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
    NSString *nowString = [outputFormatter stringFromDate:self.currentDate];
    
    UILabel *timeLabel = (UILabel *)[cell viewWithTag:RECORDINGTIME_LABEL_TAG];
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
