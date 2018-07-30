//
//  GoalsViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "GoalsViewController.h"
#import "StyleManager.h"
#import "GoalsDelegate.h"
#import "Constants.h"
#import "User.h"
#import "UIView+Extensions.h"
#import "UIColor+Extensions.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"

NSString * const CELL_TAG_GOAL_WEIGHT = @"goalWeightCell";
NSString * const CELL_TAG_GOAL_EXERCISE = @"goalExerciseCell";

static NSUInteger const TAG_GOAL_CELL_IMAGE = 1;
static NSUInteger const TAG_GOAL_CELL_TITLE = 2;
static NSUInteger const TAG_GOAL_CELL_GOAL_CONTENT = 3;
static NSUInteger const TAG_GOAL_CELL_WEIGHT_SUBCONTENT = 4;

@interface GoalsViewController() <SlideInPopupDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>

@property (nonatomic) NSArray *goalRows;
@property (nonatomic) UIPickerView *weightGoalTargetPickerView;
@property (nonatomic) NSInteger weightGoalTargetPickerViewSelectedRow;
@property (nonatomic) NSArray *weightGoalTargetOptions;
@property (nonatomic) NSArray *exerciseGoalOptions;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation GoalsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.goalRows = @[[LocalizationManager getStringFromStrId:@"Weight Goal"], [LocalizationManager getStringFromStrId:@"Exercise Goal"]];
    self.exerciseGoalOptions = @[ @[[LocalizationManager getStringFromStrId:@"Daily Step Count Goal"], @"steps", [LocalizationManager getStringFromStrId:@"daily step count"],
                                    [NSNumber numberWithUnsignedInteger:GOAL_EXERCISE_DAILY_STEP_MAX_VALUE], @2,
                                    [LocalizationManager getStringFromStrId:DAILY_STEP_COUNT_GOAL_TITLE], [LocalizationManager getStringFromStrId:DAILY_STEP_COUNT_GOAL_CONTENT]],
                                  @[[LocalizationManager getStringFromStrId:@"Weekly Step Count Goal"], @"lightExerciseIcon", [LocalizationManager getStringFromStrId:@"weekly step count"],
                                    [NSNumber numberWithUnsignedInteger:GOAL_EXERCISE_WEEKLY_STEP_MAX_VALUE], @3,
                                    [LocalizationManager getStringFromStrId:WEEKLY_STEP_COUNT_GOAL_TITLE], [LocalizationManager getStringFromStrId:WEEKLY_STEP_COUNT_GOAL_CONTENT]],
                                  @[[LocalizationManager getStringFromStrId:@"Weekly Moderate/\nVigorous Exercise Goal"], @"moderateExerciseIcon", [LocalizationManager getStringFromStrId:@"weekly moderate/vigorous exercise"],
                                    [NSNumber numberWithUnsignedInteger:GOAL_EXERCISE_WEEKLY_MODERATE_VIGOROUS_MAX_VALUE], @1,
                                    [LocalizationManager getStringFromStrId:WEEKLY_MODVIG_GOAL_TITLE], [LocalizationManager getStringFromStrId:WEEKLY_MODVIG_GOAL_CONTENT]] ];
    [StyleManager styleTable:self.tableView];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [self setupTableHeaderView];
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:[LocalizationManager getStringFromStrId:@"Synchronizing..."]]];
    GoalsDelegate *goalDelegate = [GoalsDelegate sharedService];
    [goalDelegate loadGoals];
    [goalDelegate loadGoalsFromServer].then(^(id result) {
        if ([result isEqual:@YES]) {
            [goalDelegate saveGoalsWithoutUploading];
            [self.tableView reloadData];
        }
        else {
            NSLog(@"Local goals are the lastest or no goal found.");
        }
    }).catch(^() {
        
    }).finally(^() {
        [self.view hideActivityIndicatorWithNetworkIndicatorOff];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.weightGoalTargetOptions = [WeightGoal getOptions];
    [self.tableView reloadData];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.tableHeaderView.bounds = CGRectMake(0.0, 0.0,
                                                       self.tableView.frame.size.width,
                                                       self.tableView.tableHeaderView.frame.size.height);
}

- (BOOL)validateNumber:(NSString*)number {
    BOOL res = YES;
    NSCharacterSet* tmpSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    int i = 0;
    while (i < number.length) {
        NSString * string = [number substringWithRange:NSMakeRange(i, 1)];
        NSRange range = [string rangeOfCharacterFromSet:tmpSet];
        if (range.length == 0) {
            res = NO;
            break;
        }
        i++;
    }
    return res;
}

- (void) showAlertForIndexpath:(NSIndexPath *)path {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:self.exerciseGoalOptions[path.row][5] message:self.exerciseGoalOptions[path.row][6] delegate:nil cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
    [alert show];
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.goalRows count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        default:
            return 0;
    };
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0 && indexPath.row == 0) ? 108:93;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *goalSectionHeader = [tableView dequeueReusableCellWithIdentifier:@"goalSectionHeader"];
    
    UILabel *goalSectionHeaderLabel = (UILabel *)[goalSectionHeader viewWithTag:WEIGHT_GOAL_SECTION_LABEL_TAG];
    goalSectionHeaderLabel.text = self.goalRows[section];
    
    [StyleManager stylelabel:goalSectionHeaderLabel];
    goalSectionHeaderLabel.font = [UIFont boldSystemFontOfSize:19.0];
    
    return goalSectionHeader;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0: {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TAG_GOAL_WEIGHT];
            
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:TAG_GOAL_CELL_TITLE];
            UILabel *goalContentLabel = (UILabel *)[cell viewWithTag:TAG_GOAL_CELL_GOAL_CONTENT];
            UILabel *goalSubcontent = (UILabel *)[cell viewWithTag:TAG_GOAL_CELL_WEIGHT_SUBCONTENT];
            
            [StyleManager stylelabel:titleLabel];
            [StyleManager stylelabel:goalContentLabel];
            
            goalContentLabel.textColor = [UIColor blueTextColor];
            
            GoalsDelegate *goalsDelegate = [GoalsDelegate sharedService];
            
            NSString *weightGoalTargetDesc = [LocalizationManager getStringFromStrId:@"Not Set"];
            self.weightGoalTargetPickerViewSelectedRow = 4;
            
            if (![goalsDelegate.goals[GoalTypeWeight] isEqual:[NSNull null]] && ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).target)
            {
                float weightGoalTargetValue = [((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).target valueWithMetric];
                int weightGoalType = ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).type;
                
                self.weightGoalTargetPickerViewSelectedRow = -1;
                for (NSDictionary *weightTargetOptionDict in self.weightGoalTargetOptions) {
                    self.weightGoalTargetPickerViewSelectedRow++;
                    if (weightGoalType != [weightTargetOptionDict[WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY] intValue])
                        continue;
                    if (ceilf(weightGoalTargetValue * 10.0) / 10.0 == ceilf([weightTargetOptionDict[WEIGHT_GOAL_OPTIONS_VAL_KEY] floatValue] * 10.0) / 10.0 ||
                        ceilf(weightGoalTargetValue * 10.0) / 10.0 == ceilf([weightTargetOptionDict[WEIGHT_GOAL_OPTIONS_OTHER_UNIT_TYPE_VAL_KEY] floatValue] * 10.0) / 10.0)
                    {
                        weightGoalTargetDesc = weightTargetOptionDict[WEIGHT_GOAL_OPTIONS_DESC_KEY];
                        break;
                    }
                }
            }
            
            [titleLabel setText:[LocalizationManager getStringFromStrId:@"Weight Goal"]];
            [goalContentLabel setText:weightGoalTargetDesc];
            User *user = [User sharedModel];
            [goalSubcontent setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Current weight:%.1f%@"], (user.measureUnit == MUnitMetric ?[user.weight valueWithMetric]: [user.weight valueWithImperial]) ,(user.measureUnit == MUnitMetric ? [LocalizationManager getStringFromStrId:@"kgs"]:[LocalizationManager getStringFromStrId:@"Lbs"])]];
            
            break;
        }
        case 1: {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_TAG_GOAL_EXERCISE];
            
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:TAG_GOAL_CELL_IMAGE];
            UILabel *titleLabel = (UILabel *)[cell viewWithTag:TAG_GOAL_CELL_TITLE];
            UILabel *goalContentLabel = (UILabel *)[cell viewWithTag:TAG_GOAL_CELL_GOAL_CONTENT];
            
            [StyleManager stylelabel:titleLabel];
            [StyleManager stylelabel:goalContentLabel];
            
            goalContentLabel.textColor = [UIColor blueTextColor];
            
            GoalsDelegate *goalsDelegate = [GoalsDelegate sharedService];
            
            NSString *weightGoalTargetDesc = [LocalizationManager getStringFromStrId:@"Not Set"];
            
            switch (indexPath.row) {
                case 0: {
                    if (![goalsDelegate.goals[GoalTypeExerciseDailyStepsCount] isEqual:[NSNull null]] && ((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseDailyStepsCount]).target) {
                        weightGoalTargetDesc = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.0f steps"],
                                                [((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseDailyStepsCount]).target doubleValue]];
                    }
                    //goalContentLabel setText:
                    break;
                }
                case 1: {
                    if (![goalsDelegate.goals[GoalTypeExerciseWeeklyStepsCount] isEqual:[NSNull null]] && ((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseWeeklyStepsCount]).target) {
                        weightGoalTargetDesc = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.0f steps"],
                                                [((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseWeeklyStepsCount]).target doubleValue]];
                    }
                    break;
                }
                case 2: {
                    if (![goalsDelegate.goals[GoalTypeExerciseModerateVigorous] isEqual:[NSNull null]] && ((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseModerateVigorous]).target) {
                        weightGoalTargetDesc = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.0f min"],
                                                [((ExerciseGoal*)goalsDelegate.goals[GoalTypeExerciseModerateVigorous]).target doubleValue]];
                    }
                    break;
                }
                default:
                    break;
            }
            
            [imageView setImage:[UIImage imageNamed:self.exerciseGoalOptions[indexPath.row][1]]];
            [titleLabel setText:self.exerciseGoalOptions[indexPath.row][0]];
            [goalContentLabel setText:weightGoalTargetDesc];
            
            break;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    [self showAlertForIndexpath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    if(!self.weightGoalTargetPickerView) {
                        self.weightGoalTargetPickerView = [[UIPickerView alloc] init];
                        self.weightGoalTargetPickerView.delegate = self;
                        self.weightGoalTargetPickerView.dataSource = self;
                        self.weightGoalTargetPickerView.tag = WEIGHT_GOAL_TARGET_PICKER_TAG;
                    }
                    
                    [self.weightGoalTargetPickerView reloadComponent:0];
                    [self.weightGoalTargetPickerView selectRow:self.weightGoalTargetPickerViewSelectedRow inComponent:0 animated:NO];
                    [self.view.superview slideInPopupWithTitle:[NSString stringWithFormat:@"%@ %@", self.goalRows[indexPath.section], [LocalizationManager getStringFromStrId:@"Target"]]
                                                 withComponent:self.weightGoalTargetPickerView
                                                  withDelegate:self];
                    break;
                default:
                    break;
            }
            break;
        }
        case 1: {
            NSString *msgStr = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please set your %@ goal."], self.exerciseGoalOptions[indexPath.row][2]];
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:msgStr message:@"" preferredStyle:UIAlertControllerStyleAlert];
            [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
                //textField.placeholder = maxValue;
                textField.keyboardType = UIKeyboardTypeNumberPad;
                textField.delegate = self;
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL] style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                UITextField *userInput = alert.textFields.firstObject;
                
                if ([userInput.text isEqualToString:@""] || [userInput.text integerValue] > [self.exerciseGoalOptions[indexPath.row][3] doubleValue]) {
                    UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Invalid number"] message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input a number less than %0.f"], [self.exerciseGoalOptions[indexPath.row][3] doubleValue]] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                    [invaild addAction:cancelAction];
                    [self presentViewController:invaild animated:YES completion:nil];
                }
                else {
                    GoalsDelegate *goalsDelegate = [GoalsDelegate sharedService];
                    ExerciseGoal *goal = ((ExerciseGoal *)goalsDelegate.goals[[self.exerciseGoalOptions[indexPath.row][4] intValue]]);
                    if ([goal isEqual:[NSNull null]]) {
                        goal = [[ExerciseGoal alloc] init];
                    }
                    goal.target = [NSNumber numberWithDouble:[userInput.text doubleValue]];
                    goal.createdTime = [NSDate date];
                    goal.type = [self.exerciseGoalOptions[indexPath.row][4] intValue];
                    goal.uuid = (NSString *)[[NSUUID UUID] UUIDString];
                    
                    goalsDelegate.goals[[self.exerciseGoalOptions[indexPath.row][4] intValue]] = goal;
                    [goalsDelegate saveGoalsWithType:[self.exerciseGoalOptions[indexPath.row][4] intValue]].then(^{
                        [self.tableView reloadData];
                    });
                }
            }];
            
            [alert addAction:cancelAction];
            [alert addAction:okAction];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        default:
            break;
    }
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return [self.weightGoalTargetOptions count];
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[self.weightGoalTargetPickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[self.weightGoalTargetPickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = self.weightGoalTargetOptions[row][WEIGHT_GOAL_OPTIONS_DESC_KEY];
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer {
    GoalsDelegate *goalsDelegate = [GoalsDelegate sharedService];
    
    if ([UIView slideInPopupComponentViewWithTag:WEIGHT_GOAL_TARGET_PICKER_TAG withGestureRecognizer:gestureRecognizer])
    {
        if ([goalsDelegate.goals[GoalTypeWeight] isEqual:[NSNull null]]) {
            goalsDelegate.goals[GoalTypeWeight] = [[WeightGoal alloc] init];
        }
        
        ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).createdTime = [NSDate date];
        NSNumber *selectedWeightGoalTargetOption = self.weightGoalTargetOptions[[self.weightGoalTargetPickerView selectedRowInComponent:0]][WEIGHT_GOAL_OPTIONS_VAL_KEY];
        NSNumber *selectedWeightGoalTypeOption = self.weightGoalTargetOptions[[self.weightGoalTargetPickerView selectedRowInComponent:0]][WEIGHT_GOAL_OPTIONS_GOAL_TYPE_KEY];
        ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).target = [[WeightUnit alloc] initWithMetric:[selectedWeightGoalTargetOption floatValue]];
        ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).uuid = (NSString *)[[NSUUID UUID] UUIDString];
        ((WeightGoal *)goalsDelegate.goals[GoalTypeWeight]).type = [selectedWeightGoalTypeOption intValue];
        
        [goalsDelegate saveGoalsWithType:GoalTypeWeight];
        
        [self.tableView reloadData];
        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
//                                                                  message:ADD_RECORD_SUCESS_MSG
//                                                                 delegate:nil
//                                                        cancelButtonTitle:nil
//                                                        otherButtonTitles:nil];
//            [promptAlert show];
//            
//            [NSTimer scheduledTimerWithTimeInterval:1.5
//                                             target:self
//                                           selector:@selector(dismissRecordPromptAlert:)
//                                           userInfo:promptAlert
//                                            repeats:NO];
//        });
        
        
    }
}

#pragma mark - Event Handlers

- (IBAction)settingsButtonTapped:(id)sender {
    [self.revealViewController revealToggle:self];
}

#pragma mark - Methods

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)setupTableHeaderView {
    UIView *header = [[UIView alloc] init];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorView.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerLabel.text = [LocalizationManager getStringFromStrId:@"Your weight goal affects your daily recommended calories, meal target values and scores"];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:18.0];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [header addSubview:headerLabel];
    [header addSubview:separatorView];
    
    // Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = headerLabel.lineBreakMode;
    paraStyle.alignment = NSTextAlignmentCenter;
    CGRect labelBoundingRect = [headerLabel.text boundingRectWithSize:maximumLabelSize
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{
                                                                        NSFontAttributeName: headerLabel.font,
                                                                        NSParagraphStyleAttributeName: paraStyle
                                                                        }
                                                              context:nil];
    
    header.frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, labelBoundingRect.size.height + 10.0);
    self.tableView.tableHeaderView = header;
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeLeadingMargin
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeLeadingMargin
                                                                              multiplier:1.0
                                                                                constant:8.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeTrailingMargin
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeTrailingMargin
                                                                              multiplier:1.0
                                                                                constant:-8.0]];
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [separatorView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:1.0]];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}

@end
