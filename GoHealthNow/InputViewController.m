//
//  InputViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-30.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "InputViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "UIColor+Extensions.h"
#import "WeightHelper.h"
#import "User.h"
#import "A1CView.h"
#import "GGProgressView.h"
#import "ExerciseSummaryViewController.h"
#import "MealRecord.h"
#import "InsulinRecord.h"
#import "SWRevealViewController.h"
#import "MedicationInputViewController.h"
#import "NotificationMedicationClass.h"
#import "AppDelegate.h"
#import "PedometerClass.h"
#import "GoalsDelegate.h"

@interface InputViewController() <SlideInPopupDelegate, UIAlertViewDelegate>

@property (nonatomic) NSArray *inputRows;
@property (nonatomic) NSArray *inputRowValues;
@property (nonatomic) NSArray *inputRowImageNames;
@property (nonatomic) WeightHelper *weightHelper;
@property (nonatomic) A1CView *a1cView;

@property (nonatomic) BOOL didUpdateUserProfileWithInsulin;

@property (nonatomic) UIAlertView *weightAlert;
@property (nonatomic) BOOL exerciseCellFlagEnable;
@property NSTimer *timerGoal;
@property NSTimer *timerRecords;

@property (nonatomic) int tempStepsDay;

@property (nonatomic) NSArray *selectedInputs;
@property (nonatomic) NSMutableArray *reorderedInputRows;
@property (nonatomic) NSMutableArray *reorderedInputRowValues;
@property (nonatomic) NSMutableArray *reorderedInputRowImageNames;

@property (nonatomic) NSInteger selectedCount;
@property (nonatomic) NSInteger unselectedCount;

@property (nonatomic) int avgSteps;

@end

@implementation InputViewController
@synthesize pedometer, tempStepsDay, avgSteps;

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated {

    [self.tableView reloadData];

//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    [self runPedometer];
    
    if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
        [self getDailySteps];
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    if (appDelegate.notification) {
        appDelegate.notification = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIViewController *myViewController;
            UIStoryboard *storyboard  = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            
            myViewController = [storyboard  instantiateViewControllerWithIdentifier:@"exerciseViewController"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
            
            
           // [self performSegueWithIdentifier:@"exerciseSummarySegue2" sender:self];
        });
    }
    
    [super viewWillAppear:animated];
    
    self.didUpdateUserProfileWithInsulin = NO;
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userAndSelectedInputs = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userAndSelectedInputs"]];
    User *user = [User sharedModel];
    if (![userAndSelectedInputs objectForKey:user.userId] || [[userAndSelectedInputs objectForKey:user.userId] count] == 7) {
        NSArray *selectedInputs = [[NSArray alloc]initWithObjects:@YES, @YES, @YES, @YES, @YES, @YES, @YES, @YES, nil];
        [userAndSelectedInputs setObject:selectedInputs forKey:user.userId];
        [prefs setObject:userAndSelectedInputs forKey:@"userAndSelectedInputs"];
        [prefs synchronize];
        
    }

    
    self.inputRows = @[[LocalizationManager getStringFromStrId:INPUT_ROW_DIET], [LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE], [LocalizationManager getStringFromStrId:INPUT_ROW_GLUCOSE], [LocalizationManager getStringFromStrId:INPUT_ROW_BLOODPRESSURE], [LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION], [LocalizationManager getStringFromStrId:INPUT_ROW_LABTEST], [LocalizationManager getStringFromStrId:INPUT_ROW_WEIGHT], [LocalizationManager getStringFromStrId:INPUT_ROW_SLEEP]];
    self.inputRowValues = @[@"recentMealsSegue", @"exerciseSummarySegue", @"addGlucoseSegue", @"addBloodPressureSegue", @"addMedicationSegue", @"addA1CSegue", @"addWeightSegue", @"addSleepSegue"];
    self.inputRowImageNames = @[@"dietInputIcon", @"exerciseInputIcon", @"glucoseInputIcon", @"bloodPressureInputIcon", @"insulinInputIcon", @"a1cInputIcon", @"weightInputIcon", @"sleepInputIcon"];
    
    self.reorderedInputRows = [[NSMutableArray alloc] init];
    self.reorderedInputRowValues = [[NSMutableArray alloc] init];
    self.reorderedInputRowImageNames = [[NSMutableArray alloc] init];

    
    [self readNSUserDefaults];
    [self reorderInputRows];
    [self countSelectedAndUnselectedInputs];
    
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    [StyleManager styleTable:self.tableView];
    
}

