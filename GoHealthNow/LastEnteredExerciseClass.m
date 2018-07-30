//
//  LastEnteredExerciseClass.h
//
//  Created by John Wreford
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "LastEnteredExerciseClass.h"
#import "User.h"


@implementation LastEnteredExerciseClass

@synthesize stringHours, stringMinutes, stringType;


static LastEnteredExerciseClass *singletonInstance;

+(LastEnteredExerciseClass *)getInstance
    {
        static dispatch_once_t once;
        static id singletonInstance;
        dispatch_once(&once, ^{
            singletonInstance = [[self alloc] init];
        });
        return singletonInstance;
    }

- (id)init {
    if (self = [super init]) {

    }
    return self;
}

-(void)setType:(NSString *)type{
     stringType = type;
}

-(NSString *)stringType {
    return stringType;
}

-(void)setStringHours:(NSString *)hours{
    stringHours = hours;
}

-(NSString *)stringHours {
    return stringHours;
}

-(void)setStringMinutes:(NSString *)minutes{
    stringMinutes = minutes;
}

-(NSString *)stringMinutes {
    return stringMinutes;
}

-(NSDictionary *)getUserExerciseLastEntry{
        
    NSDictionary *dictionaryUserExerciseLastEntry = [[NSDictionary alloc]initWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:[[User sharedModel] userId]]];
    return dictionaryUserExerciseLastEntry;
}

-(void)saveLastUserExerciseEntryWithType:(NSString *)type withHour:(NSString *)hours withMinutes:(NSString *)minutes{
    
    if ([type isEqualToString:@"0"]) {
        type = @"0";
    }else if ([type isEqualToString:@"2"]){
        type = @"1";
    }else{
        type= @"2";
    }

    NSMutableDictionary *testDict = [[NSMutableDictionary alloc]initWithCapacity:2];
    [testDict setObject:minutes forKey:[LocalizationManager getStringFromStrId:@"minutes"]];
    [testDict setObject:hours forKey:[LocalizationManager getStringFromStrId:@"hours"]];
    [testDict setObject:type forKey:[LocalizationManager getStringFromStrId:@"type"]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:testDict forKey:[[User sharedModel] userId]];
    
}



@end
