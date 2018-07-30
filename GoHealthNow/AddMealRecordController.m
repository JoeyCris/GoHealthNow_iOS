//
//  AddMealRecordController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-10-23.
//  Copyright © 2015 GlucoGuide. All rights reserved.
//

#import "AddMealRecordController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "SearchFoodController.h"
#import "User.h"
#import "MealCalculator.h"
#import "QuickEstimateController.h"
#import "UIView+Extensions.h"
#import "Constants.h"
#import "MealPhotoViewController.h"
#import "NutritionFactsGaugeController.h"

@interface AddMealRecordController () <UITableViewDataSource, UITableViewDelegate, FoodSummaryDelegate, SlideInPopupDelegate,
                                       UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic) UITapGestureRecognizer *navTitleTapViewGestureRecognizer;

@property (nonatomic) UIButton *mealTypeTopButton;
@property (nonatomic) NSLayoutConstraint *mealTypeTopButtonTopConstraint;
@property (nonatomic) NSLayoutConstraint *mealTypeTopButoonTrailingConstraint;

@property (nonatomic) UIButton *mealPhotoTopButton;
@property (nonatomic) NSLayoutConstraint *mealPhotoTopButtonTopConstraint;

@property (nonatomic) UILabel *mealTypeLabel;
@property (nonatomic) UITableView *mealTypeTable;

@property (nonatomic) UITableView *foodTable;
@property (nonatomic) NSIndexPath *addFoodCellIndexPath;
@property (nonatomic) UIView *addFoodDescriptionContainer;
@property (nonatomic) NSLayoutConstraint *addFoodDescriptionContainerWidthConstraint;
@property (nonatomic) NSLayoutConstraint *addFoodDescriptionContainerHeightConstraint;
@property (nonatomic) NSLayoutConstraint *foodTableHeightConstraint;

//@property (nonatomic) UIView *caloriesContainer;
//@property (nonatomic) UIView *scoreContainer;
//@property (nonatomic) UILabel *caloriesLabel;
//@property (nonatomic) UILabel *scoreLabel;

@property (nonatomic) UIButton *nutritionFactsButton;
@property (nonatomic) NSDictionary *mealNutritionFacts;
@property (nonatomic) NSArray *mealScoreAdjustmentStatements;

@property (nonatomic) UIButton *modifyDateAndTimeButton;
@property (nonatomic) NSDate *mealDate;

@property (nonatomic) UIView *foodRatingContainer;
@property (nonatomic) UILabel *foodRatingLabel;
@property (nonatomic) UIProgressView *scoreProgressView;
@property (nonatomic) UILabel *scoreProgressMin;
@property (nonatomic) UILabel *scoreProgressMax;

@property (nonatomic) BOOL isRecentMeal;
@property (nonatomic) BOOL didModifyMeal;
@property (nonatomic) BOOL shouldShowFoodDescriptionContainer;
@property (nonatomic) BOOL didAddPhoto;

@property (nonatomic) BOOL isBeingCopied;


@property (weak, nonatomic) IBOutlet UIBarButtonItem *barNotes;
@property (nonatomic) BOOL addNote;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barAddRecord;

@end

@implementation AddMealRecordController

const CGFloat MEAL_TYPE_Y_POS = 32.0;
const CGFloat MEAL_TYPE_TOP_VIEW_HEIGHT = 44.0;
const CGFloat DEFAULT_MARGIN = 8.0;
const CGFloat DEFAULT_TABLE_CELL_HEIGHT = 44.0;
const CGFloat TABLE_CELL_WITH_IMG_HEIGHT = 60.0;
const CGFloat TABLE_CELL_IMG_TOP_MARGIN = 4.0;
const CGFloat TABLE_CELL_DISCLOSURE_INDICATOR_LEFT_MARGIN = -20.0;
const CGFloat SCORE_PROGRESSBAR_HEIGHT = 5.0;
//const CGFloat CALS_CONTAINER_HEIGHT = DEFAULT_TABLE_CELL_HEIGHT;
const CGFloat NUTRITION_FACTS_BUTTON_HEIGHT = DEFAULT_TABLE_CELL_HEIGHT;
const CGFloat MODIFY_DATE_BUTTON_HEIGHT = DEFAULT_TABLE_CELL_HEIGHT;
const CGFloat FOOD_RATING_CONTAINER_HEIGHT = DEFAULT_TABLE_CELL_HEIGHT;

const NSUInteger TAG_NAV_TITLE_TAP_VIEW = 1;
const NSUInteger TAG_MEAL_TYPE_PICKER = 2;
const NSUInteger TAG_MEAL_DATE_PICKER = 3;
const NSUInteger TAG_MEAL_NOTE_TEXTVIEW = 4;


#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    [self setupNavBarTitleTapView];
    
    self.mealDate = [NSDate date];
    
    self.view.backgroundColor = [UIColor grayBackgroundColor];
    
    NSInteger foodCount = [self.meal.foods count];
    
    if (self.meal && !self.didAddPhoto) {
        //if didmodifymeal is true, then it means this instance was created from new camera based input UI and its not a recent meal
        if (!self.didModifyMeal) {//from recent meal page
            self.isRecentMeal = YES;
            self.barNotes.tintColor = [UIColor whiteColor];
        }
        else {//from camera analyze result
            self.isRecentMeal = NO;
            self.barNotes.tintColor = [UIColor whiteColor];
        }
        
        if (self.meal.name && ![self.meal.name isEqualToString:@""]) {
            self.navigationItem.title = self.meal.name;
        }
        
        self.addFoodCellIndexPath = [NSIndexPath indexPathForRow:foodCount
                                                       inSection:0];
        self.mealDate = self.meal.recordedTime;
    }
    else {//new meal record or from camera analyze but no item found/selected
        
        self.barNotes.tintColor = [UIColor whiteColor];
        
        // TODO
        if (self.meal) {
        }
        else {
            self.meal = [[MealRecord alloc] init];
        }
        self.addFoodCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self performSegueWithIdentifier:@"searchFoodSegue" sender:self];
    }
    
    if (!foodCount) {
        self.shouldShowFoodDescriptionContainer = YES;
    }
    
    // Phase 1
    [self autoSetupMealType];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self enableNavTitleTapViewUserInteraction:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // we check here whether foodTable is already within the view hierarchy
    // to avoid recreating it (and other views) multiple times
    if (self.isRecentMeal && ![self.foodTable isDescendantOfView:self.view]) {
        [self setupChooseMealTypePhase];
        
        [self.mealTypeTopButton setTitle:[self strForMealType:self.meal.type]
                                forState:UIControlStateNormal];
        [self animateMealTypeViews];
        
        if ([self.meal.foods count]) {
            [self setupNutritionFactsAndModifyDateNTimeButton:YES];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self enableNavTitleTapViewUserInteraction:NO];
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    self.foodTableHeightConstraint.constant = [self foodTableHeightWithSuperviewSize:size];
    self.addFoodDescriptionContainerHeightConstraint.constant = [self foodTableHeightWithSuperviewSize:size];
    self.addFoodDescriptionContainerWidthConstraint.constant = [self addFoodDescriptionContainerWidthWithSuperviewSize:size];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.mealTypeTable) {
        return 4;
    }
    else if (tableView == self.foodTable) {
        return [self.meal.foods count] + 1; // extra row for the add food button;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.mealTypeTable) {
        return DEFAULT_TABLE_CELL_HEIGHT;
    }
    else if (tableView == self.foodTable) {
        if ([indexPath isEqual:self.addFoodCellIndexPath]) {
            return DEFAULT_TABLE_CELL_HEIGHT;
        }
        else {
            FoodItem *foodItem = self.meal.foods[indexPath.row];
//            if (foodItem.imageData) {
//                return TABLE_CELL_WITH_IMG_HEIGHT;
//            }
//            else {
                return DEFAULT_TABLE_CELL_HEIGHT;
//            }
        }
    }
    
    return DEFAULT_TABLE_CELL_HEIGHT;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (tableView == self.mealTypeTable) {
        cell = [[UITableViewCell alloc] init];
        cell.textLabel.text = [self strForMealType:(MealType)indexPath.row];
        
        [self setupSeperatorForTableCell:cell withLeadingInset:16.0];
    }
    else if (tableView == self.foodTable) {
        if ([indexPath isEqual:self.addFoodCellIndexPath]) {
            cell = [self setupAddFoodCell];
        }
        else {
            
            cell = [self setupFoodItemCellAtIndexPath:indexPath];
        }
    }
    
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == self.mealTypeTable) {
        self.meal.type = (MealType)indexPath.row;
        [self.mealTypeTopButton setTitle:[self strForMealType:self.meal.type]
                                forState:UIControlStateNormal];
        [self animateMealTypeViews];
        
        [self performSegueWithIdentifier:@"searchFoodSegue" sender:self];
    }
    else if (tableView == self.foodTable) {
        if ([indexPath isEqual:self.addFoodCellIndexPath]) {
            [self performSegueWithIdentifier:@"searchFoodSegue" sender:self];
        }
        else {
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:nil
                                                                        action:nil];
            [self.navigationItem setBackBarButtonItem:backItem];
            
            [self performSegueWithIdentifier:@"foodSummarySegue" sender:indexPath];
        }
    }
}

// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.foodTable && ![indexPath isEqual:self.addFoodCellIndexPath]) {
        // Return YES if you want the specified item to be editable.
        return YES;
    }
    
    return NO;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // add code here for when you hit delete
        if (indexPath.row >= 0 && indexPath.row < [self.meal.foods count]) {
            FoodItem *foodToDelete = self.meal.foods[indexPath.row];
            [self didDeleteFoodItem:foodToDelete atIndex:indexPath.row sender:self];
            
            [tableView deleteRowsAtIndexPaths:@[indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - Food Summary Delegate

- (void)didAddFoodItem:(FoodItem *)foodItem sender:(id)sender {
    
    if (foodItem) {
        self.didModifyMeal = YES;

        [self.meal addFood:foodItem];
        [self calculateMealScore];
        
        if (!self.addFoodDescriptionContainer.isHidden) {
            self.shouldShowFoodDescriptionContainer = NO;
            
            self.addFoodDescriptionContainer.hidden = YES;
            self.addFoodDescriptionContainer.alpha = 0.0;
        }
        
        self.addFoodCellIndexPath = [NSIndexPath indexPathForRow:self.addFoodCellIndexPath.row + 1
                                                       inSection:self.addFoodCellIndexPath.section];
        [self.foodTable reloadData];
        
        [self setupNutritionFactsAndModifyDateNTimeButton:NO];
    }
}

- (void)didUpdateFoodItem:(FoodItem *)foodItem atIndex:(NSUInteger)index sender:(id)sender {
    if (foodItem) {
        self.didModifyMeal = YES;
        
        [self.meal updateFood:foodItem AtIndex:index];
        [self.foodTable reloadData];
        
        [self calculateMealScore];
    }
}

- (void)didDeleteFoodItem:(FoodItem *)foodItem atIndex:(NSUInteger)index sender:(id)sender
{
    if ([self.meal.foods count] > index) {
        self.didModifyMeal = YES;
        
        [self.meal removeFoodAtIndex:index];
        [self calculateMealScore];
        
        if ([self.meal.foods count]) {
            self.shouldShowFoodDescriptionContainer = NO;
        }
        else {
            self.shouldShowFoodDescriptionContainer = YES;
            
            [self.foodRatingLabel setText:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_SCORE_ADD_FOOD_FOR_SCORING]];
            // this indicates that the swipe to delete method is being used, in which case,
            // we should use animation
            if (sender == self) {
                // show the food items table
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.addFoodDescriptionContainer.hidden = NO;
                    
                    [UIView animateWithDuration:1.0 animations:^{
                        self.addFoodDescriptionContainer.alpha = 1.0;
                        self.nutritionFactsButton.alpha = 0.0;
                        self.modifyDateAndTimeButton.alpha = 0.0;
                    } completion:^(BOOL finished) {
                        [self.nutritionFactsButton removeFromSuperview];
                        [self.modifyDateAndTimeButton removeFromSuperview];
                        self.nutritionFactsButton = nil;
                        self.modifyDateAndTimeButton = nil;
                    }];
                });
            }
            else {
                self.addFoodDescriptionContainer.hidden = NO;
                self.addFoodDescriptionContainer.alpha = 1.0;
                
                [self.nutritionFactsButton removeFromSuperview];
                [self.modifyDateAndTimeButton removeFromSuperview];
                self.nutritionFactsButton = nil;
                self.modifyDateAndTimeButton = nil;
            }
        }
        
        self.addFoodCellIndexPath = [NSIndexPath indexPathForRow:self.addFoodCellIndexPath.row - 1
                                                       inSection:self.addFoodCellIndexPath.section];

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.foodTable reloadData];
        });
    }
}

#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer {
    if ([UIView slideInPopupComponentViewWithTag:TAG_MEAL_TYPE_PICKER withGestureRecognizer:gestureRecognizer]) {
        UIPickerView *mealTypePicker = (UIPickerView *)[UIView slideInPopupComponentViewWithTag:TAG_MEAL_TYPE_PICKER
                                                                          withGestureRecognizer:gestureRecognizer];
        self.meal.type = (MealType)[mealTypePicker selectedRowInComponent:0];
        [self.mealTypeTopButton setTitle:[self strForMealType:self.meal.type]
                                forState:UIControlStateNormal];
        
        [self calculateMealScore];
    }
    else if ([UIView slideInPopupComponentViewWithTag:TAG_MEAL_DATE_PICKER withGestureRecognizer:gestureRecognizer]) {
        UIDatePicker *datePicker = (UIDatePicker *)[UIView slideInPopupComponentViewWithTag:TAG_MEAL_DATE_PICKER withGestureRecognizer:gestureRecognizer];
        
        self.mealDate = datePicker.date;
        
        [self calculateMealScore];
    }else if ([UIView slideInPopupComponentViewWithTag:TAG_MEAL_NOTE_TEXTVIEW withGestureRecognizer:gestureRecognizer]) {
        self.meal.note = self.noteText.text;
    }
}

-(void)slideInPopupDidChooseCancel{
    self.noteText.text = nil;
    self.meal.note = @"";
}

#pragma mark - UIPickerViewDataSouce Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return 4;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    return [[NSAttributedString alloc] initWithString:[self strForMealType:(MealType)row]
                                           attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[actionSheet buttonTitleAtIndex:actionSheet.firstOtherButtonIndex] isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_UPDATE_RECENT_MEAL]]) {
        if (buttonIndex == 0) {//update meal
            self.isBeingCopied = NO;
            [self recordWithMeal:self.meal];
        }
        else if (buttonIndex == 1) {//log new meal
            [self calculateMealScore];
            self.isBeingCopied = YES;
            [self recordWithMeal:[self.meal copy]];
            
        }
    }
}

#pragma mark - Event Handlers

- (IBAction)didTapNotes:(id)sender {

    [self addNoteToLogEntry];
   
}


-(void)didTapMealPhotoButton:(id)sender {
    [self performSegueWithIdentifier:@"showMealPhotoSegue" sender:[self.meal loadImage]];
}

///
#pragma TextView Delegates
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.?,()!%+=-/ "] invertedSet];
    NSString *filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    return [text isEqualToString:filtered];
}


-(void)addNoteToLogEntry{
    
    self.noteText = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0)];
    self.noteText.tag = TAG_MEAL_NOTE_TEXTVIEW;
    self.noteText.backgroundColor = [UIColor whiteColor];
    self.noteText.textColor = [UIColor blackColor];
    self.noteText.font = [UIFont systemFontOfSize:14];
    self.noteText.delegate = self;
    
    [self.view.superview slideInPopupForNotesWithTitle:[LocalizationManager getStringFromStrId:@"Notes"]
                                         withComponent:self.noteText
                                          withDelegate:(id)self];
    
    [self.noteText becomeFirstResponder];
    
    if (self.meal.note){
        self.noteText.text = self.meal.note;
    }
    
}

- (IBAction)didTapRecordButton:(id)sender {

    if (self.isRecentMeal) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_UPDATE_RECENT_MEAL], [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_CREATE_NEW_MEAL], nil];
        [actionSheet showInView:self.view];
    }
    else {
        [self recordWithMeal:self.meal];
    }
 
}


- (IBAction)didTapCancelButton:(id)sender {
    if (self.didModifyMeal) {
        // show confirmation alert
        UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_TITLE]
                                                                                   message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_MESSAGE], [LocalizationManager getStringFromStrId:MSG_MEAL]]
                                                                            preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_YES_BTN] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_NO_BTN] style:UIAlertActionStyleDefault handler:nil];
        
        [confirmationAlert addAction:okAction];
        [confirmationAlert addAction:cancelAction];
        
        [self presentViewController:confirmationAlert animated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didTapNutritionFactsButton:(UIButton *)sender {
//    [self performSegueWithIdentifier:@"quickEstimateSegue" sender:self];
    [self performSegueWithIdentifier:@"NutritionFactsGaugeSegue" sender:self];
    
}

- (void)didTapModifyDateNTimeButton:(UIButton *)sender {
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.tag = TAG_MEAL_DATE_PICKER;
    
    datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    datePicker.date = self.mealDate;
    
//    [self.view slideInPopupWithTitle:(IS_IPHONE_4_OR_LESS || IS_IPHONE_5) ? MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_SHORT : MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_LONG
//                       withComponent:datePicker
//                        withDelegate:self];
    [self.view slideInPopupWithTitle: [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_LONG]
                       withComponent:datePicker
                        withDelegate:self];
}

- (void)didTapMealTypeTopButton:(UIButton *)sender {
    UIPickerView *mealTypePicker = [[UIPickerView alloc] init];
    mealTypePicker.tag = TAG_MEAL_TYPE_PICKER;
    mealTypePicker.delegate = self;
    mealTypePicker.dataSource = self;
    
    [mealTypePicker selectRow:self.meal.type inComponent:0 animated:NO];
    
    [self.view slideInPopupWithTitle:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_CHOOSE_MEAL_TYPE_SLIDE_IN_TITLE]
                       withComponent:mealTypePicker
                        withDelegate:self];
}

- (void)didTapNavBarTitle:(UITapGestureRecognizer *)gestureRecognizer {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_ADD_MEAL_NAME_ALERT_TITLE] message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_ADD_MEAL_NAME_ALERT_CONTENT];
        textField.keyboardType = UIKeyboardTypeAlphabet;
        textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL] style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alert.textFields.firstObject;
        if(textField.text.length > 0){
            self.navigationItem.title = textField.text;
            self.meal.name = textField.text;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self calculateMealScore];
            });
        }
        else{
            self.navigationItem.title = [LocalizationManager getStringFromStrId:@"New Meal Record"];
            self.meal.name = nil;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [self calculateMealScore];
            });
        }
        
    }];
    
    [alert addAction:cancelAction];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Methods

