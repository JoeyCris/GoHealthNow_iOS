//
//  FoodRecognitionCameraBaseViewController.m
//  GlucoGuide
//
//  Created by Haoyu Gu on 2016-05-03.
//  Copyright © 2016 GlucoGuide. All rights reserved.
//

#import "FoodRecognitionCameraBaseViewController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "QuickEstimateController.h"
#import "UIView+Extensions.h"
#import "FoodLabelSelectionViewController.h"
#import "AddMealRecordController.h"

#import <CoreMotion/CoreMotion.h>

#import <AVFoundation/AVFoundation.h>

#define BOTTOM_CONTROLLER_HEIGHT 120

@interface FoodRecognitionCameraBaseViewController ()

@property (nonatomic, strong) AVCaptureSession* session;
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
@property (nonatomic, strong) AVCaptureDevice *device;

@property (nonatomic) UIView *bottomBase;
@property (nonatomic) UIView *previewBase;

@property (nonatomic) UIImage *srcImage;

@property (nonatomic) UIButton *flashlightButton;

@property (nonatomic) CMMotionManager *cmManager;

@property UIDeviceOrientation curDeviceOrientation;

typedef enum {
    LayerModeCamera = 0,
    LayerModePreview
} LayerMode;


@end

@implementation FoodRecognitionCameraBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [StyleManager styleNavigationBar:self.navigationController.navigationBar];
    [self initAVCaptureSession];
    [self initControllerBase];
    [self drawCamearControllerLayer];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cancelIcon"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissView)];
    self.navigationItem.leftBarButtonItem = cancelBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
   
        if (self.session) {
            [self.session startRunning];
        }
    
        [self startMotionManager];
    }else{
         [self performSegueWithIdentifier:@"showNewMealRecordSegue" sender:nil];
    }
}


- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    if (self.session) {
        [self.session stopRunning];
    }
    [self.cmManager stopDeviceMotionUpdates];
}

#pragma mark - CoreMotion Methods for detecting orientation
- (void)startMotionManager {
    if (self.cmManager == nil) {
        self.cmManager = [[CMMotionManager alloc] init];
    }
    self.cmManager.deviceMotionUpdateInterval = 1/15.0;
    if (self.cmManager.deviceMotionAvailable) {
        NSLog(@"Device Motion Available");
        [self.cmManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler: ^(CMDeviceMotion *motion, NSError *error){
                                                [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
                                                
                                            }];
    } else {
        NSLog(@"No device motion on device.");
        self.cmManager = nil;
    }
}

- (void)handleDeviceMotion:(CMDeviceMotion *)deviceMotion{
    double x = deviceMotion.gravity.x;
    double y = deviceMotion.gravity.y;
    if (fabs(y) >= fabs(x)) {
        if (y >= 0) {
            self.curDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
            //NSLog(@"Upsidedown");
        }
        else {
            self.curDeviceOrientation = UIDeviceOrientationPortrait;
            //NSLog(@"Portrait");
        }
    }
    else {
        if (x >= 0) {
            self.curDeviceOrientation = UIDeviceOrientationLandscapeRight;
            //NSLog(@"Right");
        }
        else {
            self.curDeviceOrientation = UIDeviceOrientationLandscapeLeft;
            //NSLog(@"Left");
        }
    }
}

#pragma mark - AVFoundation Methods

- (void)initAVCaptureSession {
    self.session = [[AVCaptureSession alloc] init];

    NSError *error;
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    [self.device lockForConfiguration:nil];
    if ([self.device isFlashAvailable]) {
         [self.device setFlashMode:AVCaptureFlashModeAuto];
    }
    [self.device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        //draw error layer
        return;
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];

    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    
    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
    
    //self.session.sessionPreset = AVCaptureSessionPreset1920x1080;
    
    CALayer *blackLayer = [CALayer layer];
    blackLayer.frame = self.view.frame;
    blackLayer.backgroundColor = [UIColor blackColor].CGColor;
    
    [self.view.layer addSublayer:blackLayer];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];

    self.previewLayer.frame =  CGRectMake(self.view.bounds.origin.x, (self.view.bounds.size.height-BOTTOM_CONTROLLER_HEIGHT-44)/2 - self.view.bounds.size.width / 2, self.view.bounds.size.width, self.view.bounds.size.width);//self.view.bounds.size.height-BOTTOM_CONTROLLER_HEIGHT-44);
    //self.view.layer.masksToBounds = YES;
    [self.view.layer addSublayer:self.previewLayer];
    
    
    if ([self.device isFlashAvailable]) {
        self.flashlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.flashlightButton setImage:[self changeImage:[UIImage imageNamed:@"CameraFlashlightIcon"] withColor:[UIColor GGYellowColor]] forState:UIControlStateNormal];
        [self.flashlightButton setTitleColor:[UIColor GGYellowColor] forState:UIControlStateNormal];
        [self.flashlightButton addTarget:self action:@selector(toggleFlashlightMode) forControlEvents:UIControlEventTouchUpInside];
        [self.flashlightButton setTitle:[LocalizationManager getStringFromStrId:@"Auto"] forState:UIControlStateNormal];
        self.flashlightButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 20, 60);
        //self.flashlightButton.imageView.contentMode =
        self.flashlightButton.titleEdgeInsets = UIEdgeInsetsMake(-20, -25, 0, 0);
        self.flashlightButton.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self.view addSubview:self.flashlightButton];
        
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flashlightButton
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:16.0]];
        [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.flashlightButton
                                                              attribute:NSLayoutAttributeTrailing
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.view
                                                              attribute:NSLayoutAttributeTrailing
                                                             multiplier:1.0
                                                               constant:-8.0]];
        [self.flashlightButton addConstraint:[NSLayoutConstraint constraintWithItem:self.flashlightButton
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeWidth
                                                                         multiplier:1.0
                                                                           constant:80]];
        [self.flashlightButton addConstraint:[NSLayoutConstraint constraintWithItem:self.flashlightButton
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1.0
                                                                           constant:40]];
    }
    
    [self.view layoutIfNeeded];
}

