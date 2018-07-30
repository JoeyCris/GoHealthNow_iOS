//
//  UserSetupPageViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-25.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "UserSetupPageViewController.h"
#import "StyleManager.h"
#import "UserSetupPageViewControllerProtocol.h"
#import "ChooseUnitViewController.h"
#import "WeightRecord.h"
#import "User.h"
#import "AppDelegate.h"
#import "UIView+Extensions.h"
#import "ChooseWeightViewController.h"
#import "ChooseHeightViewController.h"
#import "ChooseRemindersViewController.h"

@interface UserSetupPageViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic) NSArray *pages;
@property (nonatomic) NSMutableDictionary *pageCache;

@end

@implementation UserSetupPageViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pages = @[STORYBOARD_ID_USER_SETUP_FIRST, STORYBOARD_ID_ORG_CODE, STORYBOARD_ID_USER_NAME, STORYBOARD_ID_GENDER,
                   STORYBOARD_ID_BIRTH_YEAR, STORYBOARD_ID_MEASURE_UNIT, STORYBOARD_ID_MEASURE_UNIT, STORYBOARD_ID_WEIGHT, STORYBOARD_ID_HEIGHT, STORYBOARD_ID_CAL_DIST, STORYBOARD_ID_BMI_WAIST, STORYBOARD_ID_REMINDERS, STORYBOARD_ID_REMINDERS];
    self.delegate = self;
    self.dataSource = self;
    
    [StyleManager styleMainView:self.view];
    
    UIViewController *firstContentViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[firstContentViewController];
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.pageCache = nil;
}

#pragma mark - Page View Controller Delegate

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    // If the page did not turn
    if (!completed) {
        // You do nothing because whatever page you thought
        // the book was on before the gesture started is still the correct page
        return;
    }
    
    for (UIViewController<UserSetupPageViewControllerProtocol> *prevVC in previousViewControllers) {
        if ([prevVC respondsToSelector:@selector(didFlipForwardToNextPageWithGesture:)]) {
            [prevVC didFlipForwardToNextPageWithGesture:self];
        }
    }
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    UIViewController<UserSetupPageViewControllerProtocol> *userSetupPageViewController = (UIViewController<UserSetupPageViewControllerProtocol> *)viewController;
    NSUInteger index = userSetupPageViewController.userSetupPageIndex ? userSetupPageViewController.userSetupPageIndex : 0;
    
    return [self viewControllerAtIndex:index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    UIViewController<UserSetupPageViewControllerProtocol> *userSetupPageViewController = (UIViewController<UserSetupPageViewControllerProtocol> *)viewController;
    NSUInteger index = userSetupPageViewController.userSetupPageIndex ? userSetupPageViewController.userSetupPageIndex : 0;
    
    return [self viewControllerAtIndex:index + 1];
}

#pragma mark - Methods

- (UIViewController *)viewControllerAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self.pages count]-1) {
        return nil;
    }
    
    if (!self.pageCache) {
        self.pageCache = [NSMutableDictionary dictionary];
    }
    
    UIViewController<UserSetupPageViewControllerProtocol> *pageContentViewController = nil;
    NSString *pageCacheKey = [NSString stringWithFormat:@"%ld-%@", (long)index, self.pages[index]];
    
    if (!self.pageCache[pageCacheKey]) {
        UIStoryboard *appStoryBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
        
        pageContentViewController = [appStoryBoard instantiateViewControllerWithIdentifier:self.pages[index]];
        pageContentViewController.delegate = self;
        pageContentViewController.isUserSetupModeEnabled = YES;
        
        if ([self.pages[index] isEqualToString:STORYBOARD_ID_MEASURE_UNIT]) {
            if (index == [self.pages indexOfObject:STORYBOARD_ID_MEASURE_UNIT]) {
                ((ChooseUnitViewController *)pageContentViewController).displayMode = UnitViewControllerWeightDisplayMode;
            }
            else if (index == [self.pages indexOfObject:STORYBOARD_ID_MEASURE_UNIT] + 1) {
                ((ChooseUnitViewController *)pageContentViewController).displayMode = UnitViewControllerGlucoseDisplayMode;
            }
        }
        
        pageContentViewController.userSetupPageIndex = index;
        
        // add to the cache
        self.pageCache[pageCacheKey] = pageContentViewController;
    }
    else {
        pageContentViewController = self.pageCache[pageCacheKey];
    }
    
    return pageContentViewController;
}

#pragma mark - User Setup First View Controller Delegate

- (void)firstControllerDidContinue:(id)sender {
    // when sender is self, we are invoking this delegate function via the
    // didFlipForwardToNextPageWithGesture method, which means that the page was already flipped
    // so we don't want to do it again
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_USER_SETUP_FIRST] + 1];
    }
}

- (void)firstControllerDidSkip:(id)sender {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setWindowRootWithAnimation:YES];
}

#pragma mark - Choose Organization Code Delegate

- (void)didChooseOrganizationCode:(NSString *)code sender:(id)sender {
    ((User *)[User sharedModel]).organizationCode = code;
    
    // when sender is self, we are invoking this delegate function via the
    // didFlipForwardToNextPageWithGesture method, which means that the page was already flipped
    // so we don't want to do it again
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_ORG_CODE] + 1];
    }
}

