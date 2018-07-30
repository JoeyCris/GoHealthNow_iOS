//
//  NotesViewController.m
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2015-01-16.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import "NotesViewController.h"
#import "StyleManager.h"
#import "NoteRecord.h"
#import "Constants.h"
#import "NotesDetailController.h"

@interface NotesViewController()

@property (nonatomic) NSArray *noteRows;

@end

@implementation NotesViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [StyleManager styleTable:self.tableView];
    self.tableView.separatorColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshTable];
    
    if (!self.navigationItem.rightBarButtonItem) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: [LocalizationManager getStringFromStrId:@"Add"]
                                                                                      style: UIBarButtonItemStyleDone
                                                                                     target: self
                                                                                     action: @selector(createNewButtonTapped:)];
        });
        
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.noteRows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noteCell"];
    
    UILabel *noteContent = (UILabel *)[cell viewWithTag:NOTES_CONTENT_LABEL_TAG];
    UILabel *noteDate = (UILabel *)[cell viewWithTag:NOTES_DATE_LABEL_TAG];
    UILabel *noteType = (UILabel *)[cell viewWithTag:NOTES_TYPE_LABEL_TAG];
    
    noteContent.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [StyleManager styleTableCell:cell];
    [StyleManager stylelabel:noteContent];
    [StyleManager stylelabel:noteDate];
    [StyleManager stylelabel:noteType];
    
    NoteRecord *currentNote = self.noteRows[indexPath.row];
    
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    outputFormatter.timeZone = [NSTimeZone systemTimeZone];
    outputFormatter.timeStyle = NSDateFormatterNoStyle;
    outputFormatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *noteRecordedTime = [outputFormatter stringFromDate:currentNote.recordedTime];
    
    
    if ([currentNote.audioPath length] > 1) {
        noteContent.text = [LocalizationManager getStringFromStrId:@"Audio Question"];
    }else{
        noteContent.text = currentNote.content;
    }
   
    noteDate.text = noteRecordedTime;
    
    switch (currentNote.type) {
        case NoteTypeDiet:
            noteType.text = [LocalizationManager getStringFromStrId:@"Diet"];
            break;
        case NoteTypeExercise:
            noteType.text = [LocalizationManager getStringFromStrId:@"Exercise"];
            break;
        case NoteTypeGlucose:
            noteType.text = [LocalizationManager getStringFromStrId:@"Glucose"];
            break;
        case NoteTypeWeight:
            noteType.text = [LocalizationManager getStringFromStrId:MSG_WEIGHT];
            break;
        case NoteTypeOthers:
            noteType.text = [LocalizationManager getStringFromStrId:@"Other"];
            break;
        default:
            noteType.text = [LocalizationManager getStringFromStrId:@"Unknown"];
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // http://stackoverflow.com/questions/25770119/ios-8-uitableview-separator-inset-0-not-working/25877725#25877725
    
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"notesDetailSegue" sender:self.noteRows[indexPath.row]];
}

#pragma mark - Event Handlers

- (IBAction)createNewButtonTapped:(id)sender {
    [self performSegueWithIdentifier:@"notesDetailSegue" sender:self];
}

#pragma mark - Methods

- (void)refreshTable {
    [NoteRecord queryFromDB:nil].then(^(NSArray *noteRecords) {
        self.noteRows = noteRecords;
    }).finally(^{
        if ([self.noteRows count]) {
            [self.tableView reloadData];
            [self hideEmptyMessageInTableView:self.tableView];
        }
        else {
            [self showEmptyMessageInTableView:self.tableView];
        }
    });
}

- (void)showEmptyMessageInTableView:(UITableView *)tableView
{
    if ([tableView viewWithTag:NOTES_TABLE_EMPTY_MESSAGE_TAG]) {
        return;
    }
    
    UILabel *emptyMessageView = [[UILabel alloc] init];
    emptyMessageView.text = [LocalizationManager getStringFromStrId:@"No Questions"];
    emptyMessageView.tag = NOTES_TABLE_EMPTY_MESSAGE_TAG;
    emptyMessageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    if (IS_IPAD) {
        emptyMessageView.font = [UIFont systemFontOfSize:19.5];
    }
    
    [emptyMessageView sizeToFit];
    [StyleManager stylelabel:emptyMessageView];
    
    [tableView addSubview:emptyMessageView];
    
    [tableView addConstraint:[NSLayoutConstraint constraintWithItem:emptyMessageView
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [tableView addConstraint:[NSLayoutConstraint constraintWithItem:emptyMessageView
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:tableView
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.0
                                                           constant:0.0]];
}

- (void)hideEmptyMessageInTableView:(UITableView *)tableView
{
    UIView *emptyMessageView = [tableView viewWithTag:NOTES_TABLE_EMPTY_MESSAGE_TAG];
    [emptyMessageView removeFromSuperview];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:[LocalizationManager getStringFromStrId:MSG_NAVI_BAR_BACK] style:UIBarButtonItemStylePlain target:nil action:nil];
    [self.navigationItem setBackBarButtonItem:backItem];
    
    NSString *segueId = [segue identifier];
    
    if ([segueId isEqualToString:@"notesDetailSegue"] && [sender isKindOfClass:[NoteRecord class]]) {
        NoteRecord *selectedNoteRecord = (NoteRecord *)sender;
        NotesDetailController *destVC = [segue destinationViewController];
        destVC.noteRecord = selectedNoteRecord;
    }
}

@end
