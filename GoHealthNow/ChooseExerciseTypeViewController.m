//
//  ChooseExerciseTypeViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-24.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "ChooseExerciseTypeViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "AddExerciseRecordViewController.h"
#import "NotificationExerciseClass.h"
#import "AppDelegate.h"
#import "LastEnteredExerciseClass.h"
#import <CoreMotion/CoreMotion.h>

@interface ChooseExerciseTypeViewController()

@property (nonatomic) NSDictionary *exerciseTypeInfo;

@end

@implementation ChooseExerciseTypeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTableHeaderView];
    [self checkIfComingFromNotification];

    [StyleManager styleTable:self.tableView];
    self.tableView.separatorColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.exerciseTypeInfo = @{
                              [NSNumber numberWithInt:ExerciseTypeLight]: @{
                                                     EXERCISE_INFO_TYPE: [NSNumber numberWithInt:ExerciseTypeLight],
                                                     EXERCISE_INFO_COLOR: [UIColor lightExerciseColor],
                                                     EXERCISE_INFO_DESC: [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_DESC],
                                                     EXERCISE_INFO_EXAMPLES: @[[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_LIGHT_WALKING],[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_YOGA],
                                                                               [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_TAICHI], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_LIGHT_EXERCISE_INFO_EXAMPLE_LIGHT_HOUSEWORK]],
                                                     EXERCISE_INFO_CALS_PER_UNIT: @1.5
                                                     },
                              [NSNumber numberWithInt:ExerciseTypeModerate]: @{
                                                        EXERCISE_INFO_TYPE: [NSNumber numberWithInt:ExerciseTypeModerate],
                                                        EXERCISE_INFO_COLOR: [UIColor moderateExerciseColor],
                                                        EXERCISE_INFO_DESC: [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_DESC],
                                                        EXERCISE_INFO_EXAMPLES: @[[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_WALKING_BRISKLY], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_WATER_AEROBICS], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_BICYCLING_SLOWLY], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_TENNIS], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_BALLROOM_GARDENING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_GENERAL_GARDENING],[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_MODERATE_EXERCISE_INFO_EXAMPLE_HEAVY_HOUSEWORK]],
                                                        EXERCISE_INFO_CALS_PER_UNIT: @4.5
                                                        },
                              [NSNumber numberWithInt:ExerciseTypeVigorous]: @{
                                                        EXERCISE_INFO_TYPE: [NSNumber numberWithInt:ExerciseTypeVigorous],
                                                        EXERCISE_INFO_COLOR: [UIColor vigrousExerciseColor],
                                                        EXERCISE_INFO_DESC: [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_INFO_DESC],
                                                        EXERCISE_INFO_EXAMPLES: @[[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_RACE_WALKING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_JOGGING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_RUNNING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_SWIMMING_LAPS], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_TENNIS], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_AEROBICS],[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_BICYCLING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_JUMPING_ROLE], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_HEAVY_GARDENING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_HIKING_UPHILL], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_INTENSE_WEIGHT_LIFTING], [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_VIGOROUS_EXERCISE_EXAMPLE_INTERVAL_TRAINING]],
                                                        EXERCISE_INFO_CALS_PER_UNIT: @8.5
                                                        }
                              };
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    ExerciseType currentExerciseType;
    NSDictionary *currentExerciseTypeInfo = nil;
    
    // get the row containing the name and the succeeding row that contains the description
    if (indexPath.row == ExerciseTypeLight + 1 || indexPath.row == ExerciseTypeLight + 2) {
        currentExerciseType = ExerciseTypeLight;
    }
    else if (indexPath.row == ExerciseTypeModerate + 3 || indexPath.row == ExerciseTypeModerate + 4) {
        currentExerciseType = ExerciseTypeModerate;
    }
    else if (indexPath.row == ExerciseTypeVigorous + 5 || indexPath.row == ExerciseTypeVigorous + 6) {
        currentExerciseType = ExerciseTypeVigorous;
    }
    
    currentExerciseTypeInfo = self.exerciseTypeInfo[[NSNumber numberWithLong:currentExerciseType]];
    
    if ([self isExerciseTypeCellFromIndexPath:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseTypeCell" forIndexPath:indexPath];
        
        UILabel *exerciseTypeLabel = (UILabel *)[cell viewWithTag:EXERCISE_TYPE_TAG_TYPE_LABEL];
        exerciseTypeLabel.textColor = currentExerciseTypeInfo[EXERCISE_INFO_COLOR];
        
        switch (currentExerciseType) {
            case ExerciseTypeLight:
                exerciseTypeLabel.text = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_LIGHT];
                break;
            case ExerciseTypeModerate:
                exerciseTypeLabel.text = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_MODERATE];
                break;
            case ExerciseTypeVigorous:
                exerciseTypeLabel.text = [LocalizationManager getStringFromStrId:EXERCISE_TYPE_VIGOROUS];
                break;
        }
        
        [StyleManager styleTableCell:cell];
    }
    else if ([self isExerciseSeperatorCellFromIndexPath:indexPath]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseSeperatorCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"exerciseTypeDescriptionCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *exerciseDescriptionLabel = (UILabel *)[cell viewWithTag:EXERCISE_TYPE_TAG_DESC_LABEL];
        UILabel *exerciseExampleLabel = (UILabel *)[cell viewWithTag:EXERCISE_TYPE_TAG_EXAMPLE_LABEL];
        
        NSString *exerciseExamples = [(NSArray *)currentExerciseTypeInfo[EXERCISE_INFO_EXAMPLES] componentsJoinedByString:@", "];
        
        exerciseDescriptionLabel.text = currentExerciseTypeInfo[EXERCISE_INFO_DESC];
        exerciseExampleLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_TYPE_VIEW_EXERCISE_EXAMPLE], exerciseExamples];
        
        [StyleManager stylelabel:exerciseDescriptionLabel];
        exerciseExampleLabel.textColor = [UIColor blueTextColor];
        
        [StyleManager styleTableCell:cell];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isExerciseTypeCellFromIndexPath:indexPath]) {
        return 44.0;
    }
    else if ([self isExerciseSeperatorCellFromIndexPath:indexPath]) {
        return 35.0;
    }
    else if (indexPath.row == 2) {
        // light exercise description
        return 170.0;
    }
    else {
        return 240.0;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellTapable:indexPath]) {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellTapable:indexPath]) {
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
        
        [self performSegueWithIdentifier:@"addExerciseRecord" sender:indexPath];
    }
}

