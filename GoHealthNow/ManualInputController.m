//
//  ManualInputController.m
//  GlucoGuide
//
//  Created by QuQi on 2016-05-08.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "ManualInputController.h"
#import "StyleManager.h"
#import "UIView+Extensions.h"
#import "Constants.h"
#import "GGImagePickerController.h"
#import "UIColor+Extensions.h"
#import "CustomizedFoodItem.h"
#import "AddMealRecordController.h"

@interface ManualInputController ()<UINavigationBarDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GGImagePickerControllerDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

@property (nonatomic) UITextField *MINameTextField;
@property (nonatomic) UIImageView *MIPhotoImageView;
@property (nonatomic) UITextField *MICalTextField;
@property (nonatomic) UITextField *MICarbsTextField;
@property (nonatomic) UITextField *MIProteinTextField;
@property (nonatomic) UITextField *MIFatTextField;
@property (nonatomic) UITextField *MIFibreTextField;

@property (nonatomic) UIImageView *MICameraIcon;
@property (nonatomic) UILabel *MICalLabel;
@property (nonatomic) UILabel *MICarbsLabel;
@property (nonatomic) UILabel *MIProteinLabel;
@property (nonatomic) UILabel *MIFatLabel;
@property (nonatomic) UILabel *MIFibreLabel;

@property (nonatomic) FoodImageData *foodImage;


@property (weak, nonatomic) IBOutlet UITableView *tableview;

@end

@implementation ManualInputController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    [self.tableview setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [StyleManager styleTable:self.tableview];
    [self.tableview setSeparatorColor:[UIColor grayColor]];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.tableview.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleNavigationBar:self.navBar];
    
    self.navBar.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];

}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.MINameTextField resignFirstResponder];
    [self.MICalTextField resignFirstResponder];
    [self.MICarbsTextField resignFirstResponder];
    [self.MIProteinTextField resignFirstResponder];
    [self.MIFatTextField resignFirstResponder];
    [self.MIFibreTextField resignFirstResponder];
    [self.view becomeFirstResponder];
}

