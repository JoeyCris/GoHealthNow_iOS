//
//  FoodSummaryViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-28.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "FoodSummaryViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "ServingSizeView.h"
#import "UIView+Extensions.h"

@interface FoodSummaryViewController() <UIPickerViewDataSource, UIPickerViewDelegate, SlideInPopupDelegate>

@property (nonatomic) float currentSelectedServingSize;

@property (nonatomic) NSUInteger servingSizeUnit;
@property (nonatomic) ServingSizeView *servingSizeView;
@property (nonatomic) UIPickerView *servingSizeUnitPicker;

@property (nonatomic) UIPickerView *topPredictionsPicker;
@property (nonatomic) long long selectedFoodIdx;

@end

@implementation FoodSummaryViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.selectedFoodIdx = 0;
    
    [StyleManager styleTable:self.tableView];
    [self.tableView setSeparatorColor:[UIColor grayColor]];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    if (![self.foodItems[self.selectedFoodIdx].servingSizeOptions count]) {
        // no serving size options available
        UIAlertController *noServingSizeAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Unable to Load"]
                                                                                    message:[LocalizationManager getStringFromStrId:@"This food item is missing serving size information."]
                                                                             preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [noServingSizeAlert addAction:okAction];
        
        [self presentViewController:noServingSizeAlert animated:YES completion:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    FoodItem *food = self.foodItems[self.selectedFoodIdx];
    
    if (food.servingSize != nil)
        self.servingSizeUnit = [food.servingSizeOptions indexOfObject:food.servingSize];
    else {
        self.servingSizeUnit = 0;
        food.servingSize = food.servingSizeOptions.firstObject;
    }
    if (food.portionSize >= 0)
        self.currentSelectedServingSize = food.portionSize;
    else {
        self.currentSelectedServingSize = 1.0f;
        food.portionSize = 1.0;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    FoodItem *food = self.foodItems[self.selectedFoodIdx];
    
    if (food.portionSize == 0.0) {
        food.portionSize = 1.0f;
    }
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if (pickerView == self.servingSizeUnitPicker) {
        return [self.foodItems[self.selectedFoodIdx].servingSizeOptions count];
    }
    else if (pickerView == self.topPredictionsPicker) {
        return [self.foodItems count];
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = nil;
    
    if (pickerView == self.servingSizeUnitPicker) {
        title = ((ServingSize *)self.foodItems[self.selectedFoodIdx].servingSizeOptions[row]).name;
    }
    else if (pickerView == self.topPredictionsPicker) {
        title = self.foodItems[row].name;
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - Methods

- (BOOL)isFoodItemBeingAdded {
    return self.index == FSUMM_INDEX_NOT_SET;
}


- (NSUInteger)servingSizeWithNumber:(float)number {
    if (number == 0) {
        return 0;
    }
    else if (number == 0.25) {
        return 1;
    }
    else if (number == 0.5) {
        return 2;
    }
    else if (number == 0.75) {
        return 3;
    }
    else {
        return 0;
    }
}

- (NSDictionary *)servingSizeInfoAtRow:(NSUInteger)row {
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:@{@"title": [NSNull null], @"value": @0.0}];
    
    switch (row) {
        case 0:
            info[@"title"] = @"0";
            info[@"value"] = @0.0;
            break;
        case 1:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00bc];
            info[@"value"] = @0.25;
            break;
        case 2:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00bd];
            info[@"value"] = @0.5;
            break;
        case 3:
            info[@"title"] = [NSString stringWithFormat:@"%C", 0x00be];
            info[@"value"] = @0.75;
            break;
    }
    
    return info;
}

- (NSString *)topPredictionsTitle {
    NSInteger foodCount = [self.foodItems count];

    if (foodCount == 1) {
        return [LocalizationManager getStringFromStrId:FSUMM_FROM_FOOD_RECOGNITION_TITLE];
    }
    else {
        return [NSString stringWithFormat:[LocalizationManager getStringFromStrId:FSUMM_PREDICTIONS_TITLE], (unsigned long)foodCount];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self isFoodItemBeingAdded])
        return 2;
    else
        return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            return 7;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    
    switch (section)
    {
        case 0:
            sectionName = self.foodItems[self.selectedFoodIdx].name;
            break;
        case 1:
            sectionName = [LocalizationManager getStringFromStrId:@"Nutrition Facts"];
            if (self.foodItems.firstObject.creationType == FoodItemCreationTypeQuickInput) {
                sectionName = [LocalizationManager getStringFromStrId:@"Estimated Nutrition Values"];
            }
            break;
        default:
            sectionName = nil;
            break;
    }
    
    return sectionName;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerView = nil;
    NSInteger numberOfLines = 2;
    NSLineBreakMode lineBreakMode = NSLineBreakByWordWrapping;
    
    if (section == 0 && (self.foodItems.firstObject.creationType == FoodItemCreationTypeQuickInput)){
        headerView = [tableView dequeueReusableCellWithIdentifier:@"foodinfoSectionHeaderWithImg"];
        numberOfLines = 1;
        lineBreakMode = NSLineBreakByTruncatingMiddle;
    } else if (section == 0 && self.foodItems.firstObject.creationType == FoodItemCreationTypeBarcode){
        headerView = [tableView dequeueReusableCellWithIdentifier:@"foodinfoSectionHeaderWithImgBarcode"];
        numberOfLines = 1;
        lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    else {
        headerView = [tableView dequeueReusableCellWithIdentifier:@"foodinfoSectionHeader"];
    }
    
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:FSUMM_SECTION_HEADER_TAG];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    if (section != 0  && self.foodItems.firstObject.creationType == FoodItemCreationTypeBarcode)  {
      
        NSMutableAttributedString *tempText = [[NSMutableAttributedString alloc] initWithString:[LocalizationManager getStringFromStrId:@"Nutrition Facts (Powered by FatSecret)"]];
        [tempText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]} range:NSMakeRange(0, 15)];       
        [tempText setAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16], NSForegroundColorAttributeName:[UIColor colorWithRed:15.0f/255.0f green:121.0f/255.0f blue:191.0f/255.0f alpha:1]} range:NSMakeRange(17, 20)];
        
        [headerLabel setAttributedText:tempText];
        
        headerLabel.userInteractionEnabled = YES;
        [headerLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToFatSecret)]];

    }
    
    if (section == 0) {
        headerLabel.numberOfLines = numberOfLines;
        headerLabel.lineBreakMode = lineBreakMode;
        headerLabel.minimumScaleFactor = 0.7;
    }
    
    const CGFloat headerImageHeight = FSUMM_0_SECTION_HEADER_HEIGHT - FSUMM_SECTION_HEADER_IMG_TOP_MARGIN * 2.0;
    
    UIImageView *headerImage = (UIImageView *)[headerView viewWithTag:FSUMM_SECTION_HEADER_IMG_TAG];
    headerImage.image = self.imageData.image;
    
    if (self.foodItems.firstObject.creationType == FoodItemCreationTypeBarcode){
        headerImage.image = [UIImage imageNamed:@"barcodeIcon"];
        UIImage* imageForRendering = [headerImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        headerImage.image = imageForRendering;
        headerImage.tintColor = [UIColor blackColor];
        
        headerLabel.center = CGPointMake(headerLabel.frame.origin.x, headerLabel.frame.origin.y + 10);
    }
    
    headerImage.contentMode = UIViewContentModeScaleAspectFill;
    headerImage.layer.cornerRadius = headerImageHeight / 2.0;
    headerImage.layer.masksToBounds = YES;
    headerImage.layer.borderColor = [UIColor colorWithWhite:0.85 alpha:1.0].CGColor;
    headerImage.layer.borderWidth = 0.5;
    
    NSString *topPredictionsButtonTitle = [self topPredictionsTitle];
    
    UIButton *topPredictionsButton = (UIButton *)[headerView viewWithTag:FSUMM_SECTION_HEADER_TOP_PREDICTIONS_BTN_TAG];
    [topPredictionsButton setTitle:topPredictionsButtonTitle forState:UIControlStateNormal];
    [topPredictionsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    topPredictionsButton.titleLabel.font = [UIFont systemFontOfSize:14.0];
    topPredictionsButton.backgroundColor = [UIColor clearColor];
    
    [topPredictionsButton addTarget:self action:@selector(didTapFoodRecognitionInfoButton) forControlEvents:UIControlEventTouchUpInside];
    
    /*
    // only add the target/action and the upArrowIcon if there is more than 1 prediction available
    if (![topPredictionsButtonTitle isEqualToString:FSUMM_FROM_FOOD_RECOGNITION_TITLE]) {
        [topPredictionsButton setImage:[UIImage imageNamed:@"upArrowIcon"] forState:UIControlStateNormal];
        [topPredictionsButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 4.0, 0.0, 0.0)];
        topPredictionsButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [topPredictionsButton addTarget:self
                                 action:@selector(didTapTopPredictionsButton:)
                       forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    }
    */
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            switch (self.foodItems.firstObject.creationType) {
                case FoodItemCreationTypeQuickInput:
                    return FSUMM_0_SECTION_HEADER_HEIGHT;
                case FoodItemCreationTypeBarcode:
                    return FSUMM_0_SECTION_HEADER_HEIGHT;
                case FoodItemCreationTypeSearch:
                    return FSUMM_SECTION_HEADER_HEIGHT;
                default:
                    return FSUMM_SECTION_HEADER_HEIGHT;
            }
        default:
            return FSUMM_SECTION_HEADER_HEIGHT;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // reduce the default footer height when using a grouped table to zero (using 0.0 doesn't work)
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"foodinfoIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"foodinfoIdentifier"];
    }
    
    [StyleManager stylelabel:cell.textLabel];
    [StyleManager stylelabel:cell.detailTextLabel];
    
    cell.detailTextLabel.textColor = [UIColor blueTextColor];
    cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.detailTextLabel.numberOfLines = 0;
    
    NSString *textString = nil;
    NSString *detailString = nil;
    
    FoodItem *food = self.foodItems[self.selectedFoodIdx];
    NSInteger servingSizeOptionCount = [food.servingSizeOptions count];
    
    switch (indexPath.section) {
        case 0:{
            if (indexPath.row == 0) {
                textString = [LocalizationManager getStringFromStrId:FSUMM_SERVING_SIZE_TITLE];
                if (food.creationType == FoodItemCreationTypeQuickInput) {
                    textString = [LocalizationManager getStringFromStrId:FSUMM_YOUR_SELECTION_TITLE];
                }
                
                if (servingSizeOptionCount > self.servingSizeUnit) {
                    ServingSize *servingSize = food.servingSizeOptions[self.servingSizeUnit];
                    detailString = servingSize.name;
                }
                else {
                    detailString = [LocalizationManager getStringFromStrId:@"Unknown"];
                }
            }
            else if (indexPath.row == 1) {
                textString = [LocalizationManager getStringFromStrId:@"Number of Servings"];
                NSString *secondPart = [self servingSizeInfoAtRow:[self servingSizeWithNumber:self.currentSelectedServingSize-floor(self.currentSelectedServingSize)]][@"title"];
                if ([secondPart isEqualToString:@"0"]) {
                    detailString = [NSString stringWithFormat:@"%d", (int)self.currentSelectedServingSize/1];
                }
                else {
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%d and %@"], (int)self.currentSelectedServingSize/1, secondPart];
                }
                
                if (servingSizeOptionCount > self.servingSizeUnit) {
                    food.servingSize = food.servingSizeOptions[self.servingSizeUnit];
                }
            }
            else {
                textString = [LocalizationManager getStringFromStrId:@"Total"];
            }
        }
            break;
        case 1:{
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            float carbs = food.carbs * self.currentSelectedServingSize;
            float fiber = food.fibre * self.currentSelectedServingSize;
            float netCarbs = carbs - fiber;
            float protein = food.protein * self.currentSelectedServingSize;
            float sugar = food.sugar * self.currentSelectedServingSize;
            float fat = food.fat * self.currentSelectedServingSize;
            
            float calories = food.calories * self.currentSelectedServingSize; //fat * 9 + protein * 4 + carbs * 4;
            
            switch (indexPath.row) {
                case 0:{
                    textString = [LocalizationManager getStringFromStrId:@"Calories"];
                    detailString = [NSString stringWithFormat:@"%0.1f", calories];
                }
                    break;
                case 1:{
                    textString = [LocalizationManager getStringFromStrId:@"Total Carbs"];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], carbs];
                }
                    break;
                case 2:{
                    textString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@Fibre"], [@" " stringByPaddingToLength:4 withString:@" " startingAtIndex:0]];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], fiber];
                }
                    break;
                case 3:{
                    textString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@Sugar"], [@" " stringByPaddingToLength:4 withString:@" " startingAtIndex:0]];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], sugar];
                }
                    break;
                case 4:{
                    textString = [LocalizationManager getStringFromStrId:@"Net Carbs"];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], netCarbs];
                }
                    break;
                case 5:{
                    textString = [LocalizationManager getStringFromStrId:@"Protein"];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], protein];
                }
                    break;
                case 6:{
                    textString = [LocalizationManager getStringFromStrId:@"Fat"];
                    detailString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%0.1f g"], fat];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2:{
            textString = [LocalizationManager getStringFromStrId:@"Delete this food"];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.textColor = [UIColor redColor];
            detailString = @"";
        }
            break;
        default:{
            textString = @"";
            detailString = @"";
        }
            break;
    }
    
    cell.textLabel.text = textString;
    cell.detailTextLabel.text = detailString;
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1){
        return nil;
    }
    return indexPath;
}

