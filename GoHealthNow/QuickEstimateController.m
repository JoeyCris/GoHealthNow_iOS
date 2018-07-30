//
//  QuickEstimateController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "QuickEstimateController.h"
#import "StyleManager.h"
#import "MealCalculator.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"

@interface QuickEstimateController() <UITextFieldDelegate, SlideInPopupDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic) NSArray *data;
@property (nonatomic) NSUInteger selectedDataIndex;
@property (nonatomic) MealType currMealType;

@property (nonatomic) float carbsRatio;
@property (nonatomic) float carbsConvert;
@property (nonatomic) float fatsRatio;
@property (nonatomic) float fatsConvert;
@property (nonatomic) float proteinRatio;
@property (nonatomic) float proteinConvert;

@property (nonatomic) NSArray *adjStatement;

@property (nonatomic) BOOL userEditEnabled;

@property (weak, nonatomic) IBOutlet UILabel *portionSizeValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *portionSizeValueSlider;

@property (weak, nonatomic) IBOutlet UILabel *carbsValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *carbsValueSlider;

@property (weak, nonatomic) IBOutlet UILabel *fatValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *fatValueSlider;

@property (weak, nonatomic) IBOutlet UILabel *proteinValueLabel;
@property (weak, nonatomic) IBOutlet UISlider *proteinValueSlider;

@property (weak, nonatomic) IBOutlet UILabel *portionSizeTinyLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionSizeIdealLabel;
@property (weak, nonatomic) IBOutlet UILabel *portionSizeHugeLabel;

@property (weak, nonatomic) IBOutlet UILabel *carbsTinyLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsIdealLabel;
@property (weak, nonatomic) IBOutlet UILabel *carbsHugeLabel;

@property (weak, nonatomic) IBOutlet UILabel *fatTinyLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatIdealLabel;
@property (weak, nonatomic) IBOutlet UILabel *fatHugeLabel;

@property (weak, nonatomic) IBOutlet UILabel *proteinTinyLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinIdealLabel;
@property (weak, nonatomic) IBOutlet UILabel *proteinHugeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailModeScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailModeSentence1;
@property (weak, nonatomic) IBOutlet UILabel *detailModeSentence2;
@property (weak, nonatomic) IBOutlet UILabel *detailModeSentence3;
@property (weak, nonatomic) IBOutlet UILabel *detailModeImgClassificationLbl;
@property (weak, nonatomic) IBOutlet UILabel *detailModeImgClassificationTopPredictionsLbl;

@property (weak, nonatomic) IBOutlet UIImageView *classificationLblUpArrow;

@end


@implementation QuickEstimateController

