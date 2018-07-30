//
//  ViewController.h
//  reminders
//
//  Created by John Wreford on 2015-09-07.
//  Copyright (c) 2015 John Wreford. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NotificationListViewController : UITableViewController{
    
    BOOL isSetup;
}

@property (nonatomic, assign) BOOL isSetup;

@end
