//
//  HomeViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-05-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "HomeViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "User.h"
#import "RecommendationDetailViewController.h"
#import "AppDelegate.h"
#import "ImageCard.h"
#import "UIView+Extensions.h"
#import "SWRevealViewController.h"
#import "RecentMealsController.h"
#import "PedometerClass.h"
#import "InputSelectionTableViewController.h"
#import "ChooseOrganizationCodeViewController.h"
#import "ProfileTableViewController.h"

@interface HomeViewController() <UIAlertViewDelegate>

@property (nonatomic) NSArray *recommendationRows;
@property (nonatomic) NSCache *imageCache;

@property (nonatomic) BOOL isPerformingInitialRetrieve;

@end

@implementation HomeViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTipNotification:)
                                                 name:@"TipsNotification"
                                               object:nil];
    
    [StyleManager styleTable:self.tableView];
    
    self.imageCache = [[NSCache alloc] init];
    self.imageCache.totalCostLimit = 5000000; // 5MB
    
    
    
}


- (void)receiveTipNotification:(NSNotification *)notification
{
   self.navigationController.tabBarItem.badgeValue = [LocalizationManager getStringFromStrId:@"NEW"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate syncHomeTabBadgeValueWithAppBadgeValue];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self refresh:nil];
    
    if (self.isPerformingInitialRetrieve) {
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:@"Retrieving..."]];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.isPerformingInitialRetrieve) {
        // network indicator remains on as we are still retrieving
        [self.view hideActivityIndicator];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [self.imageCache removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // DISABLED Points row
    // return [self.recommendationRows count] + 1;
    return [self.recommendationRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    switch (indexPath.row) {
    
    // DISABLED Points row
            
//        case 0: {
//            cell = [tableView dequeueReusableCellWithIdentifier:@"pointsCell" forIndexPath:indexPath];
//            
//            UILabel *pointsLabel = (UILabel *)[cell viewWithTag:HOME_POINTS_CELL_TAG];
//            UILabel *pointsValLabel = (UILabel *)[cell viewWithTag:HOME_POINTS_CELL_VAL_TAG];
//            UILabel *pointsGoalMsgLabel = (UILabel *)[cell viewWithTag:HOME_POINTS_CELL_GOAL_MSG_TAG];
//            
//            User *user = [User sharedModel];
//            
//            NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
//            numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
//            NSString *pointsStr = [numberFormatter stringFromNumber: [NSNumber numberWithInteger:user.points]];
//            
//            pointsLabel.text = @"Points:";
//            pointsValLabel.text = pointsStr;
//            pointsGoalMsgLabel.text = user.pointsGoalMsg;
//            
//            [StyleManager stylelabel:pointsLabel];
//            [StyleManager stylelabel:pointsValLabel];
//            [StyleManager stylelabel:pointsGoalMsgLabel];
//            
//            if (IS_IPHONE_4_OR_LESS) {
//                pointsGoalMsgLabel.font = [UIFont systemFontOfSize:11.0];
//            }
//            
//            break;
//        }
        default: {
            RecommendationRecord *currentRecommendation = [self recommendationRecordWithIndexPath:indexPath];
            NSString *titleStr = [LocalizationManager getStringFromStrId:@"Health Tip"];
            titleStr = [RecommendationRecord getTypeDescription:currentRecommendation.type];
  
            if (!currentRecommendation.imageURL || [currentRecommendation.imageURL isEqualToString:@""]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"recommendationImageCell" forIndexPath:indexPath];
                
                ImageCard *itCard = (ImageCard*)[cell viewWithTag:HOME_RECOMMENDATION_CARD_TAG];
                [itCard redrawCard];
                
                if (!itCard.loaded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [itCard loadCardTypeHomeNewsWithImage:[UIImage imageNamed:@"Message_Image"] titleString:titleStr contentString:currentRecommendation.content date:currentRecommendation.createdTime];
                    });
                }
                [self updateRecommendationImageCard:itCard withImage:[UIImage imageNamed:@"Message_Image"] withTitle:titleStr withContent:currentRecommendation.content withDate:currentRecommendation.createdTime forCell:cell forIndexPath:indexPath];
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"recommendationImageCell" forIndexPath:indexPath];
                
                ImageCard *itCard = (ImageCard*)[cell viewWithTag:HOME_RECOMMENDATION_CARD_TAG];
                [itCard redrawCard];
                
                if (!itCard.loaded) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [itCard loadCardTypeHomeNewsWithImage:[UIImage imageNamed:@"Message_Image"] titleString:titleStr contentString:currentRecommendation.content date:currentRecommendation.createdTime];
                    });
                }

                id cachedImaged = [self.imageCache objectForKey:currentRecommendation.imageURL];
                if (cachedImaged) {
                    NSLog(@"cache accessed");
                    [self updateRecommendationImageCard:itCard withImage:(UIImage *)cachedImaged withTitle:titleStr withContent:currentRecommendation.content withDate:currentRecommendation.createdTime forCell:cell forIndexPath:indexPath];
                }
                else {
                    // load image from URL async
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                        NSData *imageData = nil;
                        switch (currentRecommendation.imageLocation) {
                            case ImageLocationLocal:
                                imageData = [NSData dataWithContentsOfFile:currentRecommendation.imageURL];
                                break;
                            case ImageLocationRemote:
                                imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:currentRecommendation.imageURL]];
                                break;
                        }
                        
                        UIImage *image = nil;
                        if (imageData) {
                            image = [UIImage imageWithData:imageData];
                            if (image) {
                                [self.imageCache setObject:image forKey:currentRecommendation.imageURL cost:imageData.length];
                                [self updateRecommendationImageCard:itCard withImage:image withTitle:titleStr withContent:currentRecommendation.content withDate:currentRecommendation.createdTime forCell:cell forIndexPath:indexPath];
                            }
                        }
                        else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [itCard loadCardTypeHomeNewsWithImage:[UIImage imageNamed:@"Message_Image"] titleString:titleStr contentString:currentRecommendation.content date:currentRecommendation.createdTime];
                            });
                        }
                    });
                }
            }
            
            break;
        }
    }
    
    [StyleManager styleTableCell:cell];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    UIImageView *recommendationImg = (UIImageView *)[cell viewWithTag:HOME_RECOMMENDATION_CELL_IMAGE_TAG];
    recommendationImg.image = nil;
    recommendationImg.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
    // DISABLED Points row
            