#pragma mark - Event Handlers
- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapRecordButton:(id)sender {
    if (self.MINameTextField.text.length == 0){
       UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Alert"] message:[LocalizationManager getStringFromStrId:@"Please enter a food item name"] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self presentViewController:alertController animated:true completion:nil];

    }else{
        NSString *Name;
        float Cal;
        float Carbs;
        float Protein;
        float Fat;
        float Fibre;
        
        if(self.MINameTextField.text.length){
            Name = self.MINameTextField.text;
        }else{
            Name = @"";
        }
        

        
        if(self.MICalTextField.text.length){
            Cal = [self.MICalTextField.text floatValue];
        }else{
            Cal = 0;
        }
        
        if(self.MICarbsTextField.text.length){
            Carbs = [self.MICarbsTextField.text floatValue];
        }else{
            Carbs = 0;
        }
        
        if(self.MIProteinTextField.text.length){
            Protein = [self.MIProteinTextField.text floatValue];
        }else{
            Protein = 0;
        }
        
        if(self.MIFatTextField.text.length){
            Fat = [self.MIFatTextField.text floatValue];
        }else{
            Fat = 0;
        }
        
        if(self.MIFibreTextField.text.length){
            Fibre = [self.MIFibreTextField.text floatValue];
        }else{
            Fibre = 0;
        }

        CustomizedFoodItem *food = [CustomizedFoodItem createFoodWithManualInputName:Name Cals:Cal andCarbs:Carbs andProtein:Protein andFat:Fat andFibre:Fibre andImageData:nil];
        if (self.foodImage) {
            food.imageData = self.foodImage;
        }
        [food save].then(^(id res){
            if ([res isEqual:@1]) {
                [self performSegueWithIdentifier:@"unwindToSegueMealRecord" sender:food];
            }
        }).catch(^(NSError *err) {
            
        });
        
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation Bar Delegate

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1:6;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    [StyleManager styleTableCell:cell];
    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MINameCell" forIndexPath:indexPath];
        self.MINameTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_NAME];
        self.MINameTextField.delegate = self;
        self.MINameTextField.textColor = [UIColor buttonColor];
        self.MINameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
    }else if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MIPhotoCell" forIndexPath:indexPath];
        self.MICameraIcon = (UIImageView *)[cell viewWithTag:MANUAL_INPUT_TAG_CAMERAICON];
        self.MIPhotoImageView = (UIImageView *)[cell viewWithTag:MANUAL_INPUT_TAG_PHOTO];
        
        if (self.foodImage.image != nil){
            self.MICameraIcon.image = nil;
            [self.MIPhotoImageView setImage:self.foodImage.image];
        }else{
            self.MICameraIcon.image = [UIImage imageNamed:@"cameraIcon"];
            self.MICameraIcon.image = [self.MICameraIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [self.MICameraIcon setTintColor:[UIColor buttonColor]];
        }
        
    }else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MICalCell" forIndexPath:indexPath];
        self.MICalTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_CAL];
        self.MICalTextField.delegate = self;
        self.MICalTextField.textColor = [UIColor buttonColor];
        self.MICalLabel = (UILabel *)[cell viewWithTag:MANUAL_INPUT_TAG_CAL_LABEL];
        self.MICalLabel.textColor = [UIColor buttonColor];
        
        self.MICalTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.MICalTextField.returnKeyType = UIReturnKeyNext;
      
    }else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MICarbsCell" forIndexPath:indexPath];
        self.MICarbsTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_CARBS];
        self.MICarbsTextField.delegate = self;
        self.MICarbsTextField.textColor = [UIColor buttonColor];
        self.MICarbsLabel = (UILabel *)[cell viewWithTag:MANUAL_INPUT_TAG_CARBS_LABEL];
        self.MICarbsLabel.textColor = [UIColor buttonColor];
        
        self.MICarbsTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.MICarbsTextField.returnKeyType = UIReturnKeyNext;
        
    }else if (indexPath.row == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MIProteinCell" forIndexPath:indexPath];
        self.MIProteinTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_PROTEIN];
        self.MIProteinTextField.delegate = self;
        self.MIProteinTextField.textColor = [UIColor buttonColor];
        self.MIProteinLabel = (UILabel *)[cell viewWithTag:MANUAL_INPUT_TAG_PROTEIN_LABEL];
        self.MIProteinLabel.textColor = [UIColor buttonColor];
        
        self.MIProteinTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.MIProteinTextField.returnKeyType = UIReturnKeyNext;
     
    }else if (indexPath.row == 4){
        cell = [tableView dequeueReusableCellWithIdentifier:@"MIFatCell" forIndexPath:indexPath];
        self.MIFatTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_FAT];
        self.MIFatTextField.delegate = self;
        self.MIFatTextField.textColor = [UIColor buttonColor];
        self.MIFatLabel = (UILabel *)[cell viewWithTag:MANUAL_INPUT_TAG_FAT_LABEL];
        self.MIFatLabel.textColor = [UIColor buttonColor];
        
        self.MIFatTextField.keyboardType = UIKeyboardTypeDecimalPad;
        self.MIFatTextField.returnKeyType = UIReturnKeyNext;
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MIFibreCell" forIndexPath:indexPath];
        self.MIFibreTextField = (UITextField *)[cell viewWithTag:MANUAL_INPUT_TAG_FIBRE];
        self.MIFibreTextField.delegate = self;
        self.MIFibreTextField.textColor = [UIColor buttonColor];
        self.MIFibreLabel = (UILabel *)[cell viewWithTag:MANUAL_INPUT_TAG_FIBRE_LABEL];
        self.MIFibreLabel.textColor = [UIColor buttonColor];
        
        self.MIFibreTextField.keyboardType = UIKeyboardTypeDecimalPad;
    }

    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"";
            break;
        case 1:
            sectionName = [LocalizationManager getStringFromStrId:@"OPTIONAL"];
            break;
    }
    return sectionName;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewCell *headerView = nil;
    headerView = [tableView dequeueReusableCellWithIdentifier:@"MISectionHeader"];
    headerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    UILabel *headerLabel = (UILabel *)[headerView viewWithTag:MANUAL_INPUT_TAG_SECTION_HEADER];
    headerLabel.font = [UIFont boldSystemFontOfSize:18];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 44:(indexPath.row == 0 ? (IS_IPHONE_4_OR_LESS ? 60:80):44) ;
}


