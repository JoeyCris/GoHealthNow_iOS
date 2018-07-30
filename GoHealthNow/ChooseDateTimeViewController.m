//
//  ChooseDateTimeViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-15.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "ChooseDateTimeViewController.h"
#import "StyleManager.h"

@interface ChooseDateTimeViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *chooseButton;

@end

@implementation ChooseDateTimeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleButton:self.chooseButton];
    
    self.datePicker.datePickerMode = self.mode;
    self.datePicker.date = self.initialDate;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers

- (IBAction)chooseButtonTapped:(id)sender {
    [self.delegate didChooseDateTime:self.datePicker.date sender:sender];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