//        case 0: {
//            NSString *pointsGoalMsg = ((User *)[User sharedModel]).pointsGoalMsg;
//            return [pointsGoalMsg isEqualToString:@""] || !pointsGoalMsg ? 44.0 : 60.0;
//        }
        default: {
            RecommendationRecord *currentRecommendation = [self recommendationRecordWithIndexPath:indexPath];
            if (!currentRecommendation.imageURL || [currentRecommendation.imageURL isEqualToString:@""]) {
                return 250.0; //80
            }
            else {
                return 250.0;
            }
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // DISABLED Points row
    
//    if (indexPath.row == 0) {
//        return nil;
//    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"recommendationDetailSegue" sender:indexPath];
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

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        ChooseOrganizationCodeViewController *myViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        myViewController = [storyboard instantiateViewControllerWithIdentifier:@"chooseOrganizationCodeViewController"];
        myViewController.initialSetupFromRegistration = YES;
        [self presentViewController:myViewController animated:YES completion:^(){}];
        
    }else{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UINavigationController *navigationController = [storyboard instantiateViewControllerWithIdentifier:@"inputSelectionNavigationController"];
        InputSelectionTableViewController *viewController = navigationController.viewControllers[0];
        viewController.initialSetupFromRegistration = YES;

        [self presentViewController:navigationController animated:YES completion:^(){}];    }

    }

#pragma mark - Event Handlers

- (IBAction)settingsButtonTapped:(id)sender {
    [self.revealViewController revealToggle:self];
}

