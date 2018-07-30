//
//  ViewController.m
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "DosageInputViewController.h"
#import "NotificationMedicationClass.h"
#import "StyleManager.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "InsulinRecord.h"
#import "MedicationRecord.h"
#import "InputViewController.h"
#import "User.h"
#import "UIAlertController+Window.h"
#import "NotificationListViewController.h"
#import "UIAlertController+Window.h"
#import "NotificationDuplicateCheckClass.h"
#import "GGUtils.h"


@interface DosageInputViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtDosage;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentMeasurement;

@property (strong, nonatomic) NSString *selectedMeasurement;
@property (strong, nonatomic) NSString *selectedRecurrance;

@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewTime;
@property (weak, nonatomic) IBOutlet UIDatePicker *pickerViewDate;

@property (strong, nonatomic) NSDate *recordedDate;

@property (strong, nonatomic) IBOutlet UILabel *pickerViewLabel;
@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblDaily;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnHistory;

@property (nonatomic) int isSetup;

@property (weak, nonatomic) IBOutlet UILabel *labelMedication;

@property (nonatomic)  UIAlertController *alert;

@property (strong, nonatomic) NSMutableArray *arrayHours, *arrayMins, *arrayAmPm;

@property (nonatomic) BOOL duplicateReminder;

@property (nonatomic, strong) UITextView *noteText;
@property (nonatomic, strong) NSString *tempMedicationName;
@property (nonatomic, strong) NSString *tempMedicationID;

@property (nonatomic) NSString *noteTextString;


@end

@implementation DosageInputViewController
@synthesize notification;

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated{
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                 initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(goBack)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    //NSLog(@"test: %@", reminder.stringComingFromWhere);
    
    self.recordedDate = [NSDate date];
    
    if ([reminder.stringComingFromWhere isEqualToString:@"createNew"]) {
        [self setupTimeLabel];
        self.labelMedication.text = [NSString stringWithFormat:@"%@", [reminder.arrayDrug objectAtIndex:0][@"_Name"]];
        self.title = [LocalizationManager getStringFromStrId:@"Create Reminder"];
    }else
    
    if ([reminder.stringComingFromWhere isEqualToString:@"modifyFromNotification"]) {
       [self setupUsingPassedNotification];
        self.title = [LocalizationManager getStringFromStrId:@"Record Medication"];
    }else
    
    if ([reminder.stringComingFromWhere isEqualToString:@"logMedication"]){
        [self setupTimeLabel];
        self.labelMedication.text = [NSString stringWithFormat:@"%@", [reminder.arrayDrug objectAtIndex:0][@"_Name"]];
        self.title = [LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_MEDICATION_TITLE];
    }
    else{
        [self setupPassedInformationFromNoticationListView];
        self.labelMedication.text = [NSString stringWithFormat:@"%@", [reminder.arrayDrug objectAtIndex:0][@"_Name"]];
        self.title = [LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_MODIFY_TITLE];
    }
    
    [self setupTextLabelDosage];
    
    if (![reminder.stringComingFromWhere isEqualToString:@"modifyFromNotification"]) {
        [self checkForInsulinAndLockSegmentControl];
    }
    
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
    
    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
        [self.pickerViewDate addTarget:self action:@selector(datePickerSelected:) forControlEvents:UIControlEventValueChanged];
        [self.pickerViewTime removeFromSuperview];
    }
    else {
        [self.pickerViewDate removeFromSuperview];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    self.noteTextString = nil;
}

#pragma mark - View Setup
-(void)setupTextLabelDosage{
    
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    if ([reminder.stringComingFromWhere isEqualToString:@"logMedication"]  || [reminder.stringComingFromWhere isEqualToString:@"modifyFromNotification"]){
        self.lblDaily.text = [LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_LOG];
    }else{
        self.lblDaily.text = [LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_DAILY];
    }   
    
    self.txtDosage.delegate          = self;
    self.txtDosage.layer.borderColor = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1].CGColor;
    self.txtDosage.layer.borderWidth = 1.0;
    self.txtDosage.textColor         = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1];
    self.txtDosage.font              = [UIFont systemFontOfSize:17];

    UIFont *font                     = [UIFont systemFontOfSize:17];
    NSDictionary *attributes         = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [self.segmentMeasurement setTitleTextAttributes:attributes
                                           forState:UIControlStateNormal];
}

