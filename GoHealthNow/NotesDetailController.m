//
//  NotesDetailController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "NotesDetailController.h"
#import "StyleManager.h"
#import "Constants.h"
#import "StretchableHeaderView.h"
#import "UIColor+Extensions.h"
#import "GGImagePickerController.h"
#import "UIView+Extensions.h"

@interface NotesDetailController() <UIPickerViewDataSource, UIPickerViewDelegate, UITextViewDelegate, GGImagePickerControllerDelegate,
                                    UIActionSheetDelegate, SlideInPopupDelegate>

@property (nonatomic) StretchableHeaderView *stretchableHeaderView;
@property (nonatomic) UIPickerView *noteTypePicker;
@property (nonatomic) NSArray *noteTypes;

@end

@implementation NotesDetailController

NSUInteger const TAG_CAMERA_VIEW = 3;
NSUInteger const TAG_IMAGE_VIEW = 6;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.noteTypes = @[[LocalizationManager getStringFromStrId:@"Diet"], [LocalizationManager getStringFromStrId:@"Exercise"], [LocalizationManager getStringFromStrId:@"Glucose"], [LocalizationManager getStringFromStrId:MSG_WEIGHT], [LocalizationManager getStringFromStrId:@"Other"]];
    
//    self.noteContentTextView.delegate = self;
    [self registerForKeyboardNotifications];
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                     initWithTarget:self
                                     action:@selector(dismissKeyboard)]
     ];
    
    [StyleManager styleMainView:self.view];
    //[StyleManager addBorderToTextView:self.noteContentTextView];
    
    self.stretchableHeaderView = [[StretchableHeaderView alloc] initWithScrollViewWithView:[self cameraContainerViewWithWidth:200.0]
                                                                                withHeight:200.0
                                                               withScrollContentViewHeight:3000.0
                                                                         withTopViewHeight:0.0];
    
    self.stretchableHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stretchableHeaderView];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stretchableHeaderView
                                                          attribute:NSLayoutAttributeLeading
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeLeading
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stretchableHeaderView
                                                          attribute:NSLayoutAttributeTrailing
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTrailing
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stretchableHeaderView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.stretchableHeaderView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    UIView *bodyView = [[[NSBundle mainBundle] loadNibNamed:@"NotesDetailBodyView" owner:self options:nil] objectAtIndex:0];
    UIView *noteTypeView = [bodyView viewWithTag:NOTES_DETAIL_TAG_TYPE_VIEW];
    UILabel *noteTypeLabel = (UILabel *)[bodyView viewWithTag:NOTES_DETAIL_TAG_TYPE_LABEL];
    UITextView *noteContentTextView = (UITextView *)[bodyView viewWithTag:NOTES_DETAIL_TAG_TEXT_VIEW];
    
    bodyView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UILongPressGestureRecognizer *noteTypeViewTap =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(didTapNoteTypeView:)];
    noteTypeViewTap.minimumPressDuration = 0.1;
    noteTypeViewTap.allowableMovement = 2.0;
    [noteTypeView addGestureRecognizer:noteTypeViewTap];
    
    noteContentTextView.delegate = self;
    if ([noteContentTextView.text isEqualToString:@""]) {
        [self setupPlaceHolderForTextView:noteContentTextView];
    }
    
    NSString *noteTypeStr = [self strWithNoteType:0];
    if (self.noteRecord) {
        noteContentTextView.text = self.noteRecord.content;
        noteTypeLabel.text = [self strWithNoteType:self.noteRecord.type];
    }
    
    noteTypeLabel.text = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Category: %@"], noteTypeStr];
    
    [self.stretchableHeaderView.scrollContentView addSubview:bodyView];
    
    [self.stretchableHeaderView.scrollContentView addConstraint:[NSLayoutConstraint constraintWithItem:bodyView
                                                                                             attribute:NSLayoutAttributeLeading
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.stretchableHeaderView.scrollContentView
                                                                                             attribute:NSLayoutAttributeLeading
                                                                                            multiplier:1.0
                                                                                              constant:0.0]];
    [self.stretchableHeaderView.scrollContentView addConstraint:[NSLayoutConstraint constraintWithItem:bodyView
                                                                                             attribute:NSLayoutAttributeTrailing
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.stretchableHeaderView.scrollContentView
                                                                                             attribute:NSLayoutAttributeTrailing
                                                                                            multiplier:1.0
                                                                                              constant:0.0]];
    [self.stretchableHeaderView.scrollContentView addConstraint:[NSLayoutConstraint constraintWithItem:bodyView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                             relatedBy:NSLayoutRelationEqual
                                                                                                toItem:self.stretchableHeaderView.scrollContentView
                                                                                             attribute:NSLayoutAttributeTop
                                                                                            multiplier:1.0
                                                                                              constant:0.0]];
    [bodyView addConstraint:[NSLayoutConstraint constraintWithItem:bodyView
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1.0
                                                          constant:500.0]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view slideOutPopup];
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return 5;
}

