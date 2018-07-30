//
//  RecommendationDetailViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-01.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "RecommendationDetailViewController.h"
#import "StyleManager.h"
#import "GGWebBrowserProxy.h"
#import "ProfileTableViewController.h"
#import "EmailAssistant.h"
#import "NotificationMedicationClass.h"
#import "GoalsViewController.h"
#import "GGUtils.h"

#include <sys/types.h>
#include <sys/sysctl.h>

@interface RecommendationDetailViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLandscapeModeHeightConstraint;
@property (nonatomic) float textViewLandscapeModeHeightConstraintChosenConstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewBottomConstraint;
@property (nonatomic) float textViewBottomConstraintOrigConstant;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLandscapeModeBottomConstraint;
@property (nonatomic) float imageViewLandscapeModeBottomOrigConstant;

@property (nonatomic) NSArray *targetView;
@property (nonatomic) int jumpIndex;


@property (nonatomic) UILongPressGestureRecognizer *seeDetailsGestureRecognizerForDivider;

@end

@implementation RecommendationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textViewBottomConstraintOrigConstant = self.textViewBottomConstraint.constant;
    self.imageViewLandscapeModeBottomOrigConstant = self.imageViewLandscapeModeBottomConstraint.constant;
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_IMAGE];
    UITextView *textView = (UITextView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_TEXT_VIEW];
    UIView *seeDetailsDivider = (UIView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DIVIDER];
    UIButton *seeDetailsButton = (UIButton *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON];
    
    [StyleManager styleMainView:self.view];
    [StyleManager styleTextView:textView];
    
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    textView.editable = NO;
    textView.backgroundColor = [UIColor clearColor];
    
    //self.seeDetailsGestureRecognizerForDivider =
    //    [[UILongPressGestureRecognizer alloc]initWithTarget:self
   //                                                  action:@selector(seeDetailsLinkTapped)];
   // self.seeDetailsGestureRecognizerForDivider.minimumPressDuration = 0.1;
   // self.seeDetailsGestureRecognizerForDivider.allowableMovement = 2.0;
    
    //seeDetailsDivider.userInteractionEnabled = YES;
    
   // [seeDetailsButton addTarget:self action:@selector(seeDetailsLinkTapped) forControlEvents:UIControlEventTouchUpInside];
   // [seeDetailsDivider addGestureRecognizer:self.seeDetailsGestureRecognizerForDivider];
    
    UITapGestureRecognizer *tapGR;
    tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(seeDetailsLinkTapped)];
    tapGR.numberOfTapsRequired = 1;
 
    
    [self.view addGestureRecognizer:tapGR];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_targetView == nil) {
        _targetView = @[@[LOCAL_ACTION_ADD_MEAL, @"RecentMealsController", [LocalizationManager getStringFromStrId:@"Log a meal"]],
                        @[LOCAL_ACTION_ADD_REMINDER, @"", [LocalizationManager getStringFromStrId:@"Add a reminder"]],
                        @[LOCAL_ACTION_EDIT_PROFILE, @"profile_controller", [LocalizationManager getStringFromStrId:@"Set up your profile"]],
                        @[LOCAL_ACTION_ADD_MEAL_BY_PHOTO, @"RecentMealsController", [LocalizationManager getStringFromStrId:@"Log a meal"]],
                        @[LOCAL_ACTION_ADD_REMINDER_EXERCISE, @"", [LocalizationManager getStringFromStrId:@"Add a reminder"]],
                        @[LOCAL_ACTION_ADD_REMINDER_MEDICATION, @"", [LocalizationManager getStringFromStrId:@"Add a reminder"]],
                        @[LOCAL_ACTION_CONTACT_US, @"", [LocalizationManager getStringFromStrId:@"Contact us"]],
                        @[LOCAL_ACTION_SET_GOAL, @"setGoalSegue", [LocalizationManager getStringFromStrId:@"Set goals"]]];
    }
    
    _jumpIndex = -1;
    
    if (![self.recommendation.link isEqualToString:@""] &&
        self.recommendation.link.length >= 8 &&
        [self.recommendation.link rangeOfString:@"local://"].location != NSNotFound) {
        for (int i=0;i<[_targetView count];i++) {
            if ([_targetView[i][0] isEqualToString:self.recommendation.link]) {
                _jumpIndex = i;
                break;
            }
        }
    }
    
    if ((_jumpIndex >=0 && _jumpIndex<[_targetView count])) {
        UIButton *seeDetailsButton = (UIButton *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON];
        [seeDetailsButton setTitle:_targetView[_jumpIndex][2] forState:UIControlStateNormal];
    }
    
    switch (self.recommendation.type) {
        case NotificationTypeMessage:
            self.navigationItem.title = [LocalizationManager getStringFromStrId:@"Message"];
            break;
        case NotificationTypeAdvice:
            self.navigationItem.title = [LocalizationManager getStringFromStrId:@"Advice"];
            break;
        case NotificationTypeHealthTip:
            self.navigationItem.title = [LocalizationManager getStringFromStrId:@"Health Tip"];
            break;
    }
    
    UIImageView *imageView = (UIImageView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_IMAGE];
    UITextView *textView = (UITextView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_TEXT_VIEW];
    UIView *seeDetailsDivider = (UIView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DIVIDER];
    UIButton *seeDetailsButton = (UIButton *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON];
    
    textView.text = [self.recommendation.content stringByReplacingOccurrencesOfString:@"\\n"
                                                                           withString:@"\n"];
    
    if (self.image) {
        imageView.image = self.image;
    }
    else if (!self.recommendation.imageURL || [self.recommendation.imageURL isEqualToString:@""]) {
        imageView.image = [UIImage imageNamed:@"splashIcon"];
    }
    else {
        // load image from URL async
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSData *imageData = nil;
            switch (self.recommendation.imageLocation) {
                case ImageLocationLocal:
                    imageData = [NSData dataWithContentsOfFile:self.recommendation.imageURL];
                    break;
                case ImageLocationRemote:
                    imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.recommendation.imageURL]];
                    break;
                    
            }
            
            UIImage *image = imageData ? [UIImage imageWithData:imageData] : [UIImage imageNamed:@"splashIcon"];
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = image;
            });
        });
    }
    
    if (self.recommendation.link && ![self.recommendation.link isEqualToString:@""]) {
        seeDetailsDivider.hidden = NO;
        seeDetailsButton.hidden = NO;
    }
    else {
        seeDetailsDivider.hidden = YES;
        seeDetailsButton.hidden = YES;
    }
    
    [self setupOrientationSpecificViews];
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self setupOrientationSpecificViews];
    }
                                 completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)setupOrientationSpecificViews {
    UITextView *textView = (UITextView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_TEXT_VIEW];
    [textView scrollRangeToVisible:NSMakeRange(0, 1)];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    switch (orientation) {
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            if (self.recommendation.link && ![self.recommendation.link isEqualToString:@""]) {
                self.textViewBottomConstraint.constant = self.textViewBottomConstraintOrigConstant;
            }
            else {
                UIView *seeDetailsDivider = (UIView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DIVIDER];
                UIButton *seeDetailsButton = (UIButton *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON];

                self.textViewBottomConstraint.constant = self.textViewBottomConstraintOrigConstant -
                                                            seeDetailsDivider.frame.size.height - 8.0 -
                                                            seeDetailsButton.frame.size.height - 8.0;
            }
            break;
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight: {
            if (self.recommendation.link && ![self.recommendation.link isEqualToString:@""]) {
                self.imageViewLandscapeModeBottomConstraint.constant = self.imageViewLandscapeModeBottomOrigConstant;
            }
            else {
                UIView *seeDetailsDivider = (UIView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DIVIDER];
                UIButton *seeDetailsButton = (UIButton *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_DETAILS_BUTTON];
                
                self.imageViewLandscapeModeBottomConstraint.constant = self.imageViewLandscapeModeBottomOrigConstant -
                                                                          seeDetailsDivider.frame.size.height - 8.0 -
                                                                          seeDetailsButton.frame.size.height - 8.0;
            }
            
            if (self.textViewLandscapeModeHeightConstraintChosenConstant == 0.0) {
                UIImageView *imageView = (UIImageView *)[self.view viewWithTag:RECOMMENDATION_DETAIL_TAG_IMAGE];
                
                CGSize textViewSizeThatShouldFitTheContent = [textView sizeThatFits:CGSizeMake(imageView.frame.size.width, FLT_MAX)];
                
                // case when there is only 1 or two lines of content, which means that the text view
                // content height is much shorter than the height of the image.
                if (textViewSizeThatShouldFitTheContent.height + 55.0 <= imageView.frame.size.height) {
                    self.textViewLandscapeModeHeightConstraintChosenConstant = imageView.frame.size.height / 2.0;
                }
                else {
                    self.textViewLandscapeModeHeightConstraintChosenConstant = 0.0;
                }
            }
            
            self.textViewLandscapeModeHeightConstraint.constant = self.textViewLandscapeModeHeightConstraintChosenConstant;
            
            break;
        }
        default:
            break;
    }
}