-(void)readNSUserDefaults{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    User *user = [User sharedModel];
    if([prefs objectForKey:@"userAndSelectedInputs"]){
        self.selectedInputs = [NSMutableArray arrayWithArray:[[prefs objectForKey:@"userAndSelectedInputs"] objectForKey:user.userId]];
    }
}

-(void)reorderInputRows{
    for(int i = 0; i < [self.selectedInputs count]; i++){
        if([[self.selectedInputs objectAtIndex:i]  isEqual: @YES]){
            [self.reorderedInputRows addObject:[self.inputRows objectAtIndex:i]];
            [self.reorderedInputRowValues addObject:[self.inputRowValues objectAtIndex:i]];
            [self.reorderedInputRowImageNames addObject:[self.inputRowImageNames objectAtIndex:i]];
        }
    }
    for(int i = 0; i < [self.selectedInputs count]; i++){
        if([[self.selectedInputs objectAtIndex:i]  isEqual: @NO]){
            [self.reorderedInputRows addObject:[self.inputRows objectAtIndex:i]];
            [self.reorderedInputRowValues addObject:[self.inputRowValues objectAtIndex:i]];
            [self.reorderedInputRowImageNames addObject:[self.inputRowImageNames objectAtIndex:i]];
        }
    }

}

-(void)countSelectedAndUnselectedInputs{
    self.selectedCount = 0;
    self.unselectedCount = 0;
    for(int i = 0; i < [self.selectedInputs count]; i++){
        if([[self.selectedInputs objectAtIndex:i]  isEqual: @YES]){
            self.selectedCount++;
        }else{
            self.unselectedCount++;
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated{
  //  [pedometer stopPedometerUpdates];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pedometer-Start" object:nil];
    
}

#pragma mark - Pedometer
-(void)runPedometer{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:3 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
    
    if (!self.exerciseCellFlagEnable) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[PedometerClass getInstance] getExerciseData];
        });
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pedometerStart) name:@"Pedometer-Start" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pedometerDone)  name:@"Pedometer-Done" object:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//
    
    
    // Return the number of rows in the section.
    return [self.inputRows count];
    }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"inputCell";
    //NSString *inputRowName = self.inputRows[indexPath.row];
    NSString *inputRowName = self.reorderedInputRows[indexPath.row];
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_DIET]])
    {
        cellId = @"inputCellWithProgressView";
    }
    else if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_WEIGHT]] ||
             [inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION]]) {
        cellId = @"inputCellWithExtraLabel";
    }else if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE]])
    {
        if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
            cellId = @"inputCellWithProgressViewExercise";
        }else{
            cellId = @"inputCellWithProgressView";
        }
    
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:INPUT_ROW_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:INPUT_ROW_LABEL_TAG];
    
    image.image = [UIImage imageNamed:self.reorderedInputRowImageNames[indexPath.row]];
    label.text = inputRowName;
    [StyleManager stylelabel:label];
    
    GGProgressView *progressBar = (GGProgressView *)[cell viewWithTag:INPUT_ROW_PROGRESS_BAR_TAG];
    UILabel *progressBarDescLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_DESC_LABEL_TAG];
    UILabel *progressBarValueLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_VALUE_LABEL_TAG];
    
    UILabel *remainingStepsLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_REMAINING_STEPS_LABEL_TAG];
    remainingStepsLabel.hidden = YES;
    
    
    progressBar.progressTintColor = [UIColor excellentMealColor];
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_DIET]]) {
        progressBarDescLabel.text = [LocalizationManager getStringFromStrId:@"Last meal score"];
        __block double lastMealScoreVal = 0.0;
        
        [MealRecord lastMealScore].then(^(NSNumber *lastMealScore) {
            lastMealScoreVal = [lastMealScore doubleValue];
        }).finally(^{
            progressBar.progress = lastMealScoreVal / 100.0;
            progressBarValueLabel.text = [NSString stringWithFormat:@"%.f / 100", lastMealScoreVal];
        });
    }
    else if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE]]) {
        
        if ([[PedometerClass getInstance] isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO){
            
            if (self.exerciseCellFlagEnable == YES){
                UILabel *labelWait = (UILabel *)[cell viewWithTag:6];
                labelWait.text = [LocalizationManager getStringFromStrId:@"Please Wait - Do Not Close App\nUpdating Step Information"];
                labelWait.hidden = NO;
                
                GGProgressView *progressBar = (GGProgressView *)[cell viewWithTag:INPUT_ROW_PROGRESS_BAR_TAG];
                UILabel *progressBarDescLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_DESC_LABEL_TAG];
                UILabel *progressBarValueLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_VALUE_LABEL_TAG];
                
                progressBar.hidden = NO;
                progressBarDescLabel.hidden = YES;
                progressBarValueLabel.hidden = YES;
                
                double test1 = [[PedometerClass getInstance] recordNumber];
                double test2 = [[PedometerClass getInstance] recordNumberCount];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBar.progress = test1 / test2;
                    progressBar.progressTintColor = [UIColor redColor];
                });
                
            }else{
                UILabel *labelWait = (UILabel *)[cell viewWithTag:6];
                labelWait.hidden = YES;
                
                UILabel *remainingStepsLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_REMAINING_STEPS_LABEL_TAG];
                remainingStepsLabel.hidden = NO;
                
                GGProgressView *progressBar = (GGProgressView *)[cell viewWithTag:INPUT_ROW_PROGRESS_BAR_TAG];
                UILabel *progressBarDescLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_DESC_LABEL_TAG];
                UILabel *progressBarValueLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_VALUE_LABEL_TAG];
                
                progressBar.hidden = NO;
                progressBarDescLabel.hidden = NO;
                progressBarValueLabel.hidden = NO;
            }
            
            progressBarDescLabel.text = [LocalizationManager getStringFromStrId:@"Daily Step Count"];

            GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
            ExerciseGoal *goal = goalDelegate.goals[GoalTypeExerciseDailyStepsCount];
            int goalTarget = [goal.target intValue];
            
            GGProgressView *progressBar = (GGProgressView *)[cell viewWithTag:INPUT_ROW_PROGRESS_BAR_TAG];
            UILabel *progressBarValueLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_VALUE_LABEL_TAG];
            
            progressBar.progressTintColor = [UIColor excellentMealColor];
            progressBarValueLabel.text = [NSString stringWithFormat:@"%d / %d", tempStepsDay, goalTarget];
            progressBar.progress = [[NSNumber numberWithInt:tempStepsDay] doubleValue] / goalTarget;
            
            double current = goalTarget - tempStepsDay;
            
            
            
            
            if (avgSteps==0) {
                avgSteps = 100;
            }
            int remainingTime = current / avgSteps;
            
            remainingStepsLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Remaining: %.0f (~ %d mins)"], current, remainingTime];
      
        }else{
            
            self.exerciseCellFlagEnable = NO;

            UILabel *progressBarDescLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_PROGRESS_DESC_LABEL_TAG];
            progressBarDescLabel.text = [LocalizationManager getStringFromStrId:@"Minutes this week"];
            
            // TODO: this should be Promise, not a completion block
            [ExerciseSummaryViewController totalWeeklyMinutesInfoWithCompletionBlock:^(NSDictionary *weeklyMinutesInfo) {
                if (weeklyMinutesInfo) {
                    UITableViewCell *visibleExerciseCell = [tableView cellForRowAtIndexPath:indexPath];
                    GGProgressView *visibleExerciseProgressBar = (GGProgressView *)[visibleExerciseCell viewWithTag:INPUT_ROW_PROGRESS_BAR_TAG];
                    UILabel *visibleExerciseProgressBarValueLabel = (UILabel *)[visibleExerciseCell viewWithTag:INPUT_ROW_PROGRESS_VALUE_LABEL_TAG];
                    
                    NSNumber *weeklyModVigMinsTotal = weeklyMinutesInfo[EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG];
                    NSNumber *weeklyModVigTarget = weeklyMinutesInfo[EXERCISE_WEEKLY_MINS_INFO_KEY_MODVIG_TARGET];
                    
                    visibleExerciseProgressBarValueLabel.text = [NSString stringWithFormat:@"%@ / %@", weeklyModVigMinsTotal, weeklyModVigTarget];
                    visibleExerciseProgressBar.progress = [weeklyModVigMinsTotal doubleValue] / [weeklyModVigTarget floatValue];
                }
            }];
        }
    }
    
    [StyleManager stylelabel:progressBarDescLabel];
    [StyleManager stylelabel:progressBarValueLabel];
    
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_DETAIL_LABEL_TAG];
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_WEIGHT]]) {
        User *user = [User sharedModel];
        NSString *weightUnit = nil;
        float weightValue = 0.0;
        
        if (user.measureUnit == MUnitMetric) {
            weightUnit = [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_METRIC];
            weightValue = [user.weight valueWithMetric];
        }
        else {
            weightUnit = [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_IMPERIAL];
            weightValue = [user.weight valueWithImperial];
        }
        
        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Last recorded: %.1f %@"], weightValue, weightUnit];
        NSRange range = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(range.location+1, [detailLabel.text length] - range.location -1)];
        detailLabel.attributedText = detailAttributedStr;
    }
    else if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION]]) {
        
        User *user = [User sharedModel];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        
        if ([prefs objectForKey:@"userLastMedication"]) {
            
            if ([[prefs objectForKey:@"userLastMedication"] objectForKey:user.userId]) {
                
                detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Last recorded: %@"], [[prefs objectForKey:@"userLastMedication"] objectForKey:user.userId]];
                
                NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
                NSRange range = [detailLabel.text rangeOfString:@":"];
                [detailAttributedStr setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                             range:NSMakeRange(range.location +1,[detailLabel.text length] - range.location-1)];
                detailLabel.attributedText = detailAttributedStr;
                detailLabel.adjustsFontSizeToFitWidth = YES;
                detailLabel.minimumScaleFactor = 0.5;
            }else{
                detailLabel.text = [LocalizationManager getStringFromStrId:@"Last recorded:"];
            }
            
        }else{
            detailLabel.text = [LocalizationManager getStringFromStrId:@"Last recorded:"];
        }
        
        
        
    }
    
    [StyleManager styleTableCell:cell];
    
        if(self.unselectedCount > 0){
            if(indexPath.row >= self.selectedCount){
                cell.backgroundColor = [UIColor lightGrayColor];
            }
        }
    
    return cell;
}

