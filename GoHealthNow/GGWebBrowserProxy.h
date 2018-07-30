//
//  GGWebBrowserProxy.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-09-18.
//  Copyright © 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface GGWebBrowserProxy : NSObject

// For iOS9 this method will return SFSafariViewController while
// For any iOS 8 and below, GGWebBrowserViewController will be returned
+ (UIViewController *)browserViewControllerWithUrl:(NSString *)urlString;

@end
