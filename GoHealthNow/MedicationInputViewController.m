//
//  ViewController.h
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "MedicationInputViewController.h"
#import "MedicationInputTableViewCell.h"
#import "NotificationMedicationClass.h"
#import "MedicationRecord.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "TextAlertController.h"
#import "XMLUpdateClass.h"
#import "Constants.h"

@interface MedicationInputViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) NSString *selectedDrug;
@property (nonatomic) NSArray *insulins;
@property (nonatomic) NSArray *medications;
@property (nonatomic) NSArray *userDefined;
@property (nonatomic) NSArray *tempMedicationArray;
@property (nonatomic) UIAlertController *notFoundAlert;
@property (nonatomic) NSString *addMedicationName;

@property (nonatomic) BOOL isFiltered;
@property (nonatomic) BOOL found;

@end

@implementation MedicationInputViewController

#pragma mark - Life Cycle

-(void)viewWillAppear:(BOOL)animated{
    self.searchBar.text = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    self.definesPresentationContext = YES;
    
    [self setNeedsStatusBarAppearanceUpdate];

    [self loadMedicationIntoArrays];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                            action:@selector(barButtonBackPressed:)];
    

    
    self.navigationItem.leftBarButtonItem = backButton;
}

#pragma mark - Reload XML
-(void)loadMedicationIntoArrays{
    
    self.medications = [MedicationRecord getAllMedications];
    
    self.tempMedicationArray = [[NSMutableArray alloc]initWithArray:[self splitArrayFrom:[MedicationRecord getAllMedications]]];
    
    self.insulins = [self.tempMedicationArray objectAtIndex:0];
    self.medications = [self.tempMedicationArray objectAtIndex:1];
    self.userDefined = [self.tempMedicationArray objectAtIndex:2];
    
    self.arrayDisplay = [[NSMutableArray alloc] init];
    self.arrayValue = [MedicationRecord getAllMedications];
    [self.arrayDisplay addObjectsFromArray:self.arrayValue];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_Name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.arrayDisplay = [NSMutableArray arrayWithArray:[self.arrayDisplay sortedArrayUsingDescriptors:sortDescriptors]];
    self.arrayValue = [NSMutableArray arrayWithArray:[self.arrayValue sortedArrayUsingDescriptors:sortDescriptors]];
    
}


#pragma mark - Bar Buttons
-(void)barButtonBackPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addNewMedPressed{
    
    TextAlertController* alert = [TextAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Add New Medication"]
                                                                   message:[LocalizationManager getStringFromStrId:@"Enter A Medication That is Not Listed"]
                                                            preferredStyle:ARAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [LocalizationManager getStringFromStrId:@"Medication Name"];
    }];
    
    
    ARAlertAction* defaultAction = [ARAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:ARAlertActionStyleDefault
                                                          handler:^(ARAlertAction *action) {
                                                              [self logTextFields:alert.textFields action:action];
                                                          }];
    
    [alert addAction:defaultAction];
    
    ARAlertAction* cancelAction = [ARAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL] style:ARAlertActionStyleCancel
                                                         handler:^(ARAlertAction *action) {
                                                             [self logTextFields:alert.textFields action:action];
                                                         }];
    
    [alert addAction:cancelAction];
    
    
    [alert presentInViewController:self animated:YES completion:nil];

}

#pragma mark - add User Define Medication
- (void)logTextFields:(NSArray *)textFields action:(ARAlertAction *)action
{
    
    NSArray *allMedication = [[NSArray alloc] initWithArray:[MedicationRecord getAllMedications]];
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:[allMedication count]];
    self.found = NO;
    
    for (NSDictionary *item in allMedication)
    {
        [result addObject:[item objectForKey:@"_Name"]];
    }
    
    if (![action.title isEqualToString:[LocalizationManager getStringFromStrId:MSG_CANCEL]]) {
        
        for (UITextField *textField in textFields)
        {
                for (int i = 0; i < [result count]; i++) {
                    
                    if ([[[[result objectAtIndex:i]  lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:textField.text]) {
                        [self displayUserEnteredMedicationAlertWith:MEDICATION_IN_LIST];
                        self.found = YES;
                        break;
                    }
                    
                    //NSRange range = [[[[result objectAtIndex:i]  lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""] rangeOfString:[[textField.text stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString]];
                    
                   // if (range.length > 0){
                    //    [self displayUserEnteredMedicationAlertWith:MEDICATION_IN_LIST];
                    //    self.found = YES;
                     //   break;
                    //}
                    
                }
            
            self.addMedicationName = textField.text;
        }
        
        if (self.found == NO && [self.addMedicationName length] > 0) {
            NSLog(@"Medication to Add:%@", self.addMedicationName);
            [[XMLUpdateClass getInstance] addMedicationToUserMedicationXMLWithMedicationName:self.addMedicationName];
            [self displayUserEnteredMedicationAlertWith:[LocalizationManager getStringFromStrId:MEDICATION_ADDED]];
            [self loadMedicationIntoArrays];
            [self.tableView reloadData];
        }

    }
}

-(void)displayUserEnteredMedicationAlertWith:(NSString *)message{
    
    self.notFoundAlert = [UIAlertController alertControllerWithTitle:message
                                                             message:@""
                                                      preferredStyle: UIAlertControllerStyleAlert];

    [self presentViewController:self.notFoundAlert animated:YES completion: nil];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5
                                     target:self
                                   selector:@selector(dismissFoundAlert)
                                   userInfo:nil
                                    repeats:NO];
    
}

