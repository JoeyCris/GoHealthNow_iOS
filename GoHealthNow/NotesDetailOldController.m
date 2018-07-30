//
//  NotesDetailController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-04-05.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "NotesDetailOldController.h"
#import "StyleManager.h"
#import "UIColor+Extensions.h"
#import "Constants.h"
#import "UIView+Extensions.h"
#import "GGImagePickerController.h"
#import "ShowPhotoController.h"
#import "AVFoundation/AVFoundation.h"
#import "GGUtils.h"
#import "Mp3RecordingClient.h"
#import "RecorderIndicator.h"

@interface NotesDetailOldController() <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate, SlideInPopupDelegate, UIPickerViewDataSource, UIPickerViewDelegate, GGImagePickerControllerDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, AVAudioSessionDelegate,AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic) UITextView *noteContentTextView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UITableViewCell *cell;

@property (nonatomic) BOOL editable;

//@property (nonatomic) NSInteger aeType;
//@property (nonatomic) UIImage *aeImage;
//@property (nonatomic) NSString *aeContent;

@property (strong, nonatomic) AVAudioRecorder *recorder;
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) NSURL *currentRecording;
@property (nonatomic) NSTimer *timerCountDown;
@property (nonatomic) int intCount;
@property (nonatomic) BOOL playedBack;
@property (nonatomic) NSString *deleteAudioPath;
@property (nonatomic) NSString *sqlRecordingName;

@property (nonatomic) BOOL didSave;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnAsk;

@property (nonatomic) Mp3RecordingClient *recordClient;

@property (nonatomic) BOOL isPlaying;
@property (nonatomic) BOOL isMicrophoneAccessGranted;

@property (nonatomic) BOOL isGoingToCamera;

@property (nonatomic) RecorderIndicator* recIndicator;

@end

@implementation NotesDetailOldController

static NSString* const CELL_QUESTION_TYPE = @"cellQType";
static NSString* const CELL_QUESTION_PHOTO = @"cellQPhoto";
static NSString* const CELL_QUESTION_AUDIO = @"cellQAudio";
static NSString* const CELL_QUESTION_CONTENT = @"cellQContent";

static NSUInteger const TAG_PICKER_VIEW_FOR_AE_TYPE = 100;

static NSUInteger const TAG_CELL_AE_CONTENT = 10;
static NSUInteger const TAG_CELL_AE_PHOTO = 40;

@synthesize cell, recorder, player, intCount, timerCountDown, recordClient;

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated{
    
   
    if([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]){
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                 NSLog(@"Mic permission granted.  Call method for granted stuff.");
                self.isMicrophoneAccessGranted = YES;
            }
            else {
               NSLog(@"Mic permission denied. Call method for denied stuff.");
                self.isMicrophoneAccessGranted = NO;
            }
        }];
    }
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recIndicator = [[RecorderIndicator alloc] initWithRecordingLabelString:[LocalizationManager getStringFromStrId:@"Recording..."]
                                                                andTimeLabelStr:@"60s/60s"
                                                                andTipsLabelStr:[LocalizationManager getStringFromStrId:@"Release to finish"]
                                                                   andImageName:@"micIcon"
                                                                  andParentView:self.view];

    self.noteContentTextView.delegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.editable = YES;
    self.isGoingToCamera = NO;
    
    if (self.noteRecord) {
        self.editable = NO;
        self.noteContentTextView.text = self.noteRecord.content;
        self.noteContentTextView.editable = NO;
        self.navigationItem.rightBarButtonItem = nil;
        self.currentRecording = [NSURL URLWithString:self.noteRecord.audioPath];
    }
    else {
        
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [audioSession setActive:YES error:nil];
        [recorder setDelegate:self];

        self.playedBack = NO;
        
        self.noteRecord = [[NoteRecord alloc] init];
        
        self.noteRecord.content = @"";
        
        self.noteRecord.recordedTime = [NSDate date];
        self.noteRecord.type = 0;
        
        self.didSave = NO;
        
        recordClient = [Mp3RecordingClient sharedClient];
        
    }
    
    if ([self.noteContentTextView.text isEqualToString:@""]) {
        [self setupPlaceHolderForTextView:self.noteContentTextView];
    }
    
    [StyleManager styleMainView:self.view];
    [StyleManager addBorderToTextView:self.noteContentTextView];
    
    [self.view setBackgroundColor:self.tableView.backgroundColor];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    gesture.delegate = self;
    [self.tableView.backgroundView addGestureRecognizer:gesture];
    [self.view addGestureRecognizer:gesture];
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer {
    [self.noteContentTextView resignFirstResponder];
    [self.tableView becomeFirstResponder];
}

