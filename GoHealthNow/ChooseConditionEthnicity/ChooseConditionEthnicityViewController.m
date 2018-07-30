//
//  ChooseBirthYearViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-17.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseConditionEthnicityViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "GoalsDelegate.h"
#import "User.h"


@interface ChooseConditionEthnicityViewController () <UINavigationBarDelegate, UITableViewDelegate, UITableViewDataSource, SlideInPopupDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *conditionTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (nonatomic) UIView *headerView;
@property (nonatomic) NSIndexPath* checkedIndexPath;

@property (nonatomic) UIPickerView *weightGoalTargetPickerView;
@property (nonatomic) NSInteger weightGoalTargetPickerViewSelectedRow;
@property (nonatomic) NSArray *weightGoalTargetOptions;
@property (nonatomic) NSArray *exerciseGoalOptions;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnCancel;

@property (nonatomic) NSMutableSet *setConditions;
@property (nonatomic) NSNumber *ethnicity;

@end

@implementation ChooseConditionEthnicityViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    [StyleManager stylelabel:self.noteLabel];
    [StyleManager styleTable:_conditionTableView];
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    self.navBar.delegate = self;
    
    self.weightGoalTargetOptions = [WeightGoal getOptions];
    
    self.setConditions = [[NSMutableSet alloc] initWithCapacity:3];
    
    User *user = [User sharedModel];
    
    self.ethnicity = [NSNumber numberWithInt:user.ethnicity];
    self.checkedIndexPath = [NSIndexPath indexPathForRow:user.ethnicity inSection:1];
    
    if ([user.condition count] > 0) {
       
        NSSet *tempSet = [[NSSet alloc] initWithArray:user.condition];
        self.setConditions = [[NSMutableSet alloc] initWithSet:tempSet];        
    }
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CONTINUE] forState:UIControlStateNormal];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    User *user = [User sharedModel];
    if (user.isFreshUser) {
        [self.btnCancel setEnabled:NO];
        [self.btnCancel setTintColor: [UIColor clearColor]];
        
    }else{
        [self.btnCancel setEnabled:YES];
        [self.btnCancel setTintColor: [UIColor whiteColor]];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate
-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - User Setup Protocol
- (void)didFlipForwardToNextPageWithGesture:(id)sender {
    [self didTapRecordButton:sender];
}

#pragma mark - Event Handlers
- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    
   // [self.delegate didChooseBirthYear:[ChooseBirthYearViewController dateFromYearComponent:selectedRow + FIRST_AVAILABLE_BIRTH_YEAR] sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TableView Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0  && indexPath.row == 3) {
            return 7;
    }else if (indexPath.section == 1  && indexPath.row == 6){
            return 1;
    }else{
            return 37;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 20;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) {
        return 4;
    }else{
        return 6;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        myLabel.frame = CGRectMake(0, 0, tableView.frame.size.width -10, 20);
        myLabel.font = [UIFont boldSystemFontOfSize:15];
        myLabel.text = [LocalizationManager getStringFromStrId:@"Conditions"];
        
        self.headerView = [[UIView alloc] init];
        [self.headerView addSubview:myLabel];
        return self.headerView;
        
    }else{
        UILabel *myLabel = [[UILabel alloc] init];
        myLabel.frame = CGRectMake(0, 0, tableView.frame.size.width -10, 20);
        myLabel.font = [UIFont boldSystemFontOfSize:15];
        myLabel.text = [LocalizationManager getStringFromStrId:@"Ethnicity"];
        
        self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
        [self.headerView addSubview:myLabel];
        return self.headerView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    User *user = [User sharedModel];

    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
    }

        if (indexPath.section == 0) {
            
            if (indexPath.row == 0) {
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Diabetes / Prediabetes"];
                
                if ([self.setConditions containsObject: @"0"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }else if (indexPath.row == 1){
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"High Blood Pressure"];
                
                if ([self.setConditions containsObject: @"1"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }else if (indexPath.row == 2){
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Overweight"];
                
                if ([self.setConditions containsObject: @"2"]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }else{
                cell.textLabel.text = @"";
                cell.userInteractionEnabled = NO;
            }
        
        }else{
            
            if (indexPath.row == 0) {
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"White / Caucasian"];
                
                if (user.ethnicity == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
                
            }else if (indexPath.row == 1){
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Black / Afro-Caribbean"];
                
                if (user.ethnicity == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }else if (indexPath.row == 2){
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Asian"];
                
                if (user.ethnicity == 2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }else if (indexPath.row == 3){
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Aboriginal / American Indian"];
                
                if (user.ethnicity == 3) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            
            }else if (indexPath.row == 4){
                    cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Hispanic / Latino"];
                
                if (user.ethnicity == 4) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    
            }else{
                cell.textLabel.text = [LocalizationManager getStringFromStrId:@"Other"];
                
                if (user.ethnicity == 5) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                
            }
        }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0) {
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            UITableViewCell * uncheckCell = [tableView cellForRowAtIndexPath:indexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
            
            [self.setConditions removeObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithLong:indexPath.row]]];
            
        }else{
            UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            if (indexPath.row == 2) {
                [self askWeightGoal];
            }
            
            
            [self.setConditions addObject:[NSString stringWithFormat:@"%@", [NSNumber numberWithLong:indexPath.row]]];
            
        }
        
    }else if (indexPath.section == 1){
        
        if(self.checkedIndexPath)
        {
            UITableViewCell* uncheckCell = [tableView cellForRowAtIndexPath:self.checkedIndexPath];
            uncheckCell.accessoryType = UITableViewCellAccessoryNone;
        }
        
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        
        self.ethnicity = [NSNumber numberWithLong:indexPath.row];
        
    }
    

    
}

-(void)askWeightGoal{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Weight Goal"]
                                          message:[LocalizationManager getStringFromStrId:@"Do you wish to set a weight loss goal ?"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:MSG_NO]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:MSG_YES]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [self showWeight];
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

-(void)showWeight{
    
    if(!self.weightGoalTargetPickerView) {
        self.weightGoalTargetPickerView = [[UIPickerView alloc] init];
        self.weightGoalTargetPickerView.delegate = self;
        self.weightGoalTargetPickerView.dataSource = self;
        self.weightGoalTargetPickerView.tag = WEIGHT_GOAL_TARGET_PICKER_TAG;
    }
    
    [self.weightGoalTargetPickerView reloadComponent:0];
    
    GoalsDelegate *goalsDelegate = [GoalsDelegate sharedService];
    
    
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
                
                break;
            }
        }
    }
    
    [self.weightGoalTargetPickerView selectRow:self.weightGoalTargetPickerViewSelectedRow inComponent:0 animated:NO];
    
    [self.view.superview slideInPopupWithTitle:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight Goal %@"], [LocalizationManager getStringFromStrId:@"Target"]]
                                 withComponent:self.weightGoalTargetPickerView
                                  withDelegate:self];
    
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
        
    }
}



- (IBAction)RecordButton:(id)sender {
    
    User *user = [User sharedModel];
    
    user.condition = [self.setConditions allObjects];
    user.ethnicity = [self.ethnicity intValue];
    
    NSLog(@"testing2: %d", user.ethnicity);
    NSLog(@"testing3: %d", [self.ethnicity intValue]);
  
    [user save];
    
}


@end
