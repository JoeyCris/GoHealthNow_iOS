//
//  GGWebBrowserViewController.m
//  GlucoGuide
//
//  Created by HoriKu on 2015-04-21.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "GGWebBrowserViewController.h"
#import "StyleManager.h"

@interface GGWebBrowserViewController () <UIWebViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSURLRequest *request;

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UITextField *textAddress;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnClose;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnBack;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnForward;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btnRefreshAndStop;
@property (weak, nonatomic) IBOutlet UIToolbar *webNaviBar;

@end

@implementation GGWebBrowserViewController

- (void)initWithAddress:(NSString*)urlString withUserInput:(BOOL)isUserInputEnabled {
    [self initWithUrl:[NSURL URLWithString:[self prefixURLWithHttp:urlString]] withUserInput:isUserInputEnabled];
}

- (void)initWithUrl:(NSURL *)url withUserInput:(BOOL)isUserInputEnabled {
    [self initWithUrlRequest:[NSURLRequest requestWithURL:url] withUserInput:isUserInputEnabled];
}

- (void)initWithUrlRequest:(NSURLRequest *)urlRequest withUserInput:(BOOL)isUserInputEnabled {
    self.request = urlRequest;
    if (isUserInputEnabled) {
        [self.textAddress setUserInteractionEnabled:YES];
    }
    else {
        [self.textAddress setUserInteractionEnabled:NO];
    }
    [self.textAddress setText:[[urlRequest URL] absoluteString]];
}

- (void)dealloc {
    [self.webView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void)loadUrlRequest {
    [self.webView loadRequest:self.request];
}

- (void)refreshUI {
    UIImage *loadingImageIcon = self.webView.isLoading ? [UIImage imageNamed:@"Web-Stop.png"] : [UIImage imageNamed:@"Web-Refresh.png"];
    
    [[self.webNaviBar.items objectAtIndex:[self.webNaviBar.items count]-1] setImage:loadingImageIcon];
    [self.textAddress setText:[[[self.webView request] URL] absoluteString]];
}

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self loadUrlRequest];
    
    [self.webView setDelegate:self];
    [self registerForKeyboardNotifications];
    [StyleManager styleMainView:self.view];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self refreshUI];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshUI];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self refreshUI];
}

#pragma mark - UITextFieldDelegate

- (IBAction)textAddress_DidEndOnExit:(id)sender {
    [self initWithAddress:[self.textAddress text] withUserInput:YES];
}

#pragma mark - Event Handlers

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    if ([self.textAddress isFirstResponder])
        [self.textAddress selectAll:self];
}

- (IBAction)btnDone_Tapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)btnBack_Tapped:(id)sender {
    [self.webView goBack];
}

- (IBAction)btnForward_Tapped:(id)sender {
    [self.webView goForward];
}

- (IBAction)btnRefresh_Tapped:(id)sender {
    self.webView.isLoading ? [self.webView stopLoading] : [self.webView reload];
}

#pragma mark - Methods

- (NSString *)prefixURLWithHttp:(NSString *)url {
    if (![url hasPrefix:@"http"]) {
        return [NSString stringWithFormat:@"http://%@", url];
    }
    else {
        return url;
    }
}

- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}


@end