// TODO: Currently, there is a limitation on how FoodItems are stored in the SQLite on-device DB:
// Duplicate food items cannot be added to the same meal. This is because the 'SelectedFood' table has a unique key
// on the foodID and the mealID. So, adding multiple food items with matching foodIDs to a meal means that only one
// food item will be added.
// As a temp fix, this method performs a check for duplicates and doesn't let the user add duplicates0

- (void)addMealRecordForItemNotFound:(MealRecord *)meal {
    self.meal =[[MealRecord alloc] init];
    self.meal = meal;
    self.isRecentMeal = NO;
    self.didModifyMeal = YES;
    self.didAddPhoto = YES;
}

- (void)addFoodItems:(NSArray *)foodItem {
    if (!self.meal) {
        self.meal = [[MealRecord alloc] init];
        self.meal.recordedTime = [NSDate date];
        self.isRecentMeal = NO;
    }
    if (foodItem) {
        self.didModifyMeal = YES;
        
        for (FoodItem *item in foodItem) {
            if (![self.meal hasImage] && item.imageData.image!=nil) {
                [self.meal setImage:item.imageData.image];
            }
            [self.meal addFood:item];
        }
        [self calculateMealScore];
        
        if (!self.addFoodDescriptionContainer.isHidden) {
            self.shouldShowFoodDescriptionContainer = NO;
            
            self.addFoodDescriptionContainer.hidden = YES;
            self.addFoodDescriptionContainer.alpha = 0.0;
        }
        
        self.addFoodCellIndexPath = [NSIndexPath indexPathForRow:self.addFoodCellIndexPath.row + 1
                                                       inSection:self.addFoodCellIndexPath.section];
        [self.foodTable reloadData];
        
    }
}

- (BOOL)mealContainsDuplicateFoodItems:(MealRecord *)meal {
   // NSMutableDictionary *duplicateTracker = [[NSMutableDictionary alloc] initWithCapacity:[meal.foods count]];
    
    NSMutableArray *duplicateTracker = [[NSMutableArray alloc] initWithCapacity:[meal.foods count]];
    
    for (FoodItem *food in meal.foods) {
       
        
        //NSString *uniqueKey = [NSString stringWithFormat:@"%lld%@", food.foodId, [meal.oid str]];
       // NSLog(@"testing0: %@", meal.oid);
        


      //  if ([duplicateTracker objectForKey:uniqueKey]) {
        if ([duplicateTracker containsObject:[NSString stringWithFormat:@"%lld", food.foodId]]) {
            return YES;
        }else{
           [duplicateTracker addObject:[NSString stringWithFormat:@"%lld", food.foodId]];
        }
        

        //[duplicateTracker setObject:@1 forKey:uniqueKey];
    }
    
    duplicateTracker = nil;
    
    return NO;
}

- (void)recordWithMeal:(MealRecord *)mealToRecord
{
    if (self.mealNutritionFacts || self.didAddPhoto) {
        
        if ([self mealContainsDuplicateFoodItems:mealToRecord]) {
            UIAlertController *duplicateAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_DUPLICATE_FOOD_ALERT_TITLE]
                                                                                    message:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_DUPLICATE_FOOD_ALERT_CONTENT]
                                                                             preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [duplicateAlert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [duplicateAlert addAction:okAction];
            [self presentViewController:duplicateAlert animated:YES completion:nil];
        }
        else {
            [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:ADD_RECORD_SAVING_MSG]];
            
            dispatch_promise(^{
                
                if (self.isBeingCopied) {
                    mealToRecord.recordedTime = [NSDate date];
                }else{
                  mealToRecord.recordedTime = self.mealDate;
                }
                
                
                [mealToRecord save].then(^(BOOL success) {
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
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                });
            });
        }
    }
    
}

- (void)calculateMealScore {
    User *user = [User sharedModel];
    
    if (user.dob && user.height && user.weight)
    {
        if ([self.meal.foods count])
        {
            MealCalculator *mealCalculator = [MealCalculator sharedModel];
            NSDictionary *scoreInfo = [mealCalculator scoreForUser:(User *)[User sharedModel]
                                                     withFoodItems:self.meal.foods
                                                       forMealType:self.meal.type];
            
            self.meal.score = [(NSNumber *)scoreInfo[MC_SCORE_KEY] floatValue];
            self.mealNutritionFacts = scoreInfo[MC_NUTRITION_FACTS_KEY];
            self.mealScoreAdjustmentStatements = scoreInfo[MC_ADJUST_STATEMENTS_KEY];
            
            
            self.meal.carb = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_CARB] floatValue];
            self.meal.pro = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_PRO] floatValue];
            self.meal.fat = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_FAT] floatValue];
            self.meal.fibre = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_FIB] floatValue];
            self.meal.cals = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_CAL] floatValue];
            self.meal.sugar = [(NSNumber *) self.mealNutritionFacts[MC_NUTRITION_KEY_AMOUNTS][MC_NUTRITION_KEY_SUG] floatValue];
        }
        else {
            self.didModifyMeal = NO;
            self.mealNutritionFacts = nil;
            
            self.meal.score = 0.0;
            self.meal.carb = 0.0;
            self.meal.pro = 0.0;
            self.meal.fat = 0.0;
            self.meal.fibre = 0.0;
            self.meal.cals = 0.0;
            self.meal.sugar = 0.0;
            self.meal.foods = nil;
        }
        
        // Upate the UI
        //self.scoreLabel.attributedText = [self mealScoreValueAttributedString];
        //self.caloriesLabel.text = [NSString stringWithFormat:MSG_ADD_MEAL_RECORD_CALS, self.meal.cals];
      //  self.foodRatingLabel.text = [NSString stringWithFormat:@"%@", [MealScore getScoreRatingWithScore:self.meal.score]];
        self.foodRatingLabel.attributedText = [self mealScoreRatingAttributedString];
        self.scoreProgressView.progress = (float)self.meal.score/(float)100.0;
        self.scoreProgressView.tintColor = [self scoreProgressBarColor];

    }
    else {
        UIAlertView *missingUserValuesAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_NO_SCORE_TITLE]
                                                                         message:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_NO_SCORE_BODY]
                                                                        delegate:self
                                                               cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                               otherButtonTitles:nil];
        [missingUserValuesAlert show];
    }
}

- (UIColor *)scoreProgressBarColor {
    UIColor *mealScoreColor = [UIColor blackColor];
    
    if (self.meal.score >= 80.0) {
        mealScoreColor = [UIColor excellentMealColor];
    }
    else if (self.meal.score >= 60.0 && self.meal.score < 80) {
        mealScoreColor = [UIColor goodMealColor];
    }
    else { // < 60.0
        mealScoreColor = [UIColor notGoodMealColor];
    }
    return mealScoreColor;
}


- (NSAttributedString *)mealScoreRatingAttributedString {
    
    NSAttributedString *mealScoreLabelText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %.0f, %@", [LocalizationManager getStringFromStrId:MSG_SCORE],self.meal.score, [MealScore getScoreRatingWithScore:self.meal.score]]];
    
    NSMutableAttributedString *scoreAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:mealScoreLabelText];
    UIColor *mealScoreColor = [UIColor blackColor];
    
    if (self.meal.score >= 80.0) {
        mealScoreColor = [UIColor excellentMealColor];
    }
    else if (self.meal.score >= 60.0 && self.meal.score < 80) {
        mealScoreColor = [UIColor goodMealColor];
    }
    else { // < 60.0
        mealScoreColor = [UIColor notGoodMealColor];
    }
    
    [scoreAttributedStr addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:18.0]
                               range:NSMakeRange(0, mealScoreLabelText.length)];
    [scoreAttributedStr addAttribute:NSForegroundColorAttributeName
                               value:mealScoreColor
                               range:NSMakeRange(0, mealScoreLabelText.length)];
    return scoreAttributedStr;
}


- (NSAttributedString *)mealScoreValueAttributedString {
    NSUInteger mealScoreValueDigits = roundf(self.meal.score) == 0.0 ? 1 : (NSUInteger)log10f(ABS(self.meal.score)) + 1;
    
    NSAttributedString *mealScoreLabelText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@: %.0f / 100", [LocalizationManager getStringFromStrId:MSG_SCORE],self.meal.score]];
    NSMutableAttributedString *scoreAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:mealScoreLabelText];
    UIColor *mealScoreColor = [UIColor blackColor];
    
    if (self.meal.score >= 80.0) {
        mealScoreColor = [UIColor excellentMealColor];
    }
    else if (self.meal.score >= 60.0 && self.meal.score < 80) {
        mealScoreColor = [UIColor goodMealColor];
    }
    else { // < 60.0
        mealScoreColor = [UIColor notGoodMealColor];
    }
    
    [scoreAttributedStr addAttribute:NSFontAttributeName
                               value:[UIFont systemFontOfSize:18.0]
                               range:NSMakeRange(0, mealScoreLabelText.length)];
    [scoreAttributedStr addAttribute:NSForegroundColorAttributeName
                               value:mealScoreColor
                               range:NSMakeRange(7, mealScoreValueDigits)];
    return scoreAttributedStr;
}