- (void)jumpToViewWithURL:(NSString *)url {
    
    if (!(_jumpIndex >=0 && _jumpIndex<[_targetView count]) || _targetView == nil) {
        return;
    }
    if (!([url isEqualToString:LOCAL_ACTION_ADD_REMINDER] || [url isEqualToString:LOCAL_ACTION_ADD_REMINDER_EXERCISE] || [url isEqualToString:LOCAL_ACTION_ADD_REMINDER_MEDICATION] )) {
        if ([url isEqualToString:LOCAL_ACTION_CONTACT_US]) {
            
            
            NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
            NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            NSString *phoneType = [self phoneModel];
            
            NSString *body = [NSString stringWithFormat:@"\n\n\n\niOS: %@\nPhone Model: %@\nGoHealthNow Version: %@", iOSVersion, phoneType, appVersionString];
            
            
            [EmailAssistant showEmailViewFromController:self recipients:@[@"support@gohealthnow.ca"] subject:[LocalizationManager getStringFromStrId:@"Questions About GoHealthNow"] content:body];
            
        }
        else if ([url isEqualToString:LOCAL_ACTION_SET_GOAL]) {
            [self performSegueWithIdentifier:@"setGoalSegue" sender:self];
        }
        else {
            UIViewController *myViewController;
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            myViewController = [storyboard instantiateViewControllerWithIdentifier:_targetView[_jumpIndex][1]];
            
            [self.navigationController pushViewController:myViewController animated:YES];
        }
    }
    else {
        UIViewController *myViewController;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
        if ([url isEqualToString:LOCAL_ACTION_ADD_REMINDER_EXERCISE]) {
            
            myViewController = [storyboard instantiateViewControllerWithIdentifier:@"ExerciseNotificationViewController"];
            [self presentViewController:myViewController animated:YES completion:nil];
        }
        else if ([url isEqualToString:LOCAL_ACTION_ADD_REMINDER_MEDICATION]) {
            
            NotificationMedicationClass *reminder= [NotificationMedicationClass getInstance];
            [reminder setStringComingFromWhere:@"createNew"];
            myViewController = [storyboard instantiateViewControllerWithIdentifier:@"MedicationInputViewController"];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:myViewController];
            [self.navigationController presentViewController:navigationController animated:YES completion:nil];
            
        }
        else if ([url isEqualToString:LOCAL_ACTION_ADD_REMINDER]) {
            [self.tabBarController setSelectedIndex:3];
            return;
        }
        else
            return;
        
       
    }
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"setGoalSegue"]) {
        GoalsViewController *destvc = segue.destinationViewController;
        destvc.navigationItem.leftBarButtonItem = nil;
        UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:nil
                                                                    action:nil];
        [self.navigationItem setBackBarButtonItem:backItem];
    }
}


