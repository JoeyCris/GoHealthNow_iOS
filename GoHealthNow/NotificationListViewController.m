//
//  ViewController.h
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "NotificationListViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "User.h"
#import "SWRevealViewController.h"
#import "DosageInputViewController.h"
#import "ChooseRemindersViewController.h"
#import "NotificationMedicationClass.h"
#import "NotificationBloodGlucoseClass.h"
#import "NotificationDietClass.h"
#import "NotificationExerciseClass.h"
#import "NotificationBloodPressureClass.h"
#import "MedicationRecord.h"
#import "LocalNotificationAssistant.h"
#import "HelpTipController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface NotificationListViewController ()

@property (nonatomic) NSMutableArray *arrayDietNotification;
@property (nonatomic) NSMutableArray *arrayBloodGlucoseNotification;
@property (nonatomic) NSMutableArray *arrayMedicationNotification;
@property (nonatomic) NSMutableArray *arrayExerciseNotification;
@property (nonatomic) NSMutableArray *arrayBloodPressureNotification;

@property (nonatomic) NSMutableArray *arrayMergeNotifications;

@property (nonatomic) NSArray *insulins;
@property (nonatomic) NSArray *medications;
@property (strong, nonatomic) IBOutlet UINavigationItem *navItem;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnRevealMenu;

@end

@implementation NotificationListViewController
@synthesize isSetup;


#pragma mark - View Lifecyle

-(void)viewWillAppear:(BOOL)animated{
    if (isSetup) {
        UIBarButtonItem *btnDone = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(btnDone)];
        self.navigationItem.leftBarButtonItem = btnDone;

    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self  getNotifMergeArray];
    
    User *user = [User sharedModel];
    NSString *VCName = NSStringFromClass([self class]);
    
    if (![user.helpTipsShownTracker[VCName] boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showHelpTips:self];
        });
        [user.helpTipsShownTracker setObject:@YES forKey:VCName];
    }
}

- (void)viewDidLoad {
    [self setupToolBar];
    [self.view endEditing:YES];
    [StyleManager styleTable:self.tableView];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];

    
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    self.tableView.allowsMultipleSelection = NO;
    
    [self  getNotifMergeArray];
    
    if ([self.arrayMergeNotifications count] == 0) {
        [[LocalNotificationAssistant getInstance] cancelAllNotifications];
        [[LocalNotificationAssistant getInstance] logNotificationCount];
        [self performSegueWithIdentifier:@"segueToReminderType" sender:self];
    }
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