#pragma mark - View lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    [self.portionSizeValueLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(portionSizeValueLabelTap:)]];
    [self.carbsValueLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(carbsValueLabelTap:)]];
    [self.fatValueLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(fatsValueLabelTap:)]];
    [self.proteinValueLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(proteinValueLabelTap:)]];
    
    [self.portionSizeValueSlider addTarget:self action:@selector(portionSizeSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.portionSizeValueSlider addTarget:self action:@selector(portionSizeSliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.portionSizeValueSlider addTarget:self action:@selector(portionSizeSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.carbsValueSlider addTarget:self action:@selector(carbsSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.carbsValueSlider addTarget:self action:@selector(carbsSliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.carbsValueSlider addTarget:self action:@selector(carbsSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.fatValueSlider addTarget:self action:@selector(fatSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.fatValueSlider addTarget:self action:@selector(fatSliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.fatValueSlider addTarget:self action:@selector(fatSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.proteinValueSlider addTarget:self action:@selector(proteinSliderTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.proteinValueSlider addTarget:self action:@selector(proteinSliderTouchEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    [self.proteinValueSlider addTarget:self action:@selector(proteinSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    if (self.userEditEnabled) {
        self.tableView.allowsSelection = YES;
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupViewWithAnimation:NO];
}

#pragma mark - Methods

- (void)setupSlider:(UISlider *)slider forNutritionKey:(NSString *)nutritionKey animated:(BOOL)animate {
    NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
    
    slider.minimumValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"min"] floatValue];
    CGFloat sliderMaxValue = 0.0;
    CGFloat sliderValue = 0.0;
    
    if ([[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue] > [[[selectedData valueForKey:nutritionKey] valueForKey:@"max"] floatValue]) {
        sliderMaxValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
        sliderValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
    }
    else {
        sliderMaxValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"max"] floatValue];
        sliderValue = [[[selectedData valueForKey:nutritionKey] valueForKey:@"curr"] floatValue];
    }
    
    if (animate) {
        slider.maximumValue = sliderMaxValue;
        
        [UIView animateWithDuration:1.0 animations:^{
            [slider setValue:sliderValue animated:YES];
        }];
    }
    else {
        slider.maximumValue = sliderMaxValue;
        slider.value = sliderValue;
    }
}

- (void)setupViewWithAnimation:(BOOL)animated {
    self.portionSizeTinyLabel.textColor = [UIColor GGRedColor];
    self.portionSizeIdealLabel.textColor = [UIColor GGGreenColor];
    self.portionSizeHugeLabel.textColor = [UIColor GGRedColor];
    
    self.carbsTinyLabel.textColor = [UIColor GGRedColor];
    self.carbsIdealLabel.textColor = [UIColor GGGreenColor];
    self.carbsHugeLabel.textColor = [UIColor GGRedColor];
    
    self.fatTinyLabel.textColor = [UIColor GGRedColor];
    self.fatIdealLabel.textColor = [UIColor GGGreenColor];
    self.fatHugeLabel.textColor = [UIColor GGRedColor];
    
    self.proteinTinyLabel.textColor = [UIColor GGRedColor];
    self.proteinIdealLabel.textColor = [UIColor GGGreenColor];
    self.proteinHugeLabel.textColor = [UIColor GGRedColor];
    
    NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
    
    [self setupSlider:self.portionSizeValueSlider forNutritionKey:@"Calories" animated:animated];
    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
    
    [self setupSlider:self.carbsValueSlider forNutritionKey:@"Carbs" animated:animated];
    self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
    
    self.carbsRatio = [[[selectedData valueForKey:@"Carbs"] valueForKey:@"ratio"] floatValue];
    self.carbsConvert = [[[selectedData valueForKey:@"Carbs"] valueForKey:@"calsperunit"] floatValue];
    
    [self setupSlider:self.fatValueSlider forNutritionKey:@"Fats" animated:animated];
    self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
    
    self.fatsRatio = [[[selectedData valueForKey:@"Fats"] valueForKey:@"ratio"] floatValue];
    self.fatsConvert = [[[selectedData valueForKey:@"Fats"] valueForKey:@"calsperunit"] floatValue];

    [self setupSlider:self.proteinValueSlider forNutritionKey:@"Protein" animated:animated];
    self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
    
    self.proteinRatio = [[[selectedData valueForKey:@"Protein"] valueForKey:@"ratio"] floatValue];
    self.proteinConvert = [[[selectedData valueForKey:@"Protein"] valueForKey:@"calsperunit"] floatValue];
    
    self.adjStatement = [selectedData valueForKey:@"Adjustment"];
    
    self.detailModeSentence1.hidden = YES;
    self.detailModeSentence2.hidden = YES;
    self.detailModeSentence3.hidden = YES;
    
    if (self.userEditEnabled) {
        self.detailModeScoreLabel.hidden = YES;
    }
    else {
        self.navigationController.navigationBar.topItem.title = [LocalizationManager getStringFromStrId:@"Nutrition Facts"];
        self.navigationController.navigationBar.topItem.rightBarButtonItem = nil;
        
        self.portionSizeValueSlider.userInteractionEnabled = NO;
        self.portionSizeValueSlider.enabled = NO;
        self.carbsValueSlider.userInteractionEnabled = NO;
        self.carbsValueSlider.enabled = NO;
        self.fatValueSlider.userInteractionEnabled = NO;
        self.fatValueSlider.enabled = NO;
        self.proteinValueSlider.userInteractionEnabled = NO;
        self.proteinValueSlider.enabled = NO;
        
        float score = [[selectedData valueForKey:@"Score"] floatValue];
        self.detailModeScoreLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Score: %.0f"], score];
        
        if (score >= 80.0) {
            self.detailModeScoreLabel.textColor = [UIColor excellentMealColor];
        }
        else if (score >= 60.0 && score < 80) {
            self.detailModeScoreLabel.textColor = [UIColor goodMealColor];
        }
        else { // score<60
            self.detailModeScoreLabel.textColor = [UIColor notGoodMealColor];
        }
        
        if (self.adjStatement != nil && [self.adjStatement count]>=3) {
            self.detailModeSentence1.hidden = NO;
            self.detailModeSentence2.hidden = NO;
            self.detailModeSentence3.hidden = NO;
            
            self.detailModeSentence1.text = [self.adjStatement[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            self.detailModeSentence2.text = [self.adjStatement[1] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            self.detailModeSentence3.text = [self.adjStatement[2] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_STATEMENT];
            
            self.detailModeSentence1.textColor = [[self.adjStatement[0] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
            self.detailModeSentence2.textColor = [[self.adjStatement[1] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
            self.detailModeSentence3.textColor = [[self.adjStatement[2] objectForKey:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_ADJUSTMENT_KEY_FLAG] isEqual:MACRO_NEXML_MEAL_SCORING_LOGMETHOD_MEAL_NUTRITION_ADEQUATESTATEMENT_FLAG] ? [UIColor GGGreenColor]:[UIColor GGRedColor];
        }
        
        self.classificationLblUpArrow.hidden = YES;
    }
    
    if (self.userEditEnabled && [selectedData valueForKey:@"Name"]) {
        NSString *imgClassificationLbl = [selectedData valueForKey:@"Name"];
        NSAttributedString *imgClassificationText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Prediction: %@"], [imgClassificationLbl uppercaseString]]];
        NSMutableAttributedString *imgClassificationAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:imgClassificationText];
        
        CGFloat imgClassificationFontSize = IS_IPHONE_4_OR_LESS || IS_IPHONE_5 ? 12.0 : 17.0;
        [imgClassificationAttributedStr addAttribute:NSFontAttributeName
                                               value:[UIFont boldSystemFontOfSize:imgClassificationFontSize]
                                               range:NSMakeRange(12, imgClassificationText.length - 12)];
        
        self.detailModeImgClassificationLbl.attributedText = imgClassificationAttributedStr;
        
        if ([[selectedData valueForKey:@"Name"] isEqualToString:QUICK_ESTIMATE_UNKNOWN_MEAL_NAME]) {
            // classification failed so no point in showing the top N labels
            self.classificationLblUpArrow.hidden = YES;
            self.detailModeImgClassificationTopPredictionsLbl.text = [LocalizationManager getStringFromStrId:@"Please estimate manually or use Search"];
        }
        else {
            self.detailModeImgClassificationTopPredictionsLbl.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"See our top %lu predictions"], (unsigned long)[self.data count]];
        }
    }
    else {
        self.classificationLblUpArrow.hidden = YES;
        self.detailModeImgClassificationLbl.hidden = YES;
        self.detailModeImgClassificationTopPredictionsLbl.hidden = YES;
    }
    
    [self portionSizeSliderValueChange:nil];
    [self carbsSliderValueChange:nil];
    [self fatSliderValueChange:nil];
    [self proteinSliderValueChange:nil];
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

-(void)loadTextInputWithTag:(NSUInteger)tag {
    if (self.userEditEnabled) {
        NSString *msgStr;
        NSString *msgType;
        NSString *maxValue;
        
        if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_PORTIONSIZE) {
            msgType = QUICK_ESTIMATE_MSG_TEXT_INPUT_PROTIONSIZE;
            maxValue = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Maximum value: %.0f"], self.portionSizeValueSlider.maximumValue];
        }
        else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_CARBS) {
            msgType = QUICK_ESTIMATE_MSG_TEXT_INPUT_CARBS;
            maxValue = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Maximum value: %.0f g"], self.carbsValueSlider.maximumValue];
        }
        else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_FATS) {
            msgType = QUICK_ESTIMATE_MSG_TEXT_INPUT_FATS;
            maxValue = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Maximum value: %.0f g"], self.fatValueSlider.maximumValue];
        }
        else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_PROTEIN) {
            msgType = QUICK_ESTIMATE_MSG_TEXT_INPUT_PROTEIN;
            maxValue = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Maximum value: %.0f g"], self.proteinValueSlider.maximumValue];
        }
        
        msgStr = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input your %@ value"], msgType];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:msgStr message:@"" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
            textField.placeholder = maxValue;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.delegate = self;
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:MSG_CANCEL style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:MSG_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            UITextField *userInput = alert.textFields.firstObject;
            if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_PORTIONSIZE) {
                if ([userInput.text isEqualToString:@""] ||[userInput.text floatValue] > floorf(self.portionSizeValueSlider.maximumValue)) {
                    UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Invalid number"] message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input a number less than %0.f"], self.portionSizeValueSlider.maximumValue] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                    [invaild addAction:cancelAction];
                    [self presentViewController:invaild animated:YES completion:nil];
                }
                else {
                    self.portionSizeValueSlider.value = [userInput.text floatValue];
                    
                    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
                    
                    if (self.portionSizeValueSlider.value == 0) {
                        self.carbsValueSlider.value = 0;
                        self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
                        
                        self.fatValueSlider.value = 0;
                        self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
                        
                        self.proteinValueSlider.value = 0;
                        self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
                    }
                    else {
                        float offset = self.portionSizeValueSlider.value - self.carbsValueSlider.value * self.carbsConvert - self.fatValueSlider.value * self.fatsConvert - self.proteinValueSlider.value * self.proteinConvert;
                        
                        self.carbsValueSlider.value += offset * self.carbsRatio / self.carbsConvert;
                        self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
                        
                        self.fatValueSlider.value += offset * self.fatsRatio / self.fatsConvert;
                        self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
                        
                        self.proteinValueSlider.value += offset * self.proteinRatio / self.proteinConvert;
                        self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
                        
                    }
                    [self portionSizeSliderValueChange:nil];
                    [self carbsSliderValueChange:nil];
                    [self fatSliderValueChange:nil];
                    [self proteinSliderValueChange:nil];
                }
            }
            else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_CARBS) {
                if ([userInput.text isEqualToString:@""] ||[userInput.text floatValue] > floorf(self.carbsValueSlider.maximumValue)) {
                    UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Invalid number"] message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input a number less than %0.f"], self.carbsValueSlider.maximumValue] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                    [invaild addAction:cancelAction];
                    [self presentViewController:invaild animated:YES completion:nil];
                }
                else {
                    self.carbsValueSlider.value = [userInput.text floatValue];
                    
                    self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
                    
                    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
                    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
                    
                }
                [self portionSizeSliderValueChange:nil];
                [self carbsSliderValueChange:nil];
            }
            else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_FATS) {
                if ([userInput.text isEqualToString:@""] ||[userInput.text floatValue] > floorf(self.fatValueSlider.maximumValue)) {
                    UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Invalid number"] message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input a number less than %0.f"], self.fatValueSlider.maximumValue] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                    [invaild addAction:cancelAction];
                    [self presentViewController:invaild animated:YES completion:nil];
                }
                else {
                    self.fatValueSlider.value = [userInput.text floatValue];
                    
                    self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
                    
                    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
                    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
                    
                }
                [self portionSizeSliderValueChange:nil];
                [self fatSliderValueChange:nil];
            }
            else if (tag == QUICK_ESTIMATE_TAG_TEXT_INPUT_PROTEIN) {
                if ([userInput.text isEqualToString:@""] ||[userInput.text floatValue] > floorf(self.proteinValueSlider.maximumValue)) {
                    UIAlertController *invaild = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Invalid number"] message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Please input a number less than %0.f"], self.proteinValueSlider.maximumValue] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleCancel handler:nil];
                    [invaild addAction:cancelAction];
                    [self presentViewController:invaild animated:YES completion:nil];
                }
                else {
                    self.proteinValueSlider.value = [userInput.text floatValue];
                    
                    self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
                    
                    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
                    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
                    
                }
                [self portionSizeSliderValueChange:nil];
                [self proteinSliderValueChange:nil];
            }
        }];
        [alert addAction:cancelAction];
        [alert addAction:okAction];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
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