- (NSDictionary *)convertMealToQuickEstimateData:(MealRecord *)qeMeal {
    NSDictionary *rt = [MealCalculator getQuickEstimateValuesForType:QuickEstimateValueTypeIdeal forMeal:self.meal.type];
    
    NSMutableDictionary *tmp1 = [[NSMutableDictionary alloc] initWithDictionary:[rt objectForKey:@"Calories"] copyItems:YES];
    [tmp1 removeObjectForKey:@"curr"];
    [tmp1 setObject:[NSNumber numberWithFloat:qeMeal.cals] forKey:@"curr"];
    
    NSMutableDictionary *tmp2 = [[NSMutableDictionary alloc] initWithDictionary:[rt objectForKey:@"Carbs"] copyItems:YES];
    [tmp2 removeObjectForKey:@"curr"];
    //[tmp2 setObject:[NSNumber numberWithFloat:qeMeal.carb - qeMeal.fibre] forKey:@"curr"];
    [tmp2 setObject:[NSNumber numberWithFloat:qeMeal.carb] forKey:@"curr"];
    
    NSMutableDictionary *tmp3 = [[NSMutableDictionary alloc] initWithDictionary:[rt objectForKey:@"Fats"] copyItems:YES];
    [tmp3 removeObjectForKey:@"curr"];
    [tmp3 setObject:[NSNumber numberWithFloat:qeMeal.fat] forKey:@"curr"];
    
    NSMutableDictionary *tmp4 = [[NSMutableDictionary alloc] initWithDictionary:[rt objectForKey:@"Protein"] copyItems:YES];
    [tmp4 removeObjectForKey:@"curr"];
    [tmp4 setObject:[NSNumber numberWithFloat:qeMeal.pro] forKey:@"curr"];
    
    rt = nil;
    
    if (self.mealScoreAdjustmentStatements == nil) {
        
        MealCalculator *mealCalculator = [MealCalculator sharedModel];
        NSDictionary *scoreInfo = [mealCalculator scoreForUser:(User *)[User sharedModel]
                                                 withFoodItems:self.meal.foods
                                                   forMealType:self.meal.type];
        
        self.mealScoreAdjustmentStatements = scoreInfo[MC_ADJUST_STATEMENTS_KEY];
    }
    
    return [[NSDictionary alloc] initWithObjectsAndKeys:tmp1, @"Calories",
            tmp2, @"Carbs",
            tmp3, @"Fats",
            tmp4, @"Protein",
            [NSNumber numberWithFloat:self.meal.score], @"Score",
            self.mealScoreAdjustmentStatements, @"Adjustment",
            qeMeal.name, @"Name",
            nil];
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (UITableViewCell *)setupAddFoodCell {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    // add food item label
    
    UILabel *addFoodItemLabel = [[UILabel alloc] init];
    addFoodItemLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_ADD_FOOD_ITEM];
    addFoodItemLabel.textColor = [UIColor buttonColor];
    addFoodItemLabel.font = [UIFont boldSystemFontOfSize:14.0];
    addFoodItemLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cell.contentView addSubview:addFoodItemLabel];

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:addFoodItemLabel
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:addFoodItemLabel
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.0
                                                                  constant:0.0]];
    // plus image
    
    UIImageView *plusImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plusIcon"]];
    plusImage.image = [plusImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    plusImage.tintColor = [UIColor buttonColor];
    plusImage.translatesAutoresizingMaskIntoConstraints = NO;
    
    [cell.contentView addSubview:plusImage];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:addFoodItemLabel
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:plusImage
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:-DEFAULT_MARGIN / 2.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:plusImage
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN * 1.5]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:plusImage
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-DEFAULT_MARGIN * 1.5]];
    [plusImage addConstraint:[NSLayoutConstraint constraintWithItem:plusImage
                                                          attribute:NSLayoutAttributeWidth
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:plusImage
                                                          attribute:NSLayoutAttributeHeight
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    // seperator view
    if (self.shouldShowFoodDescriptionContainer) {
        [self setupSeperatorForTableCell:cell withLeadingInset:0.0];
    }

    return cell;
}

- (UITableViewCell *)setupFoodItemCellWithImgAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UIImageView *foodItemImageView = [[UIImageView alloc] init];
    UILabel *foodItemNameLabel = [[UILabel alloc] init];
    UILabel *foodItemDescLabel = [[UILabel alloc] init];
    UIImageView *foodItemDisclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"]];
    
    FoodItem *foodItem = self.meal.foods[indexPath.row];
    
    const CGFloat foodItemImageHeight = TABLE_CELL_WITH_IMG_HEIGHT - TABLE_CELL_IMG_TOP_MARGIN * 2.0;
    foodItemImageView.contentMode = UIViewContentModeScaleAspectFill;
    foodItemImageView.layer.cornerRadius = foodItemImageHeight / 2.0;
    foodItemImageView.layer.masksToBounds = YES;
    foodItemImageView.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    foodItemImageView.layer.borderWidth = 0.5;
    
    if (foodItem.imageData.image) {
        foodItemImageView.image = foodItem.imageData.image;
    }
    else {
        [foodItem.imageData loadFromFile].then(^(id success) {
            if (foodItem.imageData.image) {
                foodItemImageView.image = foodItem.imageData.image;
            }
        }).finally(^{
            if (!foodItemImageView.image) {
                foodItemImageView.image = [UIImage imageNamed:@"mealImage_Default"];
            }
        });
    }
    
    foodItemNameLabel.text = foodItem.name;
    foodItemDescLabel.text = [foodItem description];
    foodItemDescLabel.font = [UIFont systemFontOfSize:14.0];
    
    foodItemImageView.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    // image view
    [cell.contentView addSubview:foodItemImageView];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemImageView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemImageView
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_IMG_TOP_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemImageView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:-TABLE_CELL_IMG_TOP_MARGIN]];
    [foodItemImageView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemImageView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:foodItemImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // name label
    [cell.contentView addSubview:foodItemNameLabel];
    [cell.contentView addSubview:foodItemDisclosureIndicator];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemImageView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_DISCLOSURE_INDICATOR_LEFT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_WITH_IMG_HEIGHT * 0.175]];
    // desc label
    [cell.contentView addSubview:foodItemDescLabel];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_DISCLOSURE_INDICATOR_LEFT_MARGIN]];
    // detail view
    [foodItemDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [foodItemDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    // seperator view
    [self setupSeperatorForTableCell:cell withLeadingInset:0.0];
    
    return cell;
}

- (UITableViewCell *)setupFoodItemCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    FoodItem *foodItem = self.meal.foods[indexPath.row];
    
//    if (foodItem.imageData) {
//        cell = [self setupFoodItemCellWithImgAtIndexPath:indexPath];
//    }
//    else {
        cell = [self setupDefaultFoodItemCellAtIndexPath:indexPath];
//    }

    return cell;
}

- (UITableViewCell *)setupDefaultFoodItemCellAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    UIView *foodItemColorView = [[UIView alloc] init];
    UILabel *foodItemNameLabel = [[UILabel alloc] init];
    UILabel *foodItemDescLabel = [[UILabel alloc] init];
    UIImageView *foodItemDisclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"forwardIcon"]];

    FoodItem *foodItem = self.meal.foods[indexPath.row];
    
    if ([foodItem.foodClass isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_FOOD_RATING_LESS_OFTEN]]) {
        foodItemColorView.backgroundColor = [UIColor lessOftenFoodColor];
    }
    else if ([foodItem.foodClass isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_FOOD_RATING_IN_MODERATION]]) {
        foodItemColorView.backgroundColor = [UIColor inModerationFoodColor];
    }
    else if ([foodItem.foodClass isEqualToString:[LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_FOOD_RATING_MORE_OFTEN]]) {
        foodItemColorView.backgroundColor = [UIColor moreOftenFoodColor];
    }
    else {
        foodItemColorView.backgroundColor = [UIColor grayBackgroundColor];;
    }
    
    foodItemColorView.layer.cornerRadius = 5.0;
    
    foodItemNameLabel.text = foodItem.name;
    foodItemDescLabel.text = [foodItem description];
    foodItemDescLabel.font = [UIFont systemFontOfSize:14.0];
    
    foodItemColorView.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemNameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemDescLabel.translatesAutoresizingMaskIntoConstraints = NO;
    foodItemDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    
    // color view
    [cell.contentView addSubview:foodItemColorView];
    
    [foodItemColorView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemColorView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:15.0]];
    [foodItemColorView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemColorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:15.0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemColorView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemColorView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    // name label
    [cell.contentView addSubview:foodItemNameLabel];
    [cell.contentView addSubview:foodItemDisclosureIndicator];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemColorView
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:-DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_DISCLOSURE_INDICATOR_LEFT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:4.0]];
    // desc label
    [cell.contentView addSubview:foodItemDescLabel];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeTop
                                                                multiplier:1.0
                                                                  constant:2.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemNameLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDescLabel
                                                                 attribute:NSLayoutAttributeRight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeLeft
                                                                multiplier:1.0
                                                                  constant:TABLE_CELL_DISCLOSURE_INDICATOR_LEFT_MARGIN]];
    // detail view
    [foodItemDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [foodItemDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:foodItemDisclosureIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    // seperator view
    [self setupSeperatorForTableCell:cell withLeadingInset:0.0];
    
    return cell;
}

- (void)setupSeperatorForTableCell:(UITableViewCell *)cell withLeadingInset:(CGFloat)leadingInset
{
    UIView *seperatorView = [[UIView alloc] init];
    seperatorView.translatesAutoresizingMaskIntoConstraints = NO;
    seperatorView.backgroundColor = [UIColor grayBackgroundColor];
    
    [cell.contentView addSubview:seperatorView];

    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                 attribute:NSLayoutAttributeLeading
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeLeading
                                                                multiplier:1.0
                                                                  constant:leadingInset]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                                 attribute:NSLayoutAttributeBottom
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:cell.contentView
                                                                 attribute:NSLayoutAttributeBottom
                                                                multiplier:1.0
                                                                  constant:0.0]];
    [seperatorView addConstraint:[NSLayoutConstraint constraintWithItem:seperatorView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:0.8]];
}

