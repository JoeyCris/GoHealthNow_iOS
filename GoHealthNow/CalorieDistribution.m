//
//  CalorieDistribution.h
//  GlucoGuide
//
//
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "GlucoguideAPI.h"
#import "CalorieDistribution.h"

@interface CalorieDistribution()

@end


@implementation CalorieDistribution
@synthesize calorieDistribDictionary;

+ (instancetype) sharedService {
    static CalorieDistribution* sharedService = nil;
    
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

-(NSDictionary *)getCalorieDistribDictionary {

    User *user = [User sharedModel];

    calorieDistribDictionary =  [[NSDictionary alloc] initWithDictionary:[[GlucoguideAPI sharedService] getCalorieDistributionWithUserId:user.userId]];

    return calorieDistribDictionary;
}


@end