//
//  ExerciseHistoryTableViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-03-04.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "ExerciseHistoryTableViewController.h"
#import "Constants.h"
#import "ExerciseRecord.h"
#import "UIColor+Extensions.h"
#import "GGUtils.h"
#import "UIView+Extensions.h"
#import "StyleManager.h"
#import "PedometerClass.h"

@interface ExerciseHistoryTableViewController ()

@property (nonatomic) NSArray *dataArray;
@property (nonatomic) int scrollToDateCounter;
@property (nonatomic) NSString *nameType;

@end

@implementation ExerciseHistoryTableViewController
@synthesize passedStartDate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableView.separatorColor = [UIColor grayBackgroundColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



- (void)viewWillAppear:(BOOL)animated {
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = [LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK];
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    [self loadData];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods

- (void)loadData {
    if (!self.dataArray) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    
    [ExerciseRecord searchRecentExerciseWithFilter:@"minutes > 0"].then(^(NSMutableArray *recentExercise){
        self.dataArray = recentExercise;
    }).finally(^(){
        if (self.dataArray == nil) {
            self.dataArray = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];

        
        for (int i = 0; [self.dataArray count] > i; ++i) {
            
            if ([[self.dataArray[i] objectForKey:@"category"] isEqualToString:self.passedStartDate]) {
                self.scrollToDateCounter = i;
                break;
            }
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:self.scrollToDateCounter];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];

        
    });
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.dataArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.dataArray[section] objectForKey:MACRO_EXERCISE_ROWS_ATTR]count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentExerciseCell" forIndexPath:indexPath];
    
    [cell setBackgroundColor:[UIColor clearColor]];
    
    ExerciseRecord *record = [[ExerciseRecord alloc] init];
    record = [self.dataArray[indexPath.section] objectForKey:MACRO_EXERCISE_ROWS_ATTR][indexPath.row];
    
    UILabel *addedTypeLabel = (UILabel *)[cell viewWithTag:RECENT_EXERCISE_CELL_LABEL_ADDED_TYPE];
    UIImageView *exerciseImage = (UIImageView *)[cell viewWithTag:RECENT_EXERCISE_CELL_IMAGE_EXERCISE];
    UILabel *lblSteps = (UILabel *)[cell viewWithTag:4];
    UILabel *addedTimeLabel = (UILabel *)[cell viewWithTag:RECENT_EXERCISE_CELL_LABEL_ADDED_TIME];
    UILabel *durationLabel = (UILabel *)[cell viewWithTag:RECENT_EXERCISE_CELL_LABEL_DURATION];
    UILabel *lblCalories = (UILabel *)[cell viewWithTag:7];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.dateFormat = @"hh:mm a";

  
    if (record.entryType == nil || [record.entryType integerValue] >= 100) {
        [addedTypeLabel setText:[LocalizationManager getStringFromStrId:EXERCISE_HISTORY_MANUAL_ADD]];
    }
    else {
        [addedTypeLabel setText:([record.entryType intValue] == 0 ? [LocalizationManager getStringFromStrId:EXERCISE_HISTORY_MANUAL_ADD] : [LocalizationManager getStringFromStrId:EXERCISE_HISTORY_AUTO_ADD])];
    }
    
    [durationLabel setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@mins"], record.minutes]];
    [addedTimeLabel setText:[outputFormatter stringFromDate:record.recordedTime]];
    
    
    if ([record.entryType intValue] == 0) {
        [lblSteps setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Note: %@"], record.note]];
    }else{
        [lblSteps setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%@ steps"], record.steps]];
    }
    
    [lblCalories setText:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f cals"], [record.calories floatValue]]];
    
    switch (record.type) {
        case ExerciseTypeLight: {
            [exerciseImage setImage:[UIImage imageNamed:@"lightExerciseIcon"]];
            break;
        }
        case ExerciseTypeModerate: {
            [exerciseImage setImage:[UIImage imageNamed:@"moderateExerciseIcon"]];
            break;
        }
        case ExerciseTypeVigorous: {
            [exerciseImage setImage:[UIImage imageNamed:@"vigorousExerciseIcon"]];
            break;
        }
        default:{
            break;
        }
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *view = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    NSString *headerText = [self.dataArray[section] objectForKey:@"category"];

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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ExerciseRecord *record = [[ExerciseRecord alloc] init];
    record = [self.dataArray[indexPath.section] objectForKey:MACRO_EXERCISE_ROWS_ATTR][indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm a"];
    
    
    
    switch (record.type) {
        case ExerciseTypeLight: {
           self.nameType = [LocalizationManager getStringFromStrId:@"Light Exercise"];
            break;
        }
        case ExerciseTypeModerate: {
            self.nameType = [LocalizationManager getStringFromStrId:@"Moderate Exercise"];
            break;
        }
        case ExerciseTypeVigorous: {
            self.nameType = [LocalizationManager getStringFromStrId:@"Vigorous Exercise"];
            break;
        }
        default:{
            break;
        }
    }
    
    NSString *noteText;
    if ([record.note length] < 1) {
        noteText = [LocalizationManager getStringFromStrId:@"None"];
    }else{
        noteText = record.note;
    }

    if ([record.entryType intValue] == 0) {
    
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Exercise Info"]
                                              message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Name: %@\nExercise Time: %@\nRecord Time: %@\nCalories: %@\nNote: %@"], self.nameType, record.minutes, [dateFormatter stringFromDate:record.recordedTime], [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f cals"], [record.calories floatValue]], noteText]
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
    
    }else{
        
        UIAlertController *alertController = [UIAlertController
                                              alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Exercise Info"]
                                              message:[NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Name: %@\nExercise Time: %@\nRecord Time: %@\nCalories: %@\nSteps: %@\nNote: %@"], self.nameType, record.minutes, [dateFormatter stringFromDate:record.recordedTime], [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"%.1f cals"], [record.calories floatValue]], record.steps, noteText]
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
