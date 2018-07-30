//
//  NotificationMedicationClass.h
//  NotificationMedicationClass.h
//
//  Created by John Wreford on 7/08/2015.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//


#import "NotificationSelectViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "UIColor+Extensions.h"
#import "User.h"
#import "SWRevealViewController.h"
#import "NotificationMedicationClass.h"
#import "NotificationBloodGlucoseClass.h"
#import "NotificationDietClass.h"
#import "NotificationExerciseClass.h"
#import "NotificationBloodPressureClass.h"
#import "BloodGlucoseNotificationViewController.h"

@interface NotificationSelectViewController()

@property (nonatomic) NSArray *inputRows;
@property (nonatomic) NSArray *inputRowValues;
@property (nonatomic) NSArray *inputRowImageNames;

@property (nonatomic) BOOL didUpdateUserProfileWithInsulin;

@end

@implementation NotificationSelectViewController

- (IBAction)unwindToReminderList:(UIStoryboardSegue *)unwindSegue{
   [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.inputRows = @[[LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION], [LocalizationManager getStringFromStrId:INPUT_ROW_GLUCOSE], [LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE], [LocalizationManager getStringFromStrId:INPUT_ROW_DIET], [LocalizationManager getStringFromStrId:INPUT_ROW_BP]];
    self.inputRowImageNames = @[@"insulinInputIcon", @"glucoseInputIcon", @"exerciseInputIcon", @"dietInputIcon", @"bloodPressureInputIcon"];
    
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    [StyleManager styleTable:self.tableView];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NotificationMedicationClass *reminder = [NotificationMedicationClass getInstance];
    if ([reminder.stringComingFromWhere isEqualToString:@"createNew"]) {
        reminder.stringComingFromWhere = nil;
    }

    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.inputRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellId = @"inputCell";
    NSString *inputRowName = self.inputRows[indexPath.row];
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION]]  ||  [inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_GLUCOSE]]  || [inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_DIET]] || [inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE]] || [inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_BP]]) {
        cellId = @"inputCellWithExtraLabel";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:INPUT_ROW_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:INPUT_ROW_LABEL_TAG];
    
    image.image = [UIImage imageNamed:self.inputRowImageNames[indexPath.row]];
    label.text = inputRowName;
    [StyleManager stylelabel:label];
    
    UILabel *detailLabel = (UILabel *)[cell viewWithTag:INPUT_ROW_DETAIL_LABEL_TAG];
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_MEDICATION]]) {

        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Compliance rate: %@%%  Skipped: %@"], [[NotificationMedicationClass getInstance] getNotificationMedicationComplianceRate], [[NotificationMedicationClass getInstance] getNotificationMedicationCompliance]];
        
        NSRange skipNumRangeSecond = [detailLabel.text rangeOfString:@":" options:NSBackwardsSearch];
        NSRange skipNumRangeFirst = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeFirst.location + 2, 4)];  //17,4
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeSecond.location + 1, detailLabel.text.length - skipNumRangeSecond.location-1)];
        detailLabel.attributedText = detailAttributedStr;
  
    }
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_GLUCOSE]]) {
        
        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Compliance rate: %@%%  Skipped: %@"], [[NotificationBloodGlucoseClass getInstance] getNotificationBloodGlucoseComplianceRate],[[NotificationBloodGlucoseClass getInstance] getNotificationBloodGlucoseCompliance]];
        
        NSRange skipNumRangeSecond = [detailLabel.text rangeOfString:@":" options:NSBackwardsSearch];
        NSRange skipNumRangeFirst = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeFirst.location + 2, 4)];  //17,4
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeSecond.location + 1, detailLabel.text.length - skipNumRangeSecond.location-1)];
        detailLabel.attributedText = detailAttributedStr;
    }
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_DIET]]) {
        
        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Compliance rate: %@%%  Skipped: %@"], [[NotificationDietClass getInstance] getNotificationDietComplianceRate], [[NotificationDietClass getInstance] getNotificationDietCompliance]];
        
        NSRange skipNumRangeSecond = [detailLabel.text rangeOfString:@":" options:NSBackwardsSearch];
        NSRange skipNumRangeFirst = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeFirst.location + 2, 4)];  //17,4
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeSecond.location + 1, detailLabel.text.length - skipNumRangeSecond.location-1)];
        detailLabel.attributedText = detailAttributedStr;
        
    }
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_EXERCISE]]) {
        
        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Compliance rate: %@%%  Skipped: %@"], [[NotificationExerciseClass getInstance] getNotificationExerciseComplianceRate], [[NotificationExerciseClass getInstance] getNotificationExerciseCompliance]];
        
        NSRange skipNumRangeSecond = [detailLabel.text rangeOfString:@":" options:NSBackwardsSearch];
        NSRange skipNumRangeFirst = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeFirst.location + 2, 4)];  //17,4
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeSecond.location + 1, detailLabel.text.length - skipNumRangeSecond.location-1)];
        detailLabel.attributedText = detailAttributedStr;
    }
    
    if ([inputRowName isEqualToString:[LocalizationManager getStringFromStrId:INPUT_ROW_BP]]) {
        
        detailLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Compliance rate: %@%%  Skipped: %@"], [[NotificationBloodPressureClass getInstance] getNotificationBloodPressureComplianceRate], [[NotificationBloodPressureClass getInstance] getNotificationBloodPressureCompliance]];
        
        NSRange skipNumRangeSecond = [detailLabel.text rangeOfString:@":" options:NSBackwardsSearch];
        NSRange skipNumRangeFirst = [detailLabel.text rangeOfString:@":"];
        NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:detailLabel.text];
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeFirst.location + 2, 4)];  //17,4
        [detailAttributedStr addAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:detailLabel.font.pointSize]}
                                     range:NSMakeRange(skipNumRangeSecond.location + 1, detailLabel.text.length - skipNumRangeSecond.location-1)];
        detailLabel.attributedText = detailAttributedStr;
    }
    


    [StyleManager styleTableCell:cell];
    
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0: {
            [NotificationMedicationClass getInstance].stringComingFromWhere = @"createNew";
            [self performSegueWithIdentifier:@"segueToSelectMedication" sender:self];
            break;
        }
            
        case 1: {
            [self performSegueWithIdentifier:@"segueToGlucoseNotification" sender:self];
            break;
        }
            
        case 2: {
            [self performSegueWithIdentifier:@"segueToExerciseNotification" sender:self];
            break;
        }
            
        case 3: {
            [self performSegueWithIdentifier:@"segueToDietNotification" sender:self];
            break;
        }
        
        case 4: {
            [self performSegueWithIdentifier:@"segueToBloodPressureNotification" sender:self];
            break;
        }

        default:{
            break;
        }
            
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];

}

@end