#pragma mark - Choose User Name Delegate

- (void)didChoosefirstName:(NSString *)firstName lastName:(NSString *)lastName sender:(id)sender {
    User *user = [User sharedModel];
    user.firstName = firstName;
    user.lastName = lastName;

    
    // when sender is self, we are invoking this delegate function via the
    // didFlipForwardToNextPageWithGesture method, which means that the page was already flipped
    // so we don't want to do it again
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_USER_NAME] + 1];
    }
}

#pragma mark - Choose Unit Delegate

- (void)didChooseUnit:(NSUInteger)unit withUnitMode:(UnitViewControllerDisplayMode)unitMode sender:(id)sender {
    User *user = [User sharedModel];
    
    switch (unitMode) {
        case UnitViewControllerGlucoseDisplayMode: {
            user.bgUnit = (BGUnit)unit;
            
            if (sender != self) {
                // the +2 is needed here because STORYBOARD_ID_MEASURE_UNIT occurs twice in the pages array, which
                // means that it will find the first index that contains STORYBOARD_ID_MEASURE_UNIT. But we need
                // the second time that STORYBOARD_ID_MEASURE_UNIT occurs within the pages array.
                [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_MEASURE_UNIT] + 2];
            }
            
            break;
        }
        case UnitViewControllerWeightDisplayMode: {
            user.measureUnit = (MeasureUnit)unit;

            if (sender != self) {
                NSUInteger weightVCIndex = [self.pages indexOfObject:STORYBOARD_ID_WEIGHT];
                NSUInteger heightVCIndex = [self.pages indexOfObject:STORYBOARD_ID_HEIGHT];
                
                ChooseWeightViewController *weightVC = (ChooseWeightViewController *)[self viewControllerAtIndex:weightVCIndex];
                ChooseHeightViewController *heightVC = (ChooseHeightViewController *)[self viewControllerAtIndex:heightVCIndex];
                
                weightVC.unitMode = user.measureUnit;
                heightVC.unitMode = user.measureUnit;
                
                [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_MEASURE_UNIT] + 1];
            }
            
            break;
        }
    }
}

#pragma mark - Choose Gender Delegate

- (void)didChooseGender:(GenderType)gender sender:(id)sender {
    ((User *)[User sharedModel]).gender = gender;
    
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_GENDER] + 1];
    }
}

#pragma mark - Choose Birth Year Delegate

- (void)didChooseBirthYear:(NSDate *)date sender:(id)sender {
    ((User *)[User sharedModel]).dob = date;
    
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_BIRTH_YEAR] + 1];
    }
}

#pragma mark - Choose Height Delegate

- (void)didChooseHeight:(LengthUnit *)height sender:(id)sender {
    ((User *)[User sharedModel]).height = height;
    
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_HEIGHT] + 1];
    }
}

- (void)doHeightViewReverse {
    [self flipReverseToLastPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_HEIGHT]];
}

#pragma mark - Choose Weight Delegate

- (void)didChooseWeight:(WeightUnit *)weight sender:(id)sender {
    [((User *)[User sharedModel]) addWeightRecord:weight :[NSDate date]];
    
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_WEIGHT] + 1];
    }
}


#pragma mark - Choose BMI and Waist

- (void)didChooseWaistSize:(LengthUnit *)waistSize sender:(id)sender {
    User *user = [User sharedModel];
    user.waistSize = waistSize;
    
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_BMI_WAIST] + 1];
    }
}

#pragma mark - Choose Reminders Delegate 
-(void)didSetReminder:(id)sender{
    User *user = [User sharedModel];
    if (sender != self) {
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:USER_SAVING_MSG];
        
        dispatch_promise(^{
            [user save].then(^(BOOL success) {
                // last index so show the tab bar
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate setWindowRootWithAnimation:YES];
            }).catch(^(BOOL success) {
                UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:@"User Setup"]
                                                                      message:[LocalizationManager getStringFromStrId:@"Failed to save user information."]
                                                                     delegate:nil
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:nil];
                [promptAlert show];
            }).finally(^{
                [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            });
        });
    }
}


- (void)doWeightViewReverse {
    [self flipReverseToLastPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_WEIGHT]];
}

#pragma mark - Calorie Distribution Delegate

- (void)didUpdateMealCalculator:(id)sender {
    if (sender != self) {
        [self flipForwardToNextPageWithIndex:[self.pages indexOfObject:STORYBOARD_ID_CAL_DIST] + 1];
    }
}

#pragma mark - Methods

- (void)flipForwardToNextPageWithIndex:(NSUInteger)nextPageIndex {
    UIViewController *nextVC = [self viewControllerAtIndex:nextPageIndex];
        
    [self setViewControllers:@[nextVC]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:YES
                  completion:nil];
    
}

- (void)flipReverseToLastPageWithIndex:(NSUInteger)lastPageIndex {
    UIViewController *lastVC = [self viewControllerAtIndex:lastPageIndex];
    
    [self setViewControllers:@[lastVC]
                   direction:UIPageViewControllerNavigationDirectionReverse
                    animated:YES
                  completion:nil];
}

@end