-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation {
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}

#pragma mark - Crop image to square
- (UIImage *)cropImage:(UIImage *)imageSrc
{
    UIImageOrientation imgOrientation = UIImageOrientationUp;
    switch (self.curDeviceOrientation) {
        case UIDeviceOrientationPortrait:
            imgOrientation = UIImageOrientationRight;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            imgOrientation = UIImageOrientationLeft;
            break;
        case UIDeviceOrientationLandscapeLeft:
            imgOrientation = UIImageOrientationUp;
            break;
        case UIDeviceOrientationLandscapeRight:
            imgOrientation = UIImageOrientationDown;
            break;
        default:
            break;
    }
    UIImage *image = [UIImage imageWithCGImage:imageSrc.CGImage scale:1.0 orientation:UIImageOrientationUp];
    CGSize src = image.size;
    CGPoint cropCenter = CGPointMake((src.width/2), (src.height/2));
    CGPoint cropStart = CGPointMake((cropCenter.x - (src.height/2)), (cropCenter.y - (src.height/2)));
    CGRect cropRect = CGRectMake(cropStart.x, cropStart.y, src.height, src.height);
    CGImageRef cropRef = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage* cropImage = [UIImage imageWithCGImage:cropRef];
    CGImageRelease(cropRef);
    return [UIImage imageWithCGImage:cropImage.CGImage scale:1 orientation:imgOrientation];
}

#pragma mark - drawing UI element methods

- (void)initControllerBase {
    self.bottomBase = [[UIView alloc] init];
    [self.bottomBase setBackgroundColor:[UIColor buttonColor]];
    self.bottomBase.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.bottomBase];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBase
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBase
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBase
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:self.bottomBase
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:BOTTOM_CONTROLLER_HEIGHT]];
}

- (void)drawPreviewControllerLayer {
    UIButton *saveanalyseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveanalyseButton setTitle:[LocalizationManager getStringFromStrId:@"Analyze"] forState:UIControlStateNormal];
    saveanalyseButton.translatesAutoresizingMaskIntoConstraints = NO;
    [saveanalyseButton addTarget:self action:@selector(saveAndAnalyze) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBase addSubview:saveanalyseButton];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:saveanalyseButton
                                                                attribute:NSLayoutAttributeCenterX
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeCenterX
                                                               multiplier:1.0
                                                                 constant:0.0]];
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:saveanalyseButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    UIButton *saveOnly = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveOnly setTitle:[LocalizationManager getStringFromStrId:@"Save Only"] forState:UIControlStateNormal];
    if ([GGUtils getSystemLanguageSetting] == AppLanguageFr) {
        [saveOnly.titleLabel setFont:[UIFont systemFontOfSize:12]];
    }
    saveOnly.translatesAutoresizingMaskIntoConstraints = NO;
    [saveOnly addTarget:self action:@selector(saveOnly) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBase addSubview:saveOnly];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:saveOnly
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:8.0]];
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:saveOnly
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    UIButton *redoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [redoButton setTitle:[LocalizationManager getStringFromStrId:@"Redo"] forState:UIControlStateNormal];
    redoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [redoButton addTarget:self action:@selector(redoCamera) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBase addSubview:redoButton];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:redoButton
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:-8.0]];
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:redoButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0.0]];
    
    [self.view layoutIfNeeded];
    
}

