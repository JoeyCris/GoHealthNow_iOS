//
//  ChooseGenderViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseGenderViewController.h"
#import "StyleManager.h"

@interface ChooseGenderViewController () <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegmentedControl;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation ChooseGenderViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleSegmentedControl:self.genderSegmentedControl];
    [StyleManager styleNavigationBar:self.navBar];
    [StyleManager stylelabel:self.noteLabel];
    
    self.noteLabel.numberOfLines = 0;
    self.noteLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (!self.initialGender) {
        self.initialGender = GenderTypeMale;
    }
    
    self.navBar.delegate = self;
    self.genderSegmentedControl.selectedSegmentIndex = self.initialGender;
    
    if (self.isUserSetupModeEnabled) {
        self.navBar.topItem.leftBarButtonItem = nil;
        [StyleManager styleButton:self.recordButton];
        [self.recordButton setTitle:[LocalizationManager getStringFromStrId:MSG_CONTINUE] forState:UIControlStateNormal];
    }
    else {
        [self.recordButton setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - User Setup Protocol

- (void)didFlipForwardToNextPageWithGesture:(id)sender {
    [self segmentedControlValueDidChange:sender];
}

#pragma mark - Event Handlers

- (IBAction)segmentedControlValueDidChange:(id)sender {
    NSString *segmentedControlSelectedTitle = [self.genderSegmentedControl titleForSegmentAtIndex:self.genderSegmentedControl.selectedSegmentIndex];
    GenderType selectedGender = GenderTypeMale;
    
    if ([segmentedControlSelectedTitle isEqualToString:[LocalizationManager getStringFromStrId:GENDER_DISPLAY_FEMALE]]) {
        selectedGender = GenderTypeFemale;
    }
    
    [self.delegate didChooseGender: selectedGender sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    [self segmentedControlValueDidChange:sender];
}

@end