-(void)setupTimeLabel{
   
    self.lblTime.layer.borderColor = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1].CGColor;
    self.lblTime.layer.borderWidth = 1.0;
    self.lblTime.textColor = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1];
    self.lblTime.font = [UIFont systemFontOfSize:17];
    self.lblTime.numberOfLines = 2;
    
    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
        //setup time label
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd \n hh:mm a"];
        
        self.lblTime.text = [dateFormatter stringFromDate:self.recordedDate];
        
        
        [self configurePickerViewer];
    }
    else {
        NSString *tempTime = [NSString stringWithFormat:@"%@", [self dateToNearest15Minutes]];
        
        if ([tempTime hasPrefix:@"0"]) {
            tempTime = [tempTime substringFromIndex:1];
            self.lblTime.text = tempTime;
        }else{
            self.lblTime.text = [NSString stringWithFormat:@"%@", [self dateToNearest15Minutes]];
        }
        
        [self configurePickerViewer];
 
        NSArray *tempArray = [[NSArray alloc]initWithArray:[self getScrollToLocationsFromLabel:self.lblTime.text]];
        [self pickerViewScrollToHour:[((NSNumber*)[tempArray objectAtIndex:0]) intValue] minute:[((NSNumber*)[tempArray objectAtIndex:1]) intValue] amPm:[((NSNumber*)[tempArray objectAtIndex:2]) intValue]];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTapped)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.lblTime addGestureRecognizer:tapGestureRecognizer];
    self.lblTime.userInteractionEnabled = YES;
}

-(void)datePickerSelected:(UIDatePicker *)datePicker {
    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
        self.recordedDate = self.pickerViewDate.date;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd \n hh:mm a"];
        
        self.lblTime.text = [dateFormatter stringFromDate:self.recordedDate];
    }
}

-(void)showPickerView{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
                             self.pickerViewDate.alpha = 1.0;
                         }
                         else {
                             self.pickerViewTime.alpha = 1.0;
                         }
                     }
                     completion:nil];
}

-(void)labelTapped{
    [self.view endEditing:YES];
}


#pragma mark - TextField Delegate
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    
    NSCharacterSet *set = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
        return NO;
    }
    
    //Only allow 8 characters
    if ([self.txtDosage.text length] > 7) {
        if(range.length == 0)
            return NO;
    }
        
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    // If a period at the start
    if ([newString isEqualToString:@"."] && newString.length== 1) {
        textField.text = @"0.";
        return NO;
    }
    
    if (newString.length == 2 && [[newString substringToIndex:1] isEqualToString:@"0"]) {
        textField.text = @"0.";
        return NO;
    }
    
    if ([textField.text isEqualToString:@"00"]) {
        textField.text = @"0.";
        return NO;
    }
    
    //Only allow 1 period
    NSArray *components = [newString componentsSeparatedByString:@"."];
    if([components count] > 2)
    {
        return NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
                             self.pickerViewDate.alpha = 0.0;
                         }
                         else {
                             self.pickerViewTime.alpha = 0.0;
                         }
                     }
                     completion:nil];
}


