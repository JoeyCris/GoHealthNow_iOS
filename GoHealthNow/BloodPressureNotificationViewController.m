//
//  ViewController.m
//  reminders
//
//  Created by John Wreford on 2015-10-16.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "BloodPressureNotificationViewController.h"
#import "NotificationBloodPressureClass.h"
#import "StyleManager.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "UIAlertController+Window.h"
#import "NotificationDuplicateCheckClass.h"

@interface BloodPressureNotificationViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewTime;
@property (strong, nonatomic) IBOutlet UILabel *pickerViewLabel;

@property (strong, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) IBOutlet UILabel *lblDaily;

@property (weak, nonatomic) IBOutlet UILabel *lblMealType;
@property (weak, nonatomic) IBOutlet UILabel *lblLabelMeal;

@property (nonatomic) BOOL isTimePickerActive;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic)  UIAlertController *alert;

@property (strong, nonatomic) NSMutableArray *arrayHours, *arrayMins, *arrayAmPm, *arrayMeals;

@end

@implementation BloodPressureNotificationViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    self.isTimePickerActive = YES;
    [self configurePickerViewer];
    [self setupTimeLabel];
    [self setupTextLabels];
   
    [StyleManager styleNavigationBar:self.navBar];

    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(didTapCancelButton)];
    self.navBar.topItem.leftBarButtonItem = btnBack;
    
    //UIBarButtonItem *btnDone = [[UIBarButtonItem alloc]initWithTitle:[LocalizationManager getStringFromStrId:@"Save"] style:UIBarButtonItemStylePlain target:self action:@selector(btnDone)];
    UIBarButtonItem *btnDone = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(btnDone)];
    
    self.navBar.topItem.rightBarButtonItem = btnDone;
    
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
}

#pragma mark - View Setup

-(void)setupTextLabels{
    
    UITapGestureRecognizer* gestureDaily = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(guestureDaily)];
    [self.lblTime setUserInteractionEnabled:YES];
    [self.lblTime addGestureRecognizer:gestureDaily];
    
    UITapGestureRecognizer* gestureMeal = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureMeal)];
    [self.lblMealType setUserInteractionEnabled:YES];
    [self.lblMealType addGestureRecognizer:gestureMeal];
    
}


-(void)setupTimeLabel{
    self.lblTime.layer.borderColor = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1].CGColor;
    self.lblTime.layer.borderWidth = 1.0;
    self.lblTime.textColor = [UIColor colorWithRed:53/255.0f green:86/255.0f blue:164/255.0f alpha:1];
    self.lblTime.font = [UIFont systemFontOfSize:20];
    
    NSString *tempTime = [NSString stringWithFormat:@"%@", [self dateToNearest15Minutes]];
    
    if ([tempTime hasPrefix:@"0"]) {
        tempTime = [tempTime substringFromIndex:1];
        self.lblTime.text = tempTime;
    }else{
        self.lblTime.text = [NSString stringWithFormat:@"%@", [self dateToNearest15Minutes]];
    }
    
    NSArray *tempArray = [[NSArray alloc]initWithArray:[self getScrollToLocationsFromLabel:self.lblTime.text]];
    [self pickerViewScrollToHour:[((NSNumber*)[tempArray objectAtIndex:0]) intValue] minute:[((NSNumber*)[tempArray objectAtIndex:1]) intValue] amPm:[((NSNumber*)[tempArray objectAtIndex:2]) intValue]];
}

-(void)showPickerView{
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{self.pickerViewTime.alpha = 1.0;}
                     completion:nil];
}

-(void)hidePickerView{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{self.pickerViewTime.alpha = 0.0;}
                     completion:nil];
}

