//
//  CalorieDistributionController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "CalorieDistributionController.h"
#import "MultiColumnTableLayout.h"
#import "Constants.h"
#import "StyleManager.h"
#import "MealCalculator.h"
#import "GGWebBrowserProxy.h"

#pragma mark - CalDistCollectionViewCell

@interface CalDistCollectionViewCell : UICollectionViewCell

@property (nonatomic) NSIndexPath *indexPath;

@end

@implementation CalDistCollectionViewCell
@end

#pragma mark - CalorieDistributionController

@interface CalorieDistributionController () <UICollectionViewDataSource, UICollectionViewDelegate, UINavigationBarDelegate,
                                            UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UICollectionView *calDistTable;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calDistTableCenterXConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calDistTableWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *calDistTableHeightConstraint;

@property (nonatomic) NSArray *data;
@property (nonatomic) NSMutableDictionary *mealTargetRatios;
@property (nonatomic) NSNumberFormatter *numberFormatter;
@property (nonatomic) float totalTargetRatio;
@property (nonatomic) BOOL didAdjustLayoutConstraints;

@end

@implementation CalorieDistributionController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numberFormatter = [[NSNumberFormatter alloc] init];
    self.numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    self.numberFormatter.maximumFractionDigits = 0;
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    
    self.navBar.delegate = self;
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_BUTTON_CONTINUE] forState:UIControlStateNormal];
    }
    
    self.mealTargetRatios = [NSMutableDictionary dictionaryWithDictionary:[[MealCalculator sharedModel] mealTargetRatios]];
    [self updateData];

    self.calDistTable.dataSource = self;
    self.calDistTable.delegate = self;
    
    MultiColumnTableLayout *multiColumnTableLayout = [[MultiColumnTableLayout alloc] init];
    multiColumnTableLayout.columnWidths = @[@95.0, @45.0, @80.0, @85.0];
    multiColumnTableLayout.columnHeight = 40.0;
    multiColumnTableLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.calDistTable.collectionViewLayout = multiColumnTableLayout;
    
    UILabel *targetCalsLabel = (UILabel *)[self.view viewWithTag:CHOOSE_CAL_DIST_TAG_TARGET_CALS_LABEL];
    targetCalsLabel.textColor = [UIColor darkGrayColor];
    targetCalsLabel.font = IS_IPHONE_4_OR_LESS ? [UIFont boldSystemFontOfSize:4.0] : [UIFont boldSystemFontOfSize:22.0];
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self setupOrientationSpecificViews];
}


#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.data[section] count];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"calDistCell";
    if (indexPath.section > 0 && indexPath.section < collectionView.numberOfSections - 1 && indexPath.row == 1) {
        cellId = @"calDistTextFieldCell";
    }
    
    CalDistCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    UILabel *label = (UILabel *)[cell viewWithTag:CHOOSE_CAL_DIST_TAG_CELL_LABEL];
    label.text = self.data[indexPath.section][indexPath.row];
    label.font = [UIFont systemFontOfSize:label.font.pointSize];
    label.textColor = [UIColor blackColor];
    
    UITextField *textField = (UITextField *)[cell viewWithTag:CHOOSE_CAL_DIST_TAG_CELL_TEXT_FIELD];
    textField.text = self.data[indexPath.section][indexPath.row];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.textAlignment = NSTextAlignmentCenter;
    textField.delegate = self;
    
    cell.indexPath = indexPath;
    
    if (indexPath.section == 0 || indexPath.section == collectionView.numberOfSections - 1) {
        label.font = [UIFont boldSystemFontOfSize:label.font.pointSize];
        
        // get the footer row's 2nd column that contains
        // the total percentage value
        if (indexPath.section != 0 && indexPath.row == 1) {
            NSNumber *totalTargetPercentage = [self.numberFormatter numberFromString:self.data[indexPath.section][indexPath.row]];
            if ([totalTargetPercentage floatValue] != 100) {
                label.textColor = [UIColor redColor];
            }
        }
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // validate that the values entered are numbers only
    NSCharacterSet* notDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    // newString consists only of the digits 0 through 9
    return [string rangeOfCharacterFromSet:notDigits].location == NSNotFound;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField.tag != CHOOSE_CAL_DIST_TAG_ALERT_TEXT_FIELD) {
        CalDistCollectionViewCell *textFieldCell = (CalDistCollectionViewCell *)textField.superview.superview;
        NSUInteger dataRow = textFieldCell.indexPath.section;
        
        NSString *msgStr = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_ALERT_PLEASE_INPUT_PERCT], self.data[dataRow][0]];
        NSString *maxValue = [LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_MAX_VALUE];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:msgStr message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = maxValue;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
            textField.tag = CHOOSE_CAL_DIST_TAG_ALERT_TEXT_FIELD;
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL] style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *userInput = alert.textFields.firstObject;
            
            if ([userInput.text isEqualToString:@""] || [userInput.text floatValue] > 100.0) {
                UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_INVALID_NUMBER_ALERT_TITLE]
                                                                                 message:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_INVALID_NUMBER_ALERT_CONTENT]
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                [invaild addAction:cancelAction];
                [self presentViewController:invaild animated:YES completion:nil];
            }
            else {
                //input is valid, update the ratios
                // dataRow - 1 to compensate for the header row
                NSNumber *updateValue = [NSNumber numberWithFloat:[userInput.text floatValue] / 100.0];
                switch (dataRow - 1) {
                    case 0:
                        self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST] = updateValue;
                        break;
                    case 1:
                        self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH] = updateValue;
                        break;
                    case 2:
                        self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER] = updateValue;
                        break;
                    case 3:
                        self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK] = updateValue;
                        break;
                }
                
                [self updateData];
                [self.calDistTable reloadData];
            }
        }];
        
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    else {
        return YES;
    }
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
    if (roundf(self.totalTargetRatio * 100) / 100.0 == 1.0) {
        [[MealCalculator sharedModel] updateMealTargetRatiosWithDict:self.mealTargetRatios];
        [self.delegate didUpdateMealCalculator:sender];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:MSG_ATTENTION]
                                                                         message:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_INVALID_PERCENTAGE_ALERT_CONTENT]
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
        [invaild addAction:cancelAction];
        [self presentViewController:invaild animated:YES completion:nil];
    }
}

