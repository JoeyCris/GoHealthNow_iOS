//
//  SecurityStorage.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-19.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_SecurityStorage_h
#define GlucoGuide_SecurityStorage_h

#import <Foundation/Foundation.h>


@interface SecurityStorage : NSObject

+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)delete:(NSString *)service;


@end

#endif
