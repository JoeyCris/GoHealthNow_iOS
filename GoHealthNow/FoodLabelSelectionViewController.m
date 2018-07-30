//
//  FoodLabelSelectionViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-07.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "FoodLabelSelectionViewController.h"
#import "AddMealRecordController.h"
#import "FoodItem.h"
#import "UIView+Extensions.h"


@interface FoodLabelSelectionViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *foods;
@property (nonatomic) UIImage *img;
@property (nonatomic) NSString *imgName;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@property (nonatomic) NSMutableArray *selectedArr;
@property (nonatomic) NSString *top1ItemProb;

@end

@implementation FoodLabelSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tipLabel setText:[LocalizationManager getStringFromStrId:@"We have identified the following based upon your image. Select the one that is correct."]];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(showAlertView)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)loadFoodWithArray:(NSArray *)foodItems andSrcImage:(UIImage *)image andImageName:(NSString *)name {
    self.foods = foodItems;
    self.img = image;
    self.imgName = name;
    self.selectedArr = [[NSMutableArray alloc] init];
    self.top1ItemProb = [[foodItems objectAtIndex:0] objectForKey:@"Prob"];
    //NSLog(@"top1ItemProb: %@", self.top1ItemProb);
    if([self.top1ItemProb floatValue] > 0.9){
        [self.selectedArr addObject:@YES];
    }else{
        [self.selectedArr addObject:@NO];
    }
    
    for (int i = 1;i<[foodItems count];i++) {
        [self.selectedArr addObject:@NO];
    }

            [self.tableView reloadData];
}

- (NSArray<FoodItem *> *)foodItemsFromImgClassificationFoodItems {
    NSMutableArray<FoodItem *> *foodItems = [[NSMutableArray alloc] init];

    for (int i=0;i<[self.selectedArr count];i++) {
        if ([[self.selectedArr objectAtIndex:i] isEqual:@YES]) {
            FoodItem *item = [[FoodItem alloc] initWithClassificationData:[self.foods objectAtIndex:i]];
            item.imageData = [[FoodImageData alloc] initWithImage:self.img name:self.imgName];
            if (item) {
                [foodItems addObject:item];
            }
        }
    }
    return foodItems;
}

#pragma mark - Button Actions

- (void)showAlertView {
    // show confirmation alert
    UIAlertController *confirmationAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_TITLE]
                                                                               message:[LocalizationManager getStringFromStrId:@"Photo taken will be lost. Do you want to save photo for future use?"]
                                                                        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_YES_BTN] style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [self savePhoto];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:INPUT_CONFIRM_SAVE_NO_BTN] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [confirmationAlert addAction:okAction];
    [confirmationAlert addAction:cancelAction];
    
    [self presentViewController:confirmationAlert animated:YES completion:nil];
}

//- (void)dismissView {
//    [self dismissViewControllerAnimated:YES completion:nil];
//}

- (IBAction)didTapCheckmarkButton:(id)sender {
    NSArray<FoodItem *> *selectedItems = [self foodItemsFromImgClassificationFoodItems];
    if ([selectedItems count] == 0){
        [self performSegueWithIdentifier:@"showMealSummarySegue" sender:[self mealRecordForItemNotFound]];
    }
    else{
        [self performSegueWithIdentifier:@"showMealSummarySegue" sender:selectedItems];
    }

}

#pragma mark - UITableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? [self.foods count]:1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"foodItemCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"foodItemCell"];
        }
        
        if (indexPath.row == 0) {
            if ([[self.selectedArr objectAtIndex:0] isEqual:@YES]){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }
        }
        
        [cell.textLabel setText:[[self.foods objectAtIndex:indexPath.row] objectForKey:@"Name"]];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"ItemNotFoundCell"];
    }
    
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0){
        if ([self.selectedArr[indexPath.row] isEqual:@YES]) {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
            self.selectedArr[indexPath.row] = @NO;
        }
        else {
            [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
            self.selectedArr[indexPath.row] = @YES;
        }
    }else{
        [self performSegueWithIdentifier:@"showMealSummarySegue" sender:[self mealRecordForItemNotFound]];
//        [self savePhoto];
//        [self performSegueWithIdentifier:@"showNewMealRecordSegue" sender:nil];
    }
    
}

- (MealRecord *)mealRecordForItemNotFound{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    MealRecord *meal = [[MealRecord alloc] init];
    [meal setImage:self.img];
    meal.carb = 0;
    meal.pro = 0;
    meal.fat = 0;
    meal.cals = 0;
    if ([components hour]>=5 && [components hour]<10) {
        meal.type = MealTypeBreakfast;
    }
    else if ([components hour]>=10 && [components hour]<16) {
        meal.type = MealTypeLunch;
    }
    else if ([components hour]>=16 && [components hour]<24) {
        meal.type = MealTypeDinner;
    }
    else {
        meal.type = MealTypeSnack;
    }
    meal.recordedTime = [NSDate date];

    return meal;
}

- (void)savePhoto {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    MealRecord *meal = [[MealRecord alloc] init];
    [meal setImage:self.img];
    meal.carb = 0;
    meal.pro = 0;
    meal.fat = 0;
    meal.cals = 0;
    if ([components hour]>=5 && [components hour]<10) {
        meal.type = MealTypeBreakfast;
    }
    else if ([components hour]>=10 && [components hour]<16) {
        meal.type = MealTypeLunch;
    }
    else if ([components hour]>=16 && [components hour]<24) {
        meal.type = MealTypeDinner;
    }
    else {
        meal.type = MealTypeSnack;
    }
    meal.recordedTime = [NSDate date];
    
    [meal save];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"showMealSummarySegue"])
    {
        AddMealRecordController *destVC = [segue destinationViewController];

        if ([sender isKindOfClass:[NSArray class]]) {
            NSArray<FoodItem *> *imgClassificationResults = sender;
            if ([imgClassificationResults count] > 0) {
                    [destVC addFoodItems:imgClassificationResults];
            }
        }
        if ([sender isKindOfClass:[MealRecord class]]){
            MealRecord *meal = sender;
            [destVC addMealRecordForItemNotFound:meal];
        }
    }
}


@end