// orientation change
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // Do view manipulation here.
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self dismissKeyboard];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    [[pickerView.subviews objectAtIndex:2] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = self.noteTypes[row];
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@""]) {
        // deleting characters
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:@""];
        if ([newText isEqualToString:@""]) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else {
        // adding characters
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    if ([textView.text isEqualToString:NOTES_DETAIL_CONTENT_PLACEHOLDER]) {
//        textView.text = @"";
//        textView.textColor = [UIColor blackColor]; //optional
//    }
//    
//    // if the keyboard has already been shown then the 'keyboardWasShown notification
//    // handler won't fire. Thus, we need to animate the keyboard here
//    if (!CGSizeEqualToSize(self.keyboardSize, CGSizeZero)) {
//        [self animateTextView:textView
//             withKeyboardSize:self.keyboardSize];
//    }
//}
//
//- (void)textViewDidEndEditing:(UITextView *)textView {
//    if ([textView.text isEqualToString:@""]) {
//        [self setupPlaceHolderForTextView:textView];
//    }
//    
//    [self animateTextView:nil
//         withKeyboardSize:CGSizeZero];
//}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];
        });
    } else if (buttonIndex == 1) {
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
        });
    }
}

#pragma mark - GGImagePickerControllerDelegate

- (void)ggImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    [self updateCameraContainerViewWithImage:editedImage];
}

#pragma mark - Methods

- (NSString *)strWithNoteType:(NoteType)noteType {
    return self.noteTypes[(NSUInteger)noteType];
}

- (UIView *)cameraContainerViewWithWidth:(CGFloat)width {
    UIView *cameraContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    cameraContainerView.tag = TAG_CAMERA_VIEW;
    
    const CGFloat circleViewWidth = 100.0;
    UIView *circleView = [[UIView alloc] init];
    circleView.translatesAutoresizingMaskIntoConstraints = NO;
    circleView.layer.cornerRadius = circleViewWidth / 2.0;
    circleView.backgroundColor = [UIColor buttonColor];
    
    UILongPressGestureRecognizer *circleViewTap =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(didTapCameraCircleView:)];
    circleViewTap.minimumPressDuration = 0.1;
    circleViewTap.allowableMovement = 2.0;
    [circleView addGestureRecognizer:circleViewTap];
    
    [cameraContainerView addSubview:circleView];
    
    [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:circleView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:cameraContainerView
                                                                    attribute:NSLayoutAttributeCenterX
                                                                   multiplier:1.0
                                                                     constant:0.0]];
    [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:circleView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:cameraContainerView
                                                                    attribute:NSLayoutAttributeCenterY
                                                                   multiplier:1.0
                                                                     constant:-circleViewWidth / 3.5]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:circleView
                                                           attribute:NSLayoutAttributeWidth
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeWidth
                                                          multiplier:1.0
                                                            constant:circleViewWidth]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:circleView
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:circleViewWidth]];
    
    UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraIcon"]];
    cameraImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [circleView addSubview:cameraImageView];
    
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                           attribute:NSLayoutAttributeCenterX
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:circleView
                                                           attribute:NSLayoutAttributeCenterX
                                                          multiplier:1.0
                                                            constant:0.0]];
    [circleView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                           attribute:NSLayoutAttributeCenterY
                                                           relatedBy:NSLayoutRelationEqual
                                                              toItem:circleView
                                                           attribute:NSLayoutAttributeCenterY
                                                          multiplier:1.0
                                                            constant:0.0]];
    [cameraImageView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                                attribute:NSLayoutAttributeWidth
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeWidth
                                                               multiplier:1.0
                                                                 constant:circleViewWidth / 2.0]];
    [cameraImageView addConstraint:[NSLayoutConstraint constraintWithItem:cameraImageView
                                                                attribute:NSLayoutAttributeHeight
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:nil
                                                                attribute:NSLayoutAttributeHeight
                                                               multiplier:1.0
                                                                 constant:circleViewWidth / 2.0]];
    return cameraContainerView;
}

