//
//  SearchFoodController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-06-04.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "SearchFoodController.h"
#import "StyleManager.h"
#import "FoodItem.h"
#import "UIView+Extensions.h"
#import "UIColor+Extensions.h"
#import "GGImagePickerController.h"
#import "MealRecord.h"
#import "BarcodeViewController.h"
#import "dropdownList.h"
#import "ManualInputController.h"
#import "Reachability.h"
#import "GlucoguideAPI.h"

#include <sys/types.h>
#include <sys/sysctl.h>


#ifdef DEBUG
NSString* const GGAPI_FOOD_SEARCH1 =@"https://api.glucoguide.com/";

#else
NSString* const GGAPI_FOOD_SEARCH1 =@"https://api.glucoguide.com/";

#endif


@interface SearchFoodController() <UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate, UIActionSheetDelegate,
GGImagePickerControllerDelegate, dropdownListDelegate>

@property (nonatomic) UISearchController *searchController;
@property (nonatomic) NSArray *foodItems;

@property (nonatomic) UIImageView *searchDescriptionImage;
@property (nonatomic) UILabel *searchDescriptionLabel;

@property (nonatomic) UIView *orLeftLine;
@property (nonatomic) UILabel *orLabel;
@property (nonatomic) UIView *orRightLine;

@property (nonatomic) NSLayoutConstraint *orLabelCenterYConstraint;

@property (nonatomic) UIView *cameraView;
@property (nonatomic) UILabel *autoEstimateDescriptionLabel;


@property (nonatomic) UIView *orLeftLine2;
@property (nonatomic) UILabel *orLabel2;
@property (nonatomic) UIView *orRightLine2;

@property (nonatomic) UIImageView *barcodeImage;
@property (nonatomic) UILabel *barcodeLabel;


@property (nonatomic) UILabel *noResultsLabel;

@property (nonatomic) bool haveZoomed;

@property (nonatomic) dropdownList *recentList;
@property (nonatomic) NSArray *recentFood;
@property (nonatomic) NSArray *foodArr;

@property (nonatomic) BOOL fromInternet;
@property (nonatomic) int pageNumber;
@property (nonatomic) UISearchBar *searchItem;
@property (nonatomic) NSString *searchText;

@property (nonatomic) NSArray *tempItemsArray;

@end

@implementation SearchFoodController

#pragma mark - View life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [StyleManager styleTable:self.tableView];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.searchBar.delegate = self;
    //[self.searchController.searchBar.heightAnchor constraintEqualToConstant:40].active = YES;
    self.searchController.delegate = self;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    
    self.navigationItem.titleView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    
    
    self.haveZoomed = NO;
    //self.searchController.active = YES;
    
    // use a light gray color for the cursor and cancel button so that they are both easier to see
    self.searchController.searchBar.tintColor = [UIColor colorWithRed:210.0/255.0 green:210.0/255.0 blue:210.0/255.0 alpha:1.0];
    [self.searchController.searchBar sizeToFit];
    
    [self setupDescriptionViews];
    
    self.recentList = [[dropdownList alloc] initWithData:[[NSArray alloc] init]];
    self.recentList.frame = CGRectMake(0, self.searchController.searchBar.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height/2);
    self.recentList.hidden = YES;
    self.recentList.delegate = self;
    [self.recentList setHeaderOffsetString:@"               "];
    
    UIBarButtonItem *converstionButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"scalesIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(goToConverstionChart)];
    
    self.navigationItem.rightBarButtonItem = converstionButton;
    
}

-(void)viewWillDisappear:(BOOL)animated{
    self.pageNumber = 0;
    self.tempItemsArray = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (![self.foodItems count]) {
        self.orLabelCenterYConstraint.constant = -self.autoEstimateDescriptionLabel.frame.size.height / 3.0;
        [self animateDescriptionViews];
    }
    
    self.pageNumber = 0;
    self.tempItemsArray = [[NSArray alloc]init];
}

#pragma mark - UISearchControllerDelegate

