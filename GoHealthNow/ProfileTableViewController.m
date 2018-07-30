//
//  ProfileTableViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "User.h"
#import "ChooseUnitViewController.h"
#import "ChooseGenderViewController.h"
#import "ChooseBirthYearViewController.h"
#import "ChooseHeightViewController.h"
#import "ChooseNameViewController.h"
#import "ChooseOrganizationCodeViewController.h"
#import "ChooseBMIAndWaistViewController.h"
#import "CalorieDistributionController.h"
#import "WeightHelper.h"
#import "UIView+Extensions.h"
#import "MealCalculator.h"
#import "SWRevealViewController.h"
#import "MedicationRecord.h"
#import "GGUtils.h"
#import "AppDelegate.h"

#import "ChooseConditionEthnicityViewController.h"
#import "ChooseSpecialIDCodeViewController.h"
#import "InputSelectionTableViewController.h"



@interface ProfileTableViewController () <ChooseUnitDelegate, ChooseGenderDelegate, ChooseBirthYearDelegate,
                                          ChooseHeightDelegate, ChooseOrganizationCodeDelegate, ChooseNameDelegate,
                                            ChooseBMIAndWaistDelegate, SlideInPopupDelegate,
                                          CalorieDistributionDelegate, UIAlertViewDelegate>

@property (nonatomic) NSArray *profileRowLabels;
@property (nonatomic) NSMutableArray *profileRowValues;
@property (nonatomic) NSMutableArray *profileRowValuesSnapshot;
@property (nonatomic) NSArray *profileSelectionDisabledIndexes;
@property (nonatomic) WeightHelper *weightHelper;
@property (nonatomic) NSMutableArray *arrayMedications;

@property (nonatomic) UIAlertView *weightAlert;

@property (nonatomic) NSString *condition;
@property (nonatomic) NSString *ethnicity;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnSettings;

@end

@implementation ProfileTableViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    
    User *user = [User sharedModel];
    
    if (user.isFreshUser) {
        user.ethnicity = 99;
        if ([GGUtils getAppType] == AppTypeGlucoGuide) {
            user.condition = @[@"0"];
        }
        else {
            user.condition = [[NSArray alloc] init];
        }
    }
    
    self.profileSelectionDisabledIndexes = @[[NSNumber numberWithInteger:PROFILE_EMAIL_IDX], [NSNumber numberWithInteger:PROFILE_BMI_IDX]];
    
    
    self.profileRowLabels = @[[LocalizationManager getStringFromStrId:@"Email"],
                              [LocalizationManager getStringFromStrId:@"Name"],
                              [LocalizationManager getStringFromStrId:@"ID"],
                              [LocalizationManager getStringFromStrId:@"Access Code"],
                              [LocalizationManager getStringFromStrId:@"Gender"],
                              [LocalizationManager getStringFromStrId:@"Birth Year"],
                              [LocalizationManager getStringFromStrId:@"Conditions / Ethnicity"],
                              [LocalizationManager getStringFromStrId:@"Blood Glucose Unit"],
                              [LocalizationManager getStringFromStrId:@"Unit System"],
                              [LocalizationManager getStringFromStrId:@"Height"],
                              [LocalizationManager getStringFromStrId:MSG_WEIGHT],
                              [LocalizationManager getStringFromStrId:@"Waist Circumference"],
                              [LocalizationManager getStringFromStrId:@"BMI"],
                              [LocalizationManager getStringFromStrId:@"Calorie Distribution"]];
    
    [self getData];
}


-(void)getData{
    
    User *user = [User sharedModel];
    self.profileRowValues = [NSMutableArray arrayWithArray:@[user.email,
                                                             [user fullUserName] ? [user fullUserName] : [NSNull null],
                                                             user.specialID ? user.specialID : [NSNull null],
                                                             user.organizationCode ? user.organizationCode : [NSNull null],
                                                             [NSNumber numberWithInteger:user.gender],
                                                             user.dob ? user.dob : [NSNull null],
                                                             [NSNumber numberWithInt:user.ethnicity],
                                                             [NSNumber numberWithInteger:user.bgUnit],
                                                             [NSNumber numberWithInteger:user.measureUnit],
                                                             user.height,
                                                             user.weight ? user.weight: [NSNull null],
                                                             user.waistSize,
                                                             user.bmi,
                                                             [self mealTargetRatiosStr]
                                                             ]
                             ];
}


