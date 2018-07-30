//
//  AddExerciseRecordViewController.h
//  GlucoGuide
//
//  Created by Siddarth Kalra on 2014-11-28.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AddExerciseRecordViewController : UITableViewController <UITextViewDelegate>

@property (nonatomic) NSDictionary *exerciseInfo;
@property (nonatomic, strong) UITextView *noteText;


@end
