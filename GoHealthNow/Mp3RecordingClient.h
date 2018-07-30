//
//  Mp3RecordingClient.h
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mp3Recorder.h"
#import "Mp3EncodeOperation.h"

@interface Mp3RecordingClient : NSObject
{
    Mp3Recorder *recorder;
    NSMutableArray *recordingQueue;
    Mp3EncodeOperation *encodeOperation;
    NSOperationQueue *operationQueue;
}

@property (nonatomic, strong) NSString *currentMp3File;

+ (instancetype)sharedClient;

- (void)start;
- (void)stop;

@end
