//
//  MedicationSummaryTableViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-02-17.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "MedicationSummaryTableViewController.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"
#import "StyleManager.h"
#import "MedicationRecord.h"
#import "User.h"
#import "GGUtils.h"

@interface MedicationSummaryTableViewController ()

@property (nonatomic) NSArray *medData;

@end

@implementation MedicationSummaryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    
    //[self performSegueWithIdentifier:@"ADD_MED_VIEW" sender:self];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadMedData];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)loadMedData {
    if (self.medData == nil) {
        self.medData = [[NSArray alloc] init];
    }
    self.medData = [[[MedicationRecord getUserMedicationsDetailed] reverseObjectEnumerator] allObjects];
    
    if ([self.medData count] == 0) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userLastMedication = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userLastMedication"]];
        
        User *user = [User sharedModel];
        [userLastMedication setObject:[NSString stringWithFormat:@""] forKey:user.userId];
        [prefs setObject:userLastMedication forKey:@"userLastMedication"];
        [prefs synchronize];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.medData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.medData[section] objectForKey:@"rows"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [self.medData[section] objectForKey:@"category"];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"medicationCardCell" forIndexPath:indexPath];
    
    UILabel *medNameLabel = [cell viewWithTag:MEDICATION_SUMMARY_TAG_MED_NAME_LABEL];
    UILabel *logTimeLabel = [cell viewWithTag:MEDICATION_SUMMARY_TAG_LOG_TIME_LABEL];
    UILabel *doseageValueLabel = [cell viewWithTag:MEDICATION_SUMMARY_TAG_DOSEAGE_VALUE_LABEL];
    UILabel *noteLabel = [cell viewWithTag:MEDICATION_SUMMARY_TAG_NOTE_LABEL];
    
    MedicationRecord *record = [[MedicationRecord alloc] init];
    record = [self.medData[indexPath.section] objectForKey:@"rows"][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    [medNameLabel setText:[record getMedicationNameWithID:record.medicationId]];
    [logTimeLabel setText:[dateFormatter stringFromDate:record.recordedTime]];
    [doseageValueLabel setText:[NSString stringWithFormat:@"%.1f %@", record.dose, record.measurement]];
    [noteLabel setText:[NSString stringWithFormat:@"Note: %@", record.note]];
    
    doseageValueLabel.textColor = [UIColor buttonColor];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MedicationRecord *record = [[MedicationRecord alloc] init];
    record = [self.medData[indexPath.section] objectForKey:@"rows"][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    NSString *noteText;
    if ([record.note length] < 1) {
        noteText = @"None";
    }else{
        noteText = record.note;
    }

    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:@"Medication Info"]
                                                    message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Name: %@\nDoseage: %@\nRecordedTime: %@\nNote: %@"],
                                                             [record getMedicationNameWithID:record.medicationId],
                                                             [NSString stringWithFormat:@"%lu %@", (unsigned long)record.dose, record.measurement],
                                                             [dateFormatter stringFromDate:record.recordedTime], noteText]
                                                   delegate:nil
                                          cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                          otherButtonTitles:nil];
    
    [alert show];
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
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){

        MedicationRecord *record = [[MedicationRecord alloc] init];
        self.medData = [[[MedicationRecord getUserMedicationsDetailed] reverseObjectEnumerator] allObjects];
    
        record = [self.medData[0] objectForKey:@"rows"][0];
    
        NSString *lastMedication = [NSString stringWithFormat:@"%@ - %@", [record getMedicationNameWithID:record.medicationId], [NSString stringWithFormat:@"%.1f %@", record.dose, record.measurement]];
    
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *userLastMedication = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userLastMedication"]];
    
        User *user = [User sharedModel];
        [userLastMedication setObject:lastMedication forKey:user.userId];
        [prefs setObject:userLastMedication forKey:@"userLastMedication"];
        [prefs synchronize];
    }

    
    
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
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Delete Medication Log"]
                                          message:[LocalizationManager getStringFromStrId:@"Are you sure you want to Delete this medication ?"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:@"Cancel"]
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
                                   MedicationRecord *record = [[MedicationRecord alloc] init];
                                   record = [self.medData[indexPath.section] objectForKey:@"rows"][indexPath.row];
                                   
                                   [record deleteMedicationRecordWithID:record.uuid];
                                   
                                   [self loadMedData];
                                   
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Navigation

- (IBAction)unwindToMedication:(UIStoryboardSegue *)unwindSegue{
    
}


@end
