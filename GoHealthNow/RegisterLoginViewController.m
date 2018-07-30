//
//  ViewController.m
//  testSignUpScreens
//
//  Created by John Wreford on 2015-08-29.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "RegisterLoginViewController.h"

#import "AppDelegate.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "User.h"
#import "UIView+Extensions.h"
#import "GGWebBrowserProxy.h"
#import "LocalNotificationResponseAssistant.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface RegisterLoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imgBackgroundImageView;
//@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;

@property (strong, nonatomic) IBOutlet UIView *viewEmail;
@property (strong, nonatomic) IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIView *viewInputArea;
@property (weak, nonatomic) IBOutlet UILabel *lblInputAreaTitle;

@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;

@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *facebookLogin;


@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topConstraintEmail;
@property CGFloat tempContraint;

@property (strong, nonatomic) IBOutlet UILabel *lblError;

@property (nonatomic) BOOL registerFlag;
@property (nonatomic) BOOL facebookLoginFlag;
@property (nonatomic) BOOL eulaFlag;

@end

@implementation RegisterLoginViewController

#pragma mark - View lifecycle
-(void)viewDidAppear:(BOOL)animated{
    
    if (self.eulaFlag == 1) {
        [self continueWithRegistration];
    }else{
        self.eulaFlag = 0;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.facebookLoginFlag = 0;
    self.imgBackgroundImageView.image = [UIImage imageNamed:@"loginBackground"];
    
    //[self.viewEmail setAlpha: 0];
    //[self.viewPassword setAlpha:0];
    [self.viewInputArea setAlpha:0];
    
    self.lblError.hidden = YES;
    
    self.btnLogin.layer.cornerRadius = 5;
    self.btnRegister.layer.cornerRadius = 5;
    
    self.viewInputArea.layer.cornerRadius = 10;
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    [self.txtEmail addTarget:self
                      action:@selector(textFieldDidChange)
            forControlEvents:UIControlEventEditingChanged];
    
    [self.txtPassword addTarget:self
                         action:@selector(textFieldDidChange)
               forControlEvents:UIControlEventEditingChanged];
    self.txtPassword.returnKeyType = UIReturnKeyGo;
}

#pragma mark - Methods - View Related
- (void)hideKeyboard {
    
    [self.view endEditing:YES];
    [self moveFieldsUpOrDown:@"DOWN"];
    self.lblError.hidden = YES;
    
    if ([self validateEmail:self.txtEmail.text] && [self.txtPassword.text length] > 5) {
       
    }else{
        
        [UIView animateWithDuration:1.0 animations:^{
            //self.viewEmail.alpha = 0.0f;
            //self.viewPassword.alpha = 0.0f;
            self.viewInputArea.alpha = 0.0f;
             }];
        
    }
}

-(void)moveFieldsUpOrDown:(NSString *)upOrDown
{
    if (IS_IPHONE_4_OR_LESS) {
        
        if ([upOrDown isEqualToString:@"UP"]) {
            self.tempContraint = 90;
        }else{
            self.tempContraint = 155;
        }
        
        //self.topConstraintEmail.constant = self.tempContraint;
        //[self.viewEmail setNeedsUpdateConstraints];
        //[self.viewPassword setNeedsUpdateConstraints];
        [self.viewInputArea setNeedsUpdateConstraints];
        //[self.imgLogo setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.5 animations:^{
            //[self.viewEmail layoutIfNeeded];
            //[self.viewPassword layoutIfNeeded];
            [self.viewInputArea layoutIfNeeded];
            //[self.imgLogo layoutIfNeeded];
        }];
    }
}

-(void)showPasswordAndUsernameInputs{
    //self.viewEmail.hidden = NO;
    //self.viewPassword.hidden = NO;
    self.viewInputArea.hidden = NO;
    
    [UIView animateWithDuration:1.0 animations:^{
        //self.viewEmail.alpha = 1.0f;
        //self.viewPassword.alpha = 1.0f;
        self.viewInputArea.alpha = 0.95f;
    }];
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self validateEmail:self.txtEmail.text] && [self.txtPassword.text length] < 1){
        [self.txtPassword becomeFirstResponder];
        return YES;
    }
    
    if (![self validateEmail:self.txtEmail.text]){
        self.lblError.hidden = NO;
        self.lblError.text = [LocalizationManager getStringFromStrId:ERROR_EMAIL];
        return NO;
    }else if ([self.txtPassword.text length] < 1) {
        self.lblError.hidden = NO;
        self.lblError.text = [LocalizationManager getStringFromStrId:ERROR_PASSWORD];
        return NO;
    }else{
        //Continue with login or registry
        if (self.registerFlag == 1) {
            if ([self.txtPassword.text length] < 6) {
                self.lblError.hidden = NO;
                self.lblError.text = [LocalizationManager getStringFromStrId:ERROR_PASSWORD];
                return NO;
            }else{
                [self showEulaAlert];
            }
        }else{
             [self continueWithLogin];
        }
    }