- (IBAction)btnSave:(id)sender {
    
    User *user = [User sharedModel];
    if (user.isFreshUser) {
        
        [self performSegueWithIdentifier:@"inputSelectionSegue" sender:self];
        
    }else{
    
        SWRevealViewController *revealController = self.revealViewController;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController *mainTabBarController = [appDelegate mainTabBarController];
    
        [revealController pushFrontViewController:mainTabBarController animated:YES];
    }
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self getData];
    
    User *user = [User sharedModel];
    if (user.isFreshUser) {
        [self.btnSettings setEnabled:NO];
        [self.btnSettings setTintColor: [UIColor clearColor]];        
    }else{
        [self.btnSettings setEnabled:YES];
        [self.btnSettings setTintColor: [UIColor whiteColor]];

    }
    
    
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self checkProfileChanges];
}

#pragma mark - Table view data source
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 44)];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 58)];
    [label setFont:[UIFont boldSystemFontOfSize:14]];
    [label setNumberOfLines:0];
    [label setLineBreakMode:NSLineBreakByWordWrapping];
    label.textAlignment = NSTextAlignmentCenter;
    
    [label setText:[LocalizationManager getStringFromStrId:@"To get the Best Personalized Experience please fill in all fields. You can always update these fields later."]];
    
    [view.contentView addSubview:label];
    
    return view;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 58.0;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.profileRowLabels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell  *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"profileCell"];
        
    cell.backgroundColor = [UIColor clearColor];
    [StyleManager stylelabel:cell.textLabel];
    [StyleManager stylelabel:cell.detailTextLabel];
    
    NSString *detailText = nil;
    
    if (self.profileRowValues[indexPath.row] == [NSNull null]) {
        detailText = [LocalizationManager getStringFromStrId:PROFILE_VALUE_NOT_SET];
    }
    else {
        switch (indexPath.row) {
            case PROFILE_BGUNIT_IDX: {
                BGUnit currentBGUnit = (BGUnit)[self.profileRowValues[indexPath.row] integerValue];
                if (currentBGUnit == BGUnitMMOL) {
                    detailText = [LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MMOL];
                }
                else {
                    detailText = [LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MG];
                }
                break;
            }
            case PROFILE_UNIT_IDX: {
                MeasureUnit currentMeasureUnit = (MeasureUnit)[self.profileRowValues[indexPath.row] integerValue];
                if (currentMeasureUnit == MUnitMetric) {
                    detailText = [LocalizationManager getStringFromStrId:MUNIT_DISPLAY_METRIC];
                }
                else {
                    detailText = [LocalizationManager getStringFromStrId:MUNIT_DISPLAY_IMPERIAL];
                }
                break;
            }
            case PROFILE_BIRTH_YEAR_IDX: {
                NSUInteger currentBirthYear = [ChooseBirthYearViewController yearFromDate:self.profileRowValues[indexPath.row]];
                detailText = [NSString stringWithFormat:@"%ld", (unsigned long)currentBirthYear];
                break;
            }
            case PROFILE_GENDER_IDX: {
                detailText = self.profileRowValues[indexPath.row] == [NSNumber numberWithInteger:GenderTypeMale] ? [LocalizationManager getStringFromStrId:GENDER_DISPLAY_MALE] : [LocalizationManager getStringFromStrId:GENDER_DISPLAY_FEMALE];
                break;
            }
            case PROFILE_BMI_IDX: {
                detailText = [(BMI *)self.profileRowValues[indexPath.row] description];
                break;
            }
            case PROFILE_WAIST_SIZE_IDX: {
                MeasureUnit currentUnit = (MeasureUnit)[self.profileRowValues[PROFILE_UNIT_IDX] integerValue];
                if (currentUnit == MUnitMetric) {
                    detailText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f cm"], [(LengthUnit *)self.profileRowValues[indexPath.row] valueWithMetric]];
                }
                else {
                    float currentInches = [(LengthUnit *)self.profileRowValues[indexPath.row] valueWithImperialInchesOnly];
                    detailText = [NSString stringWithFormat:@"%.1f \"", currentInches];
                }
                break;
            }
            case PROFILE_HEIGHT_IDX: {
                MeasureUnit currentUnit = (MeasureUnit)[self.profileRowValues[PROFILE_UNIT_IDX] integerValue];
                if (currentUnit == MUnitMetric) {
                    detailText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.0f cm"], [(LengthUnit *)self.profileRowValues[indexPath.row] valueWithMetric]];
                }
                else {
                    NSDictionary *currentFeetInches = [(LengthUnit *)self.profileRowValues[indexPath.row] valueWithImperial];
                    detailText = [NSString stringWithFormat:@"%@ ' %@ \"", (NSNumber *)currentFeetInches[IMPERIAL_UNIT_HEIGHT_FEET], (NSNumber *)currentFeetInches[IMPERIAL_UNIT_HEIGHT_INCHES]];
                }
                break;
            }
            case PROFILE_WEIGHT_IDX: {
                MeasureUnit currentUnit = (MeasureUnit)[self.profileRowValues[PROFILE_UNIT_IDX] integerValue];
                User *user = [User sharedModel];
                if (currentUnit == MUnitMetric) {
                    detailText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f kg"], [user.weight valueWithMetric]];
                }
                else {
                    detailText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f lbs"], [user.weight valueWithImperial]];
                }
                break;
            }case PROFILE_CONDITION_ETHNICITY_IDX:{
                
                detailText = [self getConditionEhtnicityString];
                break;
            }case PROFILE_SPECIAL_IDX:{
                User *user = [User sharedModel];
                detailText = [NSString stringWithFormat:@"%@", user.specialID];
            }
                
            default:
                detailText = self.profileRowValues[indexPath.row];
                break;
        }
    }
    
    cell.textLabel.text = self.profileRowLabels[indexPath.row];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.minimumScaleFactor = 0.5;
    cell.tintColor = [UIColor whiteColor];
    
    if (indexPath.row == PROFILE_CONDITION_ETHNICITY_IDX) {
        cell.detailTextLabel.text = [self getConditionEhtnicityString];
    }else{
        cell.detailTextLabel.text = detailText;
    }
    
    if ([self.profileSelectionDisabledIndexes containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

-(NSString *)getConditionEhtnicityString{
    
    User *user = [User sharedModel];
 
            switch (user.ethnicity) {
                case 0:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"White/Caucasian"];
                }
                    break;
                    
                case 1:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Black/Afro-Caribbean"];
                }
                    break;
                    
                case 2:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Asian"];
                }
                    break;
                    
                case 3:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Aboriginal/American Indian"];
                }
                    break;
         
                case 4:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Hispanic/Latino"];
                }
                    break;
                    
                case 5:
                {
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Other"];
                }
                    break;
                    
                default:{
                    self.ethnicity = [LocalizationManager getStringFromStrId:@"Not Set"];
                }
            }
    
        return self.ethnicity;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.profileSelectionDisabledIndexes containsObject:[NSNumber numberWithInteger:indexPath.row]]) {
        return nil;
    }
    else {
        return indexPath;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case PROFILE_NAME_IDX:
            [self performSegueWithIdentifier:@"chooseNameSegue" sender:indexPath];
            break;
        case PROFILE_ORG_CODE_IDX:
            [self performSegueWithIdentifier:@"chooseOrgCodeSegue" sender:indexPath];
            break;
        case PROFILE_UNIT_IDX:
            [self performSegueWithIdentifier:@"chooseUnitSegue" sender:indexPath];
            break;
        case PROFILE_BIRTH_YEAR_IDX:
            [self performSegueWithIdentifier:@"chooseBirthYearSegue" sender:indexPath];
            break;
        case PROFILE_GENDER_IDX:
            [self performSegueWithIdentifier:@"chooseGenderSegue" sender:indexPath];
            break;
        case PROFILE_HEIGHT_IDX:
            [self performSegueWithIdentifier:@"chooseHeightSegue" sender:indexPath];
            break;
        case PROFILE_WEIGHT_IDX:
            [self performSegueWithIdentifier:@"chooseWeightSegue" sender:indexPath];
            break;
        case PROFILE_BGUNIT_IDX:
            [self performSegueWithIdentifier:@"chooseUnitSegue" sender:indexPath];
            break;
        case PROFILE_WAIST_SIZE_IDX:
            [self performSegueWithIdentifier:@"chooseBMIAndWaistSizeSegue" sender:indexPath];
            break;
        case PROFILE_DAILY_CAL_DIST_IDX:
            [self performSegueWithIdentifier:@"chooseDailyCalorieDistributionSegue" sender:indexPath];
            break;
        case PROFILE_CONDITION_ETHNICITY_IDX:
            [self performSegueWithIdentifier:@"chooseConditionEthnicitySegue" sender:indexPath];
            break;
        case PROFILE_SPECIAL_IDX:
            [self performSegueWithIdentifier:@"chooseSpecialCodeSegue" sender:indexPath];
            break;
        default:
            break;
    }
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


