//
//  ExerciseSummaryViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-02-04.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ExerciseSummaryViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "ExerciseRecord.h"
#import "GGUtils.h"
#import "GGProgressView.h"
#import "NotificationExerciseClass.h"
#import <CoreMotion/CoreMotion.h>
#import "PedometerClass.h"
#import "GoalsDelegate.h"
#import "ExerciseGoal.h"
#import "UIView+Extensions.h"
#import "GoalsViewController.h"
#import "User.h"
#import "FMDatabaseAdditions.h"
#import "FMDatabase.h"
#import "StyleManager.h"

@interface ExerciseSummaryViewController () <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewSummary;
@property (weak, nonatomic) UITableViewCell *cell;
@property int tempStepsDay, tempStepsWeekly;
@property NSArray *arrayTodaysMins;

@property NSTimer *timerLMVMins;


@end

@implementation ExerciseSummaryViewController
@synthesize cell, tempStepsDay, tempStepsWeekly, pedometer0, pedometer1;

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableViewSummary.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
       
    [self updateExerciseRecordTableOnce];
    
    if ([self isModal]){
        [StyleManager styleNavigationBar:self.navigationController.navigationBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapCancelButton)];
        self.navigationItem.leftBarButtonItem = btnBack;
    }
    
    self.arrayTodaysMins = [[NSArray alloc]initWithArray:[[PedometerClass getInstance] getTodayMintues]];
    
     if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
        [self getDailySteps];
     }
}

-(void)viewWillDisappear:(BOOL)animated{
   // [pedometer0 stopPedometerUpdates];
   // [pedometer1 stopPedometerUpdates];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    if ([self.timerLMVMins isValid]){
        [self.timerLMVMins invalidate];
        self.timerLMVMins = nil;
    }

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pedometer-Done" object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self startTimers];
    
    [self.tableViewSummary reloadData];
    
    if ([NotificationExerciseClass getInstance].stringGoingToExerciseType) {
        [NotificationExerciseClass getInstance].stringGoingToExerciseType = nil;
        [self performSegueWithIdentifier:@"chooseExerciseSegue2" sender:self];
    }
}

- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[self presentingViewController] presentedViewController] == self)
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    if (section == 0) {
        return 5;
    }else if (section == 1) {
        return 4;
    }else{
        return 2;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSArray *dataArray = [[NSArray alloc]initWithObjects:TIME_TODAY, TIME_THIS_WEEK, @"",  nil];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [dataArray objectAtIndex:section];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label setText:headerText];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.section == 0) {
        
        switch (indexPath.row) {
            case 0:{
                static NSString *CellIdentifier = @"Cell0";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                UILabel *lblTodaySteps = (UILabel *)[cell viewWithTag:100];
                lblTodaySteps.text = [NSString stringWithFormat:@"%d", tempStepsDay];
                cell.userInteractionEnabled = YES;
                break;
            }
            case 1:{
                static NSString *CellIdentifier = @"Cell1";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                UILabel *lblTodayRemaining = (UILabel *)[cell viewWithTag:2];
                UILabel *lblTodayGoal = (UILabel *)[cell viewWithTag:3];
                UIProgressView *progView = (UIProgressView *)[cell viewWithTag:4];
                GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
                ExerciseGoal *goal = goalDelegate.goals[GoalTypeExerciseDailyStepsCount];
                if (![goal isEqual:[NSNull null]]) {
                    double goalTarget = [goal.target doubleValue];
                    double current = goalTarget-tempStepsDay;
                    if (current > 0) {
                        int avgSteps = [[PedometerClass getInstance] getAvgStepsPerMin];
                        if (avgSteps==0) {
                            avgSteps = 100;
                        }
                        int remainingTime = current / avgSteps;
                        [lblTodayRemaining setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Remaining: %.0f (~ %d mins)"], current, remainingTime]];
                    }
                    else {
                        [lblTodayRemaining setText:[NSString stringWithFormat:@"%@", [LocalizationManager getStringFromStrId:@"Goal achieved!"]]];
                        [goalDelegate updateExerciseGoalAfterFinishWithType:GoalTypeExerciseDailyStepsCount andCurrStep:tempStepsDay].then(^(id res) {
                            if ([res isEqual:@1]) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:MSG_CONGRATS message:EXERCISE_GOAL_DAILY_STEP_COUNT_HAS_BEEN_FINISHED delegate:nil cancelButtonTitle:MSG_OK otherButtonTitles:nil];
                                [alert show];
                                [self.tableViewSummary reloadData];
                            }
                        });
                    }
                    
                    [lblTodayGoal setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Goal %.0f"], goalTarget]];
                    [progView setProgress:(tempStepsDay>=goalTarget) ?goalTarget:tempStepsDay/goalTarget animated:NO];
                }
                else {
                    [lblTodayRemaining setText:[NSString stringWithFormat:@"%@", [LocalizationManager getStringFromStrId:@"No daily step goal."]]];
                    [lblTodayGoal setText:[NSString stringWithFormat:@"%@", [LocalizationManager getStringFromStrId:@"Goal 0"]]];
                    [progView setProgress:1.0 animated:(progView.progress != 1.0)?NO:NO];
                }
                cell.userInteractionEnabled = false;
                break;
            }
            case 2:{
                static NSString *CellIdentifier = @"Cell2";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                UILabel *lblTodayLightSteps = (UILabel *)[cell viewWithTag:102];
                lblTodayLightSteps.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [self.arrayTodaysMins objectAtIndex:0]];
                break;
            }
            case 3:{
                static NSString *CellIdentifier = @"Cell3";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                UILabel *lblTodayModSteps = (UILabel *)[cell viewWithTag:103];
                lblTodayModSteps.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [self.arrayTodaysMins objectAtIndex:1]];
                break;
            }
            case 4:{
                static NSString *CellIdentifier = @"Cell4";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                UILabel *lblTodayVigSteps = (UILabel *)[cell viewWithTag:104];
                lblTodayVigSteps.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ mins"], [self.arrayTodaysMins objectAtIndex:2]];
                break;
            }
        }
    }else if (indexPath.section == 1){
        
        switch (indexPath.row) {
            case 0:{
                static NSString *CellIdentifier = @"Cell5";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                
                UILabel *lblWeeklySteps = (UILabel *)[cell viewWithTag:105];
                lblWeeklySteps.text = [NSString stringWithFormat:@"%d", tempStepsWeekly];
                break;
            }
            case 1:{
                static NSString *CellIdentifier = @"Cell6";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                UILabel *lblWeekGoal = (UILabel *)[cell viewWithTag:2];
                UIProgressView *progView = (UIProgressView *)[cell viewWithTag:3];
                GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
                ExerciseGoal *goal = goalDelegate.goals[GoalTypeExerciseWeeklyStepsCount];
                if (![goal isEqual:[NSNull null]]) {
                    double goalTarget = [goal.target doubleValue];
                    [lblWeekGoal setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Goal %.0f"], goalTarget]];
                    if (tempStepsWeekly>=goalTarget) {
                        [goalDelegate updateExerciseGoalAfterFinishWithType:GoalTypeExerciseWeeklyStepsCount andCurrStep:tempStepsWeekly].then(^(id res) {
                            if ([res isEqual:@1]) {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_CONGRATS] message:[LocalizationManager getStringFromStrId:EXERCISE_GOAL_WEEKLY_STEP_COUNT_HAS_BEEN_FINISHED] delegate:nil cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
                                [alert show];
                                [self.tableViewSummary reloadData];
                            }
                        });
                    }
                    
                    [progView setProgress:(tempStepsWeekly>=goalTarget)? goalTarget:tempStepsWeekly/goalTarget animated:NO];
                }
                else {
                    [lblWeekGoal setText:[NSString stringWithFormat:@"%@", [LocalizationManager getStringFromStrId:@"Goal 0"]]];
                    [progView setProgress:1.0 animated:(progView.progress != 1.0)? NO:NO];
                }
                cell.userInteractionEnabled = false;
                break;
            }
            case 2:{
                static NSString *CellIdentifier = @"Cell7";
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                cell.userInteractionEnabled = false;
                
                UILabel *lblmodVig = (UILabel *)[cell viewWithTag:107];
                
                NSDictionary *tempDic0 = [[NSDictionary alloc]initWithDictionary:[ExerciseRecord totalMinsWeek]];
                
                int mod = [[tempDic0 objectForKey:@"1"] intValue];
                int vig = [[tempDic0 objectForKey:@"2"] intValue];
                
                lblmodVig.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%d mins"], mod + vig];
                
                break;
            }
            case 3:{
                static NSString *CellIdentifier = @"Cell8"; //mod+vig goal
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
                UILabel *lblWeekGoal = (UILabel *)[cell viewWithTag:2];
                UIProgressView *progView = (UIProgressView *)[cell viewWithTag:3];
                GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
                ExerciseGoal *goal = goalDelegate.goals[GoalTypeExerciseModerateVigorous];
                
                NSDictionary *tempDic1 = [[NSDictionary alloc]initWithDictionary:[ExerciseRecord totalMinsWeek]];
                
                int mod = [[tempDic1 objectForKey:@"1"] intValue];
                int vig = [[tempDic1 objectForKey:@"2"] intValue];
               
                if (![goal isEqual:[NSNull null]]) {
                    double goalTarget = [goal.target doubleValue];
                    [lblWeekGoal setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Goal %.0f"], goalTarget]];
                    if (goalTarget == 0) {
                        [progView setProgress:1.0 animated:(progView.progress != 1.0)?NO:NO];
                    }
                    else {
                        [progView setProgress:(mod+vig>=goalTarget)? goalTarget:(mod+vig)/goalTarget animated:NO];
                        if (mod+vig>=goalTarget) {
                            
                        }
                    }
                }
                else {
                    [lblWeekGoal setText:[NSString stringWithFormat:@"%@", [LocalizationManager getStringFromStrId:@"Goal 0"]]];
                    [progView setProgress:1.0 animated:(progView.progress != 1.0)?NO:NO];
                }
                cell.userInteractionEnabled = false;
                break;
            }
        }
    }else if (indexPath.section == 2){
        
        if (indexPath.row == 0) {
            static NSString *CellIdentifier = @"Cell9";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
            
        }else if (indexPath.row == 1){
            static NSString *CellIdentifier = @"Cell10";
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
            
        }
        
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        if (indexPath.row == 1 && indexPath.section == 2) {
            [self performSegueWithIdentifier:@"chooseExerciseSegue" sender:self];
        }else if (indexPath.row == 0 && indexPath.section == 0){
            [self showStepAlert];
        }else if (indexPath.row == 0 && indexPath.section == 2) {
            [self performSegueWithIdentifier:@"segueToGoals" sender:self];
        }else{
    
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }

}
    
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([self.cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([self.cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self.cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([self.cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float heightForCell = 0;
    //
    if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO ){
    
        if (indexPath.section == 0){
            
            if (indexPath.row == 1) {
                heightForCell = 68;
            }else{
                heightForCell = 44;
            }

        }
        
        if (indexPath.section == 1 || indexPath.section == 2) {
            heightForCell = 44;
        }

    }else{
        
        if (indexPath.section != 2) {
            if (indexPath.row == 0 || indexPath.row == 1) {
                heightForCell = 0;
            }else{
                heightForCell = 44;
            }
        }else{
            heightForCell = 44;
        }
    }
    //
    
    
    return heightForCell;
}


#pragma mark - Methods Timer
-(void)startTimers{
    
    if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){

        if (!self.timerLMVMins) {
            self.timerLMVMins = [NSTimer scheduledTimerWithTimeInterval:65 target:self selector:@selector(getUpdatedLMVMins) userInfo:nil repeats: YES];
        }
    }
}

#pragma mark - Methods
+ (NSUInteger)calculateLightWeeklyTargetWithCurrentWeekTotalMinutes:(double)weekTotalMinutes {
    if(weekTotalMinutes < 100)
        return 100;
    else if (weekTotalMinutes < 200)
        return 200;
    else
        return EXERCISE_SUMMARY_MAX_WEEKLY_LIGHT_TARGET_MINS;
}

+ (NSUInteger)calculateModVigWeeklyTargetWithCurrentWeekTotalMinutes:(double)weekTotalMinutes {
    if(weekTotalMinutes < 30)
        return 30;
    else if (weekTotalMinutes < 60)
        return 60;
    else if (weekTotalMinutes < 90)
        return 90;
    else
        return EXERCISE_SUMMARY_MAX_WEEKLY_MOD_VIG_TARGET_MINS;
}

- (NSDate *)dateAtBeginningOfDayForDate
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* dateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    NSDate *dayBegin = [gregorian dateFromComponents:dateComponents];
    
    return dayBegin;
}

- (NSDate *)dateAtBeginningOfWeekDate
{
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents* components = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    [components setDay:([components day] - ([components weekday] -1))];
    
    NSDate *beginningOfWeek = [calendar dateFromComponents:components];
    
    return beginningOfWeek;
}

-(void)getDailySteps{
    
    pedometer0 = [[CMPedometer alloc] init];
    
    if ([CMPedometer isStepCountingAvailable]){
        
        ///Steps Today
        [pedometer0 startPedometerUpdatesFromDate:[self dateAtBeginningOfDayForDate] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"Pedometer is NOT available.");
                }else {
                    tempStepsDay = [pedometerData.numberOfSteps intValue];
                }
            });
            
        }];
    }
    
    [self getWeeklySteps];
}