#pragma mark - Step Methods
-(void)getDailySteps{
    
    pedometer = [[CMPedometer alloc] init];
    
    if ([CMPedometer isStepCountingAvailable]){
        
        ///Steps Today
        [pedometer startPedometerUpdatesFromDate:[self dateAtBeginningOfDayForDate] withHandler:^(CMPedometerData *pedometerData, NSError *error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                    NSLog(@"Pedometer is NOT available: %@", error);
                }else {
                    tempStepsDay = [pedometerData.numberOfSteps intValue];
                }
            });
            
        }];
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSDate *)dateAtBeginningOfDayForDate
{
    NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents* dateComponents = [gregorian components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[NSDate date]];
    NSDate *dayBegin = [gregorian dateFromComponents:dateComponents];

    return dayBegin;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if([self.reorderedInputRows[indexPath.row] isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE]]){
    //if (indexPath.row == 1) {
        
        if ([[PedometerClass getInstance]isPedometerCapable] && [[PedometerClass getInstance] isMotionDenied] == NO) {
            return 108;
        }else{
            return 88;
        }
        
    }else{
       return 88.0; 
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.reorderedInputRows[indexPath.row] isEqualToString:[LocalizationManager getStringFromStrId:@"Exercise"]]) {
        
        if (self.exerciseCellFlagEnable == NO){
            
            UIViewController *myViewController;
            UIStoryboard *storyboard  = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            
            myViewController = [storyboard  instantiateViewControllerWithIdentifier:@"exerciseViewController"];
            UIViewController *topRootViewController      = [UIApplication sharedApplication].keyWindow.rootViewController;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            
            [topRootViewController presentViewController:navigationController
                                                animated:YES
                                              completion:nil];
            
            
          //  [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
        }
        
        
    }else{
       [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
    }
    
   // if ([self.reorderedInputRows[indexPath.row] isEqualToString:INPUT_ROW_EXERCISE]){
        
       // if (self.exerciseCellFlagEnable == NO){

         //        [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
       
        //}
    
//    else if([self.reorderedInputRows[indexPath.row] isEqualToString:INPUT_ROW_A1C]){
//        if (!self.a1cView) {
//            self.a1cView = [[[NSBundle mainBundle] loadNibNamed:@"A1CView" owner:self options:nil] objectAtIndex:0];
//            self.a1cView.tag = A1C_INPUT_VIEW_TAG;
//        }
//        
//        [self.view.superview slideInPopupWithTitle:@"A1C"
//                                     withComponent:self.a1cView
//                                      withDelegate:self];
//    }
    
//    else if([self.reorderedInputRows[indexPath.row] isEqualToString:INPUT_ROW_WEIGHT]){
//        [self showWeightHelper];
//    }
 
              //    else{
              //        [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
              //    }
    
//    switch (indexPath.row) {
//            
//        case 1:{
//            if (self.exerciseCellFlagEnable == NO) {
//                [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
//            }
//            break;
//        }
//               // weight row
//        case 5: {
//            [self showWeightHelper];
//            break;
//        }
//        // a1c row
//        case 4:
//            if (!self.a1cView) {
//                self.a1cView = [[[NSBundle mainBundle] loadNibNamed:@"A1CView" owner:self options:nil] objectAtIndex:0];
//                self.a1cView.tag = A1C_INPUT_VIEW_TAG;
//            }
//            
//            [self.view.superview slideInPopupWithTitle:@"A1C"
//                                         withComponent:self.a1cView
//                                          withDelegate:self];
//            break;
//        default:{
//            [self performSegueWithIdentifier:self.reorderedInputRowValues[indexPath.row] sender:self];
//        }
//            break;
 //   }
    
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

//SlideInPopup disabled
#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([UIView slideInPopupComponentViewWithTag:WEIGHT_INPUT_PICKER_TAG withGestureRecognizer:gestureRecognizer])
    {
        if (self.weightHelper.weight.valueWithMetric < CHOOSE_WEIGHT_LOWER_WEIGHT_BOUND) {
            User *user = [User sharedModel];
            [self.weightHelper.weight setValueWithMetric:[user.weight valueWithMetric]];
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.tableView reloadData];
            self.weightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_WEIGHT_WARNING_MSG] message:nil delegate:self cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
            [self performSelector:@selector(showWeightAlert) withObject:nil afterDelay:0.4];
        }
        else {
            [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
            
            dispatch_promise(^{
                User *user = [User sharedModel];
                [user addWeightRecord:self.weightHelper.weight :[NSDate date]].then(^(BOOL success)
                                                                                    {
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
                                                                                        [self.tableView reloadData];
                                                                                    });
            });
        }
    }
    else if ([UIView slideInPopupComponentViewWithTag:A1C_INPUT_VIEW_TAG withGestureRecognizer:gestureRecognizer])
    {
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
        
        dispatch_promise(^{
            A1CRecord* record = [[A1CRecord alloc] init];
            
            record.value = [NSNumber numberWithFloat:self.a1cView.value];
            record.recordedTime = [NSDate date];
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
            });
        });
    }
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if ([alertView isEqual:self.weightAlert]) {
            self.weightHelper = nil;
            [self performSelector:@selector(showWeightHelper) withObject:nil afterDelay:0.6];
        }
    }
}