#pragma mark - AlertView With Medications
-(void)showAlertWithMedicationsAndInsulins{
    

}

//SlideInPopup disabled
#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseCancel {
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [self.tableView reloadData];
}

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer
{
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    if (self.weightHelper.weight.valueWithMetric < CHOOSE_WEIGHT_LOWER_WEIGHT_BOUND) {
        User *user = [User sharedModel];
        [self.weightHelper.weight setValueWithMetric:[user.weight valueWithMetric]];
        [self slideInPopupDidChooseCancel];
        [self.tableView reloadData];
        self.weightAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:CHOOSE_WEIGHT_WARNING_MSG] message:nil delegate:self cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [self performSelector:@selector(showWeightAlert) withObject:nil afterDelay:0.4];
    }
    else {
        if ([UIView slideInPopupComponentViewWithTag:WEIGHT_INPUT_PICKER_TAG withGestureRecognizer:gestureRecognizer])
        {
            [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];

            dispatch_promise(^{
                User *user = [User sharedModel];
                [user addWeightRecord:self.weightHelper.weight :[NSDate date]].catch(^(BOOL success) {
                    [self.view hideActivityIndicatorWithNetworkIndicatorOff];
                    
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
                    [self checkProfileChanges];
                    [self.view hideActivityIndicatorWithNetworkIndicatorOff];
                    [self.tableView reloadData];
                    self.weightHelper = nil;
                });
            });
        }
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

#pragma mark - Choose Unit Delegate

- (void)didChooseUnit:(NSUInteger)unit withUnitMode:(UnitViewControllerDisplayMode)unitMode sender:(id)sender {
    switch (unitMode) {
        case UnitViewControllerGlucoseDisplayMode: {
            self.profileRowValues[PROFILE_BGUNIT_IDX] = [NSNumber numberWithInteger:unit];
            ((User *)[User sharedModel]).bgUnit = (BGUnit)unit;
            break;
        }
        case UnitViewControllerWeightDisplayMode: {
            self.profileRowValues[PROFILE_UNIT_IDX] = [NSNumber numberWithInteger:unit];
            ((User *)[User sharedModel]).measureUnit = (MeasureUnit)unit;
            break;
        }
    }
    
    [self.tableView reloadData];
}

#pragma mark - Choose Gender Delegate
- (void)didChooseConditionEthnicity:(NSArray *)arrayConditionEthnicity sender:(id)sender {
    [self.tableView reloadData];
}

- (void)didChooseGender:(GenderType)gender sender:(id)sender {
    self.profileRowValues[PROFILE_GENDER_IDX] = [NSNumber numberWithInteger:gender];
    ((User *)[User sharedModel]).gender = gender;
    [self.tableView reloadData];
}

#pragma mark - Choose Birth Year Delegate

- (void)didChooseBirthYear:(NSDate *)date sender:(id)sender {
    self.profileRowValues[PROFILE_BIRTH_YEAR_IDX] = date;
    ((User *)[User sharedModel]).dob = date;
    
    [self.tableView reloadData];
}

#pragma mark - Choose Height Delegate

- (void)didChooseHeight:(LengthUnit *)height sender:(id)sender {
    self.profileRowValues[PROFILE_HEIGHT_IDX] = height;
    ((User *)[User sharedModel]).height = height;
    
    [self.tableView reloadData];
}

#pragma mark - Choose BMI And Waist Delegate

- (void)didChooseWaistSize:(LengthUnit *)waistSize sender:(id)sender {
    self.profileRowValues[PROFILE_WAIST_SIZE_IDX] = waistSize;
    ((User *)[User sharedModel]).waistSize = waistSize;
    
    [self.tableView reloadData];
}

#pragma mark - Choose Name Delegate

- (void)didChoosefirstName:(NSString *)firstName lastName:(NSString *)lastName sender:(id)sender {
    User *user = [User sharedModel];
    user.firstName = firstName;
    user.lastName = lastName;
    
    NSString *userFullName = [user fullUserName];
    self.profileRowValues[PROFILE_NAME_IDX] = userFullName == nil ? [NSNull null] : userFullName;
    
    [self.tableView reloadData];
}

#pragma mark - Choose Organization Code Delegate

- (void)didChooseOrganizationCode:(NSString *)code sender:(id)sender {    
    self.profileRowValues[PROFILE_ORG_CODE_IDX] = code == nil ? [NSNull null] : code;
    ((User *)[User sharedModel]).organizationCode = code;
    
    [self.tableView reloadData];
}

#pragma mark - CalorieDistributionDelegate

- (void)didUpdateMealCalculator:(id)sender {
    self.profileRowValues[PROFILE_DAILY_CAL_DIST_IDX] = [self mealTargetRatiosStr];
    [self.tableView reloadData];
}

#pragma mark - Event Handlers

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction)settingsButtonTapped:(id)sender {
    [self.revealViewController revealToggle:self];
}

