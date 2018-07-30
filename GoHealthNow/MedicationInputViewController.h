//
//  ViewController.h
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MedicationInputViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (strong, nonatomic) NSMutableArray * arrayDisplay;
@property (strong, nonatomic) NSArray * arrayValue;

@end