#pragma mark UIGestureRecognizerDelegate methods
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    // If the view that is touched is not the view associated with this view's table view, but
    // is one of the sub-views, we should not recognize the touch.
    if (touch.view != self.tableView && [touch.view isDescendantOfView:self.tableView]) {
        return NO;
    }
    return YES;
}

#pragma maek - SlideInPopupDelegate Methods

- (void)slideInPopupDidChooseDone:(UITapGestureRecognizer *)gestureRecognizer {
    self.noteRecord.type = (NoteType)[((UIPickerView *)[UIView slideInPopupComponentViewWithTag:TAG_PICKER_VIEW_FOR_AE_TYPE withGestureRecognizer:gestureRecognizer]) selectedRowInComponent:0];
    [self.tableView reloadData];
}

#pragma mark - UIPickerViewDataSource Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component {
    return 5;
}

#pragma mark - UIPickerViewDelegate Methods

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    // set the border color of the selection indicator
    [[pickerView.subviews objectAtIndex:1] setBackgroundColor:[UIColor buttonColor]];
    
    NSString *title = @"";
    switch (row) {
        case NoteTypeDiet:
            title = [LocalizationManager getStringFromStrId:@"Diet"];
            break;
        case NoteTypeExercise:
            title = [LocalizationManager getStringFromStrId:@"Exercise"];
            break;
        case NoteTypeGlucose:
            title = [LocalizationManager getStringFromStrId:@"Glucose"];
            break;
        case NoteTypeWeight:
            title = [LocalizationManager getStringFromStrId:MSG_WEIGHT];
            break;
        case NoteTypeOthers:
            title = [LocalizationManager getStringFromStrId:@"Other"];
            break;
        default:
            title = [LocalizationManager getStringFromStrId:@"Unknown"];
            break;
    }
    
    return [[NSAttributedString alloc] initWithString:title attributes:@{ NSForegroundColorAttributeName:[UIColor textColor] }];
}



#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (!self.editable)
        return NO;
    if ([text isEqualToString:@""]) {
        // deleting characters
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:@""];
        if ([newText isEqualToString:@""] && self.editable) {
            self.navigationItem.rightBarButtonItem.enabled = NO;
        }
    }
    else {
        // adding characters
        if (self.editable)
            self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.editable)
        return;
    if ([textView.text isEqualToString:[LocalizationManager getStringFromStrId:NOTES_DETAIL_CONTENT_PLACEHOLDER]]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
    self.tableView.frame= CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 270);
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:2 inSection:1];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self setupPlaceHolderForTextView:textView];
    }
    self.noteRecord.content = textView.text;
    self.tableView.frame= CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height+((self.tableView.frame.size.height + 190 > self.view.frame.size.height + 10)?0 :270));
}


