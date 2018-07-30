//
//  ChooseGlucoseUnitViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseUnitViewController.h"
#import "StyleManager.h"
#import "Constants.h"

@interface ChooseUnitViewController () <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *unitSegmentedControl;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;

@end

@implementation ChooseUnitViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleSegmentedControl:self.unitSegmentedControl];
    [StyleManager styleNavigationBar:self.navBar];
    
    self.navBar.delegate = self;
    
    switch (self.displayMode) {
        case UnitViewControllerGlucoseDisplayMode:
            self.navBar.topItem.title = [LocalizationManager getStringFromStrId:UNIT_VC_TITLE_BG];
            
            [self.unitSegmentedControl setTitle:[LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MMOL] forSegmentAtIndex:0];
            [self.unitSegmentedControl setTitle:[LocalizationManager getStringFromStrId:BGUNIT_DISPLAY_MG] forSegmentAtIndex:1];
            
            BGUnit initialBGUnit = (BGUnit)self.initialUnit;
            
            switch (initialBGUnit) {
                case 0:
                    self.unitSegmentedControl.selectedSegmentIndex = 0;
                    break;
                case 1:
                    self.unitSegmentedControl.selectedSegmentIndex = 1;
                    break;
                default:
                    self.unitSegmentedControl.selectedSegmentIndex = 0;
                    break;
            }
            
            break;
        case UnitViewControllerWeightDisplayMode:
            self.navBar.topItem.title = [LocalizationManager getStringFromStrId:UNIT_VC_TITLE_SYSTEM];
            
            [self.unitSegmentedControl setTitle:[LocalizationManager getStringFromStrId:MUNIT_DISPLAY_METRIC] forSegmentAtIndex:0];
            [self.unitSegmentedControl setTitle:[LocalizationManager getStringFromStrId:MUNIT_DISPLAY_IMPERIAL] forSegmentAtIndex:1];
            
            MeasureUnit initialMeasureUnit = (MeasureUnit)self.initialUnit;
            
            switch (initialMeasureUnit) {
                case 0:
                    self.unitSegmentedControl.selectedSegmentIndex = 0;
                    break;
                case 1:
                    self.unitSegmentedControl.selectedSegmentIndex = 1;
                    break;
                default:
                    self.unitSegmentedControl.selectedSegmentIndex = 0;
                    break;
            }
            
            break;
        default:
            break;
    }
    
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
    [self.delegate didChooseUnit:[self.unitSegmentedControl selectedSegmentIndex]
                    withUnitMode:self.displayMode
                          sender:sender];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    [self segmentedControlValueDidChange:sender];
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