- (void)enableNavTitleTapViewUserInteraction:(BOOL)enabled {
    if (enabled) {
        UIView *navTitleTapView = [self.navigationController.navigationBar viewWithTag:TAG_NAV_TITLE_TAP_VIEW];
        navTitleTapView.userInteractionEnabled = YES;
        [self.navTitleTapViewGestureRecognizer addTarget:self action:@selector(didTapNavBarTitle:)];
    }
    else {
        UIView *navTitleTapView = [self.navigationController.navigationBar viewWithTag:TAG_NAV_TITLE_TAP_VIEW];
        navTitleTapView.userInteractionEnabled = NO;
        [self.navTitleTapViewGestureRecognizer removeTarget:self action:@selector(didTapNavBarTitle:)];
    }
}

- (void)setupNavBarTitleTapView {
    UILabel *navTitleTapView = [[UILabel alloc] init];
    navTitleTapView.tag = TAG_NAV_TITLE_TAP_VIEW;
    //navTitleTapView.translatesAutoresizingMaskIntoConstraints = NO;
    navTitleTapView.backgroundColor = [UIColor clearColor];
    // the target action will be added in viewWillAppear and removed in viewWillDisappear
    // this is because this view is added to the navBar and thus can be accessed from other
    // view controllers, which we don't want. So we disabled user interaction when viewWillDisappear
    // is called and enable it when viewWillAppear is called
    self.navTitleTapViewGestureRecognizer = [[UITapGestureRecognizer alloc] init];
    [navTitleTapView addGestureRecognizer:self.navTitleTapViewGestureRecognizer];
    [navTitleTapView setFrame:CGRectMake(50,0,self.navigationController.navigationBar.frame.size.width-165,self.navigationController.navigationBar.frame.size.height)];
    //[navTitleTapView setFrame:self.navigationItem.titleView.frame];
    
    //self.navigationItem.titleView = navTitleTapView;
    [self.navigationController.navigationBar addSubview:navTitleTapView];
    /*
    [self.navigationController.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:navTitleTapView
                                                                                        attribute:NSLayoutAttributeTop
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.navigationController.navigationBar
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1.0
                                                                                         constant:0.0]];
    [self.navigationController.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:navTitleTapView
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.navigationController.navigationBar
                                                                                        attribute:NSLayoutAttributeBottom
                                                                                       multiplier:1.0
                                                                                         constant:0.0]];
    [self.navigationController.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:navTitleTapView
                                                                                        attribute:NSLayoutAttributeLeading
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.navigationController.navigationBar
                                                                                        attribute:NSLayoutAttributeLeading
                                                                                       multiplier:1.0
                                                                                         constant:DEFAULT_MARGIN * 2.0 + self.navigationItem.rightBarButtonItem.image.size.width + DEFAULT_MARGIN * 2.0]];
    [self.navigationController.navigationBar addConstraint:[NSLayoutConstraint constraintWithItem:navTitleTapView
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:self.navigationController.navigationBar
                                                                                        attribute:NSLayoutAttributeTrailing
                                                                                       multiplier:1.0
                                                                                         constant:-(DEFAULT_MARGIN * 2.0 + self.navigationItem.rightBarButtonItem.image.size.width + DEFAULT_MARGIN * 2.0)]];
     */
}

#pragma mark - Phase 1 - Choose Meal Type Methods

- (NSString *)strForMealType:(MealType)mealType {
    switch (mealType) {
        case MealTypeBreakfast:
            return [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_TYPE_BREAKFAST];
        case MealTypeLunch:
            return [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_TYPE_LUNCH];
        case MealTypeDinner:
            return [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_TYPE_DINNER];
        case MealTypeSnack:
            return [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_TYPE_SNACK];
    }
}

- (void)animateMealTypeViews {
    [self setupChooseFoodItemsPhase];
    
    [UIView animateWithDuration:1.0 animations:^{
        self.mealTypeLabel.alpha = 0.0;
        self.mealTypeTable.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.mealTypeLabel removeFromSuperview];
        [self.mealTypeTable removeFromSuperview];
        
        self.mealTypeLabel = nil;
        self.mealTypeTable = nil;
        
        // show the food items table
        dispatch_async(dispatch_get_main_queue(), ^ {
            self.foodTable.hidden = NO;
            //self.caloriesContainer.hidden = NO;
            //self.scoreContainer.hidden = NO;
            self.foodRatingContainer.hidden = NO;
            
            [UIView animateWithDuration:1.25 animations:^{
                self.foodTable.alpha = 1.0;
                //self.caloriesContainer.alpha = 1.0;
                //self.scoreContainer.alpha = 1.0;
                self.foodRatingContainer.alpha = 1.0;
            }];
        });
        
        // show meal type top view
        dispatch_async(dispatch_get_main_queue(), ^ {
            [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:0.5
                  initialSpringVelocity:0.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
                      self.mealTypeTopButtonTopConstraint.constant = DEFAULT_MARGIN;
                      if ([self.meal.foods count] == 0 && self.isRecentMeal && [self.meal loadImage]) {
                          self.mealPhotoTopButtonTopConstraint.constant = DEFAULT_MARGIN;
                      }
                      [self.view layoutIfNeeded];
                  } completion:nil];
        });
    }];
}

- (void)autoSetupMealType {
    if (!self.isRecentMeal) {
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
        if ([components hour]>=5 && [components hour]<10) {
               self.meal.type = MealTypeBreakfast;
            }
            else if ([components hour]>=10 && [components hour]<16) {
               self.meal.type = MealTypeLunch;
            }
            else if ([components hour]>=16 && [components hour]<24) {
               self.meal.type = MealTypeDinner;
            }
            else {
               self.meal.type = MealTypeSnack;
            }
    }
    
    Boolean hasPicture = NO;
    if ([self.meal.foods count] == 0 && [self.meal loadImage] && self.isRecentMeal) {
        hasPicture = YES;
        self.mealPhotoTopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.view addSubview:self.mealPhotoTopButton];
        [self.mealPhotoTopButton addTarget:self action:@selector(didTapMealPhotoButton:) forControlEvents:UIControlEventTouchUpInside];
        self.mealPhotoTopButton.backgroundColor = [UIColor whiteColor];
        self.mealPhotoTopButton.layer.cornerRadius = 5.0;
        [self.mealPhotoTopButton setTitle:@"" forState:UIControlStateNormal];
        [self.mealPhotoTopButton setImage:[UIImage imageNamed:@"mealPictureIcon"] forState:UIControlStateNormal];
        self.mealPhotoTopButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.mealPhotoTopButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.mealPhotoTopButton
                                                                            attribute:NSLayoutAttributeTop
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.view
                                                                            attribute:NSLayoutAttributeTop
                                                                           multiplier:1.0
                                                                             constant:-MEAL_TYPE_TOP_VIEW_HEIGHT];
        
        [self.view addConstraint:self.mealPhotoTopButtonTopConstraint];

        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealPhotoTopButton
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN]];
        
        [self.mealPhotoTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealPhotoTopButton
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:MEAL_TYPE_TOP_VIEW_HEIGHT]];
        [self.mealPhotoTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealPhotoTopButton
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:MEAL_TYPE_TOP_VIEW_HEIGHT]];
    }
    
    // meal type top button
    
    self.mealTypeTopButton = [[UIButton alloc] init];
    self.mealTypeTopButton.backgroundColor = [UIColor whiteColor];
    self.mealTypeTopButton.layer.cornerRadius = 5.0;
    self.mealTypeTopButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.mealTypeTopButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    
    //[self.mealTypeTopButton setImage:[UIImage imageNamed:@"upArrowIcon"] forState:UIControlStateNormal];
    
    UIImageView *mealTypeDisclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"expandArrowIcon"]];
    mealTypeDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mealTypeTopButton addSubview:mealTypeDisclosureIndicator];
    [mealTypeDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [mealTypeDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:mealTypeDisclosureIndicator
                                                                       attribute:NSLayoutAttributeTrailing
                                                                      multiplier:1.0
                                                                        constant:DEFAULT_MARGIN]];
    
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.0]];
    
    [self.mealTypeTopButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
    self.mealTypeTopButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.mealTypeTopButton setTitleColor:[UIColor blackColor]
                                 forState:UIControlStateNormal];
    [self.mealTypeTopButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]]
                                      forState:UIControlStateHighlighted];
    
    [self.mealTypeTopButton addTarget:self
                               action:@selector(didTapMealTypeTopButton:)
                     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self.view addSubview:self.mealTypeTopButton];
    
    self.mealTypeTopButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:-MEAL_TYPE_TOP_VIEW_HEIGHT];
    [self.view addConstraint:self.mealTypeTopButtonTopConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    
    if (!hasPicture) {
        self.mealTypeTopButoonTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                                attribute:NSLayoutAttributeTrailing
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.view
                                                                                attribute:NSLayoutAttributeTrailing
                                                                               multiplier:1.0
                                                                                 constant:-DEFAULT_MARGIN];
    }
    else {
        self.mealTypeTopButoonTrailingConstraint = [NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                           attribute:NSLayoutAttributeTrailing
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.mealPhotoTopButton
                                                                           attribute:NSLayoutAttributeLeading
                                                                          multiplier:1.0
                                                                            constant:-DEFAULT_MARGIN];
    }
    [self.view addConstraint:self.mealTypeTopButoonTrailingConstraint];
     
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:MEAL_TYPE_TOP_VIEW_HEIGHT]];
    
    [self.mealTypeTopButton setTitle:[self strForMealType:self.meal.type]
                            forState:UIControlStateNormal];
    
    [self animateMealTypeViews];
    
    if (self.isRecentMeal || self.didModifyMeal) {
        [self setupNutritionFactsAndModifyDateNTimeButton:NO];
        if (!self.isRecentMeal)
            [self calculateMealScore];
        
    }
}

