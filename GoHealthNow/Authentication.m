//
//  Authentication.m
//  GlucoGuide
//
//  Created by kthakore on 11/01/14.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Authentication.h"

@implementation Authentication

+ (id) sharedService {
    static Authentication* sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedService = [[self alloc] init];
    });
    return sharedService;
    
}

-(id)init {
    if (self = [super init]){
        self.api = [GlucoguideAPI sharedService];
    }
    return self;
}

-(PMKPromise*)login:(NSDictionary *)creds{
    
    
    
    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
//        if ([creds valueForKey:@"email"] ==nil || [creds valueForKey:@"password"] == nil){
//            
//            reject(@{ @"Error" : @"Requires email and password to login"});
//        } else {
//            NSString* email = creds[@"email"];
//            NSString* password= creds[@"password"];
//            [self.api authenticate:email :password].then(^(id res){
//                NSDictionary * result = (NSDictionary*) res;
//                fulfill(result);
//            }).catch(^(id res) {
//                reject(@{ @"Error": @"Invalid user"});
//            });
//            
//            
//        }
    }];
    
}

-(PMKPromise*)logout {

    return [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
        
        
        fulfill(@{ @"Error" : @"Not implemented"});
    }];

}

@end