-(void)getWeeklySteps{
    
    pedometer1 = [[CMPedometer alloc] init];
    
    if ([CMPedometer isStepCountingAvailable]){
        
        ///Steps Today
        [pedometer1 startPedometerUpdatesFromDate:[self dateAtBeginningOfWeekDate] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"Pedometer is NOT available.");
                }else {
                    tempStepsWeekly = [pedometerData.numberOfSteps intValue];
                    [self cellsInTableView];
                }
            });
            
        }];
    }
}

-(void)getUpdatedLMVMins{
    
     dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
         [[PedometerClass getInstance] getExerciseData];
     });
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDailyMins)  name:@"Pedometer-Done" object:nil];
}


-(void)updateDailyMins{
    
    dispatch_async(dispatch_get_main_queue(), ^{
  
        NSIndexPath *indexPath0 = [NSIndexPath indexPathForRow:2 inSection:0]; //daily light
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:3 inSection:0]; //total mod
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:4 inSection:0]; //daily vig
    
        NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:2 inSection:1]; //Total Mod / Vig mins
        NSIndexPath *indexPath4 = [NSIndexPath indexPathForRow:3 inSection:1]; //Total Mod / Vig mins goal

    
        [self.tableViewSummary reloadRowsAtIndexPaths:@[indexPath0, indexPath1, indexPath2, indexPath3, indexPath4] withRowAnimation:UITableViewRowAnimationNone];
    });
    
}


