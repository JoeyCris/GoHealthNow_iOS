//
//  ActivityLevel.m
//  GlucoGuide
//
//
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "GlucoguideAPI.h"
#import "ActivityLevel.h"

@interface ActivityLevel()

@end


@implementation ActivityLevel
@synthesize activityLevel;

+ (instancetype) sharedService {
    static ActivityLevel* sharedService = nil;
    
    if( sharedService == nil) {
        @synchronized(self){
            if( sharedService == nil) {
                sharedService = [[self alloc] init];
            }
        }
        
    }

    return sharedService;
    
}

-(instancetype)init {
    if (self = [super init]){
       
        
    }
    
    return self;
}

-(float)userActivityLevel {
    User *user = [User sharedModel];
    self.activityLevel = [[[[GlucoguideAPI sharedService] getActivityLevelWithUserId:user.userId] objectForKey:@"ActivityLevel"] floatValue];
  
    return self.activityLevel;
}


@end