- (UIColor *)getMidColorWithFirstColor:(UIColor *)color1 andColor:(UIColor *)color2 inPrecentage:(float)prct{
    //Use color1 as the base
    CGFloat red1;
    CGFloat green1;
    CGFloat blue1;
    CGFloat alpha1;
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;
    CGFloat alpha2;
    [color1 getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
    [color2 getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
    
    return [UIColor colorWithRed:red1+(red2-red1)*prct green:green1+(green2-green1)*prct blue:blue1+(blue2-blue1)*prct alpha:alpha1+(alpha2-alpha1)*prct];
}

#pragma mark - TextField Delegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return [self validateNumber:string];
}

#pragma mark - Event Handlers

- (void)portionSizeSliderValueChange:(id)sender {
    if (self.portionSizeValueSlider.value <= self.portionSizeValueSlider.maximumValue/2) {
        self.portionSizeValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGRedColor] andColor:[UIColor GGGreenColor] inPrecentage:(self.portionSizeValueSlider.value/(self.portionSizeValueSlider.maximumValue/2))];
    }
    else {
        self.portionSizeValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGGreenColor] andColor:[UIColor GGRedColor] inPrecentage:((self.portionSizeValueSlider.value-self.portionSizeValueSlider.maximumValue/2)/(self.portionSizeValueSlider.maximumValue/2))];
    }
}

