//
//  InputSelectionTableViewController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-07-13.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "InputSelectionTableViewController.h"
#import "SWRevealViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "User.h"
#import "AppDelegate.h"
#import "GlucoguideAPI.h"
#import "GGUtils.h"

@interface InputSelectionTableViewController ()
@property (nonatomic) NSArray *inputSelectionRowLabels;
@property (nonatomic) NSArray *inputSelectionRowImageNames;
@property (nonatomic) NSMutableArray *selectedInputs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarButtonItem;

@end

@implementation InputSelectionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    [self.tableView setSeparatorColor:[UIColor buttonColor]];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userAndSelectedInputs = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userAndSelectedInputs"]];
    User *user = [User sharedModel];
    if (![userAndSelectedInputs objectForKey:user.userId] || [[userAndSelectedInputs objectForKey:user.userId] count] == 7) {
        NSArray *selectedInputs = [[NSArray alloc]initWithObjects:@YES, @YES, @YES, @YES, @YES, @YES, @YES, @YES, nil];
        [userAndSelectedInputs setObject:selectedInputs forKey:user.userId];
        [prefs setObject:userAndSelectedInputs forKey:@"userAndSelectedInputs"];
        [prefs synchronize];
        
    }
    
    
    self.inputSelectionRowLabels = @[[LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_DIET], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_EXERCISE], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_GLUCOSE], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_BLOODPRESSURE], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_MEDICATION], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_LABTEST], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_WEIGHT], [LocalizationManager getStringFromStrId:INPUT_SELECTION_ROW_SLEEP]];
    self.inputSelectionRowImageNames = @[@"dietInputIcon", @"exerciseInputIcon", @"glucoseInputIcon", @"bloodPressureInputIcon", @"insulinInputIcon", @"a1cInputIcon", @"weightInputIcon", @"sleepInputIcon"];
    
    self.selectedInputs = [[NSMutableArray alloc] init];
    
    for (int i = 0;i<[self.inputSelectionRowLabels count];i++) {
        [self.selectedInputs addObject:@YES];
    }
    
    
    [self readNSUserDefaults];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    /*
     0 Diet
     1 Exercise
     2 BG
     3 BP
     4 MED
     5 A1C
     6 weight
     7 Sleep
     */
    
    if(self.initialSetupFromRegistration){
        self.leftBarButtonItem.image = (UIImage *)[UIImage imageNamed:@"cancelIcon"];
        if ([GGUtils getAppType] == AppTypeGoHealthNow) {
            self.selectedInputs[0] = @YES;
            self.selectedInputs[1] = @YES;
            self.selectedInputs[4] = @YES;
            self.selectedInputs[6] = @YES;
            self.selectedInputs[7] = @YES;
            
        }
        else if ([GGUtils getAppType] == AppTypeGlucoGuide) {
            self.selectedInputs[0] = @YES;
            self.selectedInputs[1] = @YES;
            self.selectedInputs[2] = @YES;
            self.selectedInputs[3] = @YES;
            self.selectedInputs[4] = @YES;
            self.selectedInputs[5] = @YES;
            self.selectedInputs[6] = @YES;
            self.selectedInputs[7] = @YES;
        }
        else {
            
        }
    }
    
    [self.tableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated{
    
    User *user = [User sharedModel];
    if (user.isFreshUser) {
        [self.leftBarButtonItem setEnabled:NO];
        [self.leftBarButtonItem setTintColor: [UIColor clearColor]];
        
    }else{
        [self.leftBarButtonItem setEnabled:YES];
        [self.leftBarButtonItem setTintColor: [UIColor whiteColor]];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Event Handlers
- (IBAction)settingsButtonTapped:(id)sender {
    if(self.initialSetupFromRegistration){
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];

    }else{
        [self.revealViewController revealToggle:self];
    }
    
}

- (IBAction)saveButtonTapped:(id)sender {
    
    if([self.selectedInputs containsObject:@YES]){
        [self saveNSUserDefaults];
        UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                              message:[LocalizationManager getStringFromStrId:INPUT_SELECTION_SUCESS_MSG]
                                                             delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:nil];
        [promptAlert show];
        
        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:@selector(dismissRecordPromptAlert:)
                                       userInfo:promptAlert
                                        repeats:NO];
        
        [promptAlert promise].then(^{
            
            User *user = [User sharedModel];
            if (user.isFreshUser) {

                [self dismissViewControllerAnimated:YES completion:nil];
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                
                user.isFreshUser = NO;

            }else{
                SWRevealViewController *revealController = self.revealViewController;
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                UIViewController *mainTabBarController = [appDelegate mainTabBarController];
                [revealController pushFrontViewController:mainTabBarController animated:YES];
            }
        }).catch(^(NSError *err) {
            
        });
        
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Alert"] message:[LocalizationManager getStringFromStrId:@"Please select at least 1 item to log"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alertController animated:true completion:nil];
    }
    
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)saveNSUserDefaults{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *userAndSelectedInputs = [[NSMutableDictionary alloc] initWithDictionary:[prefs objectForKey:@"userAndSelectedInputs"]];
    User *user = [User sharedModel];
    [userAndSelectedInputs setObject:self.selectedInputs forKey:user.userId];
    [prefs setObject:userAndSelectedInputs forKey:@"userAndSelectedInputs"];
    [prefs synchronize];
    
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getActualNamesOfSelectedInputAndSendToServer];
    });
}