-(void)cellsInTableView{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0]; //daily steps
        NSIndexPath *indexPath1 = [NSIndexPath indexPathForRow:1 inSection:0]; //total steps
        
        NSIndexPath *indexPath2 = [NSIndexPath indexPathForRow:0 inSection:1]; //remaining steps and goal
        NSIndexPath *indexPath3 = [NSIndexPath indexPathForRow:1 inSection:1]; // week goal steps
    
        [self.tableViewSummary reloadRowsAtIndexPaths:@[indexPath, indexPath1, indexPath2, indexPath3] withRowAnimation:UITableViewRowAnimationNone];
    
    });
    
}

-(void)showStepAlert{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:EXERCISE_STEP_COUNT_CONTENT_TITLE]
                                          message:[LocalizationManager getStringFromStrId:EXERCISE_STEP_COUNT_CONTENT]

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


+ (void)totalWeeklyMinutesInfoWithCompletionBlock:(void (^)(NSDictionary *weeklyMinutesInfo))completionBlock
{
    NSDictionary *currentWeekDateRange = [GGUtils weekDateRangeWithDate:[NSDate date]];
    
    if (currentWeekDateRange) {
        NSDate *weekStartDate = currentWeekDateRange[WEEK_START_DATE_KEY];
        NSDate *weekEndDate = currentWeekDateRange[WEEK_END_DATE_KEY];
        
        if (weekStartDate && weekEndDate) {
            [ExerciseRecord calculateTotalMinutesFrom:weekStartDate toDate:weekEndDate].then(^(NSArray *weeklyMinutes) {
                double weeklyLightMinsTotal = 0;
                double weeklyModVigMinsTotal = 0;
                
                for (NSDictionary *weeklyMinsInfo in weeklyMinutes) {
                    ExerciseType currentExerciseType = [(NSNumber *)[[weeklyMinsInfo allKeys] lastObject] intValue];
                    
                    switch (currentExerciseType) {
                        case ExerciseTypeLight:
                            weeklyLightMinsTotal += [(NSNumber *)weeklyMinsInfo[[NSNumber numberWithLong:currentExerciseType]] doubleValue];
                            break;
                        case ExerciseTypeModerate:
                        case ExerciseTypeVigorous:
                            weeklyModVigMinsTotal += [(NSNumber *)weeklyMinsInfo[[NSNumber numberWithLong:currentExerciseType]] doubleValue];
                            break;
                    }
                }
                
                NSUInteger weeklyLightTarget = [self calculateLightWeeklyTargetWithCurrentWeekTotalMinutes:weeklyLightMinsTotal];
                NSUInteger weeklyModVigTarget = [self calculateModVigWeeklyTargetWithCurrentWeekTotalMinutes:weeklyModVigMinsTotal];
                
                NSDictionary *weeklyMinutesInfo = @{EXERCISE_WEEKLY_MINS_INFO_KEY_LIGHT:[NSNumber numberWithDouble:weeklyLightMinsTotal],
                                                    EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG:[NSNumber numberWithDouble:weeklyModVigMinsTotal],
                                                    EXERCISE_WEEKLY_MINS_INFO_KEY_LIGHT_TARGET:[NSNumber numberWithInteger:weeklyLightTarget],
                                                    EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG_TARGET:[NSNumber numberWithInteger:weeklyModVigTarget],
                                                    };
                
                completionBlock(weeklyMinutesInfo);
                return;
            });
        }
    }
    
    completionBlock(nil);
}