- (void)carbsSliderValueChange:(id)sender {
    if (self.carbsValueSlider.value <= self.carbsValueSlider.maximumValue/2) {
        self.carbsValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGRedColor] andColor:[UIColor GGGreenColor] inPrecentage:(self.carbsValueSlider.value/(self.carbsValueSlider.maximumValue/2))];
    }
    else {
        self.carbsValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGGreenColor] andColor:[UIColor GGRedColor] inPrecentage:((self.carbsValueSlider.value-self.carbsValueSlider.maximumValue/2)/(self.carbsValueSlider.maximumValue/2))];
    }
}

- (void)fatSliderValueChange:(id)sender {
    if (self.fatValueSlider.value <= self.fatValueSlider.maximumValue/2) {
        self.fatValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGRedColor] andColor:[UIColor GGGreenColor] inPrecentage:(self.fatValueSlider.value/(self.fatValueSlider.maximumValue/2))];
    }
    else {
        self.fatValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGGreenColor] andColor:[UIColor GGRedColor] inPrecentage:((self.fatValueSlider.value-self.fatValueSlider.maximumValue/2)/(self.fatValueSlider.maximumValue/2))];
    }
}

- (void)proteinSliderValueChange:(id)sender {
    if (self.proteinValueSlider.value <= self.proteinValueSlider.maximumValue/2) {
        self.proteinValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGRedColor] andColor:[UIColor GGGreenColor] inPrecentage:(self.proteinValueSlider.value/(self.proteinValueSlider.maximumValue/2))];
    }
    else {
        self.proteinValueLabel.textColor = [self getMidColorWithFirstColor:[UIColor GGGreenColor] andColor:[UIColor GGRedColor] inPrecentage:((self.proteinValueSlider.value-self.proteinValueSlider.maximumValue/2)/(self.proteinValueSlider.maximumValue/2))];
    }
}


