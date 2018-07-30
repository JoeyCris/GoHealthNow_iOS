//
//  ChooseInsulinController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-07-03.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "ChooseInsulinController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "InsulinRecord.h"
#import "Constants.h"
#import "User.h"

@interface ChooseInsulinController ()

@property (nonatomic) NSArray *insulins;
@property (nonatomic) NSArray *userProfileInsulins;

@end

@implementation ChooseInsulinController

#pragma mark - View Lifecyle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleTable:self.tableView];
    
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    self.tableView.allowsSelection = NO;
    
    self.insulins = [InsulinRecord getAllInsulins];
    self.userProfileInsulins = ((User *)[User sharedModel]).insulins;
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.insulins count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            NSAttributedString *attributedText = [self firstCellAttributedStr];
            CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(tableView.bounds.size.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                       context:nil];
            return rect.size.height + 20;

            break;
        }
        default:
            return 44.0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
        case 0:
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"insulinFirstTableCell"];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.attributedText = [self firstCellAttributedStr];
            break;
        default: {
            cell = [tableView dequeueReusableCellWithIdentifier:@"insulinTableCell" forIndexPath:indexPath];
            UILabel *insulinNameLabel = (UILabel *)[cell viewWithTag:CHOOSE_INSULIN_TAG_NAME_LABEL];
            UISwitch *chooseSwitch = (UISwitch *)[cell viewWithTag:CHOOSE_INSULIN_TAG_SWITCH];
            NSUInteger insulinRow = indexPath.row - 1;
            
            BOOL isInUserProfile = self.userProfileInsulins && [self.userProfileInsulins indexOfObject:self.insulins[insulinRow]] != NSNotFound;
            [chooseSwitch setOn:isInUserProfile];
            
            chooseSwitch.tag = insulinRow;
            [chooseSwitch addTarget:self
                             action:@selector(didToggleSwitchState:)
                   forControlEvents:UIControlEventValueChanged];
            
            insulinNameLabel.text = self.insulins[insulinRow][@"_Name"];
            
            break;
        }
    }
    
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

#pragma mark - Event Handlers

- (void)didToggleSwitchState:(id)sender {
    UISwitch *chooseSwitch = (UISwitch *)sender;
    
    User *user = [User sharedModel];
    NSMutableArray *currentUserProfileInsulins = [[NSMutableArray alloc] initWithArray:user.insulins];
    
    if (chooseSwitch.isOn) {
        [currentUserProfileInsulins addObject:self.insulins[chooseSwitch.tag]];
    }
    else {
        [currentUserProfileInsulins removeObject:self.insulins[chooseSwitch.tag]];
    }
    
    user.insulins = currentUserProfileInsulins;
    self.userProfileInsulins = currentUserProfileInsulins;
    
    [self.delegate didUpdateUserProfileWithInsulin:self.insulins[chooseSwitch.tag] sender:self];
}

#pragma mark - Methods

- (NSAttributedString *)firstCellAttributedStr {
    NSString *cellText = @"Please choose the types of insulin you take on a regular basis:";
    UIFont *cellFont = [UIFont boldSystemFontOfSize:18.0];
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:cellText
                                                                         attributes:@ {
                                                                            NSFontAttributeName: cellFont,
                                                                            NSForegroundColorAttributeName: [UIColor darkGrayColor]
                                          }];
    return attributedText;
}

@end