- (void)drawCamearControllerLayer {
    
    CGRect frame = CGRectMake(0, 0, self.bottomBase.frame.size.width, 20);
    
    UILabel *lblCancel = [[UILabel alloc] initWithFrame:frame];
    lblCancel.text = [LocalizationManager getStringFromStrId:@"'CANCEL' meal log of photo"];
    lblCancel.font = [UIFont systemFontOfSize:18];
    
    UILabel *lblTake = [[UILabel alloc] initWithFrame:frame];
    lblTake.text = [LocalizationManager getStringFromStrId:@"'TAKE' a photo of the whole meal"];
    lblTake.font = [UIFont systemFontOfSize:18];
    
    UILabel *lblSkip = [[UILabel alloc] initWithFrame:frame];
    lblSkip.text = [LocalizationManager getStringFromStrId:@"'SKIP' photo to enter meal manually"];
    if ([GGUtils getSystemLanguageSetting] == AppLanguageFr) {
        lblSkip.font = [UIFont systemFontOfSize:16];
    }
    else
        lblSkip.font = [UIFont systemFontOfSize:18];
    
    [self.bottomBase addSubview:lblCancel];
    [self.bottomBase addSubview:lblTake];
    [self.bottomBase addSubview:lblSkip];
    
    lblCancel.translatesAutoresizingMaskIntoConstraints = NO;
    lblTake.translatesAutoresizingMaskIntoConstraints = NO;
    lblSkip.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblCancel
                                                                attribute:NSLayoutAttributeTop
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.0
                                                                 constant:8.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblCancel
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:8.0]];

    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblTake
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:lblCancel
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:25.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblTake
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:8.0]];
    
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblSkip
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:lblTake
                                                                attribute:NSLayoutAttributeBottom
                                                               multiplier:1.0
                                                                 constant:25.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:lblSkip
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1.0
                                                                 constant:8.0]];
    

    
    
    
    UIButton *takeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [takeButton setTitle:[LocalizationManager getStringFromStrId:@"Take"] forState:UIControlStateNormal];
    takeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [takeButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBase addSubview:takeButton];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:takeButton
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.bottomBase
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:takeButton
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.bottomBase
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:40.0]];
    //////////////////
    
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setTitle:[LocalizationManager getStringFromStrId:@"Cancel"] forState:UIControlStateNormal];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomBase addSubview:cancelButton];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.bottomBase
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:40.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:cancelButton
                                                           attribute:NSLayoutAttributeLeading
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:self.bottomBase
                                                           attribute:NSLayoutAttributeLeading
                                                          multiplier:1.0
                                                            constant:8.0]];
    
    //////////////////
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [skipButton setTitle:[LocalizationManager getStringFromStrId:@"Skip"] forState:UIControlStateNormal];
    skipButton.translatesAutoresizingMaskIntoConstraints = NO;
    [skipButton addTarget:self action:@selector(skip) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.bottomBase addSubview:skipButton];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:skipButton
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:40.0]];
    
    [self.bottomBase addConstraint:[NSLayoutConstraint constraintWithItem:skipButton
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.bottomBase
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1.0
                                                                 constant:-8.0]];
    
    [self.view layoutIfNeeded];
}

- (void)clearBottomView {
    if (self.bottomBase) {
        for(UIView *view in [self.bottomBase subviews]) {
            [view removeFromSuperview];
        }
    }
}

- (void)switchLayerMode:(LayerMode)mode {
    switch (mode) {
        case LayerModeCamera: {
            [self clearBottomView];
            [self drawCamearControllerLayer];
            break;
        }
        case LayerModePreview: {
            [self clearBottomView];
            [self drawPreviewControllerLayer];
            break;
        }
        default:
            break;
    }
}

