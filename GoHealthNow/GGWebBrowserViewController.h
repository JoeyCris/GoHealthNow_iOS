//
//  GGWebBrowserViewController.h
//  GlucoGuide
//
//  Created by HoriKu on 2015-04-21.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GGWebBrowserViewController : UIViewController

- (void)initWithAddress:(NSString*)urlString withUserInput:(BOOL)isUserInputEnabled;
- (void)initWithUrl:(NSURL *)url withUserInput:(BOOL)isUserInputEnabled;
- (void)initWithUrlRequest:(NSURLRequest *)urlRequest withUserInput:(BOOL)isUserInputEnabled;

@end
