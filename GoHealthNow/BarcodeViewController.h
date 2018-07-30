//
//  BarcodeViewController.h
//
//
//
//
//

#import <UIKit/UIKit.h>
#import "FoodSummaryViewController.h"
#import "BarcodeScanner.h"

@interface BarcodeViewController : UIViewController <UIAlertViewDelegate, UIBarPositioningDelegate>

@property (nonatomic) id<FoodSummaryDelegate> delegate;
@property (nonatomic) UIAlertController *alert;
@property (nonatomic) UIBarButtonItem *btnFlash;
@property (weak, nonatomic) IBOutlet UIView *previewView;

@property (nonatomic, strong) BarcodeScanner *scanner;
@property (nonatomic, assign) BOOL captureIsFrozen;
@property (nonatomic, assign) BOOL didShowCaptureWarning;



@end
