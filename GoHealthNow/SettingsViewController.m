//
//  SettingsViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-12.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import "SettingsViewController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "UIColor+Extensions.h"
#import "User.h"
#import "UIView+Extensions.h"
#import "AppDelegate.h"
#import "SWRevealViewController.h"
#import "GGWebBrowserProxy.h"
#import "EmailAssistant.h"
#import "GGUtils.h"

#include <sys/types.h>
#include <sys/sysctl.h>


@interface SettingsViewController () <MFMailComposeViewControllerDelegate>

@property (nonatomic) NSArray *settingsRows;
@property (nonatomic) NSArray *settingsRowValues;

@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *textColor;

@property (nonatomic) NSString *emailStatus;

@property (nonatomic) NSString *brandUrl;
@property (nonatomic) UIImage *brandLogo;
@property (nonatomic) NSString *brandName;

@property (nonatomic) NSString *currentAccessCode;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;

@end

@implementation SettingsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.backgroundColor = [UIColor colorWithRed:80.0/255.0 green:80.0/255.0 blue:80.0/255.0 alpha:1.0];
    self.textColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
    
    UIBarButtonItem *leftBarButtonTitle = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:@"Menu"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    NSDictionary *leftBarButtonTitleAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0],
                                                   NSForegroundColorAttributeName: [UIColor whiteColor]
                                                   };
    
    [leftBarButtonTitle setTitleTextAttributes:leftBarButtonTitleAttributes forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = leftBarButtonTitle;
    self.navigationController.navigationBar.barTintColor = self.backgroundColor;
    
    [StyleManager styleTable:self.tableView];
    self.tableView.separatorColor = self.textColor;;
    self.tableView.backgroundColor = self.backgroundColor;
    
    self.settingsRows = @[[LocalizationManager getStringFromStrId:SETTINGS_ROW_HOME], [LocalizationManager getStringFromStrId:SETTINGS_ROW_PROFILE], [LocalizationManager getStringFromStrId:SETTINGS_ROW_INPUT_SELECTION], [LocalizationManager getStringFromStrId:SETTINGS_ROW_GOALS], [LocalizationManager getStringFromStrId:SETTINGS_ROW_ONLINE_LOGBOOK], [LocalizationManager getStringFromStrId:SETTINGS_ROW_HOWTOVIDEO], [LocalizationManager getStringFromStrId:SETTINGS_ROW_CONTACT], [LocalizationManager getStringFromStrId:SETTINGS_ROW_LOGOUT]];
   
    
    User *user = [User sharedModel];
    self.brandUrl = [user.brandLogo getBrandUrl];
    self.currentAccessCode = user.organizationCode;
}

- (void)viewWillAppear:(BOOL)animated {
    [self updateBrandLogo];
    User *user = [User sharedModel];
    if (![user.organizationCode isEqualToString:user.brandLogo.brandAccessCode] && (user.organizationCode != nil)) {
        [user.brandLogo resetToDefault];
        [[User sharedModel] updateBrandWithAccesscode];
        //should update brand logo
        [self updateBrandLogo];
        NSLog(@"Brand logo updated.\n");
        self.brandUrl = [user.brandLogo getBrandUrl];
        self.currentAccessCode = user.organizationCode;
    }
    [super viewWillAppear:animated];
}

