//
//  CalorieDistribution.h
//  GlucoGuide
//

//

#ifndef GlucoGuide_CalorieDistribution_h
#define GlucoGuide_CalorieDistribution_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CalorieDistribution : NSObject
{
    NSDictionary *calorieDistribDictionary;
}


+ (instancetype)sharedService;

-(NSDictionary *)getCalorieDistribDictionary;

@property (nonatomic) NSDictionary *calorieDistribDictionary;



@end

#endif