- (void)didPresentSearchController:(UISearchController *)searchController {
    self.searchDescriptionImage.hidden = YES;
    self.searchDescriptionLabel.hidden = YES;
    self.orLeftLine.hidden = YES;
    self.orLabel.hidden = YES;
    self.orRightLine.hidden = YES;
    self.cameraView.hidden = YES;
    self.autoEstimateDescriptionLabel.hidden = YES;
    
    self.orLeftLine2.hidden = YES;
    self.orLabel2.hidden = YES;
    self.orRightLine2.hidden = YES;
    self.barcodeImage.hidden = YES;
    self.barcodeLabel.hidden = YES;
    
    self.barcodeLabel.alpha = 0.0;
    self.barcodeImage.alpha = 0.0;
    self.orLeftLine2.alpha = 0.0;
    self.orLabel2.alpha = 0.0;
    self.orRightLine2.alpha = 0.0;
    
    self.searchDescriptionImage.alpha = 0.0;
    self.searchDescriptionLabel.alpha = 0.0;
    self.orLeftLine.alpha = 0.0;
    self.orLabel.alpha = 0.0;
    self.orRightLine.alpha = 0.0;
    self.cameraView.alpha = 0.0;
    self.autoEstimateDescriptionLabel.alpha = 0.0;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.searchController.searchBar becomeFirstResponder];
    });
    
   /*
    [FoodItem searchRecentFoodWithFilter:nil].then(^(NSArray *recentFoodArr){
        [self showRecentFoodsWith:recentFoodArr];
        [self.searchController.view addSubview:self.recentList];
        [self.recentList show];
    });
    */
    
    [self.searchController.view addSubview:self.recentList];
    [self.recentList show];
    
}

- (void)didDismissSearchController:(UISearchController *)searchController {
    if ((!self.noResultsLabel || self.noResultsLabel.isHidden) && ![self.foodItems count]) {
        [self animateDescriptionViews];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
 
    if ([searchText length] > 1) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            
            self.foodArr = [[NSArray alloc] initWithArray:[GlucoguideAPI getAutoCompleteResponseWithKey:searchText]];
            dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.foodArr count] > 0) {
                        [self showRecentFoodsWith:self.foodArr];
                    }else{
                        [self.recentList hide];
                    }
            });
        });
           
    }else{
        [self.recentList hide];
    }
    
    
   /*
    [FoodItem searchRecentFoodWithFilter:[searchText isEqualToString:@""] ? nil:searchText].then(^(NSArray *recentFoodArr){
        [self showRecentFoodsWith:recentFoodArr];
    });
    */
}

#pragma mark - dropdownListDelegate

- (void)dropdownListSelectedAtIndex:(NSUInteger)index {
    
    NSURLResponse *response=nil;
    NSError *error=nil;
    NSData *data = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GGAPI_FOOD_SEARCH1]
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:3.0];
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data) {
        self.fromInternet = 1;
        self.searchText = [self.recentFood objectAtIndex:index]; //searchBar.text;
        self.pageNumber = 0;
        
        [self internetSearch:self.searchText];
    }else{
        self.fromInternet = 0;
        self.searchText = [self.recentFood objectAtIndex:index]; //searchBar.text;
        
        [self noInternetSearch: [self.recentFood objectAtIndex:index]]; //searchBar];
    }

    
    /*
    
    
    if (self.recentFood && self.recentFood[index]) {
        dispatch_async(dispatch_get_main_queue(), ^(){
            self.searchController.active = NO;
        });
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:MSG_NAVI_BAR_BACK
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
        
        [self performSegueWithIdentifier:@"foodSummarySegue" sender:self.recentFood[index]];
    }
     
     */
}

- (void)dropdownListSelectedString:(NSString *)string {
    //[self.searchController.searchBar setText:string];
    //[self searchBar:self.searchController.searchBar textDidChange:string];
}

#pragma mark - UISearchResultsUpdating methods

- (void)showRecentFoodsWith:(NSArray *)foodArr {
    self.recentFood = foodArr;
    [self.recentList showWithData:self.recentFood];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
}