#pragma mark - UIPickerViewDelegate / Data Source
-(void)configurePickerViewer{
    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
        self.pickerViewDate.datePickerMode = UIDatePickerModeDateAndTime;
        self.pickerViewDate.date = self.recordedDate;
    }
    else {
        self.arrayHours = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
        self.arrayMins  = [[NSMutableArray alloc] initWithObjects:  @"00", @"01", @"02", @"03", @"04", @"05",@"06", @"07", @"08", @"09",
                           @"10", @"11", @"12", @"13", @"14", @"15",@"16", @"17", @"18", @"19",
                           @"20", @"21", @"22", @"23", @"24", @"25",@"26", @"27", @"28", @"29",
                           @"30", @"31", @"32", @"33", @"34", @"35",@"36", @"37", @"38", @"39",
                           @"40", @"41", @"42", @"43", @"44", @"45",@"46", @"47", @"48", @"49",
                           @"50", @"51", @"52", @"53", @"54", @"55",@"56", @"57", @"58", @"59", nil];
        self.arrayAmPm  = [[NSMutableArray alloc] initWithObjects:TIME_AM, TIME_PM, nil];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    self.pickerViewLabel = (UILabel*)view;
    if (!self.pickerViewLabel){
        self.pickerViewLabel = [[UILabel alloc] init];
        self.pickerViewLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:25];
        self.pickerViewLabel.minimumScaleFactor = 0.5f;
        self.pickerViewLabel.adjustsFontSizeToFitWidth = YES;
        self.pickerViewLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    switch (component) {
        case 0:
            [self.pickerViewLabel setText:[self.arrayHours objectAtIndex:row]];
            break;
        case 1:
            [self.pickerViewLabel setText:@":"];
            break;
        case 2:
            [self.pickerViewLabel setText:[self.arrayMins objectAtIndex:row]];
            break;
        case 3:
            [self.pickerViewLabel setText:[self.arrayAmPm objectAtIndex:row]];
            break;
    }
    
    return self.pickerViewLabel;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [self.arrayHours count];
            break;
        case 1:
            return 1;
            break;
        case 2:
            return [self.arrayMins count];
            break;
        case 3:
            return [self.arrayAmPm count];
            break;
    }
    
    return YES;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSInteger hour = [pickerView selectedRowInComponent:0];
    NSInteger minutes = [pickerView selectedRowInComponent:2];
    NSInteger amPm = [pickerView selectedRowInComponent:3];
    
    self.lblTime.text = [NSString stringWithFormat:@"%@:%@ %@",[self.arrayHours objectAtIndex:hour],[self.arrayMins objectAtIndex:minutes], [self.arrayAmPm objectAtIndex:amPm]];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 4;
}

-(void)pickerViewScrollToHour:(int)hour minute:(int)minute amPm:(int)amPm{
    [self.pickerViewTime selectRow:hour inComponent:0 animated:YES];
    [self.pickerViewTime selectRow:minute inComponent:2 animated:YES];
    [self.pickerViewTime selectRow:amPm inComponent:3 animated:YES];
}

#pragma mark - Setup From Passed In Reminder / PreCreated Reminder
-(void)setupPassedInformationFromNoticationListView{
    
    [self setupTimeLabel];
    
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    
    NSArray *substrings = [reminder.stringDosage componentsSeparatedByString:@" "];
    NSString *correctDosage = [substrings objectAtIndex:0];
    NSString *correctMeasurement = [substrings objectAtIndex:1];
    
    //Dosage
    self.txtDosage.text = correctDosage;
    
    //Measurement
    
    if (![reminder.stringComingFromWhere isEqualToString:@"logMedication"]) {
  
        NSString *measurement = correctMeasurement;
    
        if ([measurement isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_SELECTED_MEASUREMENT_MG]]) {
            [self.segmentMeasurement setSelectedSegmentIndex:0];
        }else if ([measurement isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_SELECTED_MEASUREMENT_ML]]){
            [self.segmentMeasurement setSelectedSegmentIndex:1];
        }else{
            [self.segmentMeasurement setSelectedSegmentIndex:2];
        }
    }
    
    //Time
    if (![self.title isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_MEDICATION_TITLE]]) {
        self.lblTime.text = reminder.stringTime;
    }

    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]){
        //NSLog(@"Passed time to NMR\n");
    }
    else {
        NSArray *tempArray = [[NSArray alloc]initWithArray:[self getScrollToLocationsFromLabel:self.lblTime.text]];
        [self pickerViewScrollToHour:[((NSNumber*)[tempArray objectAtIndex:0]) intValue] minute:[((NSNumber*)[tempArray objectAtIndex:1]) intValue] amPm:[((NSNumber*)[tempArray objectAtIndex:2]) intValue]];
    }
    
}