return YES;
}

-(void)textFieldDidChange{
    self.lblError.hidden = YES;
}

#pragma mark - IBActions
- (IBAction)btnRegister:(id)sender {
    
    if ([self validateEmail:self.txtEmail.text] && [self.txtPassword.text length] > 5) {
        self.registerFlag = 1;
        [self continueWithRegistration];
    }else{
        [self.lblInputAreaTitle setText:[LocalizationManager getStringFromStrId:@"Register"]];
        [self moveFieldsUpOrDown:@"UP"];
        [self showPasswordAndUsernameInputs];
        self.registerFlag = 1;
        [self.txtEmail becomeFirstResponder];
    }
}
- (IBAction)facebookLoginClick:(id)sender {
    
    //first facebook login
    if (self.facebookLoginFlag == 0) {
        [self showFaceBookEulaAlert];
        return;

    }
    [self goToFacebookLogin];
 

}

- (IBAction)btnLogin:(id)sender {
    
    if ([self validateEmail:self.txtEmail.text] && [self.txtPassword.text length] > 5) {
        //this is the page to check whether successfully logged in or not
        [self continueWithLogin];
    }else{
        [self.lblInputAreaTitle setText:[LocalizationManager getStringFromStrId:@"Login"]];
        [self moveFieldsUpOrDown:@"UP"];
        [self showPasswordAndUsernameInputs];
        self.registerFlag = 0;
        [self.txtEmail becomeFirstResponder];
    }
}

#pragma mark - UIAlert EULA
-(void)showEulaAlert{
     UIAlertController *Alert = [UIAlertController alertControllerWithTitle:nil
     message:[LocalizationManager getStringFromStrId:ALERT_EULA_MESSAGE]
     preferredStyle:UIAlertControllerStyleAlert];
     
     UIAlertAction *Agree = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:EULA_ALERT_AGREE]
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     
     [Alert dismissViewControllerAnimated:YES completion:nil];
     [self continueWithRegistration];
     }];
     
     UIAlertAction *Eula = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:EULA_ALERT_VIEW_EULA]
     style:UIAlertActionStyleDefault
     handler:^(UIAlertAction * action){
     
     [Alert dismissViewControllerAnimated:YES completion:nil];
     self.eulaFlag = 1;
     [self showEulaController];
     }];
     
     [Alert addAction:Agree];
     [Alert addAction:Eula];
     
     [self presentViewController:Alert animated:YES completion:nil];
}

#pragma mark - showFaceBookEulaAlert EULA
-(void)showFaceBookEulaAlert{
    UIAlertController *Alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:[LocalizationManager getStringFromStrId:ALERT_EULA_MESSAGE]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *Agree = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:EULA_ALERT_AGREE]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * action){
                                                      
                                                      [Alert dismissViewControllerAnimated:YES completion:nil];
                                                      self.facebookLoginFlag = 1;

                                                      [self goToFacebookLogin];
                                                  }];
    
    UIAlertAction *Eula = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:EULA_ALERT_VIEW_EULA]
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action){
                                                     
                                                     [Alert dismissViewControllerAnimated:YES completion:nil];
                                                     [self showEulaController];
                                                 }];
    
    [Alert addAction:Agree];
    [Alert addAction:Eula];
    
    [self presentViewController:Alert animated:YES completion:nil];
}


#pragma mark - EULA WebBrowserController Method
-(void)showEulaController{
    [self presentViewController:[GGWebBrowserProxy browserViewControllerWithUrl:EULA_URL] animated:YES completion:NULL];
}

-(void)goToFacebookLogin
{
    //
    
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logOut];//This has to be added. Else, if we change to another account, there would be an error that we cannot extract info.
    
    [login logInWithReadPermissions: @[@"public_profile",@"email"]
     
                 fromViewController:self
     
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                
                                if (error) {
                                    
                                    NSLog(@"Process error");
                                    
                                } else if (result.isCancelled) {
                                    
                                    NSLog(@"Cancelled");
                                    
                                } else {
                                    
                                    NSLog(@"succeed");
                                    
                                    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                                                  
                                                                  initWithGraphPath:result.token.userID
                                                                  
                                                                  parameters:@{@"fields": @"id,name,email"}
                                                                  
                                                                  HTTPMethod:@"GET"];
                                    
                                    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result,NSError *error) {
                                        
                                        // Handle the result
                                        
                                        [self facebookSuccessLoginWithFacebookEmail:result[@"email"] name:result[@"name"]];
                                        
//                                        NSLog(@"%@,%@,%@",result[@"id"],result[@"name"],result[@"email"]);
                                        
                                    }];
                                }
                            }];
}


