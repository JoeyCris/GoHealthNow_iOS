//
//  ReminderCard.h
//  Reminder
//
//  Created by Haoyu Gu on 2015-07-17.
//  Copyright (c) 2015 Haoyu Gu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReminderRecord : NSObject

@property (nonatomic) NSString* eventName;
@property (nonatomic) BOOL remindOnADay;
@property (nonatomic) NSDate* date;
@property (nonatomic) NSDate* createDate;
@property (nonatomic) BOOL isRepeat;
@property (nonatomic) NSMutableArray* repeatDays;
@property (nonatomic) NSString* eventNote;

@end

@interface ReminderCard : UIView <UITableViewDataSource, UITableViewDelegate>

- (void)loadReminderViewWithRecord:(ReminderRecord *)rRecord withView:(UIView *)view;

- (void)loadReminderViewWithView:(UIView *)view;

@end