#pragma mark - Setup From Passed Notification
-(void)setupUsingPassedNotification{
    //Add Skip Button
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                 initWithTitle:[LocalizationManager getStringFromStrId:MSG_SKIP]
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(SkipMedication)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    //Configure using notification info
    NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
    reminder.stringNotificationIndex = [[notification userInfo] objectForKey:@"reminderID"];
    
    [self setupTimeLabel];
    
    self.labelMedication.text = [[notification userInfo] objectForKey:@"drugName"];
    self.txtDosage.text = [[notification userInfo] objectForKey:@"dosage"];
    self.lblDaily.text  = [LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_LOG];
    
    
    if ([[[notification userInfo] objectForKey:@"measurement"] isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_SELECTED_MEASUREMENT_MG]]) {
        [self.segmentMeasurement setSelectedSegmentIndex:0];
    }else if ([[[notification userInfo] objectForKey:@"measurement"] isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_SELECTED_MEASUREMENT_ML]]){
        [self.segmentMeasurement setSelectedSegmentIndex:1];
    }else{
        [self.segmentMeasurement setSelectedSegmentIndex:2];
    }
}

#pragma mark - Time Methods
-(int)getArrayLocationOfAmPmFromLabel:(NSString *)amPm{
    
    if ([amPm isEqualToString:TIME_AM]) {
        return 0;
    }else{
        return 1;
    }
}

-(NSMutableArray *)getScrollToLocationsFromLabel:(NSString *)labelTime{
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:3];
    
    int selectedRowHours = [[labelTime substringToIndex:[labelTime rangeOfString:@":"].location] intValue] - 1;
    int selectedAmPm = [self getArrayLocationOfAmPmFromLabel:[labelTime  substringWithRange:NSMakeRange([labelTime length] - 2, 2)]];
    
    int tempMin = [[labelTime  substringWithRange:NSMakeRange([labelTime rangeOfString:@":"].location + 1, 2)]intValue];
    
    [tempArray addObject:[NSNumber numberWithInt:selectedRowHours]];
    
    [tempArray addObject:[NSNumber numberWithInt:tempMin]];
    
    [tempArray addObject:[NSNumber numberWithInt:selectedAmPm]];
    
    return tempArray;
}

- (NSString *)dateToNearest15Minutes {
 
 unsigned unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal;
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:unitFlags fromDate:[NSDate date]];

    // Set the minute to the nearest 15 minutes.
    //[comps setMinute:((([comps minute] - 8 ) / 15 ) * 15 ) + 15];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"hh:mm a"];

    return [dateFormatter stringFromDate: [[NSCalendar currentCalendar] dateFromComponents:comps]];
}

#pragma mark - Segment Custom Methods
-(void)checkForInsulinAndLockSegmentControl{
    
    NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
    NSArray *tempArrayMed = [[NSArray alloc]initWithArray:[MedicationRecord getAllMedications]];
    
    for (NSDictionary *item in tempArrayMed)
    {
        if ([[item objectForKey:@"_Name"] isEqualToString:[reminder.arrayDrug objectAtIndex:0][@"_Name"]]) {
            if ([[[item objectForKey:@"_ID"] substringToIndex:1] isEqualToString:@"i"]) {
                self.segmentMeasurement.selectedSegmentIndex = 2;
                break;
            }else{
                self.segmentMeasurement.selectedSegmentIndex = 0;
                break;
            }
        }
    }
    
    if (![reminder.stringComingFromWhere isEqualToString:@"createNew"]) {
        [self setupPassedInformationFromNoticationListView];
    }
}