#pragma mark - Event Handlers
- (IBAction)btnHistory:(id)sender {
        [self performSegueWithIdentifier:@"segueToShowHistory" sender:self];
}

-(void)didTapCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)unwindToExerciseSummaryViewController:(UIStoryboardSegue *)unwindSegue {
    [self.tableViewSummary reloadData];
}

- (IBAction)didTapChooseExerciseButton:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    [self performSegueWithIdentifier:@"chooseExerciseSegue" sender:self];
}

- (void)didTapYourGoalLabel:(id)sender {
    UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:EXERCISE_SUMMARY_GOAL_TITLE]
                                                          message:[LocalizationManager getStringFromStrId:EXERCISE_SUMMARY_GOAL_CONTENT]
                                                         delegate:nil
                                                cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                otherButtonTitles:nil];
    [promptAlert show];
}


#pragma mark - Databasefix
-(void)updateExerciseRecordTableOnce{

    User *user = [User sharedModel];
    FMDatabase *database = [FMDatabase databaseWithPath:[DBHelper getDBPath:user.userId]];
        
        if(![database open])
        {
            [database open];
        }
        
        if ([database tableExists:@"ExerciseRecord"]) {
            if (![database columnExists:@"note" inTableWithName:@"ExerciseRecord"]){
                [database executeUpdate:@"ALTER TABLE ExerciseRecord ADD COLUMN note TEXT; "];
            }
        }
        
        [database close];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"segueToGoals"]) {
        GoalsViewController *destvc = segue.destinationViewController;
        destvc.navigationItem.leftBarButtonItem = nil;

    }
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


@end