- (IBAction)portionSizeSliderSlide:(id)sender {
    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
    
    float offset = self.portionSizeValueSlider.value - self.carbsValueSlider.value * self.carbsConvert - self.fatValueSlider.value * self.fatsConvert - self.proteinValueSlider.value * self.proteinConvert;
    
    self.carbsValueSlider.value += offset * self.carbsRatio / self.carbsConvert;
    self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
    
    self.fatValueSlider.value += offset * self.fatsRatio / self.fatsConvert;
    self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
    
    self.proteinValueSlider.value += offset * self.proteinRatio / self.proteinConvert;
    self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
    
    [self carbsSliderValueChange:sender];
    [self fatSliderValueChange:sender];
    [self proteinSliderValueChange:sender];
}

- (IBAction)carbsSliderSlide:(id)sender {
    self.carbsValueLabel.text = [NSString stringWithFormat:@"%.0f g",self.carbsValueSlider.value];
    
    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
    //NSLog(@"V:%f C:%f R:%f\n", self.carbsValueSlider.value, self.carbsConvert, self.carbsRatio);
    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
    
    [self portionSizeSliderValueChange:sender];
    [self carbsSliderValueChange:sender];
}

- (IBAction)fatSliderSlide:(id)sender {
    self.fatValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.fatValueSlider.value];
    
    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
    
    [self portionSizeSliderValueChange:sender];
    [self fatSliderValueChange:sender];
}