#pragma mark - Reminder Class Update and Database
-(void)addOrUpdateToDatabase{
    
    NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
    [reminder addReminderDosage:[NSString stringWithFormat:@"%@ %@", self.txtDosage.text, [self.segmentMeasurement titleForSegmentAtIndex:self.segmentMeasurement.selectedSegmentIndex]]];
    [reminder addReminderTime:self.lblTime.text];
    
    if ([reminder.stringNotificationIndex isEqualToString:@"-1"]) {
         [reminder addReminderUuid:[[NSUUID UUID] UUIDString]];
        [reminder addNotificationToDatabase:reminder withMeasurment:[self.segmentMeasurement titleForSegmentAtIndex:self.segmentMeasurement.selectedSegmentIndex] andDosage:self.txtDosage.text];
    }else{
        [reminder updateNotificationToDatabase:reminder];
    } 
}

#pragma mark - Touches
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.txtDosage resignFirstResponder];
    [self showPickerView];
}

#pragma mark - IBAction / Buttons
- (IBAction)btnAddNote:(id)sender {
    
    self.noteText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 100)];
    self.noteText.backgroundColor = [UIColor whiteColor];
    self.noteText.textColor = [UIColor blackColor];
    self.noteText.font = [UIFont systemFontOfSize:14];
    self.noteText.delegate = self;
    
    self.noteText.text = self.noteTextString;
                                    
    [self.view.superview slideInPopupForNotesWithTitle:[LocalizationManager getStringFromStrId:@"Notes"]
                                       withComponent:self.noteText
                                        withDelegate:(id)self];
                                    
    [self.noteText becomeFirstResponder];
  
   

}


- (IBAction)btnContinue {
    
    if ([[NotificationDuplicateCheckClass getInstance] isDuplicateNotificationTimeUsingNotificationTimeString:self.lblTime.text]) {
        NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
        if ([reminder.stringComingFromWhere isEqualToString:@"createNew"]) {
            [[NotificationDuplicateCheckClass getInstance] showDuplicateAlert];
            self.duplicateReminder = YES;
        }

    }
    else {
        self.duplicateReminder = NO;
    }
    
    if ([self.txtDosage.text floatValue] > 0){
            
        NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
            
            if ([reminder.stringComingFromWhere isEqualToString:@"createNew"]) {
                
                if (!self.duplicateReminder) {
                    NSLog(@"CREATE");
                    [self addOrUpdateToDatabase];
                    [self showPromptInfomation:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_CREATION_ALERT_TITLE]];
                }
                
            }else if ([reminder.stringComingFromWhere isEqualToString:@"modifyFromNotification"]) {
                    
                [self addMedicationRecord:[[notification userInfo] objectForKey:@"drugID"] medicationName:[[notification userInfo] objectForKey:@"drugName"] andNote:@"None"];
            
            }else if ([reminder.stringComingFromWhere isEqualToString:@"logMedication"]){
                NSLog(@"LOG");
              //////
                
                [self.view endEditing:YES];
                
                if (self.noteText.text) {
                    [self addMedicationRecord:[reminder.arrayDrug objectAtIndex:0][@"_ID"]medicationName:[reminder.arrayDrug objectAtIndex:0][@"_Name"] andNote:self.noteText.text];
                }else{
                    [self addMedicationRecord:[reminder.arrayDrug objectAtIndex:0][@"_ID"]medicationName:[reminder.arrayDrug objectAtIndex:0][@"_Name"] andNote:@""];
                }
                
                
                        
            }else{
                NSLog(@"EDIT");
                [self addOrUpdateToDatabase];
                [self showPromptInfomation:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_UPDATE_ALERT_TITLE]];
            }
        }
    
}

-(void)SkipMedication{
    [[NotificationMedicationClass getInstance] addOneToReminderCountSkipForMedicationCompliance:[[[notification userInfo] objectForKey:@"reminderID"]intValue]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AlertPrompt
-(void)showPromptInfomation:(NSString *)promptMessage{
    
    self.alert = [UIAlertController alertControllerWithTitle:nil message:promptMessage preferredStyle:UIAlertControllerStyleAlert];
    [self.alert show];
    
    [self performSelector:@selector(dismissAlert:) withObject:self.alert afterDelay:1.0];
    
}

-(void)dismissAlert:(UIAlertController *)alertPrompt{
    
    [alertPrompt dismissViewControllerAnimated:YES completion:nil];
    
    NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
    if ([reminder.stringComingFromWhere isEqualToString:@"createNew"]){
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"unwindToReminderList" sender:self];
    }else if ([self.title isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_MODIFY_TITLE]]) {
        [self dismissViewControllerAnimated:NO completion:nil];
        [self performSegueWithIdentifier:@"unwindToReminderList" sender:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"unwindToMedication" sender:self];
    }
}