#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [self.foodItems count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.foodItems[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoodItem *food = (FoodItem *)self.foodItems[indexPath.section][indexPath.row];
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"foodItemTableCell"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    UIImageView *mealImage = (UIImageView *)[cell viewWithTag:SEARCH_FOOD_TAG_MEAL_IMAGE];
    UILabel *mealLabel = (UILabel *)[cell viewWithTag:SEARCH_FOOD_TAG_MEAL_LABEL];
    UILabel *mealDescriptionLabel = (UILabel *)[cell viewWithTag:SEARCH_FOOD_TAG_MEAL_DESC_LABEL];
    
    [StyleManager stylelabel:mealLabel];
    [StyleManager stylelabel:mealDescriptionLabel];
    
    mealLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    mealDescriptionLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [mealLabel sizeToFit];
    [mealDescriptionLabel sizeToFit];
    
    if ([food.foodClass isEqualToString:[LocalizationManager getStringFromStrId:@"Less Often"]]) {
        mealImage.backgroundColor = [UIColor lessOftenFoodColor];
    }
    else if ([food.foodClass isEqualToString:[LocalizationManager getStringFromStrId:@"In Moderation"]]) {
        mealImage.backgroundColor = [UIColor inModerationFoodColor];
    }
    else if ([food.foodClass isEqualToString:[LocalizationManager getStringFromStrId:@"More Often"]]) {
        mealImage.backgroundColor = [UIColor moreOftenFoodColor];
    }
    else {
        mealImage.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216/255.0 alpha:1.0];
    }
    
    mealImage.layer.cornerRadius = 5.0;
    mealLabel.text = food.category;
    mealDescriptionLabel.text =  food.name; //[food description];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewCell *sectionHeader = [self.tableView dequeueReusableCellWithIdentifier:@"foodItemSectionHeader"];
    
    NSUInteger sectionCount = [self.foodItems[section] count];
    if (sectionCount) {
        NSString *sectionHeaderText = ((FoodItem *)self.foodItems[section][0]).category;
        sectionHeaderText = [NSString stringWithFormat:@"%@ (%ld)", sectionHeaderText, (unsigned long)sectionCount];
        
        UILabel *sectionHeaderLabel = (UILabel *)[sectionHeader viewWithTag:SEARCH_FOOD_TAG_SECTION_HEADER_LABEL];
        [StyleManager stylelabel:sectionHeaderLabel];
        sectionHeaderLabel.font = [UIFont boldSystemFontOfSize:18];
        sectionHeaderLabel.textColor = [UIColor darkGrayColor];
        sectionHeaderLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Searched For: %@"], self.searchText]; //sectionHeaderText;
        sectionHeaderLabel.textAlignment = NSTextAlignmentCenter;
        sectionHeaderLabel.numberOfLines = 0;
        sectionHeaderLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        [StyleManager styleTableCell:sectionHeader];
        sectionHeader.backgroundColor = [UIColor groupTableViewBackgroundColor];
    }
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                 style:UIBarButtonItemStylePlain
                                                                target:nil
                                                                action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (self.fromInternet && ![((FoodItem*)self.foodItems[indexPath.section][indexPath.row]).category isEqualToString:[LocalizationManager getStringFromStrId:@"Customized Foods"]]) {
        
        FoodItem *passingFoodItem = [[FoodItem alloc]init];
        passingFoodItem = (FoodItem *)self.foodItems[indexPath.section][indexPath.row];
        
        //[self performSegueWithIdentifier:@"foodSummarySegue" sender:[FoodItem getFoodItemFromInternetWithProvider:passingFoodItem.providerID andItemID:passingFoodItem.providerItemID]];
        
        NSDictionary* sender = [FoodItem getFoodItemFromInternetWithProvider:passingFoodItem.providerID andItemID:passingFoodItem.providerItemID];
        
        if (passingFoodItem.fromLocalDB) {
            [self performSegueWithIdentifier:@"foodSummarySegue" sender:passingFoodItem];
        }
        else {
            [self performSegueWithIdentifier:@"foodSummarySegue" sender:sender];
        }
        
    }else{
        [self performSegueWithIdentifier:@"foodSummarySegue" sender:indexPath];
    }
    
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // http://stackoverflow.com/questions/25762723/remove-separatorinset-on-ios-8-uitableview-for-xcode-6-iphone-simulator
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if (indexPath.row % 2 == 0) {
        cell.backgroundColor = [UIColor whiteColor];
    }else{
        UIColor *altCellColor = [UIColor colorWithWhite:0.5 alpha:0.1];
        cell.backgroundColor = altCellColor;
        
    }
    
    
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    //NSLog(@"SECT:%ld ROW:%ld loading new page..\n", indexPath.section, (long)indexPath.row);
    if ((indexPath.section == lastSectionIndex) && (indexPath.row == lastRowIndex) && ((indexPath.row+MAX_RESULTS_FOR_ONLINE_FOOD_SEARCH+1)%(MAX_RESULTS_FOR_ONLINE_FOOD_SEARCH))==0) {
        NSLog(@"SECT:%ld ROW:%ld loading new page..\n", indexPath.section, (long)indexPath.row);
        if (self.fromInternet) {
            self.pageNumber = self.pageNumber + 1;
            [self internetSearch:self.searchText];
        }
    }
    
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

- (void)ggImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if (info == nil) return;
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if (editedImage != nil) {
        [self classifyImage:editedImage];
    }
}

#pragma mark - Event Handlers

- (void)didTapSearchIcon:(UIGestureRecognizer *)recognizer {
    self.searchController.active = YES;
}

- (void)didTapBarcdodeIcon:(UIGestureRecognizer *)recognizer {
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self performSegueWithIdentifier:@"segueToBarcodeScan" sender:self];
    });
}

- (void)didTapCameraCircleButton:(id)sender {
    [self performSegueWithIdentifier:@"segueToManualInput" sender:self];
    
    //    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                                 delegate:self
    //                                                        cancelButtonTitle:MSG_CANCEL
    //                                                   destructiveButtonTitle:nil
    //                                                        otherButtonTitles:@"Take photo", @"Choose Existing", nil];
    //        [actionSheet showInView:self.view];
    //    }
    //    else {
    //        [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
    //    }
}

