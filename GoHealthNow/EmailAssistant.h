//
//  EmailAssistant.h
//
//  Created by John Wreford on 2015-02-31.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#ifndef email_EmailAssistant_h
#define email_EmailAssistant_h

#endif

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface EmailAssistant : NSObject<MFMailComposeViewControllerDelegate>

+ (void)showEmailViewFromController:(UIViewController *)controller
                         recipients:(NSArray *)recipients
                            subject:(NSString *)subject
                            content:(NSString *)body;

@end