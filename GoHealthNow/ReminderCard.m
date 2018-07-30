//
//  ReminderCard.m
//  Reminder
//
//  Created by Haoyu Gu on 2015-07-17.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import "ReminderCard.h"
#import "SlideInCardBaseView.h"
#import <EventKit/EventKit.h>
#import "UIColor+Extensions.h"

#define VIEW_TOP_Y_CONTROL 0

@interface ReminderCard() <SlideInCardBaseDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIPickerViewDelegate>

@property (nonatomic) UITableView *mainTable;
//Frame for card
@property (nonatomic) CGRect viewFrame;
@property (nonatomic) SlideInCardView *cardView;
@property (nonatomic) ReminderRecord *reminderRecord;

@property (nonatomic) BOOL isAccessToEventStoreGranted;

@property (nonatomic) EKCalendar *cal;
@property (nonatomic) EKEventStore *store;

@property (nonatomic) NSArray *weekdayRows;
@property (nonatomic) NSArray *weekdayRowsTags;

@property (nonatomic) BOOL essentialMarkFlag;

@property (nonatomic) BOOL datePickerVisibleFlag;
@property (nonatomic) BOOL viewMoved;

@end

@implementation ReminderRecord

@end

@implementation ReminderCard

static NSUInteger const SWITCHER_REMIND_ME_ON_A_DAY = 1;
static NSUInteger const SWITCHER_IS_REPEAT = 2;

static NSUInteger const SWITCHER_MONDAY = 1;
static NSUInteger const SWITCHER_TUESDAY = 2;
static NSUInteger const SWITCHER_WEDNESDAY = 3;
static NSUInteger const SWITCHER_THURSDAY = 4;
static NSUInteger const SWITCHER_FRIDAY = 5;
static NSUInteger const SWITCHER_SATURDAY = 6;
static NSUInteger const SWITCHER_SUNDAY = 7;

static NSUInteger const TEXTFIELD_EVENT = 8;
static NSUInteger const TEXTFIELD_NOTES = 9;

static NSUInteger const DATE_PICKER = 10;
static NSUInteger const DATE_LABEL = 11;
static CGFloat const DATE_PICKER_VISIBLE_HEIGHT = 190.0;

#pragma mark - methods

- (void)loadReminderViewWithRecord:(ReminderRecord *)rRecord withView:(UIView *)view {
    if (rRecord == nil) {
        [self loadReminderViewWithView:view];
    }
    else {
        self.viewFrame = view.frame;
        //TODO
    }
}

- (void)loadReminderViewWithView:(UIView *)view {
    self.essentialMarkFlag = NO;
    self.datePickerVisibleFlag = NO;
    
    self.reminderRecord = [[ReminderRecord alloc] init];
    self.reminderRecord.isRepeat = NO;
    self.reminderRecord.remindOnADay = NO;
    self.reminderRecord.date = [NSDate date];
    
    self.reminderRecord.repeatDays = [[NSMutableArray alloc] initWithObjects:@0, @0, @0, @0, @0, @0, @0, nil];
    
    self.viewFrame = CGRectMake(view.frame.origin.x, view.frame.origin.y,
                                [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //body
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(10, 60, self.viewFrame.size.width-60, self.viewFrame.size.height-70-self.viewFrame.size.height/4) style:UITableViewStyleGrouped];
    [self.mainTable setBackgroundColor:[UIColor clearColor]];
    self.mainTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.mainTable.bounds.size.width, 0.01f)];
    //config table view
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
 
    _store = [[EKEventStore alloc] init];
    [self checkReminderAccessiblity];

    [self showCard];
}