#pragma mark - Methods

- (BOOL)isExerciseTypeCellFromIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
        case 4:
        case 7:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isCellTapable:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 1:
        case 2:
        case 4:
        case 5:
        case 7:
        case 8:
            return YES;
        default:
            return NO;
    }
}

- (BOOL)isExerciseSeperatorCellFromIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
        case 3:
        case 6:
        case 9:
            return YES;
        default:
            return NO;
    }
}

- (void)setupTableHeaderView {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = [UIColor whiteColor];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    separatorView.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    if ([CMPedometer isStepCountingAvailable]) {
         headerLabel.text = [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_HEADER_CONTENT_WITH_PEDOMETER];
    }else{
        headerLabel.text = [LocalizationManager getStringFromStrId:MSG_CHOOSE_EXERCISE_HEADER_CONTENT_WITHOUT_PEDOMETER];
    }
    
    
   
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16.0];
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    [header addSubview:headerLabel];
    [header addSubview:separatorView];
    
    // Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = headerLabel.lineBreakMode;
    paraStyle.alignment = NSTextAlignmentCenter;
    CGRect labelBoundingRect = [headerLabel.text boundingRectWithSize:maximumLabelSize
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:@{
                                                                        NSFontAttributeName: headerLabel.font,
                                                                        NSParagraphStyleAttributeName: paraStyle
                                                                        }
                                                              context:nil];
    
    header.frame = CGRectMake(0.0, 0.0, self.tableView.frame.size.width, labelBoundingRect.size.height + 10.0);
    self.tableView.tableHeaderView = header;
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeCenterY
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeCenterY
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeLeadingMargin
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeLeadingMargin
                                                                              multiplier:1.0
                                                                                constant:8.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:headerLabel
                                                                               attribute:NSLayoutAttributeTrailingMargin
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeTrailingMargin
                                                                              multiplier:1.0
                                                                                constant:-8.0]];
    
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeLeading
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeLeading
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeTrailing
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [self.tableView.tableHeaderView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                                               attribute:NSLayoutAttributeBottom
                                                                               relatedBy:NSLayoutRelationEqual
                                                                                  toItem:self.tableView.tableHeaderView
                                                                               attribute:NSLayoutAttributeBottom
                                                                              multiplier:1.0
                                                                                constant:0.0]];
    [separatorView addConstraint:[NSLayoutConstraint constraintWithItem:separatorView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:1.0]];
}

#pragma mark - Navigation
- (IBAction)segueToExerciseTypeViewController:(UIStoryboardSegue *)unwindSegue {
}


-(void)checkIfComingFromNotification{
    
    NotificationExerciseClass *reminder= [NotificationExerciseClass getInstance];
    
    if ([reminder.stringComingFromWhere isEqualToString:@"logFromNotification"]){
         reminder.stringComingFromWhere = nil;
        
        if ([LastEnteredExerciseClass getInstance].getUserExerciseLastEntry) {
            
            int exerciseType = [[[LastEnteredExerciseClass getInstance].getUserExerciseLastEntry objectForKey:@"type"] intValue];
            
            NSIndexPath *indexPath = [[NSIndexPath alloc]init];
            indexPath = [NSIndexPath indexPathForItem:exerciseType inSection:0];
            
            [self performSegueWithIdentifier:@"addExerciseRecord" sender:indexPath];

        }else{
        
            [StyleManager styleNavigationBar:self.navigationController.navigationBar];
        
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]
                                         initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(dismissView)];
            self.navigationItem.leftBarButtonItem = leftItem;}
    
    }
}

-(void)dismissView{

    NotificationExerciseClass *reminder= [NotificationExerciseClass getInstance];
    [reminder addOneToReminderCountSkipForExerciseCompliance:[reminder.stringNotificationIndex intValue]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"addExerciseRecord"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        AddExerciseRecordViewController *destVC = ((UINavigationController *)[segue destinationViewController]).viewControllers.firstObject;
        
        switch (indexPath.row) {
            case 1:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeLight]];
                break;
            case 2:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeLight]];
                break;
            case 4:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeModerate]];
                break;
            case 5:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeModerate]];
                break;
            case 7:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeVigorous]];
                break;
            case 8:
                destVC.exerciseInfo = self.exerciseTypeInfo[[NSNumber numberWithInt:ExerciseTypeVigorous]];
                break;
            default:
                break;
        }
    }
}

@end