- (IBAction)didTapAskExpertButton:(id)sender {
    
    NoteRecord *record = self.noteRecord;

    self.didSave = YES;
    
    [self.view showActivityIndicatorWithNetworkIndicatorOnWithMessage:[LocalizationManager getStringFromStrId:NOTES_DETAIL_SENDING_MSG]];
    
    self.noteRecord.content = [self.noteContentTextView.text isEqualToString:[LocalizationManager getStringFromStrId:NOTES_DETAIL_CONTENT_PLACEHOLDER]]
    ? @""
    : self.noteContentTextView.text;
    //UIPickerView *noteTypePicker = (UIPickerView *)[self.view viewWithTag:NOTES_DETAIL_TYPE_PICKER_TAG];
    //NSUInteger selectedRowInTypePicker = 0;//[noteTypePicker selectedRowInComponent:0];
    
    dispatch_promise(^{
        /*
        NoteRecord *record = [[NoteRecord alloc] init];
        
        record.content = [self.noteContentTextView.text isEqualToString:NOTES_DETAIL_CONTENT_PLACEHOLDER]
        ? @""
        : self.noteContentTextView.text;
        
        record.recordedTime = [NSDate date];
        record.type = (NoteType)selectedRowInTypePicker;
        */
        
        
        [record save].then(^(BOOL success) {
            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                  message:[LocalizationManager getStringFromStrId:NOTES_DETAIL_SUCESS_MSG]
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:nil];
            [promptAlert show];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(dismissRecordPromptAlert:)
                                           userInfo:promptAlert
                                            repeats:NO];
        }).catch(^(BOOL success) {
            UIAlertView *promptAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                  message:[LocalizationManager getStringFromStrId:NOTES_DETAIL_FAILURE_MSG]
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:nil];
            [promptAlert show];
            
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(dismissRecordPromptAlert:)
                                           userInfo:promptAlert
                                                repeats:NO];
        }).then(^{
            
            if (self.playedBack == YES) {
                 [record uploadMP3:self.currentRecording.path];
            }
            
        }).finally(^{
            [self.view hideActivityIndicatorWithNetworkIndicatorOff];
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    });
}

- (void)dismissRecordPromptAlert:(NSTimer*)theTimer {
    UIAlertView *promptAlert = (UIAlertView*)[theTimer userInfo];
    [promptAlert dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)dismissKeyboard {
    [self.noteContentTextView resignFirstResponder];
}


- (void)setupPlaceHolderForTextView:(UITextView *)textView {
    textView.text = [LocalizationManager getStringFromStrId:NOTES_DETAIL_CONTENT_PLACEHOLDER];
    textView.textColor = [UIColor lightGrayColor]; //optional
    if (self.editable  && !self.playedBack)
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)updateImage: (UIImage *)image withView:(UIView *) processingView{
    
    __block NSString *errorDescription = nil;
    NotePhoto *photo = [[NotePhoto alloc] init];
    photo.image = image;
    [NoteRecord addNotePhoto:photo.image].then(^(NSMutableDictionary *classificationResults) {
        photo.imageName = [classificationResults objectForKey:@"Image_name"];
        photo.createdTime = [classificationResults objectForKey:@"Image_creationdate"];
        self.noteRecord.image = photo;
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
        if (errorDescription) {
            NSLog(@"Failed to save photo for note.\n");
        }
        else {
            [self.tableView reloadData];
            [processingView hideActivityIndicatorWithNetworkIndicatorOff];
            
        }
        return;
    });
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0){
        if (buttonIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypeCamera]];
            });
        } else if (buttonIndex == 1) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
            });
        } else if (buttonIndex == 2) {
            ShowPhotoController *showPhotoVC = [[ShowPhotoController alloc] init];
            showPhotoVC.imageToShow = self.noteRecord.image.image;
            [self.navigationController pushViewController:showPhotoVC animated:NO];
            
        } else if (buttonIndex == 3) {
            self.noteRecord.image.image = nil;
            [self.tableView reloadData];
        }
    }
    else if(actionSheet.tag == 1){
        if (buttonIndex == 0) {
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
            });
        } else if (buttonIndex == 1) {
            ShowPhotoController *showPhotoVC = [[ShowPhotoController alloc] init];
            showPhotoVC.imageToShow = self.noteRecord.image.image;
            [self.navigationController pushViewController:showPhotoVC animated:NO];
            
        } else if (buttonIndex == 2) {
            self.noteRecord.image.image = nil;
            [self.tableView reloadData];
       
        }

    }
    else if(actionSheet.tag == 2){
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
    
}