- (void)updateCameraContainerViewWithImage:(UIImage *)image {
    UIImageView *mealImageView = (UIImageView *)[self.view viewWithTag:TAG_IMAGE_VIEW];
    
    if (mealImageView) {
        mealImageView.image = image;
    }
    else {
        mealImageView = [[UIImageView alloc] initWithImage:image];
        mealImageView.contentMode = UIViewContentModeScaleAspectFill;
        mealImageView.translatesAutoresizingMaskIntoConstraints = NO;
        mealImageView.tag = TAG_IMAGE_VIEW;
        
        UIView *cameraContainerView = [self.view viewWithTag:TAG_CAMERA_VIEW];
        [cameraContainerView addSubview:mealImageView];
        
        [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:mealImageView
                                                                        attribute:NSLayoutAttributeLeading
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:cameraContainerView
                                                                        attribute:NSLayoutAttributeLeading
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:mealImageView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:cameraContainerView
                                                                        attribute:NSLayoutAttributeTrailing
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:mealImageView
                                                                        attribute:NSLayoutAttributeTop
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:cameraContainerView
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:0.0]];
        [cameraContainerView addConstraint:[NSLayoutConstraint constraintWithItem:mealImageView
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:cameraContainerView
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0.0]];
    }
}

#pragma mark - Event Handlers

- (void)didTapNoteTypeView:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            recognizer.view.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
            break;
        case UIGestureRecognizerStateEnded: {
            recognizer.view.backgroundColor = [UIColor whiteColor];
            
            if (!self.noteTypePicker) {
                self.noteTypePicker = [[UIPickerView alloc] init];
                self.noteTypePicker.delegate = self;
                self.noteTypePicker.dataSource = self;
            }
            
            UILabel *noteTypeLabel = (UILabel *)[self.view viewWithTag:NOTES_DETAIL_TAG_TYPE_LABEL];
            NSUInteger selectedNoteTypeIndex = [self.noteTypes indexOfObject:noteTypeLabel];
            
            [self.noteTypePicker selectRow:selectedNoteTypeIndex == NSNotFound ? 0 : selectedNoteTypeIndex
                               inComponent:0
                                  animated:NO];
            
            [self.view slideInPopupWithTitle:[LocalizationManager getStringFromStrId:@"Type"]
                               withComponent:self.noteTypePicker
                                withDelegate:self];
            
            break;
        }
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            recognizer.view.backgroundColor = [UIColor whiteColor];
            break;
    }
}

- (void)didTapCameraCircleView:(UILongPressGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            recognizer.view.backgroundColor = [UIColor colorWithRed:216.0/255.0 green:216.0/255.0 blue:216.0/255.0 alpha:1.0];
            break;
        case UIGestureRecognizerStateEnded:
            recognizer.view.backgroundColor = [UIColor buttonColor];
            
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                         delegate:self
                                                                cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                                           destructiveButtonTitle:nil
                                                                otherButtonTitles:[LocalizationManager getStringFromStrId:@"Take photo"], [LocalizationManager getStringFromStrId:@"Choose Existing"], nil];
                [actionSheet showInView:self.view];
            }
            else {
                [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
            }
            
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        default:
            recognizer.view.backgroundColor = [UIColor buttonColor];
            break;
    }
}

//// Called when the UIKeyboardDidShowNotification is sent.
//- (void)keyboardWasShown:(NSNotification*)aNotification {
//    NSDictionary* info = [aNotification userInfo];
//    self.keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
//    
//    [self animateTextView:self.self.noteContentTextView
//         withKeyboardSize:self.keyboardSize];
//}
//
//// Called when the UIKeyboardWillHideNotification is sent
//- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
//    self.keyboardSize = CGSizeZero;
//    [self animateTextView:nil
//         withKeyboardSize:CGSizeZero];
//}

