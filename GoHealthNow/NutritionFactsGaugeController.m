//
//  NutritionFactsGaugeController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-06-10.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "NutritionFactsGaugeController.h"
#import "StyleManager.h"
#import "UIView+Extensions.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "DialGaugeView.h"
#import "MealCalculator.h"

@interface NutritionFactsGaugeController ()<UINavigationBarDelegate,UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableview;

@property (nonatomic) NSArray *data;
@property (nonatomic) NSUInteger selectedDataIndex;
@property (nonatomic) MealType currMealType;
@property (nonatomic) BOOL userEditEnabled;
@property (nonatomic) NSArray *adjStatement;
@property (nonatomic) float fibre;
@property (nonatomic) float sugar;
@property (nonatomic) BOOL carbsExpanded;
@end

@implementation NutritionFactsGaugeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    
    self.navBar.delegate = self;
    self.carbsExpanded = false;
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *gaugeCellIdentifier=@"gaugeViewCell";
    static NSString *scoreCellIdentifier=@"ScoreCell";
    static NSString *carbsCellIdentifier=@"carbsGaugeViewCell";
    static NSString *additionalMessagesCellIdentifier=@"AdditionalMessagesCell";
    UITableViewCell *cell = nil;
    NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
    self.adjStatement = [selectedData valueForKey:@"Adjustment"];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:gaugeCellIdentifier forIndexPath:indexPath];
        DialGaugeView *gaugeView = (DialGaugeView *)[cell viewWithTag:1];
        [self setupGaugeView:gaugeView forNutritionKey:@"Calories"];
        gaugeView.leftLabelString = [LocalizationManager getStringFromStrId:@"Calories"];
        gaugeView.rightLabelString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f kcals"], gaugeView.value];
    }
    
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:carbsCellIdentifier forIndexPath:indexPath];
        DialGaugeView *gaugeView = (DialGaugeView *)[cell viewWithTag:1];
        [self setupGaugeView:gaugeView forNutritionKey:@"Carbs"];
        gaugeView.leftLabelString = [LocalizationManager getStringFromStrId:@"Carbs"];
        gaugeView.rightLabelString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f g"], gaugeView.value];
        UILabel *fibreLabel = (UILabel *)[cell viewWithTag:2];
        UILabel *sugarLabel = (UILabel *)[cell viewWithTag:3];
        fibreLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Fibre: %.1f g"], self.fibre];
        sugarLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Sugar: %.1f g"], self.sugar];

    }
    
    else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:gaugeCellIdentifier forIndexPath:indexPath];
        DialGaugeView *gaugeView = (DialGaugeView *)[cell viewWithTag:1];
        [self setupGaugeView:gaugeView forNutritionKey:@"Fats"];
        gaugeView.leftLabelString = [LocalizationManager getStringFromStrId:@"Fat"];
        gaugeView.rightLabelString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f g"], gaugeView.value];
    }
    
    else if (indexPath.row == 3){
        cell = [tableView dequeueReusableCellWithIdentifier:gaugeCellIdentifier forIndexPath:indexPath];
        DialGaugeView *gaugeView = (DialGaugeView *)[cell viewWithTag:1];
        [self setupGaugeView:gaugeView forNutritionKey:@"Protein"];
        gaugeView.leftLabelString = [LocalizationManager getStringFromStrId:@"Protein"];
        gaugeView.rightLabelString = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f g"], gaugeView.value];
    }

    else if (indexPath.row == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:additionalMessagesCellIdentifier forIndexPath:indexPath];
        UILabel *messageLabel = (UILabel *)[cell viewWithTag:1];
        if (self.adjStatement != nil && [self.adjStatement count]>=4) {
            messageLabel.text = [self.adjStatement[3] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            messageLabel.textColor = [UIColor GGRedColor];
        }
    }
    
    else if (indexPath.row == 5){
        cell = [tableView dequeueReusableCellWithIdentifier:additionalMessagesCellIdentifier forIndexPath:indexPath];
        UILabel *messageLabel = (UILabel *)[cell viewWithTag:1];
        if (self.adjStatement != nil && [self.adjStatement count]>=3) {
            messageLabel.text = [self.adjStatement[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            messageLabel.textColor = [[self.adjStatement[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
        }
    }
    
    else if (indexPath.row == 6){
        cell = [tableView dequeueReusableCellWithIdentifier:additionalMessagesCellIdentifier forIndexPath:indexPath];
        UILabel *messageLabel = (UILabel *)[cell viewWithTag:1];
        if (self.adjStatement != nil && [self.adjStatement count]>=3) {
            messageLabel.text = [self.adjStatement[1] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            messageLabel.textColor = [[self.adjStatement[1] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
        }
    }
    
    else if (indexPath.row == 7){
        cell = [tableView dequeueReusableCellWithIdentifier:additionalMessagesCellIdentifier forIndexPath:indexPath];
        UILabel *messageLabel = (UILabel *)[cell viewWithTag:1];
        if (self.adjStatement != nil && [self.adjStatement count]>=3) {
            messageLabel.text = [self.adjStatement[2] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            messageLabel.textColor = [[self.adjStatement[2] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
        }
    }
    
    else if (indexPath.row == 8){
        cell = [tableView dequeueReusableCellWithIdentifier:scoreCellIdentifier forIndexPath:indexPath];
        UILabel *scoreLabel = (UILabel *)[cell viewWithTag:1];
        UIProgressView *scoreProgress = (UIProgressView *)[cell viewWithTag:2];
        
        NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
        float score = [[selectedData valueForKey:@"Score"] floatValue];
        scoreProgress.progress = (float)score/(float)100.0;
        
        if (score >= 80.0) {
            scoreLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Score: %.0f, Excellent"], score];
            scoreLabel.textColor = [UIColor excellentMealColor];
            scoreProgress.tintColor  = [UIColor excellentMealColor];
        }
        else if (score >= 60.0 && score < 80) {
            scoreLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Score: %.0f, Fair"], score];
            scoreLabel.textColor = [UIColor goodMealColor];
            scoreProgress.tintColor  = [UIColor goodMealColor];
        }
        else { // score<60
            scoreLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Score: %.0f, Needs Improvement"], score];
            scoreLabel.textColor = [UIColor notGoodMealColor];
            scoreProgress.tintColor  = [UIColor notGoodMealColor];
        }

    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerText = [LocalizationManager getStringFromStrId:@"Notice: The info below comes from various sources, including your input.  If you need to determine medications etc. based on it, please check all sources by yourself."];

    return headerText;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger cellHeight = 0;
    NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
    self.adjStatement = [selectedData valueForKey:@"Adjustment"];
    if (self.adjStatement != nil && [self.adjStatement count]>=3) {
        switch (indexPath.row)
        {
            case 0:
            case 2:
            case 3:
                cellHeight = 200;
                break;
                
            case 1:
                cellHeight = self.carbsExpanded?260:200;
                break;
                
            case 4:
            case 5:
            case 6:
            case 7:
                cellHeight = 40;
                break;
                
            case 8:
                cellHeight = 70;
                break;
        }
    }
    else {
        switch (indexPath.row)
        {
            case 0:
            case 2:
            case 3:
                cellHeight = 200;
                break;
                
            case 1:
                cellHeight = self.carbsExpanded?260:200;
                break;
                
            case 4:
            case 5:
            case 6:
            case 7:
                cellHeight = 0.1;
                break;
                
            case 78:
                cellHeight = 70;
                break;
        }

    }
    
    if ([self.adjStatement count] == 3 && indexPath.row == 4) {
        cellHeight = 0;
    }
    
    return cellHeight;
}


-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 100;
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // reduce the default footer height when using a grouped table to zero (using 0.0 doesn't work)
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 1){
        if(self.carbsExpanded){
            self.carbsExpanded = false;
        }else{
            self.carbsExpanded = true;
        }
        [self.tableview beginUpdates];
        [self.tableview endUpdates];
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


-(void)loadViewWithData:(NSArray *)data andMealType:(MealType)mt userEditAllowed:(BOOL)userEditEnabled {
    self.currMealType = mt;
    if (data == nil) {
        self.data = @[[MealCalculator getQuickEstimateValuesForType:QuickEstimateValueTypeIdeal forMeal:mt]];
    }
    else {
        self.data = data;
    }
    self.userEditEnabled = userEditEnabled;
}

-(void)loadViewWithFibre:(float)fibre andSugar:(float)sugar {
    self.fibre = fibre;
    self.sugar = sugar;
}


- (void)setupGaugeView:(DialGaugeView *)gaugeView forNutritionKey:(NSString *)nutritionKey {
    NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
        
    gaugeView.minValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"min"] floatValue];
    CGFloat gaugeViewMaxValue = 0.0;
    CGFloat gaugeViewValue = 0.0;
    
    if ([[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue] > [[[selectedData valueForKey:nutritionKey] valueForKey:@"max"] floatValue]) {
        gaugeViewMaxValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
        gaugeViewValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
    }
    else {
        gaugeViewMaxValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"max"] floatValue];
        gaugeViewValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
    }
    gaugeView.maxValue = gaugeViewMaxValue;
    gaugeView.value = gaugeViewValue;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