- (IBAction)didTapInfoButton:(id)sender {
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Target Calories"]
                                          message:[LocalizationManager getStringFromStrId:@"We recommend that each day you have three meals and three snacks. Each meal and the three snacks, should each have a calorie allotment of 25% of your total daily targeted calorie consumption. \n\n Your recommeded daily calorie intake is clculated based on your profile, more information can be found by viewing the Harris-Benedict Equation."]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:@"Harris-Benedict Equation"]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       UIViewController *browserVC = [GGWebBrowserProxy browserViewControllerWithUrl:@"https://en.wikipedia.org/wiki/Harris%E2%80%93Benedict_equation"];
                                       [self presentViewController:browserVC animated:YES completion:nil];
                                       
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   NSLog(@"OK action");
                               }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];

}

#pragma mark - Methods

- (void)updateData
{
    float breakfastTargetRatio = [self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_BREAKFAST] floatValue];
    float lunchTargetRatio = [self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_LUNCH] floatValue];
    float dinnerTargetRatio = [self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_DINNER] floatValue];
    float snacksTargetRatio = [self.mealTargetRatios[MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_MEALTYPE_ATTR_SNACK] floatValue];
    self.totalTargetRatio = breakfastTargetRatio + lunchTargetRatio + dinnerTargetRatio + snacksTargetRatio;
    
    NSString *totalTargetPercentageStr = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:self.totalTargetRatio * 100.0]];
    
    NSString *breakfastTargetRatioStr = [NSString stringWithFormat:@"%.f", breakfastTargetRatio * 100.0];
    NSString *lunchTargetRatioStr = [NSString stringWithFormat:@"%.f", lunchTargetRatio * 100.0];
    NSString *dinnerTargetRatioStr = [NSString stringWithFormat:@"%.f", dinnerTargetRatio * 100.0];
    NSString *snacksTargetRatioStr = [NSString stringWithFormat:@"%.f", snacksTargetRatio * 100.0];
    
    float targetCalories = [[User sharedModel] getTargetCalories];
    NSNumber *breakfastTargetCalories = [NSNumber numberWithFloat:targetCalories * breakfastTargetRatio];
    NSNumber *lunchTargetCalories = [NSNumber numberWithFloat:targetCalories * lunchTargetRatio];
    NSNumber *dinnerTargetCalories = [NSNumber numberWithFloat:targetCalories * dinnerTargetRatio];
    NSNumber *snacksTargetCalories = [NSNumber numberWithFloat:targetCalories * snacksTargetRatio];
    
    NSString *targetCaloriesStr = [self.numberFormatter stringFromNumber:[NSNumber numberWithFloat:targetCalories]];
    NSString *breakfastTargetCaloriesStr = [self.numberFormatter stringFromNumber:breakfastTargetCalories];
    NSString *lunchTargetCaloriesStr = [self.numberFormatter stringFromNumber:lunchTargetCalories];
    NSString *dinnerTargetCaloriesStr = [self.numberFormatter stringFromNumber:dinnerTargetCalories];
    NSString *snacksTargetCaloriesStr = [self.numberFormatter stringFromNumber:snacksTargetCalories];
    
    NSNumber *minCarbs = [NSNumber numberWithFloat:targetCalories * MIN_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSNumber *maxCarbs = [NSNumber numberWithFloat:targetCalories * MAX_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSString *carbsRange = [NSString stringWithFormat:@"%@ - %@", [self.numberFormatter stringFromNumber:minCarbs], [self.numberFormatter stringFromNumber:maxCarbs]];
    
    NSNumber *minBreakfastCarbs = [NSNumber numberWithFloat:[breakfastTargetCalories floatValue] * MIN_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSNumber *maxBreakfastCarbs = [NSNumber numberWithFloat:[breakfastTargetCalories floatValue] * MAX_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSString *breakfastCarbsRange = [NSString stringWithFormat:@"%@ - %@", [self.numberFormatter stringFromNumber:minBreakfastCarbs], [self.numberFormatter stringFromNumber:maxBreakfastCarbs]];
    
    NSNumber *minLunchCarbs = [NSNumber numberWithFloat:[lunchTargetCalories floatValue] * MIN_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSNumber *maxLunchCarbs = [NSNumber numberWithFloat:[lunchTargetCalories floatValue] * MAX_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSString *lunchCarbsRange = [NSString stringWithFormat:@"%@ - %@", [self.numberFormatter stringFromNumber:minLunchCarbs], [self.self.numberFormatter stringFromNumber:maxLunchCarbs]];
    
    NSNumber *minDinnerCarbs = [NSNumber numberWithFloat:[dinnerTargetCalories floatValue] * MIN_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSNumber *maxDinnerCarbs = [NSNumber numberWithFloat:[dinnerTargetCalories floatValue] * MAX_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSString *dinnerCarbsRange = [NSString stringWithFormat:@"%@ - %@", [self.numberFormatter stringFromNumber:minDinnerCarbs], [self.numberFormatter stringFromNumber:maxDinnerCarbs]];
    
    NSNumber *minSnacksCarbs = [NSNumber numberWithFloat:[snacksTargetCalories floatValue] * MIN_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSNumber *maxSnacksCarbs = [NSNumber numberWithFloat:[snacksTargetCalories floatValue] * MAX_CAL_PERCENTAGE_FOR_CARBS / 4.0];
    NSString *snacksCarbsRange = [NSString stringWithFormat:@"%@ - %@", [self.numberFormatter stringFromNumber:minSnacksCarbs], [self.numberFormatter stringFromNumber:maxSnacksCarbs]];
    
    NSArray *headerData = @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_MEAL_OR_SNACK],
                            @"%",
                            [LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_CALORIES],
                            [LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_CARBS]];
    self.data = @[headerData, @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_BREAKFAST],
                                breakfastTargetRatioStr, breakfastTargetCaloriesStr, breakfastCarbsRange],
                              @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_LUNCH],
                                lunchTargetRatioStr, lunchTargetCaloriesStr, lunchCarbsRange],
                              @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_DINNER],
                                dinnerTargetRatioStr, dinnerTargetCaloriesStr, dinnerCarbsRange],
                              @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_3SNACKS],
                                snacksTargetRatioStr, snacksTargetCaloriesStr, snacksCarbsRange],
                              @[[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_TOTAL], totalTargetPercentageStr , targetCaloriesStr, carbsRange]];
    
    UILabel *targetCalsLabel = (UILabel *)[self.view viewWithTag:CHOOSE_CAL_DIST_TAG_TARGET_CALS_LABEL];
    targetCalsLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:MSG_CALORIE_DISTRIBUTION_HEADER_CLAORIES] , targetCaloriesStr];
}

- (void)setupOrientationSpecificViews {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

    if (IS_IPAD) {
        self.calDistTable.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view removeConstraint:self.calDistTableWidthConstraint];
        
        CGFloat calDistTableWidthMultiplier = 0.415;
        if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
            calDistTableWidthMultiplier = 0.315;
        }
        
        self.calDistTableWidthConstraint = [NSLayoutConstraint constraintWithItem:self.calDistTable
                                                                        attribute:NSLayoutAttributeWidth
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.view
                                                                        attribute:NSLayoutAttributeWidth
                                                                       multiplier:calDistTableWidthMultiplier
                                                                         constant:0.0];
        
        [self.view addConstraint:self.calDistTableWidthConstraint];
    }
}

@end
