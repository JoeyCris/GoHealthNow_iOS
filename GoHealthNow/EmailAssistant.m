//
//  EmailAssistant.m
//
//  Created by John Wreford on 2015-02-31.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "EmailAssistant.h"
#import "Constants.h"

@interface EmailAssistant ()

@property (nonatomic) NSString *emailStatus;

+ (id)sharedInstance;
- (void)launchEmailContollerwithRecipients:(NSArray *)recipients subject:(NSString *)subject content:(NSString *)messageBody;

@end

@implementation EmailAssistant

#pragma mark - Private methods
+ (id)sharedInstance{
    static EmailAssistant *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc] init];
        
    });
    
    return instance;
}

- (void)launchEmailContollerwithRecipients:(NSArray *)recipients subject:(NSString *)subject content:(NSString *)messageBody{
    NSString *resultRecipientStr;
    if(recipients && recipients.count > 0){
        NSMutableString *recipientStr = [[NSMutableString alloc] init];
        for(NSString *recipient in recipients){
            [recipientStr appendFormat:@"%@,", recipient];
        }
        resultRecipientStr = [recipientStr substringToIndex:recipientStr.length - 1];
    }else{
        resultRecipientStr = @"";
    }
    
    NSString *toRecipients = [NSString stringWithFormat:@"mailto:%@&subject=%@", resultRecipientStr, subject];
    NSString *body = [NSString stringWithFormat:@"&body=%@", messageBody];
    
    NSString *email = [NSString stringWithFormat:@"%@%@", toRecipients, body];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

#pragma mark - Public methods
+ (void)showEmailViewFromController:(UIViewController *)controller recipients:(NSArray *)recipients subject:(NSString *)subject content:(NSString *)body{
    
    EmailAssistant *assistant = [EmailAssistant sharedInstance];
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if(mailClass != nil){
        if(![mailClass canSendMail]){
            [assistant launchEmailContollerwithRecipients:recipients subject:subject content:body];
            NSLog(@"Device unable to send email. / Launch anyways perhaps they want to save as draft.");
            return;
        }
    }else{
        [assistant launchEmailContollerwithRecipients:recipients subject:subject content:body];
        return;
    }
    
    if(!controller){
        return;
    }
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = assistant;
    [mailController setSubject:subject];
    [mailController setMessageBody:body isHTML:NO];
    if(recipients && recipients.count > 0){
        [mailController setToRecipients:recipients];
    }
    [controller presentViewController:mailController animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    switch (result)
    {
        case MFMailComposeResultCancelled:
            self.emailStatus = [LocalizationManager getStringFromStrId:@"Email Cancelled."];
            NSLog(@"Email cancelled");
            break;
        case MFMailComposeResultSaved:
            self.emailStatus = [LocalizationManager getStringFromStrId:@"Email Saved."];
            NSLog(@"Email saved");
            break;
        case MFMailComposeResultSent:
            self.emailStatus = [LocalizationManager getStringFromStrId:@"Email Sent."];
            NSLog(@"Email sent");
            break;
        case MFMailComposeResultFailed:
            self.emailStatus = [NSString stringWithFormat:@"Email failure: %@", [error localizedDescription]];
            NSLog(@"Email send failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self showMessageStatus];
}

-(void)showMessageStatus {
    
    UIAlertView *promptEmailLifeCycleAlert = [[UIAlertView alloc] initWithTitle:self.emailStatus
                                                               message:nil
                                                              delegate:nil
                                                     cancelButtonTitle:MSG_OK
                                                     otherButtonTitles:nil];
    [promptEmailLifeCycleAlert show];
}
@end