-(void)dismissFoundAlert{
    [self.notFoundAlert dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - splitArrayForTableDataSource
-(NSArray *)splitArrayFrom:(NSArray *)insulinArray{
    
    NSMutableArray *tempArrayInsulin = [[NSMutableArray alloc]init];
    NSMutableArray *tempArrayMedication = [[NSMutableArray alloc]init];
    NSMutableArray *tempArrayUserDefined = [[NSMutableArray alloc]init];
    
    for (NSDictionary *item in insulinArray)
    {
        if ([[[item objectForKey:@"_ID"]substringToIndex:1] isEqualToString:@"i"]) {
            [tempArrayInsulin addObject:item];
        }else if ([[[item objectForKey:@"_ID"]substringToIndex:1] isEqualToString:@"c"]) {
            [tempArrayUserDefined addObject:item];
        }else{
            [tempArrayMedication addObject:item];
        }
    }
    
    NSArray *returnInsulins = [[NSArray alloc]initWithArray:tempArrayInsulin];
    NSArray *returnMedication = [[NSArray alloc]initWithArray:tempArrayMedication];
    NSArray *returnUserDefined = [[NSArray alloc]initWithArray:tempArrayUserDefined];
    
    //Sort User Defined Medication Array
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"_Name"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    returnUserDefined = [returnUserDefined sortedArrayUsingDescriptors:sortDescriptors];
    
    
    NSArray *returningArray = [[NSArray alloc] initWithObjects:returnInsulins, returnMedication, returnUserDefined, nil];
    
    return returningArray;
    
}


#pragma mark - Table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(self.isFiltered){
        return 1;
    }else{
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (self.isFiltered) {
        return 0;
    }else{
        if (section == 1) {
            
            if ([self.userDefined count] < 1) {
                return 0;
            }else{
               return 42;
            }
            
        }else if (section == 0){
         return 105;
            
        }else{
            return 42;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    long rowCount = 0;
    
    if(self.isFiltered){
        rowCount = [self.arrayDisplay count];
    }else{
    
        if (section == 0) {
            rowCount = 0;
        }else if (section == 1){
            rowCount = [self.userDefined count];
        }else if (section == 2){
            rowCount = [self.insulins count];
        }else if (section == 3){
            rowCount = [self.medications count];
        }
    }
    
    return rowCount;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    if(self.isFiltered){
    }else{
    
        if (section == 0) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
            ////
            
            UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 20, 55)];
            NSString *string2 = [LocalizationManager getStringFromStrId:@"Be creative when creating new medications.  Create a name that encompasses many pills or multivitamins and set the dosage to 1."];
            
            label2.font = [UIFont systemFontOfSize:14];
            label2.textColor = [UIColor blackColor];
            label2.textAlignment = NSTextAlignmentCenter;
            label2.numberOfLines = 4;
            label2.lineBreakMode = NSLineBreakByWordWrapping;
            label2.backgroundColor = [UIColor whiteColor];
            [label2 setText:string2];
            [view addSubview:label2];
            view.backgroundColor = [UIColor clearColor];
            
            ///
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 55, tableView.frame.size.width - 20, 42)];
            NSString *string = [LocalizationManager getStringFromStrId:@"Tap To Add New Medication"];
            
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            label.backgroundColor = [UIColor buttonColor];
            [label setText:string];
            [view addSubview:label];
            view.backgroundColor = [UIColor clearColor];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addNewMedPressed)];
            tapGesture.cancelsTouchesInView = NO;
            [view addGestureRecognizer:tapGesture];
            
            return view;
            
        }else if (section == 1){

            if ([self.userDefined count]) {
                UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 42)];
                NSString *string = [LocalizationManager getStringFromStrId:@"User Entered Medication"];
                
                label.font = [UIFont boldSystemFontOfSize:18];
                label.textColor = [UIColor darkGrayColor];
                label.textAlignment = NSTextAlignmentCenter;
                label.numberOfLines = 0;
                label.lineBreakMode = NSLineBreakByTruncatingMiddle;
                label.backgroundColor = [UIColor groupTableViewBackgroundColor];
                [label setText:string];
                [view addSubview:label];
                view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:244.0/255.0 blue:250/255.0 alpha:1];
                return view;
            }
        }else if (section == 2){

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 42)];
            NSString *string = [LocalizationManager getStringFromStrId:@"Insulin"];
            
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            label.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [label setText:string];
            [view addSubview:label];
            view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:244.0/255.0 blue:250/255.0 alpha:1];
            return view;
            
        }else if (section == 3){

            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width - 10, 42)];
            NSString *string = [LocalizationManager getStringFromStrId:@"Medication"];
            
            label.font = [UIFont boldSystemFontOfSize:18];
            label.textColor = [UIColor darkGrayColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByTruncatingMiddle;
            label.backgroundColor = [UIColor groupTableViewBackgroundColor];
            [label setText:string];
            [view addSubview:label];
            view.backgroundColor = [UIColor colorWithRed:235.0/255.0 green:244.0/255.0 blue:250/255.0 alpha:1];
            return view;
        }

    
    }
    return view;
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *tableIdentifier = @"Cell";
    MedicationInputTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    
    if(self.isFiltered){
        cell.label_Value.text = self.arrayDisplay[indexPath.row][@"_Name"];
    }else{
        
        if (indexPath.section == 0) {
            
        }else if (indexPath.section == 1){
           cell.label_Value.text = self.userDefined[indexPath.row][@"_Name"];
        }else if (indexPath.section == 2){
           cell.label_Value.text = self.insulins[indexPath.row][@"_Name"];
        }else if (indexPath.section == 3){
          cell.label_Value.text = self.medications[indexPath.row][@"_Name"];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.view endEditing:YES];
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    [reminder addNotificationIndex:@"-1"];
    
    if(self.isFiltered){
        self.searchBar.text = [self.arrayDisplay objectAtIndex:indexPath.row][@"_Name"];
        [reminder addReminderDrug:[self.arrayDisplay objectAtIndex:indexPath.row]];
        [self performSegueWithIdentifier:@"segueToReminerDetails" sender:self];
    }else{
    
        if (indexPath.section == 0) {
            [self addNewMedPressed];
        }else if (indexPath.section == 1){
            self.searchBar.text = [self.userDefined objectAtIndex:indexPath.row][@"_Name"];
            [reminder addReminderDrug:[self.userDefined objectAtIndex:indexPath.row]];
            [self performSegueWithIdentifier:@"segueToReminerDetails" sender:self];
        }else if (indexPath.section == 2){
            self.searchBar.text = [self.insulins objectAtIndex:indexPath.row][@"_Name"];
            [reminder addReminderDrug:[self.insulins objectAtIndex:indexPath.row]];
            [self performSegueWithIdentifier:@"segueToReminerDetails" sender:self];
        }else if (indexPath.section == 3){
            self.searchBar.text = [self.medications objectAtIndex:indexPath.row][@"_Name"];
            [reminder addReminderDrug:[self.medications objectAtIndex:indexPath.row]];
            [self performSegueWithIdentifier:@"segueToReminerDetails" sender:self];
        }
    }
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}


#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    if (searchText.length == 0) {
        [self.arrayDisplay removeAllObjects];
        [self.arrayDisplay addObjectsFromArray:self.arrayValue];
        self.isFiltered = FALSE;
        [self performSelector:@selector(hideKeyboardWithSearchBar:) withObject:searchBar afterDelay:0];
    }
    else{
        
        self.isFiltered = TRUE;
        
        [self.arrayDisplay removeAllObjects];
        
        for (NSDictionary *record in self.arrayValue) {
            
            NSString *string = [record objectForKey:@"_Name"];
            
            NSRange r = [string rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (r.location != NSNotFound ) {
                [self.arrayDisplay addObject:record];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self.arrayDisplay removeAllObjects];
    self.isFiltered = FALSE;
    [self.tableView reloadData];
    
    searchBar.text = nil;
    [searchBar resignFirstResponder];
}

-(void)hideKeyboardWithSearchBar:(UISearchBar *)searchBar{
    [self.view endEditing:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
