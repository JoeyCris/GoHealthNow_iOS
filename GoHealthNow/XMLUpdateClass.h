//
//  XMLUpdateClass.h
//
//  Created by John Wreford
//  Copyright (c) 2015 John Wreford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface XMLUpdateClass : NSObject
{

}



+(XMLUpdateClass *)getInstance;

- (NSDictionary *)medicationXMLDict;
- (void)addMedicationToUserMedicationXMLWithMedicationName:(NSString *)medicationName;
    
@end