- (IBAction)proteinSliderSlide:(id)sender {
    self.proteinValueLabel.text = [NSString stringWithFormat:@"%.0f g", self.proteinValueSlider.value];
    
    self.portionSizeValueSlider.value = self.fatValueSlider.value * self.fatsConvert + self.proteinValueSlider.value * self.proteinConvert + self.carbsValueSlider.value * self.carbsConvert;
    self.portionSizeValueLabel.text = [NSString stringWithFormat:@"%.0f",self.portionSizeValueSlider.value];
    
    [self portionSizeSliderValueChange:sender];
    [self proteinSliderValueChange:sender];
}

- (void)portionSizeSliderTouchDown:(id)sender {
    self.portionSizeTinyLabel.text = [NSString stringWithFormat:@"%.0f", self.portionSizeValueSlider.minimumValue];
    self.portionSizeIdealLabel.text = [NSString stringWithFormat:@"%.0f", self.portionSizeValueSlider.maximumValue / 2];
    self.portionSizeHugeLabel.text = [NSString stringWithFormat:@"%.0f", self.portionSizeValueSlider.maximumValue];
}

- (void)portionSizeSliderTouchEnd:(id)sender {
    self.portionSizeTinyLabel.text = [LocalizationManager getStringFromStrId:@"Too few"];
    self.portionSizeIdealLabel.text = [LocalizationManager getStringFromStrId:@"Target"];
    self.portionSizeHugeLabel.text = [LocalizationManager getStringFromStrId:@"Too many"];
}

- (void)carbsSliderTouchDown:(id)sender {
    self.carbsTinyLabel.text = [NSString stringWithFormat:@"%.0f", self.carbsValueSlider.minimumValue];
    self.carbsIdealLabel.text = [NSString stringWithFormat:@"%.0f", self.carbsValueSlider.maximumValue / 2];
    self.carbsHugeLabel.text = [NSString stringWithFormat:@"%.0f", self.carbsValueSlider.maximumValue];
}

- (void)carbsSliderTouchEnd:(id)sender {
    self.carbsTinyLabel.text = [LocalizationManager getStringFromStrId:@"Too few"];
    self.carbsIdealLabel.text = [LocalizationManager getStringFromStrId:@"Target"];
    self.carbsHugeLabel.text = [LocalizationManager getStringFromStrId:@"Too many"];
}

- (void)fatSliderTouchDown:(id)sender {
    self.fatTinyLabel.text = [NSString stringWithFormat:@"%.0f", self.fatValueSlider.minimumValue];
    self.fatIdealLabel.text = [NSString stringWithFormat:@"%.0f", self.fatValueSlider.maximumValue / 2];
    self.fatHugeLabel.text = [NSString stringWithFormat:@"%.0f", self.fatValueSlider.maximumValue];
}

- (void)fatSliderTouchEnd:(id)sender {
    self.fatTinyLabel.text = [LocalizationManager getStringFromStrId:@"Too few"];
    self.fatIdealLabel.text = [LocalizationManager getStringFromStrId:@"Target"];
    self.fatHugeLabel.text = [LocalizationManager getStringFromStrId:@"Too many"];
}

- (void)proteinSliderTouchDown:(id)sender {
    self.proteinTinyLabel.text = [NSString stringWithFormat:@"%.0f", self.proteinValueSlider.minimumValue];
    self.proteinIdealLabel.text = [NSString stringWithFormat:@"%.0f", self.proteinValueSlider.maximumValue / 2];
    self.proteinHugeLabel.text = [NSString stringWithFormat:@"%.0f", self.proteinValueSlider.maximumValue];
}

- (void)proteinSliderTouchEnd:(id)sender {
    self.proteinTinyLabel.text = [LocalizationManager getStringFromStrId:@"Too few"];
    self.proteinIdealLabel.text = [LocalizationManager getStringFromStrId:@"Target"];
    self.proteinHugeLabel.text = [LocalizationManager getStringFromStrId:@"Too many"];
}