#pragma mark - Event Handlers

- (void)showWeightHelper {
    if (!self.weightHelper) {
        self.weightHelper = [[WeightHelper alloc] init];
        self.weightHelper.weightPickerView.tag = WEIGHT_INPUT_PICKER_TAG;
    }
    
    User *user = [User sharedModel];
    [self.weightHelper.weight setValueWithMetric:[user.weight valueWithMetric]];
    self.weightHelper.unitMode = user.measureUnit;
    
    NSString *measureUnitDisplay = self.weightHelper.unitMode == MUnitMetric ? [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_METRIC] : [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_IMPERIAL];
    [self.view.superview slideInPopupWithTitle:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight (%@)"], measureUnitDisplay]
                                 withComponent:self.weightHelper.weightPickerView
                                  withDelegate:self];
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)settingsButtonTapped:(id)sender {
    [self.revealViewController revealToggle:self];
}


- (void)showWeightAlert {
    [self.weightAlert show];
}

#pragma Notification Methods

-(void)checkGoal{
    
    GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
    ExerciseGoal *goal = goalDelegate.goals[GoalTypeExerciseDailyStepsCount];
    if (![goal isEqual:[NSNull null]]) {
        self.exerciseCellFlagEnable = NO;
        
        if ([self.timerGoal isValid]){
            [self.timerGoal invalidate];
            self.timerGoal = nil;
        }
        
    }else{
        
        if (!self.timerGoal) {
            self.timerGoal =  [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkGoal) userInfo:nil repeats:NO];
        }
    }
}

-(void)pedometerDone{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self checkGoal];
        
        
        avgSteps = [[PedometerClass getInstance] getAvgStepsPerMin];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

        [self.timerRecords invalidate];
        self.timerRecords = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"Pedometer-Done" object:nil];
        
        NSIndexPath *indexPathMedication = [NSIndexPath indexPathForRow:4 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPathMedication] withRowAnimation:UITableViewRowAnimationNone];

    });
}

-(void)pedometerStart{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.exerciseCellFlagEnable = YES;
        [self updateExerciseCell];
        self.timerRecords = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateExerciseCell) userInfo:nil repeats:YES];
    });
}

-(void)updateExerciseCell{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    });
}

#pragma mark - Navigation

- (IBAction)unwindToLog:(UIStoryboardSegue *)unwindSegue{
    
}

- (IBAction)unwindToMedication:(UIStoryboardSegue *)unwindSegue{
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    

    if ([segue.identifier isEqualToString:@"addMedicationSegue"]) {
        [NotificationMedicationClass getInstance].stringComingFromWhere = @"logMedication";
    }
    
}


@end