#pragma mark - Methods

- (void)showWeightHelper {
    [self snapshotCurrentSettings];
    if (!self.weightHelper) {
        self.weightHelper = [[WeightHelper alloc] init];
        self.weightHelper.weightPickerView.tag = WEIGHT_INPUT_PICKER_TAG;
    }
    
    User *user = [User sharedModel];
    [self.weightHelper.weight setValueWithMetric:[user.weight valueWithMetric]];
    self.weightHelper.unitMode = user.measureUnit;
    
    NSString *measureUnitDisplay = self.weightHelper.unitMode == MUnitMetric ? [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_METRIC] : [LocalizationManager getStringFromStrId:WEIGHT_DISPLAY_IMPERIAL];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.view.superview slideInPopupWithTitle:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Weight (%@)"], measureUnitDisplay]
                                 withComponent:self.weightHelper.weightPickerView
                                  withDelegate:self];
}

- (void)showWeightAlert {
    [self.weightAlert show];
}

- (NSString *)mealTargetRatiosStr {
    NSDictionary *mealTargetRatios = [[MealCalculator sharedModel] mealTargetRatios];
    
    float breakfastTargetPercentage = [mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST] floatValue] * 100;
    float lunchTargetPercentage = [mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH] floatValue] * 100;
    float dinnerTargetPercentage = [mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER] floatValue] * 100;
    float snacksTargetPercentage = [mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK] floatValue] * 100;
    
    NSString *mealTargetRatiosStr = [NSString stringWithFormat:@"%.f/%.f/%.f/%.f", breakfastTargetPercentage, lunchTargetPercentage,
                                                                                   dinnerTargetPercentage, snacksTargetPercentage];
    
    return mealTargetRatiosStr;
}

