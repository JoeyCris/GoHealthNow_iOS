//
//  ViewController.h
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "MedicationProfileListViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "User.h"
#import "NotificationMedicationClass.h"
#import "InsulinRecord.h"
#import "MedicationRecord.h"

@interface MedicationProfileListViewController ()

@property (nonatomic) NSArray *insulins;
@property (nonatomic) NSArray *medications;

@end

@implementation MedicationProfileListViewController

#pragma mark - View Lifecyle

- (void)viewDidLoad {
    
    [StyleManager styleTable:self.tableView];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    
    self.arrayMedicationNotification = [NSMutableArray arrayWithArray:[[NotificationMedicationClass getInstance] getAllNotificationsFromDatabase]];
}

#pragma mark - Table view DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.arrayMedicationNotification count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    UILabel *lblName = (UILabel *)[cell viewWithTag:100];
    lblName.text = [[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"drugName"];
        
    UILabel *lblDosage = (UILabel *)[cell viewWithTag:200];
    lblDosage.text = [[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"drugDose"];
        
    UILabel *lblTime = (UILabel *)[cell viewWithTag:300];
    lblTime.text = [[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"notificationTime"];
        
    UILabel *lblRepeat = (UILabel *)[cell viewWithTag:400];
    lblRepeat.text = @"Daily";
    
    return cell;
}


#pragma mark - TableView Delegates
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self setInformationForSelectedMedication:[[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"drugName"] indexPath:indexPath];
  
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    DosageInputViewController *viewController = [storyboard  instantiateViewControllerWithIdentifier:@"DosageInputViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
        [reminder deleteNotificationFromDatabase:[[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
        [self.arrayMedicationNotification removeObjectAtIndex:indexPath.row];
            
        [tableView reloadData];
    }
}

#pragma mark - IBAction
- (IBAction)btnAddReminder:(id)sender {
    
    [self performSegueWithIdentifier:@"segueToReminderType" sender:self];
}

- (IBAction)btnsettings:(id)sender {
    [self.revealViewController revealToggle:self];
}


#pragma mark - Custom

-(void)setInformationForSelectedMedication:(NSString *)MedicationName indexPath:(NSIndexPath *)indexPath{
    
    //SWITCH SECTION 0 = medication
    self.insulins = [InsulinRecord getAllInsulins];
    self.medications = [MedicationRecord getAllMedications];
    
    long locationInInsulinArray = -1;
    long locationInMedicationArray = -1;
    
    for (NSDictionary* dict in self.insulins) {
        if ([[dict objectForKey:@"_Name"] isEqualToString:MedicationName]) {
            locationInInsulinArray = [self.insulins indexOfObject:dict];
        }
    }
    
    for (NSDictionary* dict in self.medications){
        if ([[dict objectForKey:@"_Name"] isEqualToString:MedicationName]) {
            locationInMedicationArray = [self.medications indexOfObject:dict];
        }
    }
    
    NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
    
    if (locationInInsulinArray > -1) {
        [reminder addReminderDrug:[self.insulins objectAtIndex:locationInInsulinArray]];
    }else{
        [reminder addReminderDrug:[self.medications objectAtIndex:locationInMedicationArray]];
    }
    
    [reminder addReminderDosage:[[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"drugDose"]];
    [reminder addReminderTime:[[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"notificationTime"]];
    [reminder addNotificationIndex:[[self.arrayMedicationNotification objectAtIndex:indexPath.row]valueForKey:@"indexID"]];
}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
}


@end
