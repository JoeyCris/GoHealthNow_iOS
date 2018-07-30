//
//  RecentMealsController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "RecentMealsController.h"
#import "MealRecord.h"
#import "ImageCard.h"
#import "Constants.h"   
#import "UIColor+Extensions.h"
#import "StyleManager.h"
#import "AddMealRecordController.h"
#import "FoodRecognitionCameraBaseViewController.h"

@interface RecentMealsController ()

@property (nonatomic) NSArray *recentMeals;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;

@end

@implementation RecentMealsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    [self setupTableHeaderView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    if (self.isQuickAccess) {
        [self didTapAddNewMealButton:nil];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.tableHeaderView.bounds = CGRectMake(0.0, 0.0,
                                                       self.tableView.frame.size.width,
                                                       self.tableView.tableHeaderView.frame.size.height);
}

- (BOOL)isModal {
    if([self presentingViewController])
        return YES;
    if([[self presentingViewController] presentedViewController] == self)
        return YES;
    if([[[self navigationController] presentingViewController] presentedViewController] == [self navigationController])
        return YES;
    if([[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]])
        return YES;
    
    return NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self isModal]){
        [StyleManager styleNavigationBar:self.navigationController.navigationBar];
        
        UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(didTapCancelButton)];
        self.navItem.leftBarButtonItem = btnBack;
    }
    
    [self getRecentMealsArray];
    
}

-(void)getRecentMealsArray{
    
    self.recentMeals = [[NSArray alloc] init];
    [MealRecord searchRecentMeal:nil].then(^(NSArray *recentMealArr){
        self.recentMeals = recentMealArr;
    }).finally(^(){
        if (self.recentMeals == nil) {
            self.recentMeals = [[NSArray alloc] init];
        }
        [self.tableView reloadData];
    });
    
}

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.recentMeals count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.recentMeals[section] objectForKey:@"rows"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self shouldShowImageCardWithIndexPath:indexPath]) {
        return 225.0;
    }
    
    return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [self.recentMeals[section] objectForKey:@"category"];
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [label setFont:[UIFont boldSystemFontOfSize:15.0]];
    [label setText:[headerText uppercaseString]];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    [view.contentView addSubview:label];
    
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MealRecord *meal = [self.recentMeals[indexPath.section] objectForKey:@"rows"][indexPath.row];
    
    UITableViewCell *cell = nil;
    
    if ([self shouldShowImageCardWithIndexPath:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recentMealCellWithImg" forIndexPath:indexPath];
        
        ImageCard *mealCard = (ImageCard *)[cell viewWithTag:RECENT_MEALS_TAG_IMAGE_CARD];
        mealCard.frame = CGRectMake(10, 10, cell.frame.size.width - 20, cell.frame.size.height - 20);
        
        NSString *score = [NSString stringWithFormat:@"%.0f", meal.score];
        
        __block UIImage *mealImage = nil;
        __block Boolean gotImage = NO;
        
        if ([meal.foods count] == 0) {
            [mealCard loadCardTypeAWithImage:[meal loadImage]
                                 titleString:[self cellLabelTextWithMeal:meal]
                              descriptString:meal.description
                              indicatorColor:[UIColor clearColor]];
            
            if ([mealCard superview] == nil) {
                [cell addSubview:mealCard];
            }
            gotImage = YES;
        }
        
        
        for (FoodItem *food in meal.foods) {
            if (food.imageData) {
                [food.imageData loadFromFile].then(^(id success) {
                    if (food.imageData.image) {
                        mealImage = food.imageData.image;
                    }
                }).finally(^{
                    if (mealImage == nil) {
                        mealImage = [UIImage imageNamed:@"mealImage_Default"];
                    }
                    
                    UIColor *idcColor;
                    if (meal.score >= 80.0) {
                        idcColor = [UIColor excellentMealColor];
                    }
                    else if (meal.score >= 60.0 && meal.score < 80) {
                        idcColor = [UIColor goodMealColor];
                    }
                    else { // < 60.0
                        idcColor = [UIColor notGoodMealColor];
                    }
                    
                    [mealCard loadCardTypeAWithImage:mealImage
                                         titleString:[self cellLabelTextWithMeal:meal]
                                      descriptString:meal.description
                                         scoreString:score
                                      indicatorColor:idcColor];
                    
                    gotImage = YES;
                    if ([mealCard superview] == nil) {
                        [cell addSubview:mealCard];
                    }
                });
                
                break;
            }
        }
        if (!gotImage) {
            UIColor *idcColor;
            if (meal.score >= 80.0) {
                idcColor = [UIColor excellentMealColor];
            }
            else if (meal.score >= 60.0 && meal.score < 80) {
                idcColor = [UIColor goodMealColor];
            }
            else { // < 60.0
                idcColor = [UIColor notGoodMealColor];
            }
            
            [mealCard loadCardTypeAWithImage:[meal loadImage]
                                 titleString:[self cellLabelTextWithMeal:meal]
                              descriptString:meal.description
                                 scoreString:score
                              indicatorColor:idcColor];
            
            if ([mealCard superview] == nil) {
                [cell addSubview:mealCard];
            }
        }
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recentMealCell" forIndexPath:indexPath];
        
        UILabel *label = [(UILabel *)cell viewWithTag:RECENT_MEALS_TAG_LABEL];
        UILabel *subLabel = [(UILabel *)cell viewWithTag:RECENT_MEALS_TAG_SUB_LABEL];
        UIImageView *imageView = [(UIImageView *)cell viewWithTag:RECENT_MEALS_TAG_IMAGE];
        
        label.font = [UIFont systemFontOfSize:18.0];
        subLabel.font = [UIFont systemFontOfSize:12.0 weight:UIFontWeightLight];
        
        label.text = [self cellLabelTextWithMeal:meal];
        
        NSString *score = [NSString stringWithFormat:@"%.0f", meal.score];
        subLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Score: %@, %.1f calories"], score, meal.cals];
    
        imageView.image = [UIImage imageNamed:@"addFoodDescriptionIcon"];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.tintColor = [UIColor buttonColor];
    }
    
    return cell;
}