- (void)setupChooseMealTypePhase
{
    if (!self.isRecentMeal) {
        // meal type label
        
        self.mealTypeLabel = [[UILabel alloc] init];
        self.mealTypeLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_TYPE_CHOOSER_CONTENT];
        self.mealTypeLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.mealTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.mealTypeLabel];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeLabel
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeLabel
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:MEAL_TYPE_Y_POS]];
        // meal type table
        
        self.mealTypeTable = [[UITableView alloc] init];
        self.mealTypeTable.delegate = self;
        self.mealTypeTable.dataSource = self;
        self.mealTypeTable.layer.cornerRadius = 5.0;
        self.mealTypeTable.translatesAutoresizingMaskIntoConstraints = NO;
        
        [StyleManager styleTable:self.mealTypeTable];
        self.mealTypeTable.separatorColor = [UIColor clearColor];
        
        [self.view addSubview:self.mealTypeTable];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTable
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.mealTypeLabel
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:32.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTable
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:DEFAULT_MARGIN]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTable
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN]];
        [self.mealTypeTable addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTable
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:DEFAULT_TABLE_CELL_HEIGHT * 4.0]];
    }
    
    // meal type top button
    
    self.mealTypeTopButton = [[UIButton alloc] init];
    self.mealTypeTopButton.backgroundColor = [UIColor whiteColor];
    self.mealTypeTopButton.layer.cornerRadius = 5.0;
    self.mealTypeTopButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.mealTypeTopButton.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    
    
    //[self.mealTypeTopButton setImage:[UIImage imageNamed:@"upArrowIcon"] forState:UIControlStateNormal];
    
    UIImageView *mealTypeDisclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"expandArrowIcon"]];
    mealTypeDisclosureIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mealTypeTopButton addSubview:mealTypeDisclosureIndicator];
    [mealTypeDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [mealTypeDisclosureIndicator addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:15.0]];
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                 attribute:NSLayoutAttributeTrailing
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:mealTypeDisclosureIndicator
                                                                 attribute:NSLayoutAttributeTrailing
                                                                multiplier:1.0
                                                                  constant:DEFAULT_MARGIN]];
    
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:mealTypeDisclosureIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.mealTypeTopButton
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0
                                                                  constant:0.0]];
    
    [self.mealTypeTopButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, -10.0, 0.0, 0.0)];
    self.mealTypeTopButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.mealTypeTopButton setTitleColor:[UIColor blackColor]
                                 forState:UIControlStateNormal];
    [self.mealTypeTopButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]]
                                      forState:UIControlStateHighlighted];
    
    [self.mealTypeTopButton addTarget:self
                               action:@selector(didTapMealTypeTopButton:)
                     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [self.view addSubview:self.mealTypeTopButton];
    
    self.mealTypeTopButtonTopConstraint = [NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeTop
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeTop
                                                                      multiplier:1.0
                                                                        constant:-MEAL_TYPE_TOP_VIEW_HEIGHT];
    [self.view addConstraint:self.mealTypeTopButtonTopConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-DEFAULT_MARGIN]];
    [self.mealTypeTopButton addConstraint:[NSLayoutConstraint constraintWithItem:self.mealTypeTopButton
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:nil
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:1.0
                                                                        constant:MEAL_TYPE_TOP_VIEW_HEIGHT]];
    
}

#pragma mark - Phase 2 - Choose Food Items Methods

- (const CGFloat)foodTableHeightWithSuperviewSize:(CGSize)superviewSize {
    CGFloat mealTypeTopViewHeightWithMargin = MEAL_TYPE_Y_POS + MEAL_TYPE_TOP_VIEW_HEIGHT + self.navigationController.navigationBar.frame.size.height + 20; // need to add status bar height which is 20
    //CGFloat caloriesContainerHeightWithMargin = CALS_CONTAINER_HEIGHT + DEFAULT_MARGIN;
    CGFloat modifyDateContainerHeightWithMargin = MODIFY_DATE_BUTTON_HEIGHT + DEFAULT_MARGIN;
    CGFloat foodRatingContainerHeightWithMargin = DEFAULT_MARGIN + FOOD_RATING_CONTAINER_HEIGHT;
    
    const CGFloat foodTableHeight = superviewSize.height - mealTypeTopViewHeightWithMargin -
                                    modifyDateContainerHeightWithMargin - NUTRITION_FACTS_BUTTON_HEIGHT - foodRatingContainerHeightWithMargin - (IS_IPHONE_X?32+24:0);
    
    return foodTableHeight;
}

- (const CGFloat)addFoodDescriptionContainerWidthWithSuperviewSize:(CGSize)superviewSize {
    return superviewSize.width - DEFAULT_MARGIN * 2.0;
}

- (void)setupChooseFoodItemsPhase {
    self.foodTable = [[UITableView alloc] init];
    self.foodTable.delegate = self;
    self.foodTable.dataSource = self;
    self.foodTable.layer.cornerRadius = 5.0;
    self.foodTable.translatesAutoresizingMaskIntoConstraints = NO;;
    self.foodTable.hidden = YES;
    self.foodTable.alpha = 0.0;
    
    [StyleManager styleTable:self.foodTable];
    self.foodTable.separatorColor = [UIColor clearColor];
    
    [self.view addSubview:self.foodTable];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodTable
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.mealTypeTopButton
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodTable
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodTable
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-DEFAULT_MARGIN]];
    
    self.foodTableHeightConstraint = [NSLayoutConstraint constraintWithItem:self.foodTable
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:[self foodTableHeightWithSuperviewSize:self.view.frame.size]];
    [self.foodTable addConstraint:self.foodTableHeightConstraint];
    
    if (self.shouldShowFoodDescriptionContainer) {
        // add food description container
        
        self.addFoodDescriptionContainer = [[UIView alloc] init];
        self.addFoodDescriptionContainer.backgroundColor = [UIColor clearColor];
        self.addFoodDescriptionContainer.userInteractionEnabled = NO;
        self.addFoodDescriptionContainer.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.foodTable addSubview:self.addFoodDescriptionContainer];
        
        [self.foodTable addConstraint:[NSLayoutConstraint constraintWithItem:self.addFoodDescriptionContainer
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.foodTable
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1.0
                                                                    constant:0.0]];
        [self.foodTable addConstraint:[NSLayoutConstraint constraintWithItem:self.addFoodDescriptionContainer
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.foodTable
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0]];
        
        self.addFoodDescriptionContainerWidthConstraint = [NSLayoutConstraint constraintWithItem:self.addFoodDescriptionContainer
                                                                                       attribute:NSLayoutAttributeWidth
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:nil
                                                                                       attribute:NSLayoutAttributeWidth
                                                                                      multiplier:1.0
                                                                                        constant:[self addFoodDescriptionContainerWidthWithSuperviewSize:self.view.frame.size]];
        [self.addFoodDescriptionContainer addConstraint:self.addFoodDescriptionContainerWidthConstraint];
        
        self.addFoodDescriptionContainerHeightConstraint = [NSLayoutConstraint constraintWithItem:self.addFoodDescriptionContainer
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:nil
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                       multiplier:1.0
                                                                                         constant:[self foodTableHeightWithSuperviewSize:self.view.frame.size]];
        [self.addFoodDescriptionContainer addConstraint:self.addFoodDescriptionContainerHeightConstraint];
        
        // add description food icon
        
        UIImageView *addFoodDescriptionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addFoodDescriptionIcon"]];
        addFoodDescriptionImage.image = [addFoodDescriptionImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        addFoodDescriptionImage.tintColor = [UIColor buttonColor];
        addFoodDescriptionImage.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.addFoodDescriptionContainer addSubview:addFoodDescriptionImage];
        
        
        const CGFloat addFoodDescriptionImageHeight = 65.0;
        [self.addFoodDescriptionContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.addFoodDescriptionContainer
                                                                                     attribute:NSLayoutAttributeCenterY
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:addFoodDescriptionImage
                                                                                     attribute:NSLayoutAttributeCenterY
                                                                                    multiplier:1.0
                                                                                      constant:-DEFAULT_TABLE_CELL_HEIGHT / 2.0 + addFoodDescriptionImageHeight / 2.0]];
        [self.addFoodDescriptionContainer addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionImage
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.addFoodDescriptionContainer
                                                                                     attribute:NSLayoutAttributeCenterX
                                                                                    multiplier:1.0
                                                                                      constant:DEFAULT_MARGIN]];
        [addFoodDescriptionImage addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:addFoodDescriptionImageHeight]];
        [addFoodDescriptionImage addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:addFoodDescriptionImage
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0.0]];
        // add food description label
        
        UILabel *addFoodDescriptionLabel = [[UILabel alloc] init];
        addFoodDescriptionLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_SCORE_DESCRIPTION];
        addFoodDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        addFoodDescriptionLabel.numberOfLines = 0;
        addFoodDescriptionLabel.font = [UIFont systemFontOfSize:17.0];
        addFoodDescriptionLabel.textColor = [UIColor buttonColor];
        addFoodDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        // the food table's width is not available here so using self.view's width instead
        //addFoodDescriptionLabel.preferredMaxLayoutWidth = self.view.frame.size.width - DEFAULT_MARGIN * 10.0;
        addFoodDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.addFoodDescriptionContainer addSubview:addFoodDescriptionLabel];
        
        [self.addFoodDescriptionContainer addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionLabel
                                                                                     attribute:NSLayoutAttributeTop
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:addFoodDescriptionImage
                                                                                     attribute:NSLayoutAttributeBottom
                                                                                    multiplier:1.0
                                                                                      constant:DEFAULT_MARGIN]];
        [self.addFoodDescriptionContainer addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionLabel
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.addFoodDescriptionContainer
                                                                                     attribute:NSLayoutAttributeLeading
                                                                                    multiplier:1.0
                                                                                      constant:DEFAULT_MARGIN]];
        [self.addFoodDescriptionContainer addConstraint:[NSLayoutConstraint constraintWithItem:addFoodDescriptionLabel
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                     relatedBy:NSLayoutRelationEqual
                                                                                        toItem:self.addFoodDescriptionContainer
                                                                                     attribute:NSLayoutAttributeTrailing
                                                                                    multiplier:1.0
                                                                                      constant:-DEFAULT_MARGIN]];
    }
    
    [self setupCaloriesAndScoreContainer];
}