#pragma mark - GGImagePickerControllerDelegate

- (void)ggImagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info withProcessingView:(UIView *)view {
    
    NSLog(@"testing: %@", info);
    if (info == nil) return;
    UIImage *editedImage = info[UIImagePickerControllerEditedImage];
    if (editedImage != nil) {
        [self updateImage:editedImage withView:view];
    }
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (section == 0) ? 1:4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_QUESTION_TYPE];
    }else{
        
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_QUESTION_PHOTO];
        }else if (indexPath.row == 1){
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_QUESTION_AUDIO];
        }else if (indexPath.row == 3){
            cell = [tableView dequeueReusableCellWithIdentifier:@"cellQInfo"];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:CELL_QUESTION_CONTENT];
        }
    }


    if (!self.editable) {
        cell.userInteractionEnabled = indexPath.row == 1 ? YES: NO;
    }
    
    if (indexPath.section == 0) {
        NSString *title = @"";
        switch (self.noteRecord.type) {
            case NoteTypeDiet:
                title = [LocalizationManager getStringFromStrId:@"Diet"];
                break;
            case NoteTypeExercise:
                title = [LocalizationManager getStringFromStrId:@"Exercise"];
                break;
            case NoteTypeGlucose:
                title = [LocalizationManager getStringFromStrId:@"Glucose"];
                break;
            case NoteTypeWeight:
                title = [LocalizationManager getStringFromStrId:MSG_WEIGHT];
                break;
            case NoteTypeOthers:
                title = [LocalizationManager getStringFromStrId:@"Other"];
                break;
            default:
                title = [LocalizationManager getStringFromStrId:@"Unknown"];
                break;
        }
        [cell.detailTextLabel setText:title];
        cell.accessoryType = self.editable? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    } else {
        if (indexPath.row == 0) {
            
            UILabel *lblQuestionAudio = ((UILabel *)[cell viewWithTag:101]);
            lblQuestionAudio.text = [LocalizationManager getStringFromStrId:@"Attach photo"];
                        
            UIImageView *imgView = ((UIImageView *)[cell viewWithTag:TAG_CELL_AE_PHOTO]);
            [imgView setImage:nil];
            if (self.noteRecord.image.image != nil) {
                [imgView setImage:self.noteRecord.image.image];
                lblQuestionAudio.text = [LocalizationManager getStringFromStrId:@"Attached photo"];
            }
            cell.accessoryType = self.editable? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
        }else if (indexPath.row == 2) {
            UITextView *textView = (UITextView *)[cell viewWithTag:TAG_CELL_AE_CONTENT];
            textView.delegate = self;
            [textView setText:self.noteRecord.content];
            textView.editable = self.editable;
            self.noteContentTextView = textView;
            if ([self.noteRecord.content isEqualToString:@""]) {
                [self setupPlaceHolderForTextView:textView];
            }
        }else if (indexPath.row == 1){
         
            if (self.playedBack && !self.isPlaying) {
                UIButton *btnRecord = ((UIButton *)[cell viewWithTag:200]);
                btnRecord.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                btnRecord.titleLabel.textAlignment = NSTextAlignmentCenter;
                //[btnRecord setTitle:[LocalizationManager getStringFromStrId:@"Play\nBack"] forState:UIControlStateNormal];
                [btnRecord setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
                
                
                [btnRecord removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [btnRecord addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchDown];
                
                UIButton *btnDelete = ((UIButton *)[cell viewWithTag:300]);
                [btnDelete addTarget:self action:@selector(deleteRecording) forControlEvents:UIControlEventTouchDown];
                btnDelete.hidden = NO;
                
            }else if (self.isPlaying){
                
                UIButton *btnRecord = ((UIButton *)[cell viewWithTag:200]);
                btnRecord.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                btnRecord.titleLabel.textAlignment = NSTextAlignmentCenter;
                //[btnRecord setTitle:[LocalizationManager getStringFromStrId:@"Playing..."] forState:UIControlStateNormal];
                [btnRecord setImage:[UIImage imageNamed:@"stopIcon"] forState:UIControlStateNormal];
                
                [btnRecord removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                [btnRecord addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchDown];
                
            }else{
            
                if (self.editable) {
                    UIButton *btnRecord = ((UIButton *)[cell viewWithTag:200]);
                    btnRecord.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                    btnRecord.titleLabel.textAlignment = NSTextAlignmentCenter;
                    //[btnRecord setTitle:[LocalizationManager getStringFromStrId:@"Hold\nTo Record"] forState:UIControlStateNormal];
                    [btnRecord setImage:[UIImage imageNamed:@"recIcon"] forState:UIControlStateNormal];
                    
                    [btnRecord removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
                    
                    [btnRecord addTarget:self action:@selector(holdDown) forControlEvents:UIControlEventTouchDown];
                    [btnRecord addTarget:self action:@selector(holdRelease) forControlEvents:UIControlEventTouchUpInside];
                    [btnRecord addTarget:self action:@selector(holdRelease) forControlEvents:UIControlEventTouchDragExit];
                    
                    UIButton *btnDelete = ((UIButton *)[cell viewWithTag:300]);
                    btnDelete.hidden = YES;
                    
                    UILabel *lblQuestionAudio = ((UILabel *)[cell viewWithTag:100]);
                    lblQuestionAudio.text = [LocalizationManager getStringFromStrId:@"Record audio\n(60 seconds max)"];
                    
                    ////
                
                    
                    NSMutableAttributedString *detailAttributedStr = [[NSMutableAttributedString alloc] initWithString:lblQuestionAudio.text];
                    [detailAttributedStr setAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:12]}
                                                 range:NSMakeRange(14,[lblQuestionAudio.text length] - 15)];

                    
                    lblQuestionAudio.attributedText = detailAttributedStr;
                    
                    
                    
                    ////
                    
                    
                    
                }else{
                    
                    UIButton *btnDelete = ((UIButton *)[cell viewWithTag:300]);
                    btnDelete.hidden = YES;
                    
                    UILabel *lblQuestionAudio = ((UILabel *)[cell viewWithTag:100]);
                    lblQuestionAudio.text = [LocalizationManager getStringFromStrId:@"Recorded audio"];
                    
                    if ([self.noteRecord.audioPath length] >  1) {
                        UIButton *btnRecord = ((UIButton *)[cell viewWithTag:200]);
                        btnRecord.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
                        btnRecord.titleLabel.textAlignment = NSTextAlignmentCenter;
                        //[btnRecord setTitle:[LocalizationManager getStringFromStrId:@"Play\nBack"] forState:UIControlStateNormal];
                        [btnRecord setImage:[UIImage imageNamed:@"playIcon"] forState:UIControlStateNormal];
                        
                        [btnRecord addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchDown];

                    }else{
                         UIButton *btnRecord = ((UIButton *)[cell viewWithTag:200]);
                         btnRecord.hidden = YES;
                    }
                    
                }
                
          }
        }
       
        
        if (indexPath.row == 3){
            cell.textLabel.text = [LocalizationManager getStringFromStrId:@"We will do our best to provide a quick answer to your question. If you have a medical issue, consult your healthcare providers directly."];
            cell.textLabel.numberOfLines = 7;
            cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont  systemFontOfSize:16];
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section == 0 ? @"" : @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  //  return indexPath.section == 0 ? 44: (indexPath.row == 0 ? (IS_IPHONE_4_OR_LESS ? 60:80): (IS_IPHONE_4_OR_LESS ? 180:200));
    

    if (indexPath.section == 0) {
        return 44;
        
    }else{
        
        if (indexPath.row < 2 || indexPath.row == 3) {
            if (IS_IPHONE_4_OR_LESS) {
                return 60;
            }else{
                return 80;
            }
        }else{
            if (IS_IPHONE_4_OR_LESS) {
                return 180;
            }else{
                return 200;
            }
        }
        
    }
    
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell1 forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25877725#25877725
    
    // Remove seperator inset
    if ([cell1 respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell1 setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell1 respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell1 setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell1 respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell1 setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.editable)
        return indexPath;
    else {
        if (indexPath.section == 1 && indexPath.row == 1){
            return indexPath;
        }
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (!self.editable) {
        return;
    }
    [self.noteContentTextView resignFirstResponder];
    [self.tableView becomeFirstResponder];
    
    if (indexPath.section == 0) {
        UIPickerView *picker = [[UIPickerView alloc] init];
        picker.dataSource = self;
        picker.delegate = self;
        picker.tag = TAG_PICKER_VIEW_FOR_AE_TYPE;
        [picker selectRow:self.noteRecord.type inComponent:0 animated:NO];
        
        [self.view slideInPopupWithTitle:[LocalizationManager getStringFromStrId:@"Question type"]
                           withComponent:picker
                            withDelegate:self];
    }
    else {
        if (indexPath.row == 0) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                if (self.noteRecord.image.image != nil) {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                             delegate:self
                                                                    cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:[LocalizationManager getStringFromStrId:@"Take photo"], [LocalizationManager getStringFromStrId:@"Choose Existing"], [LocalizationManager getStringFromStrId:@"Show photo"], [LocalizationManager getStringFromStrId:@"Delete photo"], nil];
                    [actionSheet setTag:0];
                    [actionSheet showInView:self.view];
                }
                else {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                             delegate:self
                                                                    cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:[LocalizationManager getStringFromStrId:@"Take photo"], [LocalizationManager getStringFromStrId:@"Choose Existing"], nil];
                    [actionSheet setTag:2];
                    [actionSheet showInView:self.view];
                }
            }else {
                if (self.noteRecord.image.image != nil) {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                             delegate:self
                                                                    cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_CANCEL]
                                                               destructiveButtonTitle:nil
                                                                    otherButtonTitles:[LocalizationManager getStringFromStrId:@"Choose Existing"], [LocalizationManager getStringFromStrId:@"Show photo"], [LocalizationManager getStringFromStrId:@"Delete photo"], nil];
                    [actionSheet setTag:1];
                    [actionSheet showInView:self.view];
                }
                else {
                    [self performSegueWithIdentifier:@"chooseDevicePictureSegue" sender:[NSNumber numberWithInt:UIImagePickerControllerSourceTypePhotoLibrary]];
                }
            }
            
   
        }
        else {
            
        }
    }
}