- (IBAction)didTapAskExpertButton:(id)sender {
//    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:NOTES_DETAIL_SENDING_MSG];
//    
//    UIPickerView *noteTypePicker = (UIPickerView *)[self.view viewWithTag:NOTES_DETAIL_TYPE_PICKER_TAG];
//    NSUInteger selectedRowInTypePicker = [noteTypePicker selectedRowInComponent:0];
//
//    dispatch_promise(^{
//        NoteRecord *record = [[NoteRecord alloc] init];
//
//        record.content = [self.noteContentTextView.text isEqualToString:NOTES_DETAIL_CONTENT_PLACEHOLDER]
//                            ? @""
//                            : self.noteContentTextView.text;
//        
//        record.recordedTime = [NSDate date];
//        record.type = (NoteType)selectedRowInTypePicker;
//        
//        [record save].then(^(BOOL success) {
//            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
//                                                                  message:NOTES_DETAIL_SUCESS_MSG
//                                                                 delegate:nil
//                                                        cancelButtonTitle:nil
//                                                        otherButtonTitles:nil];
//            [promptAlert show];
//            
//            [NSTimer scheduledTimerWithTimeInterval:1.0
//                                             target:self
//                                           selector:@selector(dismissRecordPromptAlert:)
//                                           userInfo:promptAlert
//                                            repeats:NO];
//        }).catch(^(BOOL success) {
//            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
//                                                                  message:NOTES_DETAIL_FAILURE_MSG
//                                                                 delegate:nil
//                                                        cancelButtonTitle:nil
//                                                        otherButtonTitles:nil];
//            [promptAlert show];
//            
//            [NSTimer scheduledTimerWithTimeInterval:1.0
//                                             target:self
//                                           selector:@selector(dismissRecordPromptAlert:)
//                                           userInfo:promptAlert
//                                            repeats:NO];
//        }).finally(^{
//            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
//            [self.navigationController popViewControllerAnimated:YES];
//        });
//
//    });
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dismissKeyboard {
    //[self.noteContentTextView resignFirstResponder];
}

- (void)registerForKeyboardNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWasShown:)
//                                                 name:UIKeyboardDidShowNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillBeHidden:)
//                                                 name:UIKeyboardWillHideNotification object:nil];
}

//- (void)animateTextView:(UITextView *)textView withKeyboardSize:(CGSize)kbSize
//{
//    float newNoteContentTextViewTopConstant = self.noteContentTextViewTopConstraintOrigConstant;
//    float newNoteContentTextViewBottomConstant = self.noteContentTextViewBottomConstraintOrigConstant;
//    BOOL shouldAnimateTextView = YES;
//    
//    // hide the background mask and place the textField back in its original position
//    if (CGSizeEqualToSize(kbSize, CGSizeZero)) {
//        
//    }
//    else {
//        
//        float kbYPos = self.view.frame.size.height - kbSize.height;
//        float textFieldYPosPlusHeight = textView.frame.origin.y + textView.frame.size.height;
//        
//        // add in the does not equal 0.0 check because when the device orientation
//        // changes, the keyboard notifications will get fired multiple times and during that
//        // period textFieldYPosPlusHeight will be 0.0
//        const float topBottomMargin = 4.0;
//        if (textFieldYPosPlusHeight != kbYPos + topBottomMargin && textFieldYPosPlusHeight != 0.0) {
//            newNoteContentTextViewBottomConstant += textFieldYPosPlusHeight - kbYPos + topBottomMargin;
//            newNoteContentTextViewTopConstant = (self.noteTypePickerHeightConstraint.constant - topBottomMargin) * -1.0;
//        }
//        else {
//            shouldAnimateTextView = NO;
//        }
//    }
//    
//    if (shouldAnimateTextView) {
//        self.noteContentTextViewTopConstraint.constant = newNoteContentTextViewTopConstant;
//        self.noteContentTextViewBottomConstraint.constant = newNoteContentTextViewBottomConstant;
//        [self.view setNeedsUpdateConstraints];
//        
//        [UIView animateWithDuration:0.3 animations:^{
//            [self.view layoutIfNeeded];
//        }];
//        [self.view toggleBackgroundMaskDisplayBelowSubview:textView];
//    }
//}

- (void)setupPlaceHolderForTextView:(UITextView *)textView {
    textView.text = [LocalizationManager getStringFromStrId:NOTES_DETAIL_CONTENT_PLACEHOLDER];
    textView.textColor = [UIColor lightGrayColor]; //optional
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"chooseDevicePictureSegue"]) {
        GGImagePickerController *destVC = [segue destinationViewController];
        destVC.sourceType = [(NSNumber *)sender intValue];
        destVC.delegate = self;
    }
}

@end