- (void)setupCaloriesAndScoreContainer {
    //food rating container
    
    self.foodRatingContainer = [[UILabel alloc] init];
    //self.foodRatingContainer.backgroundColor = [UIColor whiteColor];
    self.foodRatingContainer.backgroundColor = [UIColor grayBackgroundColor];
    
    self.foodRatingContainer.layer.cornerRadius = 5.0;
    self.foodRatingContainer.clipsToBounds = YES;
    self.foodRatingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.foodRatingContainer.hidden = YES;
    self.foodRatingContainer.alpha = 0.0;
    
    [self.view addSubview:self.foodRatingContainer];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingContainer
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.foodTable
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingContainer
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:DEFAULT_MARGIN]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingContainer
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:-DEFAULT_MARGIN]];
    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:FOOD_RATING_CONTAINER_HEIGHT]];
    [self.view layoutIfNeeded];
    
    
//    // calories container
//    
//    self.caloriesContainer = [[UIView alloc] init];
//    self.caloriesContainer.backgroundColor = [UIColor whiteColor];
//    self.caloriesContainer.layer.cornerRadius = 5.0;
//    self.caloriesContainer.translatesAutoresizingMaskIntoConstraints = NO;
//    self.caloriesContainer.hidden = YES;
//    self.caloriesContainer.alpha = 0.0;
//    
//    [self.view addSubview:self.caloriesContainer];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesContainer
//                                                          attribute:NSLayoutAttributeTop
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.foodRatingContainer
//                                                          attribute:NSLayoutAttributeBottom
//                                                         multiplier:1.0
//                                                           constant:DEFAULT_MARGIN]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesContainer
//                                                          attribute:NSLayoutAttributeLeading
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeLeading
//                                                         multiplier:1.0
//                                                           constant:DEFAULT_MARGIN]];
//    [self.caloriesContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesContainer
//                                                                       attribute:NSLayoutAttributeHeight
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:nil
//                                                                       attribute:NSLayoutAttributeHeight
//                                                                      multiplier:1.0
//                                                                        constant:CALS_CONTAINER_HEIGHT]];
    
    
    
//    // score container
//    
//    self.scoreContainer = [[UIView alloc] init];
//    self.scoreContainer.backgroundColor = [UIColor whiteColor];
//    self.scoreContainer.layer.cornerRadius = 5.0;
//    self.scoreContainer.translatesAutoresizingMaskIntoConstraints = NO;
//    self.scoreContainer.hidden = YES;
//    self.scoreContainer.alpha = 0.0;
//    
//    [self.view addSubview:self.scoreContainer];
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreContainer
//                                                          attribute:NSLayoutAttributeTop
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.foodRatingContainer
//                                                          attribute:NSLayoutAttributeBottom
//                                                         multiplier:1.0
//                                                           constant:DEFAULT_MARGIN]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreContainer
//                                                          attribute:NSLayoutAttributeTrailing
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.view
//                                                          attribute:NSLayoutAttributeTrailing
//                                                         multiplier:1.0
//                                                           constant:-DEFAULT_MARGIN]];
//    [self.scoreContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreContainer
//                                                                       attribute:NSLayoutAttributeHeight
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:nil
//                                                                       attribute:NSLayoutAttributeHeight
//                                                                      multiplier:1.0
//                                                                        constant:DEFAULT_TABLE_CELL_HEIGHT]];
    
    
    
    
//    // common constrinats between the calories and score containers
//    
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesContainer
//                                                          attribute:NSLayoutAttributeTrailing
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.scoreContainer
//                                                          attribute:NSLayoutAttributeLeading
//                                                         multiplier:1.0
//                                                           constant:-DEFAULT_MARGIN]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesContainer
//                                                          attribute:NSLayoutAttributeWidth
//                                                          relatedBy:NSLayoutRelationEqual
//                                                             toItem:self.scoreContainer
//                                                          attribute:NSLayoutAttributeWidth
//                                                         multiplier:1.0
//                                                           constant:0.0]];
    
    
    // food rating label
    self.foodRatingLabel = [[UILabel alloc] init];
    if(self.isRecentMeal){
    self.foodRatingLabel.attributedText = [self mealScoreRatingAttributedString];
    }else{
    self.foodRatingLabel.text = [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_MEAL_SCORE_ADD_FOOD_FOR_SCORING];
    }
//    self.foodRatingLabel.text = self.isRecentMeal ? [MealScore getScoreRatingWithScore:self.meal.score] : MSG_ADD_MEAL_RECORD_MEAL_SCORE_ADD_FOOD_FOR_SCORING;
    self.foodRatingLabel.font = [UIFont systemFontOfSize:18.0];
    self.foodRatingLabel.textAlignment = NSTextAlignmentCenter;
    //self.foodRatingLabel.backgroundColor = [UIColor orangeColor];
    self.foodRatingLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.foodRatingContainer addSubview:self.foodRatingLabel];

    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingLabel
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:DEFAULT_MARGIN]];
    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingLabel
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:-DEFAULT_MARGIN]];
    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingLabel
                                                                         attribute:NSLayoutAttributeTop
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:0]];
    
    //score progress bar
    self.scoreProgressView = [[UIProgressView alloc] init];
    if(self.isRecentMeal){
        self.scoreProgressView.progress = (float)self.meal.score/(float)100.0;
    }else{
        self.scoreProgressView.progress = 0.0;
    }
    self.scoreProgressView.tintColor = [self scoreProgressBarColor];
    self.scoreProgressView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.foodRatingContainer addSubview:self.scoreProgressView];
    

    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressView
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:DEFAULT_MARGIN]];
    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressView
                                                                         attribute:NSLayoutAttributeTrailing
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeTrailing
                                                                        multiplier:1.0
                                                                          constant:-DEFAULT_MARGIN]];
    
    
    [self.scoreProgressView addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:SCORE_PROGRESSBAR_HEIGHT]];
    
    
    [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.foodRatingLabel
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.scoreProgressView
                                                                         attribute:NSLayoutAttributeTop
                                                                        multiplier:1.0
                                                                          constant:-3]];
    
    
 //score progress min and max
    self.scoreProgressMin = [[UILabel alloc] init];
    self.scoreProgressMax = [[UILabel alloc] init];
    self.scoreProgressMin.text = @"0";
    self.scoreProgressMax.text = @"100";
    self.scoreProgressMin.textColor = [UIColor notGoodMealColor];
    self.scoreProgressMax.textColor = [UIColor excellentMealColor];
    self.scoreProgressMin.font = [UIFont systemFontOfSize:10.0];
    self.scoreProgressMax.font = [UIFont systemFontOfSize:10.0];
    self.scoreProgressMin.textAlignment = NSTextAlignmentLeft;
    self.scoreProgressMax.textAlignment = NSTextAlignmentRight;
    self.scoreProgressMin.translatesAutoresizingMaskIntoConstraints = NO;
    self.scoreProgressMax.translatesAutoresizingMaskIntoConstraints = NO;
    [self.foodRatingContainer addSubview:self.scoreProgressMin];
    [self.foodRatingContainer addSubview:self.scoreProgressMax];
    
   //min label
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMin
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.scoreProgressView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:2]];
    
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMin
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.foodRatingContainer
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:0]];
 
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMin
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0]];

        // max label
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMax
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.scoreProgressView
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:2]];
    
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMax
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.foodRatingContainer
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:0]];
    
    
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMax
                                                                         attribute:NSLayoutAttributeBottom
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.foodRatingContainer
                                                                         attribute:NSLayoutAttributeBottom
                                                                        multiplier:1.0
                                                                          constant:0]];
    
        // common constrinats between the min and max labels
    
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMin
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.scoreProgressMax
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN]];
    
        [self.foodRatingContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreProgressMin
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.scoreProgressMax
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0.0]];

 
//    // calories label
//    
//    self.caloriesLabel = [[UILabel alloc] init];
//    self.caloriesLabel.text = [NSString stringWithFormat:MSG_ADD_MEAL_RECORD_CALS, self.isRecentMeal ? self.meal.cals : 0.0];
//    self.caloriesLabel.font = [UIFont systemFontOfSize:18.0];
//    self.caloriesLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self.caloriesContainer addSubview:self.caloriesLabel];
//    
//    [self.caloriesContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesLabel
//                                                                       attribute:NSLayoutAttributeCenterX
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:self.caloriesContainer
//                                                                       attribute:NSLayoutAttributeCenterX
//                                                                      multiplier:1.0
//                                                                        constant:0.0]];
//    [self.caloriesContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.caloriesLabel
//                                                                       attribute:NSLayoutAttributeCenterY
//                                                                       relatedBy:NSLayoutRelationEqual
//                                                                          toItem:self.caloriesContainer
//                                                                       attribute:NSLayoutAttributeCenterY
//                                                                      multiplier:1.0
//                                                                        constant:0.0]];
    
    
    
    
//    // score label
//    
//    self.scoreLabel = [[UILabel alloc] init];
//    self.scoreLabel.attributedText = [self mealScoreValueAttributedString];
//    self.scoreLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    [self.scoreContainer addSubview:self.scoreLabel];
//    
//    [self.scoreContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreLabel
//                                                                    attribute:NSLayoutAttributeCenterX
//                                                                    relatedBy:NSLayoutRelationEqual
//                                                                       toItem:self.scoreContainer
//                                                                    attribute:NSLayoutAttributeCenterX
//                                                                   multiplier:1.0
//                                                                     constant:0.0]];
//    [self.scoreContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.scoreLabel
//                                                                    attribute:NSLayoutAttributeCenterY
//                                                                    relatedBy:NSLayoutRelationEqual
//                                                                       toItem:self.scoreContainer
//                                                                    attribute:NSLayoutAttributeCenterY
//                                                                   multiplier:1.0
//                                                                     constant:0.0]];
}

