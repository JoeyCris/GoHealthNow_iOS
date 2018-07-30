//
//  UserSetupFirstViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-02.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "UserSetupFirstViewController.h"
#import "StyleManager.h"
#import "Constants.h"

@interface UserSetupFirstViewController () <UINavigationBarDelegate>

@property (nonatomic)NSArray *steps;
@property (nonatomic)NSArray *stepIcons;

@property (strong, nonatomic) IBOutlet UIImageView *logoImageView;
@property (strong, nonatomic) IBOutlet UILabel *topLabel;
@property (strong, nonatomic) IBOutlet UITableView *stepsTableView;
@property (strong, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation UserSetupFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UINavigationBar *navBar = (UINavigationBar *)[self.view viewWithTag:USER_SETUP_FIRST_VC_TAG_NAV_BAR];
    UILabel *mainLabel = (UILabel *)[self.view viewWithTag:USER_SETUP_FIRST_VC_TAG_MAIN_LABEL];
    UIButton *skipButton = (UIButton *)[self.view viewWithTag:USER_SETUP_FIRST_VC_TAG_SKIP_BUTTON];
    UIButton *continueButton = (UIButton *)[self.view viewWithTag:USER_SETUP_FIRST_VC_TAG_CONT_BUTTON];
    
    navBar.delegate = self;
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:navBar];
    [StyleManager stylelabel:mainLabel];
    [StyleManager styleButton:skipButton];
    [StyleManager styleButton:continueButton];
    
    self.steps = @[[LocalizationManager getStringFromStrId:@"1.  Access Code"], [LocalizationManager getStringFromStrId:@"2.  Name"], [LocalizationManager getStringFromStrId:@"3.  Gender"], [LocalizationManager getStringFromStrId:@"4.  Birth Year"],
                   [LocalizationManager getStringFromStrId:@"5.  Unit System"], [LocalizationManager getStringFromStrId:@"6.  Blood Unit"], [LocalizationManager getStringFromStrId:@"7.  Weight"],
                   [LocalizationManager getStringFromStrId:@"8.  Height"], [LocalizationManager getStringFromStrId:@"9.  Daily Calorie"], [LocalizationManager getStringFromStrId:@"10.  BMI and Waist"], [LocalizationManager getStringFromStrId:@"11 Reminders"]];
    
    self.stepIcons = @[@"userSetupAccessCodeIcon", @"userSetupNameIcon", @"userSetupGenderIcon",
                       @"userSetupBirthYearIcon", @"userSetupUnitSystemIcon", @"userSetupBloodUnitIcon",
                       @"userSetupBmiWaistIcon", @"userSetupWeightIcon", @"userSetupHeightIcon",
                       @"userSetupDailyCalorieIcon", @"userSetupReminderIcon"];
    
    [StyleManager styleTable:self.stepsTableView];
    
    [self.stepsTableView setSeparatorColor:[UIColor whiteColor]];
    [self.stepsTableView setBackgroundColor:[UIColor grayColor]];
    [self.stepsTableView.layer setCornerRadius:8.0f];
    [self.stepsTableView setAllowsSelection:NO];
    
    self.topLabel.text = [LocalizationManager getStringFromStrId:@"To set up your profile, press Continue and follow these steps:"];
    self.bottomLabel.text = [LocalizationManager getStringFromStrId:@"or press Skip to set up your profile later from the Menu."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Event Handlers

- (IBAction)didTapSkipButton:(id)sender {
    [self.delegate firstControllerDidSkip:sender];
}

- (IBAction)didTapContinueButton:(id)sender {
    [self.delegate firstControllerDidContinue:sender];
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPAD) {
        return 70;
    }
    
    return 44;
}

#pragma mark - Table View Source Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell  *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StepsTableViewCell"];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = [self.steps objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[self.stepIcons objectAtIndex:indexPath.row]];
    
    return cell;
}

@end
