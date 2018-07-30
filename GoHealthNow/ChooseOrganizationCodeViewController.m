//
//  ChooseOrganizationCodeViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-26.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseOrganizationCodeViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"
#import "Constants.h"
#import "User.h"
#import "InputSelectionTableViewController.h"

@interface ChooseOrganizationCodeViewController () <UINavigationBarDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic) UITextField *accesscodeTextField;

@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ChooseOrganizationCodeViewController

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
    [self.accesscodeTextField resignFirstResponder];
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
    self.initialOrganizationCode = textf.text;
    [self.accesscodeTextField becomeFirstResponder];
}

#pragma mark - Event Handlers

- (IBAction)didTapCancelButton:(id)sender {
    
    if(self.initialSetupFromRegistration == YES){
        [self performSegueWithIdentifier:@"inputSelectionSegue" sender:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)didTapRecordButton:(id)sender {
    NSString *orgCode = [self.accesscodeTextField.text isEqualToString:@""] ? nil : self.accesscodeTextField.text;
    if (![self.delegate respondsToSelector:@selector(didChooseOrganizationCode:sender:)]) {
        ((User *)[User sharedModel]).organizationCode = orgCode;
        User *user = [User sharedModel];
        [user updateBrandWithAccesscode];
        [user save];
    }
    else {
        [self.delegate didChooseOrganizationCode:orgCode sender:sender];
    }

    if(self.initialSetupFromRegistration == YES){
        [self performSegueWithIdentifier:@"inputSelectionSegue" sender:self];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }

}

#pragma mark - Methods


-(void)underlineNoteTextViewSubstrings {
//    NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithAttributedString:self.noteTextView.attributedText];
    
//    self.noteTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor buttonColor],
//                                             NSUnderlineStyleAttributeName: [NSNumber numberWithInt:NSUnderlineStyleSingle]};
//    
//    NSString *email = @"mailto:solutions@glucoguide.com?subject=Tell me more about the GlucoGuide's access code!";
//    email = [email stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
//    
//    [noteStr addAttribute:NSLinkAttributeName
//                    value:[NSURL URLWithString:email]
//                    range:NSMakeRange(46, 10)];
//    
//    self.noteTextView.attributedText = noteStr;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    if(indexPath.row == 1) {
        return 60.0;
    }

    return 44;
}

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
        cell = [tableView dequeueReusableCellWithIdentifier:@"accesscodeCell" forIndexPath:indexPath];
        self.accesscodeTextField = (UITextField *)[cell viewWithTag:ACCESS_CODE_TAG_ACCESS_CODE];
        
        self.accesscodeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.accesscodeTextField.text = self.initialOrganizationCode;
        
        self.accesscodeTextField.returnKeyType = UIReturnKeyDone;
        [self.accesscodeTextField addTarget:self action:@selector(textFieldDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
        
        [self.accesscodeTextField becomeFirstResponder];
    }
    else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"noteCell" forIndexPath:indexPath];
        
        UILabel *lblUsage = (UILabel *)[cell viewWithTag:100];
        lblUsage.textColor = [UIColor blackColor];
        lblUsage.text = [LocalizationManager getStringFromStrId:@"If your organization requires you to use a specific Access Code, please enter it above. If not, please leave blank"];
        lblUsage.numberOfLines = 0;
        lblUsage.contentMode = NSTextAlignmentCenter;
        lblUsage.lineBreakMode = NSLineBreakByWordWrapping;
                        
    }
    [self setLastCellSeperatorToLeft:cell];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.accesscodeTextField becomeFirstResponder];
    }
    else {
        [self.accesscodeTextField resignFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // reduce the default footer height when using a grouped table to zero (using 0.0 doesn't work)
}

-(void)setLastCellSeperatorToLeft:(UITableViewCell*)cell
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




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     NSString *segueId = [segue identifier];
    if ([segueId isEqualToString:@"inputSelectionSegue"]) {
        UINavigationController *destVC = [segue destinationViewController];
        InputSelectionTableViewController *inputSelectionController = destVC.viewControllers[0];
        inputSelectionController.initialSetupFromRegistration = YES;
    }

}


@end