#pragma mark - Table view DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrayMergeNotifications count];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *resuseCell = @"resuseCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:resuseCell];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:resuseCell];
    }
    
    
    //Name
    if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"drugName"]){
        UILabel *lblName = (UILabel *)[cell viewWithTag:100];
        lblName.text = [[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"drugName"];
    }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row] valueForKey:@"mealType"]){
        UILabel *lblName = (UILabel *)[cell viewWithTag:100];
        lblName.text = [[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"mealType"];
    
    }else if ([[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"BloodPressure"]){
        UILabel *lblName = (UILabel *)[cell viewWithTag:100];
        lblName.text = [LocalizationManager getStringFromStrId:@"Blood Pressure Reminder"];
    
    }else{
        UILabel *lblName = (UILabel *)[cell viewWithTag:100];
        lblName.text = [LocalizationManager getStringFromStrId:@"Exercise Reminder"];
    }
    
    //Details
    if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"drugDose"]){
        UILabel *lblDosage = (UILabel *)[cell viewWithTag:200];
        lblDosage.text = [[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"drugDose"];
    
    }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"BloodGlucose"]){
        UILabel *lblDetails = (UILabel *)[cell viewWithTag:200];
        lblDetails.text = [LocalizationManager getStringFromStrId:@"Blood Glucose Testing"];
    
    }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"Exercise"]){
        UILabel *lblDetails = (UILabel *)[cell viewWithTag:200];
        lblDetails.text = [LocalizationManager getStringFromStrId:@"Exercise"];
        
    }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"BloodPressure"]){
        UILabel *lblDetails = (UILabel *)[cell viewWithTag:200];
        lblDetails.text = [LocalizationManager getStringFromStrId:@"Blood Pressure"];
    }else{
        UILabel *lblDetails = (UILabel *)[cell viewWithTag:200];
        lblDetails.text = [LocalizationManager getStringFromStrId:@"Meal Reminder"];
    }
    
    UILabel *lblTime = (UILabel *)[cell viewWithTag:300];
    lblTime.text = [[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"notificationTime"];
    
    UILabel *lblRepeat = (UILabel *)[cell viewWithTag:400];
    lblRepeat.text = [LocalizationManager getStringFromStrId:@"Daily"];
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"Medication"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        
        //Used for spacing / alignment
       cell.accessoryType = UITableViewCellAccessoryCheckmark;
       cell.tintColor = [UIColor whiteColor];
    }
    
    return cell;
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"drugName"]){
        
        [self setInformationForSelectedMedication:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"drugName"] indexPath:indexPath];
        
        [NotificationMedicationClass getInstance].stringComingFromWhere = @"editNotification";
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        DosageInputViewController *viewController = [storyboard  instantiateViewControllerWithIdentifier:@"DosageInputViewController"];
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        //Medication
        if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"drugName"]){
            
            NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
            [reminder deleteNotificationFromDatabase:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
            [self.arrayMergeNotifications removeObjectAtIndex:indexPath.row];
        
        //BG
        }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"BloodGlucose"]){
            
            NotificationBloodGlucoseClass *reminder = [NotificationBloodGlucoseClass getInstance];
            [reminder deleteNotificationFromDatabase:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
            [self.arrayMergeNotifications removeObjectAtIndex:indexPath.row];
            
        //Exercise
        }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"Exercise"]){
            
             NotificationExerciseClass *reminder = [NotificationExerciseClass getInstance];
            [reminder deleteNotificationFromDatabase:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
            [self.arrayMergeNotifications removeObjectAtIndex:indexPath.row];
            
        //Blood Pressure
        }else if ([[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] && [[[self.arrayMergeNotifications objectAtIndex:indexPath.row]objectForKey:@"NotfiType"] isEqualToString:@"BloodPressure"]){
            
            NotificationBloodPressureClass *reminder = [NotificationBloodPressureClass getInstance];
            [reminder deleteNotificationFromDatabase:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
            [self.arrayMergeNotifications removeObjectAtIndex:indexPath.row];
            
        //Meal
        }else{
            NotificationDietClass *reminder = [NotificationDietClass getInstance];
            [reminder deleteNotificationFromDatabase:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
            [self.arrayMergeNotifications removeObjectAtIndex:indexPath.row];
        }
        
        [tableView reloadData];
    }
}

#pragma mark - IBAction
- (IBAction)btnAddReminder:(id)sender {
    [self performSegueWithIdentifier:@"segueToReminderType" sender:self];
}

- (IBAction)btnsettings:(id)sender {
    [self.revealViewController revealToggle:self];
}

-(void)btnDone{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToReminderList:(UIStoryboardSegue *)unwindSegue
{
}


#pragma mark - Custom

- (void)setupToolBar {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 67.5, self.navigationController.navigationBar.frame.size.height + 1.0)];
    toolbar.clipsToBounds = YES;
    [toolbar setBackgroundImage:[[UIImage alloc] init]
             forToolbarPosition:UIToolbarPositionAny
                     barMetrics:UIBarMetricsDefault];
    [toolbar setShadowImage:[UIImage new]
         forToolbarPosition:UIToolbarPositionAny];
    
    // create an array for the buttons
    NSMutableArray *buttons = [[NSMutableArray alloc] initWithCapacity:4];
    
    // http://stackoverflow.com/questions/6021138/how-to-adjust-uitoolbar-left-and-right-padding
    UIBarButtonItem *negativeSeparator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                                       target:self
                                                                                       action:@selector(btnsettings:)];
    negativeSeparator.width = IS_IPAD ? -20.0 : -16.0;
    
    [buttons addObject:negativeSeparator];
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settingsIcon"]
                                                                       style:UIBarButtonItemStylePlain
                                                                      target:self
                                                                      action:@selector(btnsettings:)];
    //cancelButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:settingsButton];
    
    // create a help tip button
    UIButton *helpTipButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    [helpTipButton addTarget:self
                      action:@selector(showHelpTips:)
            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    UIBarButtonItem *helpTipBarButton = [[UIBarButtonItem alloc] initWithCustomView:helpTipButton];
    //helpTipBarButton.style = UIBarButtonItemStyleBordered;
    [buttons addObject:helpTipBarButton];
    
    // put the buttons in the toolbar and release them
    [toolbar setItems:buttons animated:NO];
    
    // place the toolbar into the navigation bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
}