- (void)showCard {
    self.cardView = [[SlideInCardView alloc] init];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]  initWithTarget:self action:@selector(tapToHideKeyboard)];
    tap.delegate = self;
    [self.cardView addGestureRecognizer:tap];
    
    [self.cardView loadCardWithTitle:@"New Reminder"
                               withFrame:CGRectMake(20, self.viewFrame.size.height/4, self.viewFrame.size.width - 40, self.viewFrame.size.height - (self.viewFrame.size.height/4)+10)
                     withLeftButtonImage:[UIImage imageNamed:@"cancelIcon"]
                    withRightButtonImage:[UIImage imageNamed:@"checkmarkIcon"]
                withBackgroundColorArray:nil
                            withEndTitle:@"Saved!"
                           withComponent:self.mainTable
                            withDelegate:self];
}

- (void)checkReminderAccessiblity {
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeReminder];
    switch (authorizationStatus) {
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            self.isAccessToEventStoreGranted = NO;
            break;
        case EKAuthorizationStatusAuthorized:
            self.isAccessToEventStoreGranted = YES;
            break;
        case EKAuthorizationStatusNotDetermined: {
            [self.store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
                // handle access here
                self.isAccessToEventStoreGranted = granted;
            }];
            break;
        }
    }
}

- (EKCalendar *)getCalendar {
    if (!self.cal) {
        NSArray *calendars = [self.store calendarsForEntityType:EKEntityTypeReminder];

        NSString *calendarTitle = @"GoHealthNow";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
        NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
        
        if ([filtered count]) {
            self.cal = [filtered firstObject];
        } else {
            self.cal = [EKCalendar calendarForEntityType:EKEntityTypeReminder eventStore:self.store];
            self.cal.title = @"GoHealthNow";
            self.cal.source = self.store.defaultCalendarForNewReminders.source;

            NSError *calendarErr = nil;
            BOOL calendarSuccess = [self.store saveCalendar:self.cal commit:YES error:&calendarErr];
            if (!calendarSuccess) {
                
            }
        }
    }
    return self.cal;
}

- (void)saveReminder {
    [_store requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError *error) {
        // handle access here
        self.isAccessToEventStoreGranted = granted;
        if (granted) {
            EKReminder *reminder = [EKReminder reminderWithEventStore:_store];
            
            EKCalendar *cal = [self getCalendar];

            reminder.title = self.reminderRecord.eventName;
            reminder.notes = self.reminderRecord.eventNote;
            
            EKAlarm *alarm = [EKAlarm alarmWithAbsoluteDate:self.reminderRecord.date];
            [reminder addAlarm:alarm];
            
            NSMutableArray *rDays = [[NSMutableArray alloc] init];
            for (int i=0;i<7;i++) {
                if ([self.reminderRecord.repeatDays[i] boolValue] == YES) {
                    [rDays addObject:[EKRecurrenceDayOfWeek dayOfWeek:i+1]];
                }
            }
            
            EKRecurrenceRule *recur = [[EKRecurrenceRule alloc] initRecurrenceWithFrequency:EKRecurrenceFrequencyWeekly
                                                                                   interval:1
                                                                              daysOfTheWeek:rDays
                                                                             daysOfTheMonth:nil
                                                                            monthsOfTheYear:nil
                                                                             weeksOfTheYear:nil
                                                                              daysOfTheYear:nil
                                                                               setPositions:nil
                                                                                        end:nil];
            
            reminder.recurrenceRules = [[NSArray alloc] initWithObjects:recur, nil];
            NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            NSDateComponents *dailyComponents=[gregorian components:(NSCalendarUnitYear|NSCalendarUnitMonth|
                                               NSCalendarUnitDay|NSCalendarUnitHour|
                                               NSCalendarUnitMinute|NSCalendarUnitSecond|
                                               NSCalendarUnitTimeZone)
                                                           fromDate:self.reminderRecord.date];
            reminder.dueDateComponents = dailyComponents;
            reminder.calendar = cal;
            
            NSError *errs;
            
            [_store saveReminder:reminder commit:YES error:&errs];
            if (errs != nil) {
                NSLog(@"Error occured on saving reminders to system db\n");
                NSLog(@"%@\n", errs);
            }
        }
        else {
            //not allowed to access
        }
        
    }];
}