#pragma Audio Alert Permission Not Granted
-(void)showAudioAlert{
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:[LocalizationManager getStringFromStrId:@"Not Available"]
                                  message:[LocalizationManager getStringFromStrId:@"You denied GoHealthNow Access to the Microphone.\n\nTo enable access go to\nSettings -> GoHealthNow -> Microphone"]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:[LocalizationManager getStringFromStrId:MSG_OK]
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    [alert addAction:ok];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

#pragma Audio Methods
-(void)holdDown{
    
    if (self.isMicrophoneAccessGranted == YES){

        [self record];

        intCount = 61;
        timerCountDown = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
        
    }else{
       
        [self showAudioAlert];
        
    }

}

-(void)updateTime{

    intCount = intCount - 1;
    //self.title = [NSString stringWithFormat:[LocalizationManager getStringFromStrId:@"Remaining: %d seconds"], intCount];
    
    [self.recIndicator setTimeLabelWithString:[NSString stringWithFormat:@"%ds/60s", intCount]];
    
    if (intCount <= 0) {
        [self holdRelease];
    }
    
}

-(void)holdRelease{
    
    if (self.isMicrophoneAccessGranted == YES){

        [self.recIndicator hide];
        [timerCountDown invalidate];
        timerCountDown = nil;
        
        [self stopRecording];
        intCount = 60;
        [self play];
    }
}

- (NSString *) dateString
{
    // return a formatted string for a file name
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"ddMMMYY_hhmmssa";
    return [[formatter stringFromDate:[NSDate date]] stringByAppendingString:@".mp3"];
}


- (BOOL)record
{
    [self.recIndicator show];
    [self.recIndicator setTimeLabelWithString:@"60s/60s"];
    NSString *recordingDate = [self dateString];
    
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               [NSString stringWithFormat:@"cachedAudio/QuestionAudio-%@", recordingDate],
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    self.currentRecording = outputFileURL;
    self.sqlRecordingName = [NSString stringWithFormat:@"QuestionAudio-%@",recordingDate];
    
    recordClient.currentMp3File = self.currentRecording.path;
    
    [recordClient start];
    
    
    return YES;
}

-(void)stop {
    //self.isPlaying = NO;
    //[self.tableView reloadData];
    
    if (player) {
        [player stop];
        [self audioPlayerDidFinishPlaying:player successfully:YES];
    }
}

-(void)play
{
    
    self.isPlaying = YES;
    [self.tableView reloadData];
    
    if (!self.editable) {
        
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil]; //Playback to speaker
        NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/cachedAudio/%@", documentdir, self.currentRecording]] error:&error];
        
        NSLog(@"error: %@", error);
    }else{
        
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error: nil]; //Playback to speaker
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.currentRecording error:&error];
       
        NSLog(@"error: %@", error);
    }

    player.delegate = self;
    
    [player prepareToPlay];
    
    //analyze recording file first in case the recorder get stucked.
    //check the duration is longer than "+1sec" :)
    if ([player duration] < 1.0f) {
        [self deleteRecording];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[LocalizationManager getStringFromStrId:@"Please hold the microphone button while you are speaking. \nRelease the button to finish."] delegate:self cancelButtonTitle:[LocalizationManager getStringFromStrId:MSG_OK] otherButtonTitles:nil];
        [alert show];
        //NSLog(@"Recording length was too short!\n");
        return;
    }
         
    self.title = [LocalizationManager getStringFromStrId:@"Playing recording..."];
    [player play];
    
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    self.title = @"";
    self.isPlaying = NO;
    
    if (self.editable) {

        self.playedBack = YES;
        self.noteRecord.audioFileName = self.sqlRecordingName;
        self.noteRecord.audioPath = self.sqlRecordingName;
         self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self.tableView reloadData];
    
}

