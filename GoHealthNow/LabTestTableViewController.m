//
//  LabTestTableViewController.m
//  GoHealthNow
//
//  Created by Haoyu Gu on 2017-05-25.
//  Copyright © 2017 GoHealthNow. All rights reserved.
//

#import "LabTestTableViewController.h"
#import "UIColor+Extensions.h"
#import "GGUtils.h"
#import "Constants.h"
#import "StyleManager.h"
#import "A1CRecord.h"

@interface LabTestTableViewController ()

@property (nonatomic) NSArray *a1cRecords;

@end

@implementation LabTestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationItem.title = [LocalizationManager getStringFromStrId:@"Lab Tests"];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    [self loadA1CData];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)loadA1CData {
    if (!self.a1cRecords) {
        self.a1cRecords = [[NSMutableArray alloc] init];
    }
    
    [A1CRecord searchRecentA1CWithFilter:nil].then(^(NSMutableArray *recentA1C){
        self.a1cRecords = recentA1C;
    }).finally(^(){
        if (self.a1cRecords == nil) {
            self.a1cRecords = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)navibarLeftButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.a1cRecords count]==0 ? 1 : [self.a1cRecords count];
    }
    else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return [LocalizationManager getStringFromStrId:@"Tests Entered by User"];
    }
    else {
        return [LocalizationManager getStringFromStrId:@"Tests Uploaded by Lab (if any)"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LabTestNoRecordCardCell"];
    if (indexPath.section == 0) {
        if ([self.a1cRecords count] != 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"LabTestRecordCardCell"];
            
            UILabel *titleLabel = [cell viewWithTag:LAB_TEST_TAG_RECORD_CELL_TITLE_LABEL];
            UILabel *dateLabel = [cell viewWithTag:LAB_TEST_TAG_RECORD_CELL_DATE_LABEL];
            UILabel *valueLabel = [cell viewWithTag:LAB_TEST_TAG_RECORD_CELL_VALUE_LABEL];
            
            if (IS_IPHONE_5) {
                [dateLabel setFont:[UIFont systemFontOfSize:14]];
            }
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
            
            //
            //since we only have a1c record for now, thus we directly set the title to "A1C" for now!
            //
            [titleLabel setText:[LocalizationManager getStringFromStrId:@"A1C"]];
            [dateLabel setText:[dateFormatter stringFromDate:((A1CRecord *)self.a1cRecords[indexPath.row]).recordedTime]];
            [valueLabel setText:[NSString stringWithFormat:@"%.1f%%", [((A1CRecord *)self.a1cRecords[indexPath.row]).value floatValue]]];
            
        }
    }
    else {
        //we dont have any uploaded value for now
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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