- (void)togglePreviewLayer:(UIImage *)image andMode:(LayerMode)mode{
    switch (mode) {
        case LayerModeCamera: {
            [self.previewBase removeFromSuperview];
            self.previewBase = nil;
            break;
        }
        case LayerModePreview: {
            self.previewBase = [[UIView alloc] init];
            self.previewBase.translatesAutoresizingMaskIntoConstraints = NO;
            self.previewBase.backgroundColor = [UIColor blackColor];
            
            [self.view addSubview:self.previewBase];
            
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewBase
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTopMargin
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewBase
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeLeading
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewBase
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewBase
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.view
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.previewBase
                                                                  attribute:NSLayoutAttributeBottom
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.bottomBase
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:0.0]];
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            self.srcImage = image;
            
            [self.previewBase addSubview:imageView];
            
            [self.previewBase addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeCenterX
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.previewBase
                                                                        attribute:NSLayoutAttributeCenterX
                                                                       multiplier:1.0
                                                                         constant:0.0]];
            [self.previewBase addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                        attribute:NSLayoutAttributeCenterY
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.previewBase
                                                                        attribute:NSLayoutAttributeCenterY
                                                                       multiplier:1.0
                                                                         constant:0.0]];
            [self.previewBase addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                         attribute:NSLayoutAttributeWidth
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.previewBase
                                                                         attribute:NSLayoutAttributeWidth
                                                                        multiplier:1.0
                                                                          constant:0.0]];
            [self.previewBase addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.previewBase
                                                                         attribute:NSLayoutAttributeHeight
                                                                        multiplier:1.0
                                                                          constant:0.0]];
            [self.view layoutIfNeeded];
            break;
        }
        default:
            break;
    }
}

- (void)loadResultLayer:(UIImage *)image {
    [self togglePreviewLayer:image andMode:LayerModePreview];
    [self switchLayerMode:LayerModePreview];
}

- (UIImage *)changeImage:(UIImage *)image withColor:(UIColor *)color {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Button actions

- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)redoCamera {
    [self switchLayerMode:LayerModeCamera];
    [self togglePreviewLayer:nil andMode:LayerModeCamera];
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)skip {
    [self performSegueWithIdentifier:@"showNewMealRecordSegue" sender:nil];
}

- (void)takePhoto {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    //UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:self.curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:1];
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        NSData *jpegData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        [self loadResultLayer:[self cropImage:[UIImage imageWithData:jpegData]]];
    }];
}