#pragma mark - Table view delegate
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0){
        if (indexPath.row == 0){
            if(!self.servingSizeUnitPicker) {
                self.servingSizeUnitPicker = [[UIPickerView alloc] init];
                self.servingSizeUnitPicker.delegate = self;
                self.servingSizeUnitPicker.dataSource = self;
                self.servingSizeUnitPicker.tag = FSUMM_SERVING_SIZE_UNIT_PICKER_TAG;
            }
            
            [self.servingSizeUnitPicker reloadComponent:0];
            [self.servingSizeUnitPicker selectRow:self.servingSizeUnit inComponent:0 animated:NO];

            NSString *slideInPopupTitle = [LocalizationManager getStringFromStrId:FSUMM_SERVING_SIZE_TITLE];
            if (self.foodItems[self.selectedFoodIdx].creationType == FoodItemCreationTypeQuickInput) {
                slideInPopupTitle = [LocalizationManager getStringFromStrId:FSUMM_YOUR_SELECTION_TITLE];
            }
            
            [self.view.superview slideInPopupWithTitle:slideInPopupTitle
                                         withComponent:self.servingSizeUnitPicker
                                          withDelegate:self];
        }
        else if (indexPath.row == 1) {
            if (!self.servingSizeView) {
                self.servingSizeView = [[[NSBundle mainBundle] loadNibNamed:@"ServingSizeView" owner:self options:nil] objectAtIndex:0];
                self.servingSizeView.tag = FSUMM_SERVING_SIZE_VIEW_TAG;
            }
            
            self.servingSizeView.value = self.currentSelectedServingSize;

            [self.view.superview slideInPopupWithTitle:[LocalizationManager getStringFromStrId:@"Number of Servings"]
                                         withComponent:self.servingSizeView
                                          withDelegate:self];
        }
    }
    else if (indexPath.section == 2){
        if (indexPath.row == 0) {
            [self didTapDeleteButton:nil];
        }
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

#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([UIView slideInPopupComponentViewWithTag:FSUMM_SERVING_SIZE_VIEW_TAG withGestureRecognizer:gestureRecognizer]){
        if (self.servingSizeView.value == 0.0) {
            return;
        }
        self.currentSelectedServingSize = self.servingSizeView.value;
        self.foodItems[self.selectedFoodIdx].portionSize = self.currentSelectedServingSize;
        [self.tableView reloadData];
        
        if (self.currentSelectedServingSize == 0.0) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
        else {
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }
    else if ([UIView slideInPopupComponentViewWithTag:FSUMM_SERVING_SIZE_UNIT_PICKER_TAG withGestureRecognizer:gestureRecognizer]) {
        self.servingSizeUnit = [self.servingSizeUnitPicker selectedRowInComponent:0];
        self.foodItems[self.selectedFoodIdx].servingSize = (ServingSize *)self.foodItems[self.selectedFoodIdx].servingSizeOptions[self.servingSizeUnit];
        [self.tableView reloadData];
    }
    else if ([UIView slideInPopupComponentViewWithTag:FSUMM_TOP_PREDICTIONS_PICKER_TAG withGestureRecognizer:gestureRecognizer]) {
        self.selectedFoodIdx = [self.topPredictionsPicker selectedRowInComponent:0];
        self.servingSizeUnit = 0; // reset the serving size unit picker's default selection row
        [self.tableView reloadData];
    }
}

