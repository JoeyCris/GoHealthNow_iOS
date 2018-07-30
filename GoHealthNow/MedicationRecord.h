//
//  MedicationRecord.h
//  GlucoGuide
//
//  Created by John Wreford on 2015-09-15.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_MedicationRecord_h
#define GlucoGuide_MedicationRecord_h

#import <UIKit/UIKit.h>
#import "GGRecord.h"
#import "DBHelper.h"
#import "ServicesConstants.h"


@interface MedicationRecord : NSObject<GGRecord, DBProtocol>

//return type MedicationRecord

+ (NSArray *)getAllMedications;
+ (NSArray *)getUserMedicationsDetailed;

-(NSString*) toXML;

-(NSString *)getMedicationNameWithID:(NSString *)medID;

-(void)deleteMedicationRecordWithID:(NSString *)uuid;


@property (nonatomic)   float dose;
@property (nonatomic)   NSString *medicationId;
@property (nonatomic)   NSString *measurement;
@property (nonatomic)   NSDate *recordedTime;
@property (nonatomic)   NSString *uuid;
@property (nonatomic)   NSString *note;



@end

#endif
