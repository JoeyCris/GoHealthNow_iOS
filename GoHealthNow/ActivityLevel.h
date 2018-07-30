//
//  ActivityLevel.h
//  GlucoGuide
//

//

#ifndef GlucoGuide_ActivityLevel_h
#define GlucoGuide_ActivityLevel_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ActivityLevel : NSObject
{
    float activityLevel;
}


+ (instancetype)sharedService;

-(float) userActivityLevel;


@property (nonatomic) float activityLevel;

@end

#endif