#pragma mark - UIPickerViewDelegate / Data Source
-(void)configurePickerViewer{
    
    self.arrayHours = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", nil];
   
    
    self.arrayMins  = [[NSMutableArray alloc] initWithObjects:  @"00", @"01", @"02", @"03", @"04", @"05",@"06", @"07", @"08", @"09",
                                                                @"10", @"11", @"12", @"13", @"14", @"15",@"16", @"17", @"18", @"19",
                                                                @"20", @"21", @"22", @"23", @"24", @"25",@"26", @"27", @"28", @"29",
                                                                @"30", @"31", @"32", @"33", @"34", @"35",@"36", @"37", @"38", @"39",
                                                                @"40", @"41", @"42", @"43", @"44", @"45",@"46", @"47", @"48", @"49",
                                                                @"50", @"51", @"52", @"53", @"54", @"55",@"56", @"57", @"58", @"59", nil];

    self.arrayAmPm  = [[NSMutableArray alloc] initWithObjects:TIME_AM, TIME_PM, nil];
    
    self.arrayMeals = [[NSMutableArray alloc] initWithObjects:[LocalizationManager getStringFromStrId:MSG_BREAKFAST], [LocalizationManager getStringFromStrId:MSG_LUNCH], [LocalizationManager getStringFromStrId:MSG_DINNER], [LocalizationManager getStringFromStrId:MSG_SNACK], nil];
    
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
    
    
    if (self.isTimePickerActive) {
    
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
    }else{
        [self.pickerViewLabel setText:[self.arrayMeals objectAtIndex:row]];
    }
    
    return self.pickerViewLabel;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.isTimePickerActive) {
    
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
    }else{
        return [self.arrayMeals count];
    }
    
    return YES;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (self.isTimePickerActive) {

        NSInteger hour = [pickerView selectedRowInComponent:0];
        NSInteger minutes = [pickerView selectedRowInComponent:2];
        NSInteger amPm = [pickerView selectedRowInComponent:3];
        
        self.lblTime.text = [NSString stringWithFormat:@"%@:%@ %@",[self.arrayHours objectAtIndex:hour],[self.arrayMins objectAtIndex:minutes], [self.arrayAmPm objectAtIndex:amPm]];
    }else{
        self.lblMealType.text = [NSString stringWithFormat:@"%@", [self.arrayMeals objectAtIndex:row]];
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    
    if (self.isTimePickerActive) {
        return 4;
    }else{
        return 1;
    }
}

-(void)pickerViewScrollToHour:(int)hour minute:(int)minute amPm:(int)amPm{
    [self.pickerViewTime selectRow:hour inComponent:0 animated:NO];
    [self.pickerViewTime selectRow:minute inComponent:2 animated:NO];
    [self.pickerViewTime selectRow:amPm inComponent:3 animated:NO];
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
    // [comps setMinute:((([comps minute] - 8 ) / 15 ) * 15 ) + 15];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [dateFormatter setDateFormat:@"hh:mm a"];

    
    return [dateFormatter stringFromDate: [[NSCalendar currentCalendar] dateFromComponents:comps]];
}

#pragma mark - Meal Label Methods
-(void)scrollMealPickerToMatchLabel{
    
    for (id item in self.arrayMeals){
        
        if ([self.lblMealType.text isEqualToString:item]) {
            long indexOfItem = (unsigned long)[self.arrayMeals indexOfObject:item];
            [self.pickerViewTime selectRow:indexOfItem inComponent:0 animated:NO];
            break;
        }
    }
}

#pragma mark - IBAction / Buttons
- (void)btnDone {
    
    if ([[NotificationDuplicateCheckClass getInstance] isDuplicateNotificationTimeUsingNotificationTimeString:self.lblTime.text]) {
        [[NotificationDuplicateCheckClass getInstance] showDuplicateAlert];
    }else{
        NotificationBloodPressureClass *reminder = [NotificationBloodPressureClass getInstance];
        [reminder addReminderTime:self.lblTime.text];
        reminder.uuidString = [[NSUUID UUID] UUIDString];
  
        [reminder addNotificationToDatabase:reminder];
  
        [self showPromptInfomation:[LocalizationManager getStringFromStrId:INPUT_NOTIFICATION_CREATION_ALERT_TITLE]];
    }
}

-(void)gestureMeal{
    self.isTimePickerActive = NO;
    [self hidePickerView];
    [self.pickerViewTime reloadAllComponents];
    [self scrollMealPickerToMatchLabel];
    [self showPickerView];
}

-(void)guestureDaily{
    self.isTimePickerActive = YES;
    [self hidePickerView];
    [self.pickerViewTime reloadAllComponents];
    [self setupTimeLabel];
    [self showPickerView];
}

-(void)didTapCancelButton{
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
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSegueWithIdentifier:@"unwindToReminderList" sender:self];
}
  
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
