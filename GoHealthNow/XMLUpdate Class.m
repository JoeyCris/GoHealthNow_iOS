//
//  XMLUpdateClass.h
//
//  Created by John Wreford
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import "XMLUpdateClass.h"
#import "XMLDictionary/XMLDictionary.h"
#import "User.h"


@implementation XMLUpdateClass


static XMLUpdateClass *singletonInstance;

+(XMLUpdateClass *)getInstance
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

- (NSDictionary *)medicationXMLDict {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self userSpecificMedicationXMLFilePath]]) {
        return [NSDictionary dictionaryWithXMLFile:[self userSpecificMedicationXMLFilePath]];
    }else{
        return [NSDictionary dictionaryWithXMLFile:[[NSBundle mainBundle] pathForResource:@"assets/medication" ofType:@"xml"]];
    }
}


-(void)addMedicationToUserMedicationXMLWithMedicationName:(NSString *)medicationName{
    
    medicationName = [[[medicationName substringToIndex:1] uppercaseString] stringByAppendingString:[medicationName substringFromIndex:1]];
    
    NSString *filePath = [self userSpecificMedicationXMLFilePath];
    NSError *error = nil;
    
    NSMutableDictionary *addDictionary = [[NSMutableDictionary alloc]initWithDictionary:self.medicationXMLDict];
    
    NSString *stringID = [NSString stringWithFormat:@"cus%lu", [[addDictionary objectForKey:@"Medicine"] count] +1];
    
    NSMutableDictionary *tempDict = [[NSMutableDictionary alloc]initWithCapacity:4];
    [tempDict setObject:stringID forKey:@"_ID"];
    [tempDict setObject:@"2" forKey:@"_IsCommon"];
    [tempDict setObject:@"0" forKey:@"_Type"];
    [tempDict setObject:medicationName forKey:@"_Name"];
    [[addDictionary objectForKey:@"Medicine"] addObject:tempDict];
    
    [[addDictionary XMLString] writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
}

- (NSString *)userSpecificMedicationXMLFilePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *document = [path objectAtIndex:0];
    
    User *user = [User sharedModel];
    
    //NSLog(@"directory: %@", document);
    
    NSString *fileName = [NSString stringWithFormat:@"medication_%@.xml", user.userId];
    
    return [document stringByAppendingPathComponent:fileName];
}

@end
