//
//  BloodPressureSummaryViewController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-08-03.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "BloodPressureSummaryViewController.h"
#import "AddBloodPressureViewController.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"
#import "StyleManager.h"
#import "BPRecord.h"
#import "GGUtils.h"
#import "Constants.h"

@interface BloodPressureSummaryViewController ()
@property (nonatomic) NSMutableArray *bpArray;
@end

@implementation BloodPressureSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    
    //self.tableView.allowsSelection = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadBPData];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void) loadBPData {
    if (!self.bpArray) {
        self.bpArray = [[NSMutableArray alloc] init];
    }
    
    [BPRecord searchRecentBPWithFilter:nil].then(^(NSMutableArray *recentBP){
        self.bpArray = recentBP;
    }).finally(^(){
        if (self.bpArray == nil) {
            self.bpArray = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.bpArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
return [[self.bpArray[section] objectForKey:MACRO_BP_ROWS_ATTR] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [self.bpArray[section] objectForKey:MSG_BLOOD_PRESSURE_SUMMARY_SECTION_HEADER_CATEGORY];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BPCardCell" forIndexPath:indexPath];
    
    UILabel *systolicLabel = [cell viewWithTag:BP_DIASTOLIC_LABEL_TAG];
    UILabel *diastolicLabel = [cell viewWithTag:BP_SYSTOLIC_LABEL_TAG];
    UILabel *pulseLabel = [cell viewWithTag:BP_PULSE_LABEL_TAG];
    UILabel *noteLabel = [cell viewWithTag:BP_NOTE_LABEL_TAG];
    UILabel *recordedTimeLabel  = [cell viewWithTag:BP_RECORDEDTIME_LABEL_TAG];
    
    BPRecord *record = [[BPRecord alloc] init];
    record = [self.bpArray[indexPath.section] objectForKey:MACRO_BP_ROWS_ATTR][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    [systolicLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Sys: %@ mmHg"], record.systolic]];
    [diastolicLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Dia: %@ mmHg"], record.diastolic]];
    [pulseLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ BPM"], record.pulse]];
    [noteLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Note: %@"], record.note]];
    [recordedTimeLabel setText:[dateFormatter stringFromDate:record.recordedTime]];
    
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    

    BPRecord *record = [[BPRecord alloc] init];
    record = [self.bpArray[indexPath.section] objectForKey:MACRO_BP_ROWS_ATTR][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, YYYY - hh:mm a"];
    

    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Blood Pressure Info"]
                                          message: [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Date: %@\nSystolic: %@\nDiastolic: %@\nBPM: %@\nNote: %@"], [dateFormatter stringFromDate:record.recordedTime], record.systolic, record.diastolic, record.pulse, record.note]
                                          preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [tableView deselectRowAtIndexPath:indexPath animated:YES];
                               }];

    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
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
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Delete Blood Pressure Log"]
                                          message:[LocalizationManager getStringFromStrId:@"Are you sure you want to Delete this Blood Pressure Log ?"]
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
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
                                   BPRecord *record = [[BPRecord alloc] init];
                                   record = [self.bpArray[indexPath.section] objectForKey:MACRO_BP_ROWS_ATTR][indexPath.row];
                                   
                                   [record deleteBPRecordWithID:record.uuid];
                                   
                                   [self loadBPData];
                                   
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
}

@end