#pragma mark - Event Handlers

- (IBAction)didTapDoneButton:(id)sender {
    if ([self isFoodItemBeingAdded] && self.foodItems.firstObject.creationType != FoodItemCreationTypeBarcode) {
        self.foodItems[self.selectedFoodIdx].imageData = self.imageData;
        [self.delegate didAddFoodItem:self.foodItems[self.selectedFoodIdx] sender:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    
    }else if ([self isFoodItemBeingAdded] && self.foodItems.firstObject.creationType == FoodItemCreationTypeBarcode) {
        
        if (self.foodItems)
        
        self.foodItems[self.selectedFoodIdx].imageData = self.imageData;
        [self.delegate didAddFoodItem:self.foodItems[self.selectedFoodIdx] sender:self];
        
        [self dismissViewControllerAnimated:NO completion:nil];
        [self performSegueWithIdentifier:@"unwindToSegueMealRecord" sender:self];
    }
    else {
        [self.delegate didUpdateFoodItem:self.foodItems[self.selectedFoodIdx] atIndex:self.index sender:self];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapDeleteButton:(id)sender {
    [self.delegate didDeleteFoodItem:self.foodItems[self.selectedFoodIdx] atIndex:self.index sender:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didTapFoodRecognitionInfoButton {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_FSUMM_ABOUT_FOOD_RECOGNITION_TITLE] message:[LocalizationManager getStringFromStrId:MSG_FSUMM_ABOUT_FOOD_RECOGNITION_CONTENT] delegate:nil cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
    [alert show];
}

/*
- (void)didTapTopPredictionsButton:(id)sender {
    if(!self.topPredictionsPicker) {
        self.topPredictionsPicker = [[UIPickerView alloc] init];
        self.topPredictionsPicker.delegate = self;
        self.topPredictionsPicker.dataSource = self;
        self.topPredictionsPicker.tag = FSUMM_TOP_PREDICTIONS_PICKER_TAG;
    }
    
//    [self.servingSizeUnitPicker reloadComponent:0];
    [self.topPredictionsPicker selectRow:self.selectedFoodIdx inComponent:0 animated:NO];
    
    [self.view.superview slideInPopupWithTitle:[self topPredictionsTitle]
                                 withComponent:self.topPredictionsPicker
                                  withDelegate:self];
}
 */

-(void)goToFatSecret{
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://platform.fatsecret.com"]];
    
}

@end