#pragma mark - Phase 3 - See Nutrition Facts Methods

- (void)setupNutritionFactsAndModifyDateNTimeButton:(BOOL)animated
{
    if (!self.nutritionFactsButton) {
        self.nutritionFactsButton = [[UIButton alloc] init];
        self.nutritionFactsButton.translatesAutoresizingMaskIntoConstraints = NO;
        
//        [self.nutritionFactsButton setTitle:(IS_IPHONE_4_OR_LESS || IS_IPHONE_5) ? MSG_ADD_MEAL_RECORD_BUTTON_SEE_NUTRITION_FACTS_SHORT : MSG_ADD_MEAL_RECORD_BUTTON_SEE_NUTRITION_FACTS_LONG forState:UIControlStateNormal]; //See Nutrition Facts
        [self.nutritionFactsButton setTitle:MSG_ADD_MEAL_RECORD_BUTTON_SEE_NUTRITION_FACTS_LONG forState:UIControlStateNormal]; //See Nutrition Facts
        [self.nutritionFactsButton addTarget:self
                                      action:@selector(didTapNutritionFactsButton:)
                            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        [StyleManager styleButton:self.nutritionFactsButton];
        
        if (animated) {
            self.nutritionFactsButton.hidden = YES;
            self.nutritionFactsButton.alpha = 0.0;
        }
        
        [self.view addSubview:self.nutritionFactsButton];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:DEFAULT_MARGIN]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN]];
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
//                                                              attribute:NSLayoutAttributeBottom
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:self.modifyDateAndTimeButton
//                                                              attribute:NSLayoutAttributeTop
//                                                             multiplier:1.0
//                                                               constant:-DEFAULT_MARGIN]];
        
        [self.nutritionFactsButton addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
                                                                              attribute:NSLayoutAttributeHeight
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:nil
                                                                              attribute:NSLayoutAttributeHeight
                                                                             multiplier:1.0
                                                                               constant:NUTRITION_FACTS_BUTTON_HEIGHT]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
                                                                                            attribute:NSLayoutAttributeTop
                                                                                            relatedBy:NSLayoutRelationEqual
                                                                                               toItem:self.foodRatingContainer
                                                                                            attribute:NSLayoutAttributeBottom
                                                                                           multiplier:1.0
                                                                                             constant:DEFAULT_MARGIN]];
        
        
        //modify date & time
        
        self.modifyDateAndTimeButton = [[UIButton alloc] init];
        self.modifyDateAndTimeButton.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.modifyDateAndTimeButton setTitle:(IS_IPHONE_4_OR_LESS || IS_IPHONE_5) ? MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_SHORT : MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_LONG forState:UIControlStateNormal];
        [self.modifyDateAndTimeButton setTitle: [LocalizationManager getStringFromStrId:MSG_ADD_MEAL_RECORD_BUTTON_MODIFY_TIME_LONG] forState:UIControlStateNormal];
        
        [StyleManager styleButton:self.modifyDateAndTimeButton];
        
        [self.modifyDateAndTimeButton addTarget:self
                                      action:@selector(didTapModifyDateNTimeButton:)
                            forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
        
        if (animated) {
            self.modifyDateAndTimeButton.hidden = YES;
            self.modifyDateAndTimeButton.alpha = 0.0;
        }
        
        [self.view addSubview:self.modifyDateAndTimeButton];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.modifyDateAndTimeButton
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeBottom
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN - (IS_IPHONE_X?32:0)]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.modifyDateAndTimeButton
                                                              attribute:NSLayoutAttributeLeading
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeLeading
                                                             multiplier:1.0
                                                               constant:DEFAULT_MARGIN]];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.modifyDateAndTimeButton
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-DEFAULT_MARGIN]];
        
        [self.modifyDateAndTimeButton addConstraint:[NSLayoutConstraint constraintWithItem:self.modifyDateAndTimeButton
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                 relatedBy:NSLayoutRelationEqual
                                                                                    toItem:nil
                                                                                 attribute:NSLayoutAttributeHeight
                                                                                multiplier:1.0
                                                                                  constant:MODIFY_DATE_BUTTON_HEIGHT]];
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
//                                                              attribute:NSLayoutAttributeTrailing
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:self.modifyDateAndTimeButton
//                                                              attribute:NSLayoutAttributeLeading
//                                                             multiplier:1.0
//                                                               constant:-DEFAULT_MARGIN]];
        
//        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.nutritionFactsButton
//                                                              attribute:NSLayoutAttributeWidth
//                                                              relatedBy:NSLayoutRelationEqual
//                                                                 toItem:self.modifyDateAndTimeButton
//                                                              attribute:NSLayoutAttributeWidth
//                                                             multiplier:1.0
//                                                               constant:0.0]];
        
        if (animated) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.nutritionFactsButton.hidden = NO;
                self.modifyDateAndTimeButton.hidden = NO;
                [UIView animateWithDuration:1.45 animations:^{
                    self.nutritionFactsButton.alpha = 1.0;
                    self.modifyDateAndTimeButton.alpha = 1.0;
                }];
            });
        }
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"searchFoodSegue"]) {
        UINavigationController *destVC = [segue destinationViewController];
        SearchFoodController *searchController = destVC.viewControllers[0];
        searchController.delegate = self;
    }
    else if ([segueId isEqualToString:@"quickEstimateSegue"])
    {
        UINavigationController *destVC = [segue destinationViewController];
        QuickEstimateController *qeController = destVC.viewControllers[0];
        
        NSArray *data = @[[self convertMealToQuickEstimateData:self.meal]];
        [qeController loadViewWithData:data
                           andMealType:self.meal.type
                       userEditAllowed:NO];
    }
    else if([segueId isEqualToString:@"NutritionFactsGaugeSegue"])
    {
        NutritionFactsGaugeController *destVC = [segue destinationViewController];
        NSArray *data = @[[self convertMealToQuickEstimateData:self.meal]];
        float fibre = self.meal.fibre;
        float sugar = self.meal.sugar;
        [destVC loadViewWithData:data
                           andMealType:self.meal.type
                       userEditAllowed:NO];
        [destVC loadViewWithFibre:fibre andSugar:sugar];

    }
    
    else if ([segueId isEqualToString:@"foodSummarySegue"])
    {
        NSInteger index = ((NSIndexPath *)sender).row;
        
        if (index >= 0) {
            FoodItem *food = self.meal.foods[index];
            
            FoodSummaryViewController *destVC = [segue destinationViewController];
            destVC.index = index;
            destVC.delegate = self;
            destVC.foodItems = @[food];
            destVC.imageData = food.imageData;
        }
    }
    else if ([segueId isEqualToString:@"showMealPhotoSegue"]) {
        MealPhotoViewController *destVC = [segue destinationViewController];
        [destVC loadImage:sender];
    }
}

-(IBAction)unwindToSegueMealRecord:(UIStoryboardSegue *)unwindSegue{
    
}


@end
