//
//  Authentication.h
//  GlucoGuide
//
//  Created by kthakore on 11/01/14.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_Authentication_h
#define GlucoGuide_Authentication_h
#import "GlucoguideAPI.h"

@interface Authentication : NSObject
+ (id)sharedService;

@property GlucoguideAPI* api;

//Logins in using FB or GGAPI
- (PMKPromise*) login:(NSDictionary*)creds;

- (PMKPromise*) logout;


@end
#endif