- (void)refresh:(id)sender
{
    self.navigationController.tabBarItem.badgeValue = nil;
    
    dispatch_promise(^{
        if (!sender) {
            self.isPerformingInitialRetrieve = YES;
        }
        
        [RecommendationRecord retrieve].then(^(NSArray *recommendationRecords) {
            // refresh if there is a new record or if this method was NOT called
            // by the UIRefreshControl refresh event
            if ([recommendationRecords lastObject] || !sender) {
                [self refreshTable];
            }
        }).catch(^(NSError *error) {
            [self refreshTable];
        }).finally(^{
            // End Refreshing
            
            if ([sender isKindOfClass:[UIRefreshControl class]]) {
                [(UIRefreshControl *)sender endRefreshing];
            }
            else if (!sender) {
                self.isPerformingInitialRetrieve = NO;
                [self.view hideActivityIndicatorWithNetworkIndicatorOff];
                
                // Initialize Refresh Control after the initial recommendations have
                // been retrieved
                UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
                
                // Configure Refresh Control
                [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
                self.refreshControl = refreshControl;
            }
           
            
           User *user = [User sharedModel];
           if (user.isFreshUser) {
               
               [self performSegueWithIdentifier:@"segueToProfile" sender:self];
            }
           
        });
    });
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    dispatch_async(dispatch_get_main_queue(), ^ {
        [self.tableView reloadData];
    });
}

#pragma mark - Methods

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

- (void)updateRecommendationImageCard:(ImageCard *)card
                            withImage:(UIImage *)image
                            withTitle:(NSString *)title
                          withContent:(NSString *)content
                             withDate:(NSDate *)date
                              forCell:(UITableViewCell *)cell
                         forIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UITableViewCell *cellToUpdate = [self.tableView cellForRowAtIndexPath:indexPath];
        if (cellToUpdate) {
            ImageCard *targetImageCard = (ImageCard *)[cell viewWithTag:HOME_RECOMMENDATION_CARD_TAG];
            [targetImageCard updateImage:image];
            if (title != nil) {
                [targetImageCard updateTitle:title];
            }
            if (date != nil) {
                [targetImageCard updateDate:date];
            }
            if (content != nil) {
                [targetImageCard updateContent:content];
            }
        }
    });
}

- (void)refreshTable {
    [RecommendationRecord queryFromDB:nil].then(^(NSArray *recommendationRecords) {
        self.recommendationRows = recommendationRecords;
    }).finally(^{
        if ([self.recommendationRows count]) {
            [self.tableView reloadData];
            [self hideEmptyMessageInTableView:self.tableView];
        }
        else {
            [self showEmptyMessageInTableView:self.tableView];
        }
    });
}

- (void)showEmptyMessageInTableView:(UITableView *)tableView
{
    if ([tableView viewWithTag:HOME_RECOMMENDATION_EMPTY_MESSAGE_TAG]) {
        return;
    }
    
    UILabel *emptyMessageView = [[UILabel alloc] init];
    emptyMessageView.text = [LocalizationManager getStringFromStrId:@"No notifications"];
    emptyMessageView.tag = HOME_RECOMMENDATION_EMPTY_MESSAGE_TAG;
    emptyMessageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (IS_IPAD) {
        emptyMessageView.font = [UIFont systemFontOfSize:19.5];
    }
    
    [emptyMessageView sizeToFit];
    [StyleManager stylelabel:emptyMessageView];
    
    [tableView addSubview:emptyMessageView];
    
    [tableView addConstraint:[NSLayoutConstraint constraintWithItem:emptyMessageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [tableView addConstraint:[NSLayoutConstraint constraintWithItem:emptyMessageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)hideEmptyMessageInTableView:(UITableView *)tableView
{
    UIView *emptyMessageView = [tableView viewWithTag:HOME_RECOMMENDATION_EMPTY_MESSAGE_TAG];
    [emptyMessageView removeFromSuperview];
}

- (RecommendationRecord *)recommendationRecordWithIndexPath:(NSIndexPath *)indexPath {
    // DISABLED Points row
    //return self.recommendationRows[indexPath.row - 1];
    return self.recommendationRows[indexPath.row];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    NSString *segueId = [segue identifier];

    if ([segueId isEqualToString:@"recommendationDetailSegue"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        RecommendationRecord *currentRecommendation = [self recommendationRecordWithIndexPath:indexPath];
        RecommendationDetailViewController *recommendationDetailController = [segue destinationViewController];
        recommendationDetailController.recommendation = currentRecommendation;
        recommendationDetailController.image = [self.imageCache objectForKey:currentRecommendation.imageURL];
    }
}

@end