- (IBAction)didTapCancelButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    
    NSURLResponse *response=nil;
    NSError *error=nil;
    NSData *data = nil;
   
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:GGAPI_FOOD_SEARCH1]
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:3.0];
    
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    [self.tableView setContentOffset:CGPointZero animated:NO];
    
    if (data) {
        self.fromInternet = 1;
        self.searchText = searchBar.text;
        self.pageNumber = 0;
        
        [self internetSearch:self.searchText];
    }else{
        self.fromInternet = 0;
        self.searchText = searchBar.text;
       
        [self noInternetSearch:searchBar];
    }

}

-(void)internetSearch:(NSString *)searchText{

    self.noResultsLabel.hidden = YES;
    
    NSLog(@"searching for '%@' with page: %d", self.searchText, self.pageNumber);
    [self.tableView showActivityIndicatorWithMessage:[LocalizationManager getStringFromStrId:@"Searching..."]];
    
    dispatch_promise(^{
        
        [FoodItem  newSearchFoodWithName:self.searchText withPage:self.pageNumber].then(^(NSArray *filteredFoodItems) {
            
            if ([[filteredFoodItems objectAtIndex:0] count] > 0){
                
                if (self.pageNumber == 0) {
                    
                    self.foodItems = filteredFoodItems;
                }else{
                    
                    NSMutableArray *new = [[NSMutableArray alloc]initWithArray:[filteredFoodItems objectAtIndex:0]];
                    
                    NSMutableArray *old = [[NSMutableArray alloc] initWithArray:[self.foodItems lastObject]];
                    
                    NSArray *tempCombined = [old arrayByAddingObjectsFromArray:new];
                    
                    NSArray *combined = ([self.foodItems count]==1)?[[NSArray alloc] initWithObjects:tempCombined, nil]:[[NSArray alloc] initWithObjects:[self.foodItems firstObject],tempCombined, nil];
                    
                    //NSArray *combined = [[NSArray alloc] initWithObjects:tempCombined, nil];
                    
                    self.foodItems = combined;
                    
                }
                
            }else{
            
                self.foodItems = [[NSArray alloc]init];
                
                [self setupNoResultsLabel];
                self.noResultsLabel.hidden = NO;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                
             //   if ([self.tableView numberOfRowsInSection:0] > 0) {
             //       NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
             //       [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
             //   }
                
                if (!self.foodItems.firstObject) {
                    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5 || [[UIScreen mainScreen] bounds].size.width == 320.0f) {
                        if (!self.haveZoomed) {
                            self.haveZoomed = YES;
                            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                            self.tableView.frame = CGRectMake(0, self.tableView.sectionHeaderHeight*2.3, self.tableView.frame.size.width, self.tableView.frame.size.height);
                        }
                    }
                    [self setupNoResultsLabel];
                    self.noResultsLabel.hidden = NO;
                }
                else {
                    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5 || [[UIScreen mainScreen] bounds].size.width == 320.0f) {
                        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        self.tableView.frame = CGRectMake(0, self.tableView.sectionHeaderHeight*2.2 + 60, self.tableView.frame.size.width, self.tableView.frame.size.height);
                    }
                }
            });
        }).finally(^{
            [self.tableView hideActivityIndicator];
            self.searchController.active = NO;
        });
    });
}

-(void)noInternetSearch:(UISearchBar *)searchBar{
    
    if ([searchBar.text isEqualToString:@""]) {
        return;
    }
    
    self.noResultsLabel.hidden = YES;
    
   // NSLog(@"searching for '%@'", searchBar.text);
    [self.tableView showActivityIndicatorWithMessage:[LocalizationManager getStringFromStrId:@"Searching..."]];
    
    dispatch_promise(^{
       
            [FoodItem searchForFoodWithName:searchBar.text].then(^(NSArray *filteredFoodItems) {
            self.foodItems = filteredFoodItems;
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
                
                if (!self.foodItems.firstObject) {
                    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5 || [[UIScreen mainScreen] bounds].size.width == 320.0f) {
                        if (!self.haveZoomed) {
                            self.haveZoomed = YES;
                            self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                            self.tableView.frame = CGRectMake(0, self.tableView.sectionHeaderHeight*2.3, self.tableView.frame.size.width, self.tableView.frame.size.height);
                        }
                    }
                    [self setupNoResultsLabel];
                    self.noResultsLabel.hidden = NO;
                }
                else {
            
                    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5 || [[UIScreen mainScreen] bounds].size.width == 320.0f) {
                        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                        self.tableView.frame = CGRectMake(0, self.tableView.sectionHeaderHeight*2.2, self.tableView.frame.size.width, self.tableView.frame.size.height);
                    }
                }
            });
        }).finally(^{
            [self.tableView hideActivityIndicator];
            self.searchController.active = NO;
        });
    });
    
}