- (void)snapshotCurrentSettings {
    if (self.profileRowValuesSnapshot == nil) {
        self.profileRowValuesSnapshot = [[NSMutableArray alloc] init];
    }
    else {
        [self.profileRowValuesSnapshot removeAllObjects];
    }
    self.profileRowValuesSnapshot = [self.profileRowValues mutableCopy];
    self.profileRowValuesSnapshot[[self.profileRowLabels indexOfObject:[LocalizationManager getStringFromStrId:@"BMI"]]] = [((BMI*)self.profileRowValues[[self.profileRowLabels indexOfObject:[LocalizationManager getStringFromStrId:@"BMI"]]]) description];
}

- (void)checkProfileChanges {
    if (self.profileRowValuesSnapshot != nil) {
        if ([self.profileRowValues count] == [self.profileRowValuesSnapshot count]) {
            for (int i=0;i<[self.profileRowValues count];i++) {
                //self.navigationItem.title = [NSString stringWithFormat:@"%@", self.profileRowLabels[i]];
                if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Height"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:MSG_WEIGHT]]){
                    //only need to check BMI
                }
                else if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Waist Circumference"]]) {
                    if ([((WeightUnit*)self.profileRowValues[i]) valueWithMetric] != [((WeightUnit*)self.profileRowValuesSnapshot[i]) valueWithMetric]) {
                        [self updateProfile];
                        break;
                    }
                }
                else if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"BMI"]]) {
                    if (![[(self.profileRowValues[i]) description] isEqualToString:self.profileRowValuesSnapshot[i]]) {
                        [self updateProfile];
                        break;
                    }
                }
                else if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Birth Year"]]) {
                    if (![[GGUtils stringOfYear:self.profileRowValues[i]] isEqualToString:[GGUtils stringOfYear:self.profileRowValuesSnapshot[i]]]) {
                        [self updateProfile];
                        break;
                    }
                }
                else if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Gender"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Unit System"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Blood Glucose Unit"]]) {
                    if (![self.profileRowValues[i] isEqual:self.profileRowValuesSnapshot[i]]) {
                        [self updateProfile];
                        break;
                    }
                }
                else if ([self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Calorie Distribution"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Email"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Name"]] || [self.profileRowLabels[i] isEqualToString:[LocalizationManager getStringFromStrId:@"Access Code"]]) {
                    if (self.profileRowValues[i] == [NSNull null] && self.profileRowValuesSnapshot[i] == [NSNull null]){
                        //do nothing
                    }
                    else if (self.profileRowValues[i] == [NSNull null] && self.profileRowValuesSnapshot[i] != [NSNull null]){
                        [self updateProfile];
                        break;
                    }
                    else if (self.profileRowValues[i] != [NSNull null] && self.profileRowValuesSnapshot[i] == [NSNull null]){
                        [self updateProfile];
                        break;
                    }
                    else {
                        if (![self.profileRowValues[i] isEqualToString:self.profileRowValuesSnapshot[i]]) {
                            [self updateProfile];
                            break;
                        }
                    }
                }
                else {
                    if (self.profileRowValues[i] != self.profileRowValuesSnapshot[i]) {
                        [self updateProfile];
                    }
                }
            }
        }
        else {
            [self updateProfile];
        }
    }
    else {
        //[self updateProfile];
    }
}

