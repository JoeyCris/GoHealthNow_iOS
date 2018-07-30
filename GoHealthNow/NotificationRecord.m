//
//  ReminderRecord.h
//  GlucoGuide
//
//  Created by John Wreford on 2015-09-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NotificationRecord.h"
#import "GGUtils.h"
#import "GlucoguideAPI.h"
#import "User.h"
#import "XMLUpdateClass.h"

#import "XMLDictionary/XMLDictionary.h"


NSString* const REMINDERRECORD_MEDICATION_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Reminder_Records> \
<Reminder> \
<Uuid>%@</Uuid>\
<ReminderType>0</ReminderType>\
<ReminderTime>%@</ReminderTime>\
<RecordedTime>%@</RecordedTime>\
<RepeatType>%@</RepeatType>\
<Parameters>\
<Dose>%@</Dose> \
<Unit>%@</Unit>\
<MedicineID>%@</MedicineID> \
<MedicineName>%@</MedicineName> \
<MedicineType>%@</MedicineType> \
</Parameters>\
</Reminder> \
</Reminder_Records> \
</User_Record>";

NSString* const REMINDERRECORD_BG_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Reminder_Records> \
<Reminder> \
<Uuid>%@</Uuid>\
<ReminderType>1</ReminderType>\
<ReminderTime>%@</ReminderTime>\
<RecordedTime>%@</RecordedTime>\
<RepeatType>%@</RepeatType>\
<Parameters>\
<GlucoseType>%@</GlucoseType> \
</Parameters>\
</Reminder> \
</Reminder_Records> \
</User_Record>";

NSString* const REMINDERRECORD_BP_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Reminder_Records> \
<Reminder> \
<Uuid>%@</Uuid>\
<ReminderType>1</ReminderType>\
<ReminderTime>%@</ReminderTime>\
<RecordedTime>%@</RecordedTime>\
<RepeatType>%@</RepeatType>\
<Parameters>\
</Parameters>\
</Reminder> \
</Reminder_Records> \
</User_Record>";

NSString* const REMINDERRECORD_EXERCISE_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Reminder_Records> \
<Reminder> \
<Uuid>%@</Uuid>\
<ReminderType>2</ReminderType>\
<ReminderTime>%@</ReminderTime>\
<RecordedTime>%@</RecordedTime>\
<RepeatType>%@</RepeatType>\
<Parameters>\
<ExerciseType>%@</ExerciseType> \
</Parameters>\
</Reminder> \
</Reminder_Records> \
</User_Record>";

NSString* const REMINDERRECORD_MEAL_UPLOADING = @"\
<User_Record> \
<UserID>%@</UserID> \
<Reminder_Records> \
<Reminder> \
<Uuid>%@</Uuid>\
<ReminderType>3</ReminderType>\
<ReminderTime>%@</ReminderTime>\
<RecordedTime>%@</RecordedTime>\
<RepeatType>%@</RepeatType>\
<Parameters>\
<MealType>%@</MealType> \
</Parameters>\
</Reminder> \
</Reminder_Records> \
</User_Record>";



@implementation NotificationRecord

- (PMKPromise *)saveMedication {
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:REMINDERRECORD_MEDICATION_UPLOADING,
                           user.userId,
                           self.uuid,
                           //self.reminderType, HARD CODED INTO XML
                           [GGUtils stringFromDate:[self createDateReminder:self.reminderTime]],
                           [GGUtils stringFromDate:[NSDate date]],
                           self.repeatType,
                           self.medicineDose,
                           self.medicineUnit,
                           self.medicineID,
                           self.medicineName,
                           self.medicineType];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

- (PMKPromise *)saveBG {
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:REMINDERRECORD_BG_UPLOADING,
                           user.userId,
                           self.uuid,
                           //self.reminderType,
                           [GGUtils stringFromDate:[self createDateReminder:self.reminderTime]],
                           [GGUtils stringFromDate:[NSDate date]],
                           self.repeatType,
                           self.glucoseType];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

- (PMKPromise *)saveBloodPressure {
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:REMINDERRECORD_BG_UPLOADING,
                           user.userId,
                           self.uuid,
                           //self.reminderType,
                           [GGUtils stringFromDate:[self createDateReminder:self.reminderTime]],
                           [GGUtils stringFromDate:[NSDate date]],
                           self.repeatType,
                           self.glucoseType];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

- (PMKPromise *)saveExercise {
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:REMINDERRECORD_EXERCISE_UPLOADING,
                           user.userId,
                           self.uuid,
                           //self.reminderType,
                           [GGUtils stringFromDate:[self createDateReminder:self.reminderTime]],
                           [GGUtils stringFromDate:[NSDate date]],
                           self.repeatType,
                           self.exerciseType];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

- (PMKPromise *)saveMeal {
    
    User* user = [User sharedModel];
    
    NSString* xmlRecord = [NSString stringWithFormat:REMINDERRECORD_MEAL_UPLOADING,
                           user.userId,
                           self.uuid,
                           //self.reminderType,
                           [GGUtils stringFromDate:[self createDateReminder:self.reminderTime]],
                           [GGUtils stringFromDate:[NSDate date]],
                           self.repeatType,
                           self.mealType];
    
    return [[GlucoguideAPI sharedService ]saveRecordWithXML:xmlRecord];
}

#pragma Create Proper Date Format
-(NSDate *)createDateReminder:(NSString *)notificationTime{
    
    NSDate *currentDate          = [NSDate date];
    NSCalendar *calendar         = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
    
    [components month];
    [components day];
    [components year];
    
    NSDateFormatter * formatter=[[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"dd/MM/yyyy hh:mma"];
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld/%ld/%ld %@", (long)[components day], (long)[components month], (long)[components year], notificationTime];
    
    NSDate *fireDate = [formatter dateFromString:dateStr];
    
    return fireDate;
}


@end