-(void)getActualNamesOfSelectedInputAndSendToServer{
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    User *user = [User sharedModel];
    NSArray *preNamesArray = [[NSArray alloc] initWithArray: [NSMutableArray arrayWithArray:[[prefs objectForKey:@"userAndSelectedInputs"] objectForKey:user.userId]]];
    
    NSMutableArray *actualNamesArray = [[NSMutableArray alloc]initWithCapacity:8];
    

    if ([[preNamesArray objectAtIndex:0]  isEqual:@YES]){
        [actualNamesArray addObject:@"Diet"];
    }
    if ([[preNamesArray objectAtIndex:1]  isEqual:@YES]){
        [actualNamesArray addObject:@"Exercise"];
    }
    if ([[preNamesArray objectAtIndex:2]  isEqual:@YES]){
        [actualNamesArray addObject:@"Blood Glucose"];
    }
    if ([[preNamesArray objectAtIndex:3]  isEqual:@YES]){
        [actualNamesArray addObject:@"Blood Pressure"];
    }
    if ([[preNamesArray objectAtIndex:4]  isEqual:@YES]){
        [actualNamesArray addObject:@"Medication"];
    }
    if ([[preNamesArray objectAtIndex:5]  isEqual:@YES]){
        [actualNamesArray addObject:@"A1C"];
    }
    if ([[preNamesArray objectAtIndex:6]  isEqual:@YES]){
        [actualNamesArray addObject:@"Weight"];
    }
    if ([[preNamesArray objectAtIndex:7]  isEqual:@YES]){
        [actualNamesArray addObject:@"Sleep"];
    }
    
    NSDictionary *responseDic =[[NSDictionary alloc] initWithDictionary: [[GlucoguideAPI sharedService] sendInputSelectionWithArray:actualNamesArray]];
    
    if ([[responseDic objectForKey:@"Result"] isEqualToString:@"success"]) {
        NSLog(@"InputSelection upload: %@", [responseDic objectForKey:@"Result"]);
    }else{
        NSLog(@"InputSelection - Failed: %@", responseDic);
    }
    
}

-(void)readNSUserDefaults{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    User *user = [User sharedModel];
    if([prefs objectForKey:@"userAndSelectedInputs"]){
        self.selectedInputs = [NSMutableArray arrayWithArray:[[prefs objectForKey:@"userAndSelectedInputs"] objectForKey:user.userId]];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inputSelectionRowLabels count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"inputSelectionCell";
    NSString *inputSelectionRowName = self.inputSelectionRowLabels[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    
    if([self.selectedInputs[indexPath.row] isEqual:@YES]){
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    
    UIImageView *image = (UIImageView *)[cell viewWithTag:INPUT_SELECTION_ROW_IMAGE_TAG];
    UILabel *label = (UILabel *)[cell viewWithTag:INPUT_SELECTION_ROW_LABEL_TAG];
    
    image.image = [UIImage imageNamed:self.inputSelectionRowImageNames[indexPath.row]];
    label.text = inputSelectionRowName;
    [StyleManager stylelabel:label];

    // Configure the cell...
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
        NSString *headerName = [LocalizationManager getStringFromStrId:@"Choose your data to be logged:"];
        return headerName;
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerView = nil;
    headerView = [tableView dequeueReusableCellWithIdentifier:@"inputSelectionHeaderCell"];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:INPUT_SELECTION_HEADER_LABEL_TAG];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    return headerView;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([self.selectedInputs[indexPath.row] isEqual:@YES]) {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryNone];
        self.selectedInputs[indexPath.row] = @NO;
    }
    else {
        [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
        self.selectedInputs[indexPath.row] = @YES;
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

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