-(void)updateProfile {
    //update needed
    NSLog(@"User profile have changed!\n");
    
    User *user = [User sharedModel];
    [user updateBrandWithAccesscode];
    [user save];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self snapshotCurrentSettings];
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"chooseUnitSegue"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        ChooseUnitViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.initialUnit = [self.profileRowValues[indexPath.row] integerValue];
        destVC.displayMode = indexPath.row == 7 ? UnitViewControllerGlucoseDisplayMode : UnitViewControllerWeightDisplayMode;
    }
    else if ([segueId isEqualToString:@"chooseGenderSegue"]) {
        ChooseGenderViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.initialGender = (GenderType)[self.profileRowValues[PROFILE_GENDER_IDX] integerValue];
    }
    else if ([segueId isEqualToString:@"chooseBirthYearSegue"]) {
        ChooseBirthYearViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.initialDob = self.profileRowValues[PROFILE_BIRTH_YEAR_IDX];
    }
    else if ([segueId isEqualToString:@"chooseHeightSegue"]) {
        ChooseHeightViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        
        destVC.initialHeight = self.profileRowValues[PROFILE_HEIGHT_IDX];
        destVC.unitMode = (MeasureUnit)[self.profileRowValues[PROFILE_UNIT_IDX] integerValue];
    }
    else if ([segueId isEqualToString:@"chooseOrgCodeSegue"]) {
        ChooseOrganizationCodeViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        destVC.initialOrganizationCode = self.profileRowValues[PROFILE_ORG_CODE_IDX] != [NSNull null] ? self.profileRowValues[PROFILE_ORG_CODE_IDX] : nil;
    }
    else if ([segueId isEqualToString:@"chooseNameSegue"]) {
        ChooseNameViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        
        if (self.profileRowValues[PROFILE_NAME_IDX] != [NSNull null]) {
            NSArray *userNameComponents = [self.profileRowValues[PROFILE_NAME_IDX] componentsSeparatedByString:@" "];
            NSUInteger userNameComponentsCount = [userNameComponents count];
            
            destVC.initialFirstName = userNameComponentsCount > 0 ? userNameComponents[0] : nil;
            destVC.initialLastName = userNameComponentsCount > 1 ? userNameComponents[1] : nil;
        }
    }
    else if ([segueId isEqualToString:@"chooseBMIAndWaistSizeSegue"]) {
        ChooseBMIAndWaistViewController *destVC = [segue destinationViewController];
        destVC.delegate = self;
        
        destVC.initialWaistSize = self.profileRowValues[PROFILE_WAIST_SIZE_IDX];
        destVC.unitMode = (MeasureUnit)[self.profileRowValues[PROFILE_UNIT_IDX] integerValue];
    }
    else if ([segueId isEqualToString:@"chooseDailyCalorieDistributionSegue"]) {
        CalorieDistributionController *destVC = [segue destinationViewController];
        destVC.delegate = self;
    }
    else if ([segueId isEqualToString:@"inputSelectionSegue"]) {
        UINavigationController *destVC = [segue destinationViewController];
        InputSelectionTableViewController *inputSelectionController = destVC.viewControllers[0];
        inputSelectionController.initialSetupFromRegistration = YES;
    }
}

@end