- (void)updateBrandLogo {
    [self.tableView reloadData];
    NSIndexPath *indexPathBrand = [NSIndexPath indexPathForRow:0 inSection:0];
    //NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPathBrand, indexPathBrand,nil];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPathBrand, nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void) loadBrandUrl {
    if (self.brandUrl) {
        @try {
            UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:[NSString stringWithFormat:(([self.brandUrl  rangeOfString:@"http"].location == NSNotFound) ? @"https://%@" : @"%@"), self.brandUrl]];
            [self presentViewController:browser animated:YES completion:nil];
        }
        @catch (NSException *exception) {
            NSLog(@"Invalid URL.\n");
        }
        @finally {
            
        }
    }
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        User *user = [User sharedModel];
        
        if(user.organizationCode){
            
            if ([user.brandLogo getBrandLogo] == nil) {
                return 0;
            }
            
            return 120+ 45; //120+45+10
        }else{
            return 0;//0
        }
        
    }else if (indexPath.row > 0 && indexPath.row < 9) {
        return 40;
    }else {
        return 80;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.settingsRows count] + 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCellLogo" forIndexPath:indexPath];
        
        User *user = [User sharedModel];
        
        //LOGO
        UIImageView *imgLogo = [[UIImageView alloc]initWithFrame:CGRectMake(15 + 35, 0, 160, 120)]; //
        imgLogo.image = [user.brandLogo getBrandLogo];
        imgLogo.contentMode = UIViewContentModeScaleAspectFit;
        imgLogo.backgroundColor = [UIColor clearColor];
        [cell addSubview:imgLogo];
        
        if ([user.brandLogo getBrandLogo]) {
            self.brandUrl = [user.brandLogo getBrandUrl];
            self.currentAccessCode = user.organizationCode;
        }

        //NAME
        if ([cell viewWithTag:324] != nil) {
            UILabel *lblCompanyName = [cell viewWithTag:324];
            [lblCompanyName setText:[user.brandLogo getBrandName]];
        }
        else {
            UILabel *lblCompanyName = [[UILabel alloc]initWithFrame:CGRectMake(15,120, 260 - 15, 45)];  // (260 is taken from SWReveal controller default size)
            lblCompanyName.textColor = [UIColor whiteColor];
            lblCompanyName.text = [user.brandLogo getBrandName];
            lblCompanyName.backgroundColor = [UIColor clearColor];
            lblCompanyName.lineBreakMode = NSLineBreakByWordWrapping;
            lblCompanyName.textAlignment = NSTextAlignmentCenter;
            lblCompanyName.numberOfLines = 0;
            lblCompanyName.font = [UIFont systemFontOfSize:14];
            lblCompanyName.tag = 324;
            [cell addSubview:lblCompanyName];
        }
        
        //SEPERATOR
        UILabel *lblSeperator = (UILabel *)[cell viewWithTag:10];
        lblSeperator.backgroundColor = [UIColor whiteColor];
        
        [StyleManager styleTableCell:cell];
        cell.backgroundColor = self.backgroundColor;
        
        cell.clipsToBounds = YES;
        
        return cell;
        
    }else if (indexPath.row > 0 && indexPath.row < 9){
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCellLabel" forIndexPath:indexPath];
        
        UILabel *lblRowName = (UILabel *)[cell viewWithTag:300];
        lblRowName.text = [NSString stringWithFormat:@"%@", self.settingsRows[indexPath.row - 1]];
        lblRowName.textColor = self.textColor;
        
        UILabel *lblSeperator = (UILabel *)[cell viewWithTag:10];
        lblSeperator.backgroundColor = [UIColor whiteColor];
        
        [StyleManager styleTableCell:cell];
        cell.backgroundColor = self.backgroundColor;
        
        return cell;
        
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCellVersion" forIndexPath:indexPath];
        
        UILabel *lblVersion = (UILabel *)[cell viewWithTag:100];
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *appBuild = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GitHash"];
        lblVersion.text = [NSString stringWithFormat:@"Version %@ (%@)", appVersion, appBuild];
        lblVersion.textColor = self.textColor;
        
        UILabel *lblName = (UILabel *)[cell viewWithTag:200];
        lblName.textColor = self.textColor;
        
        [StyleManager styleTableCell:cell];
        cell.backgroundColor = self.backgroundColor;
        
        return cell;
    }
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        SWRevealViewController *revealController = self.revealViewController;
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UIViewController *mainTabBarController = [appDelegate mainTabBarController];
        
        [revealController pushFrontViewController:mainTabBarController animated:YES];
    }
    else if (indexPath.row == 2) {
        [self performSegueWithIdentifier:@"profileSegue" sender:self];
    }
    else if (indexPath.row == 3) {
        [self performSegueWithIdentifier:@"inputSelectionSegue" sender:self];
    }
    else if (indexPath.row == 4) {
        [self performSegueWithIdentifier:@"segueToGoals" sender:self];
    }
    else if (indexPath.row == 5) {
        UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:([GGUtils getAppType] == AppTypeGlucoGuide ? @"https://myaccount.glucoguide.com" : @"https://myaccount.glucoguide.com/#!/signin_ghn")];
        [self presentViewController:browser animated:YES completion:nil];
    }
    else if (indexPath.row == 6) {
        NSString *url;
        if ([GGUtils getAppType] == AppTypeGoHealthNow) {
            url = [GGUtils getSystemLanguageSetting] == AppLanguageEn ? @"http://www.gohealthnow.ca/GH_guide_En.html" : @"http://www.gohealthnow.ca/GH_guide_Fr.html";
        }
        else {
            url = [GGUtils getSystemLanguageSetting] == AppLanguageEn ? @"https://glucoguide.com/GG_guide_En.html": @"https://glucoguide.com/GG_guide_Fr.html";
        }
        
        UIViewController *browser = [GGWebBrowserProxy browserViewControllerWithUrl:url];
        [self presentViewController:browser animated:YES completion:nil];
    }
    else if (indexPath.row == 7) {
        
        NSString *iOSVersion = [[UIDevice currentDevice] systemVersion];
        NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        NSString *phoneType = [self phoneModel];
        
        NSString *body = [NSString stringWithFormat:@"\n\n\n\niOS: %@\nPhone Model: %@\nGoHealthNow Version: %@", iOSVersion, phoneType, appVersionString];
        
        
        [EmailAssistant showEmailViewFromController:self recipients:@[@"support@gohealthnow.ca"] subject:[LocalizationManager getStringFromStrId:@"Questions About GoHealthNow"] content:body];
    }
    else if (indexPath.row == 8) {
        [self.view showActivityIndicatorWithMessage:[LocalizationManager getStringFromStrId:@"Logging out..."]];
        
        dispatch_promise(^{
            [((User *)[User sharedModel]) logout].then(^(BOOL success) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate setWindowRootWithAnimation:YES];
            }).catch(^(NSError *error) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:ALERT_TITLE_OOPS]
                                                                message:[LocalizationManager getStringFromStrId:@"Unable to logout."]
                                                               delegate:self
                                                      cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                      otherButtonTitles:nil];
                
                [alert show];
            }).finally(^{
                [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            });
        });
    }else if (indexPath.row == 0){
        
        [self loadBrandUrl];
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