- (void)saveOnly {
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *components = [cal components:( NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond ) fromDate:[[NSDate alloc] init]];
    
    MealRecord *meal = [[MealRecord alloc] init];
    [meal setImage:self.srcImage];
    meal.carb = 0;
    meal.pro = 0;
    meal.fat = 0;
    meal.cals = 0;
    if ([components hour]>=5 && [components hour]<10) {
        meal.type = MealTypeBreakfast;
    }
    else if ([components hour]>=10 && [components hour]<16) {
        meal.type = MealTypeLunch;
    }
    else if ([components hour]>=16 && [components hour]<24) {
        meal.type = MealTypeDinner;
    }
    else {
        meal.type = MealTypeSnack;
    }
    meal.recordedTime = [NSDate date];
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:@"Saving Photo..."]];
    [self.view toggleBackgroundMaskDisplayBelowSubview:nil];

    [meal save].then(^(id res){
        [self.view hideActivityIndicatorWithNetworkIndicatorOff];
        [self.view toggleBackgroundMaskDisplayBelowSubview:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)saveAndAnalyze {
    [self classifyImage:self.srcImage];
}

- (void)toggleFlashlightMode {
    if (self.device) {
        AVCaptureFlashMode mode = self.device.flashMode;
        mode++;
        if (mode>2)
            mode = 0;
        [self.device lockForConfiguration:nil];
        [self.device setFlashMode:mode];
        [self.device unlockForConfiguration];
        switch (mode) {
            case AVCaptureFlashModeOn: {
                [self.flashlightButton setTitle:[LocalizationManager getStringFromStrId:@"On"] forState:UIControlStateNormal];
                [self.flashlightButton setImage:[self changeImage:[UIImage imageNamed:@"CameraFlashlightIcon"] withColor:[UIColor GGYellowColor]] forState:UIControlStateNormal];
                [self.flashlightButton setTitleColor:[UIColor GGYellowColor] forState:UIControlStateNormal];
                break;
            }
            case AVCaptureFlashModeOff: {
                [self.flashlightButton setTitle:[LocalizationManager getStringFromStrId:@"Off"] forState:UIControlStateNormal];
                [self.flashlightButton setImage:[self changeImage:[UIImage imageNamed:@"CameraFlashlightIcon"] withColor:[UIColor whiteColor]] forState:UIControlStateNormal];
                [self.flashlightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                break;
            }
            case AVCaptureFlashModeAuto: {
                [self.flashlightButton setTitle:[LocalizationManager getStringFromStrId:@"Auto"] forState:UIControlStateNormal];
                [self.flashlightButton setImage:[self changeImage:[UIImage imageNamed:@"CameraFlashlightIcon"] withColor:[UIColor GGYellowColor]] forState:UIControlStateNormal];
                [self.flashlightButton setTitleColor:[UIColor GGYellowColor] forState:UIControlStateNormal];
                break;
            }
            default:
                break;
        }
    }
}

#pragma mark - ClassifyImage Methods

- (void)classifyImage:(UIImage *)foodImage
{
    if (foodImage) {
        // TODO: this is a really hacky way to get the background mask to also cover the
        // navigation bar. Need to change this in the future
        [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:@"Auto Estimating..."]];
        [self.view toggleBackgroundMaskDisplayBelowSubview:nil];
        
        dispatch_promise(^{
            __block NSDictionary *imgClassificationResults = nil;
            __block NSString *errorDescription = nil;
            
            [MealRecord autoEstimateWithImage:foodImage].then(^(NSMutableDictionary *classificationResults) {
                if (classificationResults) {
                    // "0" signifies that the classification was successful
                    if ([classificationResults[@"Classficiation_status"] isEqualToString:@"0"])
                    {
                        [classificationResults setObject:foodImage forKey:@"Image_object"];
                        imgClassificationResults = classificationResults;
                    }
                    else {
                        errorDescription = [LocalizationManager getStringFromStrId:@"Unable to classify image"];
                    }
                }
                else {
                    errorDescription = [LocalizationManager getStringFromStrId:@"Unable to retrieve classification results"];
                }
            }).catch(^(id error) {
                if ([error isKindOfClass:[NSError class]]) {
                    NSError *classificationError = (NSError *)error;
                    errorDescription = [classificationError description];
                    NSLog(@"classification error: %@", errorDescription);
                }
                else {
                    errorDescription = [LocalizationManager getStringFromStrId:@"Unknown error"];
                }
            }).finally(^{
                [self.view hideActivityIndicatorWithNetworkIndicatorOff];
                [self.view toggleBackgroundMaskDisplayBelowSubview:nil];
                
                if (errorDescription) {
                    [self showImageClassificationErrorAlertWithMessage:errorDescription];
                }
                else {
                    [self performSegueWithIdentifier:@"showFoodLabelSelectionSegue" sender:imgClassificationResults];
                }
            });
        });
    }
    else {
        // failed to get image for classification
        [self showImageClassificationErrorAlertWithMessage:[LocalizationManager getStringFromStrId:@"Unable to retrieve image"]];
    }
}

- (void)showImageClassificationErrorAlertWithMessage:(NSString *)errorMessage {
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Sorry we could not recognize your food item"]
                                                                        message:[LocalizationManager getStringFromStrId:@"Often lighting, angle, zoom, and camera quality can have an negative affect. Your photo has been saved to help us improve! Thank you."]
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
#warning TODO=======
        //[self dismissViewControllerAnimated:YES completion:nil];
    }];
    [errorAlert addAction:cancelAction];
    
    [self presentViewController:errorAlert animated:YES completion:nil];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"showFoodLabelSelectionSegue"])
    {
        FoodLabelSelectionViewController *destVC = [segue destinationViewController];
        
        if ([sender isKindOfClass:[NSDictionary class]]) {
            // auto estimate
            NSDictionary *imgClassificationResults = (NSDictionary *)sender;
            
            [destVC loadFoodWithArray:[[imgClassificationResults objectForKey:@"Lables"] objectForKey:@"Label"] andSrcImage:self.srcImage andImageName:[imgClassificationResults objectForKey:@"Image_name"]];
            /*
            destVC.imageData = [[FoodImageData alloc] initWithImage:imgClassificationResults[@"Image_object"]
                                                               name:imgClassificationResults[@"Image_name"]];
            destVC.foodItems = [self foodItemsFromImgClassificationResults:imgClassificationResults];
             */
        }
    }
}

@end
