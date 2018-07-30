//
//  ExerciseHistoryDayViewController
//  GlucoGuide
//
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "ExerciseHistoryDayViewController.h"
#import "Constants.h"
#import "ExerciseRecord.h"
#import "UIColor+Extensions.h"
#import "GGUtils.h"
#import "UIView+Extensions.h"
#import "StyleManager.h"
#import "PedometerClass.h"
#import "ExerciseHistoryTableViewController.h"

@interface ExerciseHistoryDayViewController ()

@property (nonatomic) NSArray *arraySteps;
@property (nonatomic) NSArray *arrayStartDate;
@property (nonatomic) NSArray *arrayEndDate;
@property (nonatomic) NSMutableArray *allData;
@property (nonatomic) NSString *passingStartDate;

@end

@implementation ExerciseHistoryDayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
        [self getStepData];
    }else{
        [self getDailyExerciseInfoNoPedometer];
    }
}

#pragma mark - Methods
-(void)getDailyExerciseInfoNoPedometer{
    
    NSArray *datesArray = [[NSArray alloc]initWithArray:[[PedometerClass getInstance] getAllManuallyAddedDates]]; //No Steps
    
    self.arrayStartDate = [datesArray objectAtIndex:0];
    self.arrayEndDate = [datesArray  objectAtIndex:1];
    
    datesArray = nil;
    
    self.allData = [[NSMutableArray alloc]initWithCapacity:[self.arrayStartDate count]];
    
    for (int i = 0; i < [self.arrayStartDate count]; i++) {
        
        [self.allData addObject:[[PedometerClass getInstance]getAutomaticLightModerateVigorousWithStartDate:[[self.arrayStartDate objectAtIndex:i] intValue] andEndDate:[[self.arrayEndDate objectAtIndex:i] intValue]]];
    }
}


-(void)getStepData{
    
    NSDictionary *tempDict = [[NSDictionary alloc]initWithDictionary:[[PedometerClass getInstance]getStepsFromDatabaseDaysWorth]];
    
    self.arraySteps = [tempDict objectForKey:@"steps"];
    self.arrayStartDate = [tempDict objectForKey:@"startDate"];
    self.arrayEndDate = [tempDict objectForKey:@"endDate"];
    
   NSLog(@"StartDate Epoch: %@", self.arrayStartDate);
   NSLog(@"EndDate Epoch: %@", self.arrayEndDate);
    
    [self getDailyExerciseInfo];
    
}

-(void)getDailyExerciseInfo{
    
    self.allData = [[NSMutableArray alloc]initWithCapacity:[self.arrayStartDate count]];
    
    for (int i = 0; i < [self.arrayStartDate count]; i++) {
        
      [self.allData addObject:[[PedometerClass getInstance]getAutomaticLightModerateVigorousWithStartDate:[[self.arrayStartDate objectAtIndex:i] intValue] andEndDate:[[self.arrayEndDate objectAtIndex:i] intValue]]];
    }
}

#pragma mark - Alert
-(void)showNoInfoAlert{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:EXERCISE_DAILY_NO_INFO_TITLE]
                                          message:[LocalizationManager getStringFromStrId:EXERCISE_DAILY_NO_INFO_CONTENT]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertCalories{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:EXERCISE_CALORIE_CONTENT_TITLE]
                                          message:[LocalizationManager getStringFromStrId:EXERCISE_CALORIE_TITLE]
                                          
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                               }];
    
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrayStartDate count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

     if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
          UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifier" forIndexPath:indexPath];
         
         UIImageView *imgInfo = (UIImageView *)[cell viewWithTag:500];
         UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertCalories)];
         tapped.numberOfTapsRequired = 1;
         [imgInfo addGestureRecognizer:tapped];
         
         /////Automatic
         UILabel *lblSteps = (UILabel *)[cell viewWithTag:100];
         lblSteps.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ steps"], [self.arraySteps objectAtIndex:indexPath.section]];
         
         UILabel *lblLight = (UILabel *)[cell viewWithTag:101];
         lblLight.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:0]];
         
         UILabel *lblMod = (UILabel *)[cell viewWithTag:102];
         lblMod.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:1]];
         
         UILabel *lblVig = (UILabel *)[cell viewWithTag:103];
         lblVig.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:2]];
         
         ////Manual
         UILabel *lblLightMan = (UILabel *)[cell viewWithTag:104];
         lblLightMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:3]];
         
         UILabel *lblModanMan = (UILabel *)[cell viewWithTag:105];
         lblModanMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:4]];
         
         UILabel *lblVigMan = (UILabel *)[cell viewWithTag:106];
         lblVigMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:5]];
         
         UILabel *lblCalories = (UILabel *)[cell viewWithTag:107];
         lblCalories.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ cals"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:6]];
         
         [cell setBackgroundColor:[UIColor clearColor]];
         
         return cell;
         
     }else{
          UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellIdentifierNoPed" forIndexPath:indexPath];
         
         UIImageView *imgInfo = (UIImageView *)[cell viewWithTag:500];
         UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alertCalories)];
         tapped.numberOfTapsRequired = 1;
         [imgInfo addGestureRecognizer:tapped];
         
         ////Manual
         UILabel *lblLightMan = (UILabel *)[cell viewWithTag:104];
         lblLightMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:3]];
         
         UILabel *lblModanMan = (UILabel *)[cell viewWithTag:105];
         lblModanMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:4]];
         
         UILabel *lblVigMan = (UILabel *)[cell viewWithTag:106];
         lblVigMan.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:5]];
         
         UILabel *lblCalories = (UILabel *)[cell viewWithTag:107];
         lblCalories.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ cals"], [[self.allData objectAtIndex:indexPath.section] objectAtIndex:6]];
         
         [cell setBackgroundColor:[UIColor clearColor]];
         
         
         return cell;

     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForCell;
    
    if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
        heightForCell = 369;
    }else{
        heightForCell = 188;
    }
    
    return heightForCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //////
    NSDate *displayDate = [NSDate dateWithTimeIntervalSince1970:[[self.arrayStartDate objectAtIndex:section] intValue]];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM dd, yyyy"];

    /////
    NSString *headerText = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:displayDate]];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label setText:[headerText uppercaseString]];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    [view.contentView addSubview:label];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDate *displayDate = [NSDate dateWithTimeIntervalSince1970:[[self.arrayStartDate objectAtIndex:indexPath.section] intValue]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"EEE MMM dd, yyyy"];
    NSString *headerText = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:displayDate]];
    
    self.passingStartDate = headerText;

    if ([[[self.allData objectAtIndex:indexPath.section] objectAtIndex:6] intValue] == 0) {
        [self showNoInfoAlert];
    }else{        
        [self performSegueWithIdentifier:@"segueToRecentExerciseDetails" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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

#pragma Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"segueToRecentExerciseDetails"])
    {
        ExerciseHistoryTableViewController *vc = segue.destinationViewController;
        vc.passedStartDate = self.passingStartDate;
    }
    
}



@end