- (void)stopRecording
{
    [recordClient stop];
}

-(void)deleteRecording{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    BOOL success = [fileManager removeItemAtPath:self.currentRecording.path error:&error];
    if (!success) {
        
        NSLog(@"Could not delete file: %@ ",[error localizedDescription]);

    }
    
    [player stop];
    [recordClient stop];
    
    self.isPlaying = NO;
    self.playedBack = NO;
    [self.tableView reloadData];
    self.currentRecording = nil;
    self.noteRecord.audioPath = nil;
    self.noteRecord.audioFileName = nil;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.title = @"";
    [self.timerCountDown invalidate];

}

-(void)viewDidDisappear:(BOOL)animated{
    
     [self stopRecording];
    
    if (self.didSave == NO) {
        
        if (self.editable == YES && self.isGoingToCamera == NO) {
            [self deleteRecording];
        }
    }
    
    [player stop];
    player = nil;
}

////////////


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"chooseDevicePictureSegue"]) {
        
        self.isGoingToCamera = YES;
        
        GGImagePickerController *destVC = [segue destinationViewController];
        destVC.sourceType = [(NSNumber *)sender intValue];
        destVC.delegate = self;
    }
}

-(IBAction)unwindToSegueNoteRecord:(UIStoryboardSegue *)unwindSegue{
    
}

@end