- (void)showHelpTips:(id)sender {
    CGPoint checkmarkButtonArrowHeadPoint = CGPointMake(self.view.frame.size.width - 25.0, 60.0);
    CGPoint helpTipTitlePos = CGPointMake(25.0, 70.0);
    
    if (IS_IPHONE_6P) {
        checkmarkButtonArrowHeadPoint.x -= 10.0;
    }
    else if (IS_IPAD) {
        checkmarkButtonArrowHeadPoint.x -= 15.0;
        helpTipTitlePos.x = self.view.frame.size.width / 2.5;
    }

    HelpTipController *helpTipController = [[HelpTipController alloc] init];
    [helpTipController addTipWithTitle:[LocalizationManager getStringFromStrId:@"Set up daily reminders here. If you usually take your morning medication from 7 to 8 am, set it up for 7 am.\n\nWhen the 7 am notification comes, you can click Snooze (reminds you again in 15 min), if you wish.\n\n Try to space your notifications 2 to 3 minutes apart to give you time to address each notification.\n\nYou can delete a notification by swiping the notification to the right and tapping the delete button.\n\nYou can modify medication reminders by tapping on them.  To modify any other reminder please delete and create a new one."]
                               atPoint:helpTipTitlePos
                     arrowTailPosition:HelpTipArrowTailPositionRightMiddle
                            arrowCurve:HelpTipArrowCurveRight
                      arrowCurveRadius:35.0
                  withArrowHeadAtPoint:checkmarkButtonArrowHeadPoint];
    
    [self presentViewController:helpTipController animated:YES completion:nil];
}

-(void)setInformationForSelectedMedication:(NSString *)MedicationName indexPath:(NSIndexPath *)indexPath{
    
    self.medications = [MedicationRecord getAllMedications];
    
    long locationInMedicationArray = -1;
    
    for (NSDictionary* dict in self.medications){
        if ([[dict objectForKey:@"_Name"] isEqualToString:MedicationName]) {
            locationInMedicationArray = [self.medications indexOfObject:dict];
        }
    }
    
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    
    if (locationInMedicationArray > -1) {
        [reminder addReminderDrug:[self.medications objectAtIndex:locationInMedicationArray]];
    }
    
    [reminder addReminderDosage:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"drugDose"]];
    [reminder addReminderTime:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"notificationTime"]];
    [reminder addNotificationIndex:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
    [reminder addReminderUuid:[[self.arrayMergeNotifications objectAtIndex:indexPath.row]valueForKey:@"uuid"]];
}

-(void)getNotifMergeArray{
    
    self.arrayMedicationNotification = [NSMutableArray arrayWithArray:[[NotificationMedicationClass getInstance] getAllNotificationsFromDatabase]];
    self.arrayBloodGlucoseNotification = [NSMutableArray arrayWithArray:[[NotificationBloodGlucoseClass getInstance] getAllBloodGlucoseNotificationsFromDatabase]];
    self.arrayDietNotification = [NSMutableArray arrayWithArray:[[NotificationDietClass getInstance] getAllDietNotificationsFromDatabase]];
    self.arrayExerciseNotification = [NSMutableArray arrayWithArray:[[NotificationExerciseClass getInstance] getAllExerciseNotificationsFromDatabase]];
    self.arrayBloodPressureNotification = [NSMutableArray arrayWithArray:[[NotificationBloodPressureClass getInstance] getAllBloodPressureNotificationsFromDatabase]];
    
    self.arrayMergeNotifications = [[NSMutableArray alloc]init];
    [self.arrayMergeNotifications addObjectsFromArray:self.arrayMedicationNotification];
    [self.arrayMergeNotifications addObjectsFromArray:self.arrayBloodGlucoseNotification];
    [self.arrayMergeNotifications addObjectsFromArray:self.arrayDietNotification];
    [self.arrayMergeNotifications addObjectsFromArray:self.arrayExerciseNotification];
    [self.arrayMergeNotifications addObjectsFromArray:self.arrayBloodPressureNotification];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: @"sortByTime" ascending:YES];
    NSArray *sortedArray = [[NSArray alloc]initWithArray:[self.arrayMergeNotifications sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    
    self.arrayMergeNotifications = [[NSMutableArray alloc] initWithArray:sortedArray];
    [self.tableView reloadData];
    
    if ([self.arrayMergeNotifications count] == 0) {
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0") ) {
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center removeAllPendingNotificationRequests];
            [center removeAllDeliveredNotifications];
            
        }else{
            [[LocalNotificationAssistant getInstance] cancelAllNotifications];
        }
        
        
    }
    
    [[LocalNotificationAssistant getInstance] logNotificationCount];
}

#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
}


@end