- (NSString *)dateStrFromDate:(NSDate *)date {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateStyle = NSDateFormatterMediumStyle;
    outputFormatter.timeStyle = NSDateFormatterShortStyle;
    
    return [outputFormatter stringFromDate:date];
}

- (void)datePickerSelected:(UIDatePicker *)datePicker {
    self.reminderRecord.date = datePicker.date;
    UITableViewCell *cell = [self.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    UILabel *dateLabel = (UILabel *)[cell viewWithTag:DATE_LABEL];
    [dateLabel setText:[self dateStrFromDate:self.reminderRecord.date]];
}

- (void)drawCellsWithCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath {
    self.weekdayRows = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    self.weekdayRowsTags = @[[NSNumber numberWithUnsignedInteger:SWITCHER_MONDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_TUESDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_WEDNESDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_THURSDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_FRIDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_SATURDAY],
                             [NSNumber numberWithUnsignedInteger:SWITCHER_SUNDAY]];
    
        switch (indexPath.row) {
            case 0:
            {
                UIImageView *icon = [[UIImageView alloc] init];
                [icon setFrame:CGRectMake((cell.frame.size.height - 20)/2, (cell.frame.size.height - 20)/2, 20, 20)];
                [icon setImage:[UIImage imageNamed:@"reminderEventIcon"]];
                [cell addSubview:icon];
                
                UITextField *inputBox = [[UITextField alloc] init];
                [inputBox setFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width +10, 0, cell.frame.size.width - 60, 44)];
                inputBox.placeholder = @"Event";
                if (self.reminderRecord.eventName != nil) {
                    inputBox.text = self.reminderRecord.eventName;
                }
                inputBox.tag = TEXTFIELD_EVENT;
                inputBox.returnKeyType = UIReturnKeyDone;
                inputBox.delegate = self;
                [inputBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                [inputBox addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                [cell addSubview:inputBox];
                
                if (self.essentialMarkFlag) {
                    UILabel *emLabel = [[UILabel alloc] init];
                    emLabel.frame = CGRectMake(cell.frame.size.width - 20, 12, 10, 30);
                    emLabel.text = @"*";
                    emLabel.font = [UIFont systemFontOfSize:30];
                    emLabel.textColor = [UIColor redColor];
                    [cell addSubview:emLabel];
                }
            }
                break;
            case 1:
            {
                UIImageView *icon = [[UIImageView alloc] init];
                [icon setFrame:CGRectMake((cell.frame.size.height - 20)/2, (cell.frame.size.height - 20)/2, 20, 20)];
                [icon setImage:[UIImage imageNamed:@"reminderNoteIcon"]];
                [cell addSubview:icon];
                
                UITextField *inputBox = [[UITextField alloc] init];
                [inputBox setFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width +10, 0, cell.frame.size.width - 60, 44)];
                inputBox.placeholder = @"Notes";
                inputBox.delegate = self;
                if (self.reminderRecord.eventNote != nil) {
                    inputBox.text = self.reminderRecord.eventNote;
                }
                inputBox.tag = TEXTFIELD_NOTES;
                inputBox.returnKeyType = UIReturnKeyDone;
                [inputBox addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
                [inputBox addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
                [cell addSubview:inputBox];
            }
                break;
            case 2:
            {
                UIImageView *icon = [[UIImageView alloc] init];
                UISwitch *switcher = [[UISwitch alloc] init];
                UILabel *label = [[UILabel alloc] init];
                [switcher setFrame:CGRectMake(cell.frame.size.width - 60, 6, cell.frame.size.height*3, cell.frame.size.height)];
                [icon setFrame:CGRectMake((cell.frame.size.height - 20)/2, (cell.frame.size.height - 20)/2, 20, 20)];
                [label setFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 10, 0, cell.frame.size.width - 100, 44)];
                
                [icon setImage:[UIImage imageNamed:@"reminderCalendarIcon"]];
                [label setText:@"Remind me on a day"];
                
                [switcher addTarget:self action:@selector(remindMeOnADayTapped:) forControlEvents:UIControlEventTouchUpInside];
                [switcher setTag:SWITCHER_REMIND_ME_ON_A_DAY];
                [switcher setOn:self.reminderRecord.remindOnADay];
                
                [cell addSubview:icon];
                [cell addSubview:label];
                [cell addSubview:switcher];
            }
                break;
            case 3:
            {
                UIImageView *icon = [[UIImageView alloc] init];
                UILabel *label = [[UILabel alloc] init];
                [icon setFrame:CGRectMake((cell.frame.size.height - 20)/2, (cell.frame.size.height - 20)/2, 20, 20)];
                [label setFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 10, 0, cell.frame.size.width - 75, 44)];
                
                [label setTextColor:[UIColor buttonColor]];
                
                [icon setImage:[UIImage imageNamed:@"reminderAlarmIcon"]];
                
                [label setText:[self dateStrFromDate:self.reminderRecord.date]];
                label.tag = DATE_LABEL;
                
                //set time
                UIDatePicker *datePicker = [[UIDatePicker alloc] init];
                datePicker.tag = DATE_PICKER;
                datePicker.date = self.reminderRecord.date ? self.reminderRecord.date : [NSDate date];
                datePicker.datePickerMode = UIDatePickerModeDateAndTime;
                
                datePicker.frame = CGRectMake(icon.frame.origin.x, icon.frame.origin.y+20,
                                              cell.frame.size.width -20, DATE_PICKER_VISIBLE_HEIGHT - icon.frame.origin.y - 20);
                [datePicker addTarget:self action:@selector(datePickerSelected:) forControlEvents:UIControlEventValueChanged];
                
                [cell addSubview:icon];
                [cell addSubview:label];
                [cell addSubview:datePicker];
                
                if (self.datePickerVisibleFlag) {
                    datePicker.hidden = NO;
                }
                else {
                    datePicker.hidden = YES;
                }
            }
                break;
            case 4:
            {
                UIImageView *icon = [[UIImageView alloc] init];
                UISwitch *switcher = [[UISwitch alloc] init];
                UILabel *label = [[UILabel alloc] init];
                [switcher setFrame:CGRectMake(cell.frame.size.width - 60, 6, cell.frame.size.height*3, cell.frame.size.height)];
                [icon setFrame:CGRectMake((cell.frame.size.height - 20)/2, (cell.frame.size.height - 20)/2, 20, 20)];
                [label setFrame:CGRectMake(icon.frame.origin.x + icon.frame.size.width + 10, 0, cell.frame.size.width - 100, 44)];
                
                [icon setImage:[UIImage imageNamed:@"reminderRepeatIcon"]];
                [label setText:@"Repeat"];
                
                [switcher addTarget:self action:@selector(remindMeOnADayTapped:) forControlEvents:UIControlEventTouchUpInside];
                [switcher setTag:SWITCHER_IS_REPEAT];
                [switcher setOn:self.reminderRecord.isRepeat];
                
                [cell addSubview:icon];
                [cell addSubview:label];
                [cell addSubview:switcher];
            }
                break;
            default:
            {
                UILabel *label = [[UILabel alloc] init];
                UISwitch *switcher = [[UISwitch alloc] init];
                
                [label setFrame:CGRectMake((cell.frame.size.height - 20)/2 + 30, 0, 200, 44)];
                [switcher setFrame:CGRectMake(cell.frame.size.width - 60, 6, cell.frame.size.height*3, cell.frame.size.height)];
                
                [label setText:self.weekdayRows[indexPath.row-5]];
                
                [switcher addTarget:self action:@selector(weekdayTapped:) forControlEvents:UIControlEventTouchUpInside];
                [switcher setTag:[self.weekdayRowsTags[indexPath.row-5] unsignedIntegerValue]];
                [switcher setOn:[self.reminderRecord.repeatDays[indexPath.row-5] boolValue]];
                
                [cell addSubview:label];
                [cell addSubview:switcher];
            }
                break;
    }
}

#pragma mark UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:self.mainTable]) {
        return NO;
    }
    return YES;
}