- (void)classifyImage:(UIImage *)foodImage
{
    if (foodImage) {
        // TODO: this is a really hacky way to get the background mask to also cover the
        // navigation bar. Need to change this in the future
        [self.tableView.superview.superview.superview showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:@"Auto Estimating..."]];
        [self.tableView.superview.superview.superview toggleBackgroundMaskDisplayBelowSubview:nil];
        
        dispatch_promise(^{
            __block NSDictionary *imgClassificationResults = nil;
            __block NSString *errorDescription = nil;
            
            [MealRecord autoEstimateWithImage:foodImage].then(^(NSMutableDictionary *classificationResults) {
                if (classificationResults) {
                    // "0" signifies that the classification was successful
                    if ([classificationResults[@"Classficiation_status"] isEqualToString:@"0"])
                    {
                        [classificationResults setObject:foodImage forKey:@"Image_object"];
                        imgClassificationResults = classificationResults;
                    }
                    else {
                        errorDescription = [LocalizationManager getStringFromStrId:@"Unable to classify image"];
                    }
                }
                else {
                    errorDescription = [LocalizationManager getStringFromStrId:@"Unable to retrieve classification results"];
                }
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
                [self.tableView.superview.superview.superview hideActivityIndicatorWithNetworkIndicatorOff];
                [self.tableView.superview.superview.superview toggleBackgroundMaskDisplayBelowSubview:nil];
                
                if (errorDescription) {
                    [self showImageClassificationErrorAlertWithMessage:errorDescription];
                }
                else {
                    [self performSegueWithIdentifier:@"foodSummarySegue" sender:imgClassificationResults];
                }
            });
        });
    }
    else {
        // failed to get image for classification
        [self showImageClassificationErrorAlertWithMessage:[LocalizationManager getStringFromStrId:@"Unable to retrieve image"]];
    }
}

- (void)showImageClassificationErrorAlertWithMessage:(NSString *)errorMessage {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Sorry we could not recognize your food item"]
                                                                        message:[LocalizationManager getStringFromStrId:@"Often lighting, angle, zoom, and camera quality can have an negative affect.  Your photo has been  saved to help us improve! Thank you."]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [errorAlert addAction:cancelAction];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

- (void)setupNoResultsLabel
{
    if (!self.noResultsLabel) {
        self.noResultsLabel = [[UILabel alloc] init];
        self.noResultsLabel.text = [LocalizationManager getStringFromStrId:@"No results found"];
        self.noResultsLabel.textColor = [UIColor darkGrayColor];
        self.noResultsLabel.font = [UIFont boldSystemFontOfSize:IS_IPHONE_4_OR_LESS ? 15.0 : 20.0];
        self.noResultsLabel.textAlignment = NSTextAlignmentCenter;
        self.noResultsLabel.numberOfLines = 0;
        self.noResultsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.noResultsLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.noResultsLabel.hidden = YES;
        
        [self.tableView addSubview:self.noResultsLabel];
        
        [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.noResultsLabel
                                                                   attribute:NSLayoutAttributeLeading
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.tableView
                                                                   attribute:NSLayoutAttributeLeading
                                                                  multiplier:1.0
                                                                    constant:8.0]];
        [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.noResultsLabel
                                                                   attribute:NSLayoutAttributeTrailing
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.tableView
                                                                   attribute:NSLayoutAttributeTrailing
                                                                  multiplier:1.0
                                                                    constant:-8.0]];
        [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.noResultsLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.tableView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    }
}

- (void)animateDescriptionViews
{
    self.barcodeImage.hidden = NO;
    self.barcodeLabel.hidden = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.barcodeImage.alpha = 1.0;
        self.barcodeLabel.alpha = 1.0;
    }];
    
    self.orLeftLine.hidden = NO;
    self.orLabel.hidden = NO;
    self.orRightLine.hidden = NO;
    [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.orLeftLine.alpha = 1.0;
        self.orLabel.alpha = 1.0;
        self.orRightLine.alpha = 1.0;
    } completion:nil];
    
    self.searchDescriptionImage.hidden = NO;
    self.searchDescriptionLabel.hidden = NO;
    [UIView animateWithDuration:0.20 delay:0.1 * 1.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.searchDescriptionImage.alpha = 1.0;
        self.searchDescriptionLabel.alpha = 1.0;
    } completion:nil];
    
    self.orLeftLine2.hidden = NO;
    self.orLabel2.hidden = NO;
    self.orRightLine2.hidden = NO;
    [UIView animateWithDuration:0.25 delay:0.1 * 2.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.orLeftLine2.alpha = 1.0;
        self.orLabel2.alpha = 1.0;
        self.orRightLine2.alpha = 1.0;
    } completion:nil];
    
    self.cameraView.hidden = NO;
    self.autoEstimateDescriptionLabel.hidden = NO;
    [UIView animateWithDuration:0.35 delay:0.1 * 3.5 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.cameraView.alpha = 1.0;
        self.autoEstimateDescriptionLabel.alpha = 1.0;
    } completion:nil];
}