#pragma mark - Login / Facebook
-(void)facebookSuccessLoginWithFacebookEmail:(NSString *)facebookEmail name:(NSString *)name {
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:REGISTER_LOGIN_MSG]];
    
//    NSString *facebookEmail = @"245673746748@qq.com";
//    NSString *firstName = @"c666Wn";
//    NSString *lastName = @"chengang";
    
    dispatch_promise(^{
        User* user = [User sharedModel];
        
        [user facebookLogin:facebookEmail :name].then(^(id res) {
            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate setWindowRootWithAnimation:YES];
            
            
            // Show notifications once the user is logged in
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSMutableArray *arrayNotifications = [[NSMutableArray alloc]init];
            
            if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"notifications"]){
                arrayNotifications = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"notifications"]];
            }
            
            UILocalNotification *notification = [[UILocalNotification alloc]init];
            
            for (notification in arrayNotifications){
                
                double delayInSeconds = 65;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    if ([[[notification userInfo]objectForKey:@"userID"] isEqualToString:[[User sharedModel]userId]]){
                        [[LocalNotificationResponseAssistant getInstance] localNotificationForegroundResponseWithNotification:notification];
                        [arrayNotifications removeObject:notification];
                    }
                    
                });
            }
            
        }).catch(^(NSError* error) {
            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            
            [self hideKeyboard];
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:ALERT_TITLE_OOPS]
                                                            message:[error localizedDescription]
                                                           delegate:self
                                                  cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                  otherButtonTitles:nil];
            
            [alert show];
            
        });
    });
}

#pragma mark - Login / Registration Methods
-(void)continueWithLogin{
     [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:REGISTER_LOGIN_MSG]];
     
     dispatch_promise(^{
     User* user = [User sharedModel];
     
     [user login: self.txtEmail.text : self.txtPassword.text].then(^(id res) {
     [self.view hideActivityIndicatorWithNetworkIndicatorOff];
     
     AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
     [appDelegate setWindowRootWithAnimation:YES];
         
         
         // Show notifications once the user is logged in
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
         NSMutableArray *arrayNotifications = [[NSMutableArray alloc]init];
         
         if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"notifications"]){
             arrayNotifications = [NSKeyedUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"notifications"]];
         }
         
         UILocalNotification *notification = [[UILocalNotification alloc]init];
         
         for (notification in arrayNotifications){
             
             double delayInSeconds = 65;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             
                 if ([[[notification userInfo]objectForKey:@"userID"] isEqualToString:[[User sharedModel]userId]]){
                     [[LocalNotificationResponseAssistant getInstance] localNotificationForegroundResponseWithNotification:notification];
                     [arrayNotifications removeObject:notification];
                 }
                 
                });
         }

     }).catch(^(NSError* error) {
     [self.view hideActivityIndicatorWithNetworkIndicatorOff];
     
     [self hideKeyboard];
     
     UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:ALERT_TITLE_OOPS]
     message:[error localizedDescription]
     delegate:self
     cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
     otherButtonTitles:nil];
     
     [alert show];
         
     });
     });
}

-(void)continueWithRegistration{
     [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:REGISTER_REGESTERING_MSG]];
     
     dispatch_promise(^{
         User* user = [User sharedModel];
         
         [user signUp: self.txtEmail.text : self.txtPassword.text].then(^(id res) {
             [self.view hideActivityIndicatorWithNetworkIndicatorOff];
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate setWindowRootWithAnimation:YES];
             /*
             AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
             [appDelegate setWindowRootToUserSetupPageViewControllerWithAnimation:YES];
             */
         }).catch(^(NSError* error) {
             [self.view hideActivityIndicatorWithNetworkIndicatorOff];
             
             [self hideKeyboard];
             
             UIAlertView* alert = [[UIAlertView alloc] initWithTitle:[LocalizationManager getStringFromStrId:ALERT_TITLE_OOPS]
                                                             message:[error localizedDescription]
                                                            delegate:self
                                                            cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                                            otherButtonTitles:nil];
             
             [alert show];
         });
     });
}

#pragma mark - Email Validation Method
- (BOOL)validateEmail:(NSString *)emailStr {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
