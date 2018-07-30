//
//  Mp3EncodeOperation.h
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface Mp3EncodeOperation : NSOperation

@property (nonatomic, assign) BOOL setToStopped;
@property (nonatomic, assign) NSMutableArray *recordQueue;
@property (nonatomic, strong) NSString *currentMp3File;

@end