#pragma mark - SlideInCard Delegate

- (void)slideInCardBaseDidChooseLeftButton {
    [self.cardView cancel];
}

- (void)slideInCardBaseDidChooseRightButton {
    if (self.reminderRecord.eventName == nil || [self.reminderRecord.eventName isEqualToString:@""]) {
        self.essentialMarkFlag = YES;
        [self.mainTable reloadData];
        return;
    }
    [self saveReminder];
    [self.cardView done];
}

#pragma mark - UITextField Delegate

- (IBAction)textFieldDoneEditing:(UITextField *)textf{
    if (textf != nil) {
        if (textf.tag == TEXTFIELD_EVENT) {
            self.reminderRecord.eventName = textf.text;
        }
        else if (textf.tag == TEXTFIELD_NOTES) {
            self.reminderRecord.eventNote = textf.text;
        }
        [textf resignFirstResponder];
    }
    else {
        for (int i=0;i<2;i++) {
            UITableViewCell *cell = [self.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            for (id objInput in [cell subviews]) {
                if ([objInput isKindOfClass:[UITextField class]]) {
                    UITextField *tf = objInput;
                    if (tf.tag == TEXTFIELD_EVENT) {
                        self.reminderRecord.eventName = tf.text;
                        if (tf.isEditing) {
                            [tf resignFirstResponder];
                        }
                    }
                    else if (tf.tag == TEXTFIELD_NOTES) {
                        self.reminderRecord.eventNote = tf.text;
                        if (tf.isEditing) {
                            [tf resignFirstResponder];
                        }
                    }
                }
            }
        }
    }
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textf {
    if (textf.tag == TEXTFIELD_EVENT) {
        self.reminderRecord.eventName = textf.text;
    }
    else if (textf.tag == TEXTFIELD_NOTES) {
        self.reminderRecord.eventNote = textf.text;
    }
    return YES;
}

-(void)textFieldDidChange :(UITextField *)textf{
    if (textf.tag == TEXTFIELD_EVENT) {
        self.reminderRecord.eventName = textf.text;
    }
    else if (textf.tag == TEXTFIELD_NOTES) {
        self.reminderRecord.eventNote = textf.text;
    }
}

#pragma mark - UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3 + (self.reminderRecord.remindOnADay ? 2:0) + (self.reminderRecord.isRepeat ? 7:0);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *tableIdentifier = @"tableIdentifier";
    UITableViewCell *cell = nil;
    
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tableIdentifier];
    }
    
    cell.frame = CGRectMake(0, 0, self.mainTable.frame.size.width, 40);
    
    [self drawCellsWithCell:cell withIndexPath:indexPath];
    
    if (indexPath.row != 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    [cell setAlpha:0.8];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        if (self.datePickerVisibleFlag) {
            return DATE_PICKER_VISIBLE_HEIGHT;
        }
        else {
            return 44;
        }
    }
    else {
        return 44;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != 0 || indexPath.row != 1) {
        [self textFieldDoneEditing:nil];
    }
    if (indexPath.row == 3) {
        if (self.datePickerVisibleFlag) {
            self.datePickerVisibleFlag = NO;
            [self.mainTable reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else {
            self.datePickerVisibleFlag = YES;
            [self.mainTable reloadRowsAtIndexPaths:[[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - Event Handlers

-(void) keyboardWillShow:(NSNotification *) note {
    if (!self.viewMoved) {
        [UIView animateWithDuration:0.5 animations:^(){
            self.cardView.frame = CGRectMake(self.cardView.frame.origin.x, self.cardView.frame.origin.y-80, self.cardView.frame.size.width, self.cardView.frame.size.height);
        }];
        self.viewMoved = YES;
    }
    
}

-(void) keyboardWillHide:(NSNotification *) note {
    if (self.viewMoved) {
        [UIView animateWithDuration:0.5 animations:^(){
            self.cardView.frame = CGRectMake(self.cardView.frame.origin.x, self.cardView.frame.origin.y+80, self.cardView.frame.size.width, self.cardView.frame.size.height);
        }];
        self.viewMoved = NO;
    }
}

- (void)tapToHideKeyboard {
    [self textFieldDoneEditing:nil];
}

- (void)remindMeOnADayTapped:(UISwitch *)switcher {
    if (switcher.tag == SWITCHER_REMIND_ME_ON_A_DAY) {
        if (!self.reminderRecord.remindOnADay && switcher.isOn) {
            self.reminderRecord.remindOnADay = switcher.isOn;
            [self.mainTable insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:
                                                    [NSIndexPath indexPathForRow:3 inSection:0],
                                                    [NSIndexPath indexPathForRow:4 inSection:0], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (self.reminderRecord.remindOnADay && !switcher.isOn) {
            if (self.reminderRecord.isRepeat) {
                self.reminderRecord.isRepeat = NO;
                [self.mainTable deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:
                                                        [NSIndexPath indexPathForRow:5 inSection:0],
                                                        [NSIndexPath indexPathForRow:6 inSection:0],
                                                        [NSIndexPath indexPathForRow:7 inSection:0],
                                                        [NSIndexPath indexPathForRow:8 inSection:0],
                                                        [NSIndexPath indexPathForRow:9 inSection:0],
                                                        [NSIndexPath indexPathForRow:10 inSection:0],
                                                        [NSIndexPath indexPathForRow:11 inSection:0], nil]
                                      withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            self.reminderRecord.remindOnADay = switcher.isOn;
            [self.mainTable deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:
                                                   [NSIndexPath indexPathForRow:3 inSection:0],
                                                   [NSIndexPath indexPathForRow:4 inSection:0], nil]
             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
    else if (switcher.tag == SWITCHER_IS_REPEAT) {
        if (!self.reminderRecord.isRepeat && switcher.isOn) {
            self.reminderRecord.isRepeat = switcher.isOn;
            [self.mainTable insertRowsAtIndexPaths:[[NSArray alloc] initWithObjects:
                                                    [NSIndexPath indexPathForRow:5 inSection:0],
                                                    [NSIndexPath indexPathForRow:6 inSection:0],
                                                    [NSIndexPath indexPathForRow:7 inSection:0],
                                                    [NSIndexPath indexPathForRow:8 inSection:0],
                                                    [NSIndexPath indexPathForRow:9 inSection:0],
                                                    [NSIndexPath indexPathForRow:10 inSection:0],
                                                    [NSIndexPath indexPathForRow:11 inSection:0], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if (self.reminderRecord.isRepeat && !switcher.isOn) {
            self.reminderRecord.isRepeat = switcher.isOn;
            [self.mainTable deleteRowsAtIndexPaths:[[NSArray alloc] initWithObjects:
                                                    [NSIndexPath indexPathForRow:5 inSection:0],
                                                    [NSIndexPath indexPathForRow:6 inSection:0],
                                                    [NSIndexPath indexPathForRow:7 inSection:0],
                                                    [NSIndexPath indexPathForRow:8 inSection:0],
                                                    [NSIndexPath indexPathForRow:9 inSection:0],
                                                    [NSIndexPath indexPathForRow:10 inSection:0],
                                                    [NSIndexPath indexPathForRow:11 inSection:0], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)weekdayTapped:(UISwitch *)switcher {
    switch (switcher.tag) {
        case SWITCHER_MONDAY:
            self.reminderRecord.repeatDays[0] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_TUESDAY:
            self.reminderRecord.repeatDays[1] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_WEDNESDAY:
            self.reminderRecord.repeatDays[2] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_THURSDAY:
            self.reminderRecord.repeatDays[3] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_FRIDAY:
            self.reminderRecord.repeatDays[4] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_SATURDAY:
            self.reminderRecord.repeatDays[5] = [NSNumber numberWithBool:switcher.isOn];
            break;
        case SWITCHER_SUNDAY:
            self.reminderRecord.repeatDays[6] = [NSNumber numberWithBool:switcher.isOn];
            break;
        default:
            break;
    }
}


@end
