//
//  BloodGlucoseSummaryViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-02-15.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "BloodGlucoseSummaryViewController.h"
#import "AddGlucoseRecordViewController.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "UIView+Extensions.h"
#import "StyleManager.h"
#import "GlucoseRecord.h"
#import "User.h"
#import "GGUtils.h"


@interface BloodGlucoseSummaryViewController ()
@property (nonatomic) NSMutableArray *bgArray;

@end

@implementation BloodGlucoseSummaryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [StyleManager styleTable:self.tableView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    
    //[self performSegueWithIdentifier:@"ADD_GLUCOSE_VIEW" sender:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self loadBGData];
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods 

- (void) loadBGData {
    if (!self.bgArray) {
        self.bgArray = [[NSMutableArray alloc] init];
    }
    
    [GlucoseRecord searchRecentBGWithFilter:nil].then(^(NSMutableArray *recentBG){
        self.bgArray = recentBG;
    }).finally(^(){
        if (self.bgArray == nil) {
            self.bgArray = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    });
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.bgArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[self.bgArray[section] objectForKey:MACRO_BG_ROWS_ATTR] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [self.bgArray[section] objectForKey:[LocalizationManager getStringFromStrId:MSG_BLOOD_GLUCOSE_SUMMARY_SECTION_HEADER_CATEGORY]];
    
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bloodGlucoseCardCell" forIndexPath:indexPath];
    
    UILabel *logTypeLabel = [cell viewWithTag:BLOOD_GLUCOSE_SUMMARY_TAG_LOG_TYPE_LABEL];
    UILabel *logTimeLabel = [cell viewWithTag:BLOOD_GLUCOSE_SUMMARY_TAG_LOG_TIME_LABEL];
    UILabel *bgValueLabel = [cell viewWithTag:BLOOD_GLUCOSE_SUMMARY_TAG_BG_VALUE_LABEL];
    UILabel *bgNoteLabel  = [cell viewWithTag:BLOOD_GLUCOSE_SUMMARY_TAG_NOTE_LABEL];
    
    GlucoseRecord *record = [[GlucoseRecord alloc] init];
    NSArray *bgTypeMsg = [GlucoseRecord getBGTypeOptions];
    record = [self.bgArray[indexPath.section] objectForKey:MACRO_BG_ROWS_ATTR][indexPath.row];
    
    User *user = [User sharedModel];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm a"];
    
    [logTypeLabel setText:bgTypeMsg[[record.type intValue]]];
    [logTimeLabel setText:[dateFormatter stringFromDate:record.recordedTime]];
    [bgValueLabel setText:[NSString stringWithFormat:@"%.1f %@", (user.bgUnit == 0 ? [record.level valueWithMMOL]:[record.level valueWithMG]), (user.bgUnit == 0 ? [LocalizationManager getStringFromStrId:@"mmol"] : [LocalizationManager getStringFromStrId:@"mg"])]];
    [bgNoteLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Note: %@"], record.note]];
    
    if ([record.level valueWithMMOL] <= 3.9) {
        bgValueLabel.textColor = [UIColor GGRedColor];
    }
    else if ([record.level valueWithMMOL] >= 10) {
        bgValueLabel.textColor = [UIColor GGOrangeColor];
    }
    else {
        bgValueLabel.textColor = [UIColor GGGreenColor];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    GlucoseRecord *record = [[GlucoseRecord alloc] init];
    record = [self.bgArray[indexPath.section] objectForKey:MACRO_BG_ROWS_ATTR][indexPath.row];
    NSArray *bgTypeMsg = [GlucoseRecord getBGTypeOptions];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    User *user = [User sharedModel];
    
    NSString *noteText;
    if ([record.note length] < 1) {
        noteText = [LocalizationManager getStringFromStrId:@"None"];
    }else{
        noteText = record.note;
    }
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Blood Glucose Info"]
                                                               message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Name: %@\nLevel: %@\nRecord Time: %@\nNote: %@"], [bgTypeMsg objectAtIndex:[record.type intValue]], [NSString stringWithFormat:@"%.1f %@", (user.bgUnit == 0 ? [record.level valueWithMMOL]:[record.level valueWithMG]), (user.bgUnit == 0 ? [LocalizationManager getStringFromStrId:@"mmol"] : [LocalizationManager getStringFromStrId:@"mg"])], [dateFormatter stringFromDate:record.recordedTime], noteText]
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
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
                                          alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Delete Blood Glucose Log"]
                                          message:[LocalizationManager getStringFromStrId:@"Are you sure you want to Delete this Blood Glucose Log ?"]
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
                                   GlucoseRecord *record = [[GlucoseRecord alloc] init];
                                   record = [self.bgArray[indexPath.section] objectForKey:MACRO_BG_ROWS_ATTR][indexPath.row];
                                   
                                   [record deleteGlucoseRecordWithID:record.uuid];
                                   
                                   [self loadBGData];
                                   
                               }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
    
    
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