//
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete        
        
        [self confirmDeletewithIndexPath:indexPath];
    }
    
   
}

///

-(void)confirmDeletewithIndexPath:(NSIndexPath *)indexPath{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Delete Meal Log"]
                                          message:[LocalizationManager getStringFromStrId:@"Are you sure you want to Delete this meal ?"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       [self.tableView reloadData];
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:@"Delete"]
                               style:UIAlertActionStyleDestructive
                               handler:^(UIAlertAction *action)
                               {
                                   MealRecord *meal = [self.recentMeals[indexPath.section] objectForKey:@"rows"][indexPath.row];
                                   [meal removeMealWithID:meal.oid.str];
                                   
                                   [self getRecentMealsArray];
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    [self performSegueWithIdentifier:@"addMealSegue" sender:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - Methods

- (NSString *)cellLabelTextWithMeal:(MealRecord *)meal {
    NSString *labelText = meal.name;
    
    if (!meal.name || [meal.name isEqualToString:@""]) {
        unsigned long foodCount = (unsigned long)[meal.foods count];
        
        if (foodCount == 1) {
            labelText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@, %ld item"], [self foodNameWithType:meal.type], foodCount];
        }
        else {
            labelText = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@, %ld items"], [self foodNameWithType:meal.type], foodCount];
        }
    }
    
    return labelText;
}

- (BOOL)shouldShowImageCardWithIndexPath:(NSIndexPath *)indexPath {
    MealRecord *meal = [self.recentMeals[indexPath.section] objectForKey:@"rows"][indexPath.row];
    
    for (FoodItem *food in meal.foods) {
        if (food.imageData) {
            return YES;
        }
    }
    
    if ([meal hasImage]) {
        return YES;
    }
    
    return NO;
}

- (void)setupTableHeaderView {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor whiteColor];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorView.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    headerLabel.text = [LocalizationManager getStringFromStrId:@"Select a recent meal below or tap 'Add' to add a new meal"];
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

-(NSString *)foodNameWithType:(NSUInteger)type {
    if (type == MealTypeBreakfast) {
        return [LocalizationManager getStringFromStrId:MSG_BREAKFAST];
    }
    else if (type == MealTypeDinner) {
        return [LocalizationManager getStringFromStrId:MSG_DINNER];
    }
    else if (type == MealTypeLunch) {
        return [LocalizationManager getStringFromStrId:MSG_LUNCH];
    }
    else if (type == MealTypeSnack) {
        return [LocalizationManager getStringFromStrId:MSG_SNACK];
    }
    return [LocalizationManager getStringFromStrId:@"Unknown"];
}

#pragma mark - Event Handlers

-(void)didTapCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapAddNewMealButton:(id)sender {
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"addMealSegue"] && sender != self) {
        NSIndexPath *selectedCellIndexPath = (NSIndexPath *)sender;
        
        UINavigationController *destVC = [segue destinationViewController];
        AddMealRecordController *addMealRecordController = destVC.viewControllers.firstObject;
        addMealRecordController.meal = [self.recentMeals[selectedCellIndexPath.section] objectForKey:@"rows"][selectedCellIndexPath.row];
    }
    
}

@end