- (IBAction)recordButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    /*
    if (self.userEditEnabled) {
        NSDictionary *selectedData = [self.data objectAtIndex:self.selectedDataIndex];
        NSDictionary *qe = [[MealCalculator sharedModel] scoreForUser:[User sharedModel] withQuickEstimate:@{
                                                                                                             @"Calories":[NSNumber numberWithFloat:self.portionSizeValueSlider.value],
                                                                                                             @"Carbs":[NSNumber numberWithFloat:self.carbsValueSlider.value],
                                                                                                             @"Fats":[NSNumber numberWithFloat:self.fatValueSlider.value],
                                                                                                             @"Protein":[NSNumber numberWithFloat:self.proteinValueSlider.value] }
                                                          forMealType:self.currMealType];
        
        MealRecord *qeMeal = [[MealRecord alloc] init];
        qeMeal.type = self.currMealType;
        qeMeal.cals = self.portionSizeValueSlider.value;
        qeMeal.carb = self.carbsValueSlider.value;
        qeMeal.fat = self.fatValueSlider.value;
        qeMeal.pro = self.proteinValueSlider.value;
        qeMeal.score = [[qe valueForKey:MC_SCORE_KEY] floatValue];
        qeMeal.name = [selectedData objectForKey:@"Name"];
        
        [self.delegate didCreateQuickEstimateMeal:qeMeal];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    */
}

- (IBAction)cancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)portionSizeValueLabelTap:(UITapGestureRecognizer *)sender {
    [self loadTextInputWithTag:QUICK_ESTIMATE_TAG_TEXT_INPUT_PORTIONSIZE];
}

-(void)carbsValueLabelTap:(UITapGestureRecognizer *)sender {
    [self loadTextInputWithTag:QUICK_ESTIMATE_TAG_TEXT_INPUT_CARBS];
}

-(void)fatsValueLabelTap:(UITapGestureRecognizer *)sender {
    [self loadTextInputWithTag:QUICK_ESTIMATE_TAG_TEXT_INPUT_FATS];
}

-(void)proteinValueLabelTap:(UITapGestureRecognizer *)sender {
    [self loadTextInputWithTag:QUICK_ESTIMATE_TAG_TEXT_INPUT_PROTEIN];
}

#pragma mark - TableView Delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.detailModeImgClassificationTopPredictionsLbl.isHidden && indexPath.section == 1 && indexPath.row == 1) {
        return YES;
    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!self.detailModeImgClassificationTopPredictionsLbl.isHidden && indexPath.section == 1 && indexPath.row == 1) {
        UIPickerView *classificationLabelPicker = [[UIPickerView alloc] init];
        classificationLabelPicker.tag = QUICK_ESTIMATE_TAG_CLASSIFICATION_LBL_PICKER;
        classificationLabelPicker.delegate = self;
        classificationLabelPicker.dataSource = self;
        
        [classificationLabelPicker selectRow:self.selectedDataIndex inComponent:0 animated:NO];
        
        [self.view slideInPopupWithTitle:[LocalizationManager getStringFromStrId:@"Choose Alternative Prediction"]
                           withComponent:classificationLabelPicker
                            withDelegate:self];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.userEditEnabled) {
        if (indexPath.section == 0) {
            return 120.0;
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0 && !self.detailModeImgClassificationLbl.isHidden) {
                return 44.0;
            }
            else if (indexPath.row == 1 && !self.detailModeImgClassificationTopPredictionsLbl.isHidden) {
                return 44.0;
            }
            
            return 0.0;
        }
    }
    else {
        if (indexPath.section == 0) {
            return 120.0;
        }
        else if (indexPath.section == 1) {
            if (indexPath.row == 0) {
                if (!self.detailModeImgClassificationLbl.isHidden) {
                    return 44.0;
                }
            
                return 0.0;
            }
            else {
                if (indexPath.row == 1) {
                    return 0.0;
                }
                else if (indexPath.row == 2) {
                    return 44.0;
                }
                else if ([self.adjStatement count]<3) {
                    return 0.0;
                }
                else {
                    if (indexPath.row <= 5) {
                        return 44.0;
                    }
                    else
                        return 0.0;
                }
            }
        }
    }
    
    return 120.0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - UIPickerViewDataSouce Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return [self.data count];
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    return [[NSAttributedString alloc] initWithString:self.data[row][@"Name"]
                                           attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - SlideInPopupDelegate

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer {
    UIPickerView *classificationLabelPicker = (UIPickerView *)[UIView slideInPopupComponentViewWithTag:QUICK_ESTIMATE_TAG_CLASSIFICATION_LBL_PICKER
                                                                                 withGestureRecognizer:gestureRecognizer];
    if (classificationLabelPicker) {
        self.selectedDataIndex = [classificationLabelPicker selectedRowInComponent:0];
        [self setupViewWithAnimation:YES];
    }
}

@end