- (void)setupDescriptionViews
{
    self.orLabel = [[UILabel alloc] init];
    self.orLabel.text = [LocalizationManager getStringFromStrId:@"OR"];
    self.orLabel.textColor = [UIColor blackColor];
    self.orLabel.font = [UIFont boldSystemFontOfSize:20.0];
    self.orLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLabel.hidden = YES;
    self.orLabel.alpha = 0.0;
    
    [self.tableView addSubview:self.orLabel];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    
    self.orLeftLine = [[UIView alloc] init];
    self.orLeftLine.backgroundColor = [UIColor blackColor];
    self.orLeftLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLeftLine.hidden = YES;
    self.orLeftLine.alpha = 0.0;
    
    [self.tableView addSubview:self.orLeftLine];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:-8.0]];
    [self.orLeftLine addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:120.0]];
    [self.orLeftLine addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:1.0]];
    
    self.orRightLine = [[UIView alloc] init];
    self.orRightLine.backgroundColor = [UIColor blackColor];
    self.orRightLine.translatesAutoresizingMaskIntoConstraints = NO;
    self.orRightLine.hidden = YES;
    self.orRightLine.alpha = 0.0;
    
    [self.tableView addSubview:self.orRightLine];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:8.0]];
    [self.orRightLine addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:120.0]];
    [self.orRightLine addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:1.0]];
  
    
    self.barcodeLabel = [[UILabel alloc] init];
    self.barcodeLabel.text = [LocalizationManager getStringFromStrId:@"Scan Barcode"];
    self.barcodeLabel.textColor = [UIColor buttonColor];
    
    self.barcodeLabel.font = [UIFont boldSystemFontOfSize:22.0];
    self.barcodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.barcodeLabel.numberOfLines = 0;
    self.barcodeLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.barcodeLabel.textAlignment = NSTextAlignmentCenter;
    self.barcodeLabel.hidden = YES;
    self.barcodeLabel.alpha = 0.0;
    
    [self.tableView addSubview:self.barcodeLabel];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:8.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:-8.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeLabel
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:-30.0]];
    
    
    self.barcodeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"barcodeIcon"]];
    self.barcodeImage.image = [self.barcodeImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.barcodeImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.barcodeImage.tintColor = [UIColor buttonColor];
    self.barcodeImage.hidden = YES;
    self.barcodeImage.alpha = 0.0;
    
    self.barcodeImage.userInteractionEnabled = YES;
    [self.barcodeImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(didTapBarcdodeIcon:)]];
    
    [self.tableView addSubview:self.barcodeImage];
    
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeImage
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeImage
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.barcodeLabel
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:-8.0]];
    [self.barcodeImage addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:1.0
                                                                             constant:60.0]];
    [self.barcodeImage addConstraint:[NSLayoutConstraint constraintWithItem:self.barcodeImage
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:self.barcodeImage
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1.0
                                                                             constant:0.0]];
   
    
    
    self.searchDescriptionImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchIcon"]];
    self.searchDescriptionImage.image = [self.searchDescriptionImage.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.searchDescriptionImage.tintColor = [UIColor buttonColor];
    self.searchDescriptionImage.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchDescriptionImage.hidden = YES;
    self.searchDescriptionImage.alpha = 0.0;
    
    self.searchDescriptionImage.userInteractionEnabled = YES;
    [self.searchDescriptionImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                              action:@selector(didTapSearchIcon:)]];
    
    [self.tableView addSubview:self.searchDescriptionImage];
    
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionImage
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLabel
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.searchDescriptionImage
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:-30.0]];
    [self.searchDescriptionImage addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionImage
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:60.0]];
    [self.searchDescriptionImage addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionImage
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.searchDescriptionImage
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    self.orLabelCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.searchDescriptionImage
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.tableView
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:0.9
                                                                  constant:0.0];
    
    
    
    [self.tableView addConstraint:self.orLabelCenterYConstraint];

    
    self.searchDescriptionLabel = [[UILabel alloc] init];
    self.searchDescriptionLabel.text = [LocalizationManager getStringFromStrId:@"Search"];
    self.searchDescriptionLabel.textColor = [UIColor buttonColor];
    
    self.searchDescriptionLabel.font = [UIFont boldSystemFontOfSize:22.0];
    self.searchDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.searchDescriptionLabel.numberOfLines = 0;
    self.searchDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.searchDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.searchDescriptionLabel.hidden = YES;
    self.searchDescriptionLabel.alpha = 0.0;
    
    [self.tableView addSubview:self.searchDescriptionLabel];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:8.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:-8.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.searchDescriptionImage
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.searchDescriptionLabel
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1.0
                                                                constant:-8.0]];
    

    self.orLabel2 = [[UILabel alloc] init];
    self.orLabel2.text = [LocalizationManager getStringFromStrId:@"OR"];
    self.orLabel2.textColor = [UIColor blackColor];
    self.orLabel2.font = [UIFont boldSystemFontOfSize:20.0];
    self.orLabel2.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLabel2.hidden = YES;
    self.orLabel2.alpha = 0.0;
    
    [self.tableView addSubview:self.orLabel2];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLabel2
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLabel2
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.searchDescriptionLabel
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:30.0]];
    

    self.orLeftLine2 = [[UIView alloc] init];
    self.orLeftLine2.backgroundColor = [UIColor blackColor];
    self.orLeftLine2.translatesAutoresizingMaskIntoConstraints = NO;
    self.orLeftLine2.hidden = YES;
    self.orLeftLine2.alpha = 0.0;
    
    [self.tableView addSubview:self.orLeftLine2];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine2
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel2
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine2
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel2
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:-8.0]];
    
    [self.orLeftLine2 addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine2
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeWidth
                                                                multiplier:1.0
                                                                  constant:120.0]];
    
    [self.orLeftLine2 addConstraint:[NSLayoutConstraint constraintWithItem:self.orLeftLine2
                                                                 attribute:NSLayoutAttributeHeight
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeHeight
                                                                multiplier:1.0
                                                                  constant:1.0]];

    
    self.orRightLine2 = [[UIView alloc] init];
    self.orRightLine2.backgroundColor = [UIColor blackColor];
    self.orRightLine2.translatesAutoresizingMaskIntoConstraints = NO;
    self.orRightLine2.hidden = YES;
    self.orRightLine2.alpha = 0.0;
    
    [self.tableView addSubview:self.orRightLine2];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine2
                                                               attribute:NSLayoutAttributeCenterY
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel2
                                                               attribute:NSLayoutAttributeCenterY
                                                              multiplier:1.0
                                                                constant:0.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine2
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel2
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:8.0]];
    [self.orRightLine2 addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine2
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:120.0]];
    [self.orRightLine2 addConstraint:[NSLayoutConstraint constraintWithItem:self.orRightLine2
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:1.0]];

    
    self.cameraView = [[UIView alloc] init];
    self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    self.cameraView.hidden = YES;
    self.cameraView.alpha = 0.0;
    
    [self.tableView addSubview:self.cameraView];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraView
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.orLabel2
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:40.0]];
    
    [self.cameraView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:70.0]];
    
    [self.cameraView addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.cameraView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    [self setupCameraView:self.cameraView withWidth:60.0];
    
    self.autoEstimateDescriptionLabel = [[UILabel alloc] init];
    self.autoEstimateDescriptionLabel.text = [LocalizationManager getStringFromStrId:@"Manual Input"];
    self.autoEstimateDescriptionLabel.textColor = [UIColor buttonColor];
    
    self.autoEstimateDescriptionLabel.font = [UIFont boldSystemFontOfSize:22.0];
    self.autoEstimateDescriptionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.autoEstimateDescriptionLabel.numberOfLines = 0;
    self.autoEstimateDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.autoEstimateDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.autoEstimateDescriptionLabel.hidden = YES;
    self.autoEstimateDescriptionLabel.alpha = 0.0;
    
    [self.tableView addSubview:self.autoEstimateDescriptionLabel];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.autoEstimateDescriptionLabel
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.autoEstimateDescriptionLabel
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.cameraView
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.autoEstimateDescriptionLabel
                                                               attribute:NSLayoutAttributeLeading
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeLeading
                                                              multiplier:1.0
                                                                constant:8.0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.autoEstimateDescriptionLabel
                                                               attribute:NSLayoutAttributeTrailing
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeTrailing
                                                              multiplier:1.0
                                                                constant:-8.0]];
    
    
    if (IS_IPHONE_4_OR_LESS || IS_IPHONE_5) {
        self.tableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.7, 0.7);
    }
    
}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIView *)setupCameraView:(UIView *)cameraContainerView withWidth:(const CGFloat)cameraViewWidth {
    UIButton *circleButton = [[UIButton alloc] init];
    circleButton.translatesAutoresizingMaskIntoConstraints = NO;
    circleButton.layer.cornerRadius = cameraViewWidth / 2.0;
    circleButton.backgroundColor = [UIColor buttonColor];
    circleButton.clipsToBounds = YES;
    circleButton.tag = SEARCH_FOOD_TAG_CAMERA_BUTTON;
    
    [circleButton setBackgroundImage:[self imageWithColor:[UIColor lightGrayColor]]
                            forState:UIControlStateHighlighted];
    [circleButton addTarget:self
                     action:@selector(didTapCameraCircleButton:)
           forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    [cameraContainerView addSubview:circleButton];
    
    [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:circleButton
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:cameraContainerView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:circleButton
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:cameraContainerView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:-cameraViewWidth / 3.5]];
    [circleButton addConstraint:[NSLayoutConstraint constraintWithItem:circleButton
                                                             attribute:NSLayoutAttributeWidth
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeWidth
                                                            multiplier:1.0
                                                              constant:cameraViewWidth]];
    [circleButton addConstraint:[NSLayoutConstraint constraintWithItem:circleButton
                                                             attribute:NSLayoutAttributeHeight
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:nil
                                                             attribute:NSLayoutAttributeHeight
                                                            multiplier:1.0
                                                              constant:cameraViewWidth]];
    
    //    UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraIcon"]];
    UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"createNewIcon"]];
    
    cameraImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [circleButton addSubview:cameraImageView];
    
    [circleButton addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:circleButton
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0.0]];
    [circleButton addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:circleButton
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0.0]];
    [cameraImageView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:cameraViewWidth / 2.0]];
    [cameraImageView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:cameraViewWidth / 2.0]];
    return cameraContainerView;
}