-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 40:(IS_IPHONE_4_OR_LESS ? 60:65);
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.MINameTextField becomeFirstResponder];
    }
    else if (indexPath.row == 0) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:MSG_CANCEL
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:[LocalizationManager getStringFromStrId:@"Take photo"], [LocalizationManager getStringFromStrId:@"Choose Existing"], nil];
            [actionSheet showInView:self.view];
        }else {
            [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
        }
    }
    else if (indexPath.row == 1) {
        [self.MICalTextField becomeFirstResponder];
    }
    else if (indexPath.row == 2) {
        [self.MICarbsTextField becomeFirstResponder];
    }
    else if (indexPath.row == 3) {
        [self.MIProteinTextField becomeFirstResponder];
    }
    else if (indexPath.row == 4) {
        [self.MIFatTextField becomeFirstResponder];
    }
    else if (indexPath.row == 5) {
        [self.MIFibreTextField becomeFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1; // reduce the default footer height when using a grouped table to zero (using 0.0 doesn't work)
}



#pragma mark - UITextFieldDelegate

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textf{
    NSIndexPath *indexPath;
    
    self.tableview.frame= CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, self.tableview.frame.size.height - 250);
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 35.0f)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(resetView:)];
    [toolbar setItems:[NSArray arrayWithObjects:flexibleSpace, barButtonItem, nil]];

    if (textf.tag == MANUAL_INPUT_TAG_CAL){
        indexPath =[NSIndexPath indexPathForRow:1 inSection:1];
        textf.inputAccessoryView = toolbar;
    }
    else if (textf.tag == MANUAL_INPUT_TAG_CARBS){
        indexPath =[NSIndexPath indexPathForRow:2 inSection:1];
        textf.inputAccessoryView = toolbar;
    }
    else if (textf.tag == MANUAL_INPUT_TAG_PROTEIN){
        indexPath =[NSIndexPath indexPathForRow:3 inSection:1];
        textf.inputAccessoryView = toolbar;
    }
    else if (textf.tag == MANUAL_INPUT_TAG_FAT){
        indexPath =[NSIndexPath indexPathForRow:4 inSection:1];
        textf.inputAccessoryView = toolbar;
    }
    else if (textf.tag == MANUAL_INPUT_TAG_FIBRE){
        indexPath =[NSIndexPath indexPathForRow:5 inSection:1];
        textf.inputAccessoryView = toolbar;
    }
    [self.tableview scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)resetView:(UITextField *)textf{
    [self.view endEditing:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textf{
    if (textf.tag == MANUAL_INPUT_TAG_NAME) {
        [self.MINameTextField resignFirstResponder];
    }else if (textf.tag == MANUAL_INPUT_TAG_CAL) {
        [self.MICalTextField resignFirstResponder];

    }else if (textf.tag == MANUAL_INPUT_TAG_CARBS){
        [self.MICarbsTextField resignFirstResponder];

    }else if (textf.tag == MANUAL_INPUT_TAG_PROTEIN){
        [self.MIProteinTextField resignFirstResponder];

    }else if (textf.tag == MANUAL_INPUT_TAG_FAT){
        [self.MIFatTextField resignFirstResponder];

    }else if (textf.tag == MANUAL_INPUT_TAG_FIBRE){
        [self.MIFibreTextField resignFirstResponder];
        
    }
    
    self.tableview.frame= CGRectMake(self.tableview.frame.origin.x, self.tableview.frame.origin.y, self.tableview.frame.size.width, self.tableview.frame.size.height+250);
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];
        });
    } else if (buttonIndex == 1) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
        });
    }
}

#pragma mark - GGImagePickerControllerDelegate

- (void)ggImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info withProcessingView:(UIView *)view {
    if (info == nil) return;
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if (editedImage != nil) {
        __block NSString *errorDescription = nil;
        [CustomizedFoodItem addFoodItemPhoto:editedImage].then(^(NSMutableDictionary *classificationResults) {
            self.foodImage = [[FoodImageData alloc] initWithImage:editedImage name:[classificationResults objectForKey:@"Image_name"]];
        }).catch(^(id error) {
            if ([error isKindOfClass:[NSError class]]) {
                NSError *classificationError = (NSError *)error;
                errorDescription = [classificationError description];
                NSLog(@"classification error: %@", errorDescription);
            }
            else {
                errorDescription = [LocalizationManager getStringFromStrId:@"Unknown error"];
            }
        }).finally(^{
            [view hideActivityIndicatorWithNetworkIndicatorOff];
            if (errorDescription) {
                NSLog(@"Failed to save photo for note.\n");
            }
            else {
                [self.tableview reloadData];
            }
            return;
        });
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"chooseDevicePictureSegue"]) {
        GGImagePickerController *destVC = [segue destinationViewController];
        destVC.sourceType = [(NSNumber *)sender intValue];
        destVC.delegate = self;
    }
    else if ([segueId isEqualToString:@"unwindToSegueMealRecord"]) {
        AddMealRecordController *destVC = [segue destinationViewController];
        [destVC didAddFoodItem:(FoodItem *)sender sender:nil];
        
    }
}

@end