#pragma mark - Add Records

- (NSDate *)recordedTime {
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components;
    
    if ([[NotificationMedicationClass getInstance].stringComingFromWhere isEqualToString:@"logMedication"]) {
        components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute
                                 fromDate:self.recordedDate];
    }
    else {
        NSInteger hour = [[self.arrayHours objectAtIndex:[self.pickerViewTime selectedRowInComponent:0]] integerValue];
        NSInteger minutes = [[self.arrayMins objectAtIndex:[self.pickerViewTime selectedRowInComponent:2]] integerValue];
        NSInteger amPm = [self.pickerViewTime selectedRowInComponent:3];
        
        // convert AM/PM to 24 hour clock
        if ([[self.arrayAmPm objectAtIndex:amPm] isEqualToString:TIME_PM] && hour != 12) {
            hour += 12;
        }
        else if (hour == 12 && [[self.arrayAmPm objectAtIndex:amPm] isEqualToString:TIME_AM]) {
            hour = 0;
        }
        
        components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                 fromDate:[NSDate date]];
        [components setHour:hour];
        [components setMinute:minutes];
    }
    
    return [calendar dateFromComponents:components];
}

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer{
   // [self addMedicationRecord:self.tempMedicationID medicationName:self.tempMedicationName andNote:self.noteText.text];
    self.noteTextString = self.noteText.text;
}

-(void)slideInPopupDidChooseCancel{
    self.noteTextString = nil;
    self.noteText = nil;
}

-(void)addMedicationRecord:(NSString *)medicationID medicationName:(NSString *)medicationName andNote:(NSString *)note{
    
    User *user = [User sharedModel];
    NSMutableArray *tempUserMedicineArray = [[NSMutableArray alloc]initWithArray:user.medications];
    
    if (![tempUserMedicineArray containsObject:medicationName]) {
        [tempUserMedicineArray addObject:medicationName];
    }
    
    user.medications = tempUserMedicineArray;
    
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
    
    dispatch_promise(^{
        
        MedicationRecord *record = [[MedicationRecord alloc] init];
        record.dose = [self.txtDosage.text floatValue];
        record.measurement = [self.segmentMeasurement titleForSegmentAtIndex:self.segmentMeasurement.selectedSegmentIndex];
        record.medicationId = medicationID;
        record.recordedTime = [self recordedTime];
        record.uuid = (NSString *)[[NSUUID UUID] UUIDString];
        record.note = self.noteText.text;
        
        [record save].then(^(BOOL success) {
            [self showPromptInfomation:[LocalizationManager getStringFromStrId:ADD_RECORD_SUCESS_MSG]];
        }).catch(^(BOOL success) {
            [self showPromptInfomation:[LocalizationManager getStringFromStrId:ADD_RECORD_FAILURE_MSG]];
            
        }).finally(^{
            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
        });
    });
    
    NSString *lastMedication = [NSString stringWithFormat:@"%@ - %@ %@", medicationName, self.txtDosage.text, [self.segmentMeasurement titleForSegmentAtIndex:self.segmentMeasurement.selectedSegmentIndex]];
   
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userLastMedication = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userLastMedication"]];

    [userLastMedication setObject:lastMedication forKey:user.userId];
    [prefs setObject:userLastMedication forKey:@"userLastMedication"];
    [prefs synchronize];

}

#pragma TextView Delegates
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.?,()!%+=-/ "] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [text isEqualToString:filtered];
}

#pragma mark - Navigation
-(void)goBack{
    
    if ([self.title isEqualToString:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_MODIFY_TITLE]]) {
        [self performSegueWithIdentifier:@"unwindToReminderList" sender:self];
    }else{
       [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
