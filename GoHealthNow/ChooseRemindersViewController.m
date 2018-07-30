//
//  ChooseGlucoseUnitViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseRemindersViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "NotificationListViewController.h"
#import "DosageInputViewController.h"
#import "NotificationMedicationClass.h"

@interface ChooseRemindersViewController () <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (strong, nonatomic) IBOutlet UIButton *btnCreateReminders;

@end

@implementation ChooseRemindersViewController

static ChooseRemindersViewController *singletonInstance;

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager styleButton:self.recordButton];
    
    self.navBar.delegate = self;
    
    [StyleManager styleButton:self.recordButton];
    [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CONTINUE] forState:UIControlStateNormal];
    
    [StyleManager styleButton:self.btnCreateReminders];
    self.btnCreateReminders.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}


- (IBAction)didTapRecordButton:(id)sender {
        [self.delegate didSetReminder:self];
}

- (IBAction)btnCreateReminders:(id)sender {
    [self performSegueWithIdentifier:@"segueToReminders" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"segueToReminders"])
    {
        UINavigationController  *navVC = segue.destinationViewController;
        NotificationListViewController *vc = navVC.viewControllers.firstObject;
        vc.isSetup = true;
    }
}


@end
