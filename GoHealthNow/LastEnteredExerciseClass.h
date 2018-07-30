//
//  LastEnteredExerciseClass.h
//
//  Created by John Wreford
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface LastEnteredExerciseClass : NSObject
{
    NSString *stringType;
    NSString *stringMinutes;
    NSString *stringHours;    
}

+(LastEnteredExerciseClass *)getInstance;

@property (nonatomic) NSString *stringType;
@property (nonatomic) NSString *stringMinutes;
@property (nonatomic) NSString *stringHours;

-(NSDictionary *)getUserExerciseLastEntry;
-(void)saveLastUserExerciseEntryWithType:(NSString *)type withHour:(NSString *)hours withMinutes:(NSString *)minutes;
    
@end