- (NSArray<FoodItem *> *)foodItemsFromImgClassificationResults:(NSDictionary *)results {
    
    if (self.fromInternet) {
        
        NSMutableArray<FoodItem *> *foodItems = [[NSMutableArray alloc] initWithCapacity:1];
        FoodItem *classificationFood = [[FoodItem alloc] initWithClassificationData:results];
        classificationFood.creationType = FoodItemCreationTypeOnlineSearch;
        
            if (classificationFood) {
                [foodItems addObject:classificationFood];
            }
       
        return foodItems;

    }else{
    
    
    NSArray *classificationData = results[@"Lables"][@"Label"];
    NSMutableArray<FoodItem *> *foodItems = [[NSMutableArray alloc] initWithCapacity:[classificationData count]];
    
    for (NSDictionary *eachClassificationLabelData in classificationData) {
        FoodItem *classificationFood = [[FoodItem alloc] initWithClassificationData:eachClassificationLabelData];
        
        if (classificationFood) {
            [foodItems addObject:classificationFood];
        }
    }
    
    return foodItems;
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"foodSummarySegue"])
    {
        FoodSummaryViewController *destVC = [segue destinationViewController];
        destVC.index = FSUMM_INDEX_NOT_SET;
        destVC.delegate = self.delegate;
        
        if ([sender isKindOfClass:[NSDictionary class]]) {
            // auto estimate
            NSDictionary *imgClassificationResults = (NSDictionary *)sender;
            
            destVC.imageData = [[FoodImageData alloc] initWithImage:imgClassificationResults[@"Image_object"]
                                                               name:imgClassificationResults[@"Image_name"]];
            destVC.foodItems = [self foodItemsFromImgClassificationResults:imgClassificationResults];
        }
        else if ([sender isMemberOfClass:[NSIndexPath class]]) {
            // search
            NSIndexPath *indexPath = (NSIndexPath *)sender;
            FoodItem *foodItem = (FoodItem *)self.foodItems[indexPath.section][indexPath.row];
            foodItem.portionSize = 1;
            destVC.foodItems = @[foodItem];
            
        }
        else if ([sender isKindOfClass:[FoodItem class]]) {
            FoodItem *foodItem = (FoodItem *)sender;
            foodItem.portionSize = 1;
            destVC.foodItems = @[foodItem];
        }

    }
    else if ([segueId isEqualToString:@"chooseDevicePictureSegue"]) {
        GGImagePickerController *destVC = [segue destinationViewController];
        destVC.sourceType = [(NSNumber *)sender intValue];
        destVC.delegate = self;
    }
    else if ([segueId isEqualToString:@"segueToBarcodeScan"]){
        UINavigationController *destVC = [segue destinationViewController];
        BarcodeViewController *barcodeViewController = destVC.viewControllers[0];
        barcodeViewController.delegate = self.delegate;
        
    }
    else if ([segueId isEqualToString:@"segueToManualInput"]){
        //UINavigationController *destVC = [segue destinationViewController];
        //ManualInputController *manualInputController = destVC.viewControllers[0];
        //manualInputController.delegate = self.delegate;
    }
}

-(void)goToConverstionChart{
    [self performSegueWithIdentifier:@"segueToConversionChart2" sender:self];
}

-(void)dealloc {
    [self.searchController.view removeFromSuperview];
}

@end


//camera (auto estimate) section was repaced by manual input section; some variable names remain unchanged; need improvement in the future