#pragma mark - Event Handlers
- (void)seeDetailsLinkTapped {
    if (self.recommendation.link && ![self.recommendation.link isEqualToString:@""]) {
        if (![self.recommendation.link isEqualToString:@""] &&
            self.recommendation.link.length >= 8 &&
            [self.recommendation.link rangeOfString:@"local://"].location != NSNotFound) {
            [self jumpToViewWithURL:self.recommendation.link];
        }
        else {
            UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:self.recommendation.link];
            [self presentViewController:browser animated:YES completion:nil];
        }
    }
}

-(NSString *)phoneModel{
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    
    free(machine);
    
    return [self platformType:platform];
}

- (NSString *) platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    if ([platform isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([platform isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPod7,1"])      return @"iPod Touch 6G";
    
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"iPad6,7"])      return @"iPad Pro (WiFi)";
    if ([platform isEqualToString:@"iPad6,8"])      return @"iPad Pro (Cellular)";
    
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,1"])      return @"iPad mini 4 (WiFi)";
    if ([platform isEqualToString:@"iPad5,2"])      return @"iPad mini 4 (Cellular)";
    
    if ([platform isEqualToString:@"Watch1,1"])      return @"Apple Watch";
    if ([platform isEqualToString:@"Watch1,2"])      return @"Apple Watch";
    
    if ([platform isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3G";
    if ([platform isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4G";
    
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}


@end
