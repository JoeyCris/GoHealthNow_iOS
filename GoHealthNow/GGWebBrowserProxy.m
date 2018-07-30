//
//  GGWebBrowserProxy.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-09-18.
//  Copyright © 2015 GlucoGuide. All rights reserved.
//

#import "GGWebBrowserProxy.h"
#import <SafariServices/SafariServices.h>
#import "GGWebBrowserViewController.h"
#import "Constants.h"

@implementation GGWebBrowserProxy

+ (UIViewController *)browserViewControllerWithUrl:(NSString *)urlString {
    UIViewController *browserViewController = nil;
    
    if (NSClassFromString(@"SFSafariViewController")) {
        browserViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
    }
    else {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:APP_DELEGATE_STORYBOARD_NAME bundle:[NSBundle mainBundle]];
        GGWebBrowserViewController *webBrowser = [storyBoard instantiateViewControllerWithIdentifier:@"webViewController"];
        [webBrowser initWithAddress:urlString
                      withUserInput:NO];
        
        browserViewController = webBrowser;
    }
    
    return browserViewController;
}

@end
