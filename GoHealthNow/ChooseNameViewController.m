//
//  ChooseNameViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-02-04.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//

#import "ChooseNameViewController.h"
#import "StyleManager.h"
#import "UIView+Extensions.h"

@interface ChooseNameViewController () <UINavigationBarDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic) UITextField *firstnameTextField;
@property (nonatomic) UITextField *lastnameTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ChooseNameViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [StyleManager styleTable:self.tableview];
    [self.tableview setSeparatorColor:[UIColor grayColor]];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    
    self.navBar.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.firstnameTextField resignFirstResponder];
    [self.lastnameTextField resignFirstResponder];
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
    [self didTapRecordButton:sender];
}

#pragma mark - UITextFieldDelegate


- (IBAction)textFieldDoneEditing:(UITextField *)textf{
    if (textf.tag == CHOOSE_NAME_TAG_FIRST_NAME) {
        self.initialFirstName = textf.text;
        [self.lastnameTextField becomeFirstResponder];
    }
    else { //last name
        self.initialLastName = textf.text;
        [self.lastnameTextField resignFirstResponder];
    }
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    NSString *fNameVal = [self.firstnameTextField.text isEqualToString:@""] ? nil : self.firstnameTextField.text;
    NSString *lNameVal = [self.lastnameTextField.text isEqualToString:@""] ? nil : self.lastnameTextField.text;
    
    [self.delegate didChoosefirstName:fNameVal
                             lastName:lNameVal
                               sender:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    [StyleManager styleTableCell:cell];
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"firstnameCell" forIndexPath:indexPath];
        self.firstnameTextField = (UITextField *)[cell viewWithTag:CHOOSE_NAME_TAG_FIRST_NAME];
        
        self.firstnameTextField.returnKeyType = UIReturnKeyNext;
        [self.firstnameTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        self.firstnameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.firstnameTextField.text = self.initialFirstName;
        [self.firstnameTextField becomeFirstResponder];
        
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"lastnameCell" forIndexPath:indexPath];
        self.lastnameTextField = (UITextField *)[cell viewWithTag:CHOOSE_NAME_TAG_LAST_NAME];
        
        self.lastnameTextField.returnKeyType = UIReturnKeyDone;
        [self.lastnameTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        self.lastnameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.lastnameTextField.text = self.initialLastName;
    }
    
    setLastCellSeperatorToLeft(cell);
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.firstnameTextField becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        [self.lastnameTextField becomeFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // reduce the default footer height when using a grouped table to zero (using 0.0 doesn't work)
}

void setLastCellSeperatorToLeft(UITableViewCell* cell)
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

@end
