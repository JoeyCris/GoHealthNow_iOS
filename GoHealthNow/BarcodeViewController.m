//
//  BarcodeViewController.m
//
//
//
//  
//

#import "BarcodeViewController.h"
#import "StyleManager.h"
#import "GlucoguideAPI.h"
#import "FoodItem.h"
#import "UIView+Extensions.h"
#import "UIAlertController+Window.h"

@implementation BarcodeViewController

#pragma mark - Lifecycle

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [BarcodeScanner requestCameraPermissionWithSuccess:^(BOOL success) {
        if (success) {
            [self startScanning];
        } else {
            [self displayPermissionMissingAlert];
        }
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    UIBarButtonItem *btnBack = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"cancelIcon"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(didTapCancelButton)];
    self.navigationController.navigationBar.topItem.leftBarButtonItem = btnBack;
    
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    
    self.btnFlash = [[UIBarButtonItem alloc]initWithTitle:[LocalizationManager getStringFromStrId:MSG_BARCODE_FLASH_BUTTON]
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(didToggleFlash)];
    self.navigationController.navigationBar.topItem.rightBarButtonItem = self.btnFlash;
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.scanner stopScanning];
    [super viewWillDisappear:animated];
}

#pragma mark - Scanner
- (BarcodeScanner *)scanner {
    if (!_scanner) {
        _scanner = [[BarcodeScanner alloc] initWithPreviewView:_previewView];
    }
    return _scanner;
}

#pragma mark - Scanning
- (void)startScanning {
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        for (AVMetadataMachineReadableCodeObject *code in codes) {
            if (code.stringValue) {
                NSLog(@"Found unique code: %@", code.stringValue);
                [self.scanner freezeCapture];
                [self didScanCode:code.stringValue];
            }
        }
    }];
}

- (void)stopScanning {
    [self.scanner stopScanning];
    self.captureIsFrozen = NO;
}


#pragma mark - Barcode Methods
- (void)didScanCode:(NSString *)scannedCode{

    NSArray *arrayResponse = [[NSArray alloc]initWithArray:[GlucoguideAPI sendBarcode:scannedCode]];
    int returnStatus = [[arrayResponse objectAtIndex:0] intValue];
    
    if ([arrayResponse count] == 1) {
        [self showBarcodeAlertMessage:[LocalizationManager getStringFromStrId:@"Failed to get the food info, please retry!"]];
        return;
    }
    
    switch (returnStatus) {
        case 0:
            [self performSegueWithIdentifier:@"foodSummarySegue" sender:[arrayResponse objectAtIndex:1]];
            break;
        case 1:
            [self showBarcodeAlertMessage:[arrayResponse objectAtIndex:1]];
            break;
        case 2:
            [self showBarcodeAlertMessage:[arrayResponse objectAtIndex:1]];
            break;
        default:
            break;
    }
}

#pragma mark - Methods
- (NSArray<FoodItem *> *)foodItemsFromImgClassificationResults:(NSDictionary *)results {
    NSArray *classificationData = results[@"Labels"][@"Label"];
    NSMutableArray<FoodItem *> *foodItems = [[NSMutableArray alloc] initWithCapacity:[classificationData count]];
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:1];
    [tempArray addObject:classificationData];
    
    for (NSDictionary *eachClassificationLabelData in tempArray) {
        FoodItem *classificationFood = [[FoodItem alloc] initWithClassificationData:eachClassificationLabelData];
        classificationFood.creationType = FoodItemCreationTypeBarcode;
        if (classificationFood) {
            [foodItems addObject:classificationFood];
        }
    }
    
    return foodItems;
}

#pragma mark - Alerts
- (void)displayPermissionMissingAlert {
    NSString *message = nil;
    if ([BarcodeScanner scanningIsProhibited]) {
        message = [LocalizationManager getStringFromStrId:MSG_BARCODE_ALERT_CAMERA_PROHIBITED];
    } else if (![BarcodeScanner cameraIsPresent]) {
        message = [LocalizationManager getStringFromStrId:MSG_BARCODE_ALERT_CAMERA_NOT_EXIST];
    } else {
        message = [LocalizationManager getStringFromStrId:MSG_BARCODE_ALERT_CAMERA_UNKNOWN_ERROR];
    }
    
    [self showBarcodeAlertMessage:message];
}

-(void)showBarcodeAlertMessage:(NSString *)alertMessage{
    
    self.alert =   [UIAlertController alertControllerWithTitle:alertMessage
                                                  message:nil
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"cancel");
                                           [self.scanner unfreezeCapture];
                                   }];
    
    [self.alert addAction:cancelAction];
    
    [self.alert show];
    
}

#pragma mark - IBACTION
- (void)didTapCancelButton{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)didToggleFlash{
    if (self.scanner.torchMode == MTBTorchModeOff || self.scanner.torchMode == MTBTorchModeAuto) {
        self.scanner.torchMode = MTBTorchModeOn;
    } else {
        self.scanner.torchMode = MTBTorchModeOff;
    }
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    if ([segueId isEqualToString:@"foodSummarySegue"])
    {
        FoodSummaryViewController *destVC = [segue destinationViewController];
        destVC.index = FSUMM_INDEX_NOT_SET;
        destVC.delegate = self.delegate;
        
        if ([sender isKindOfClass:[NSDictionary class]]) {
            NSDictionary *imgClassificationResults = (NSDictionary *)sender;
            destVC.foodItems = [self foodItemsFromImgClassificationResults:imgClassificationResults];
        }
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
