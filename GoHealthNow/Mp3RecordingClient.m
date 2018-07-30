
//
//  Mp3RecordingClient.m
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//

#import "Mp3RecordingClient.h"

@implementation Mp3RecordingClient

+ (instancetype)sharedClient {
    static Mp3RecordingClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [Mp3RecordingClient new];
    });
    
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        recordingQueue = [[NSMutableArray alloc] init];
        operationQueue = [[NSOperationQueue alloc] init];
        
        recorder = [[Mp3Recorder alloc] init];
        recorder.recordQueue = recordingQueue;
        
    }
    return self;
}

- (void)start
{
    [recordingQueue removeAllObjects];
    
    [recorder startRecording];
    
    if (encodeOperation) {
        encodeOperation = nil;
    }
    
    encodeOperation = [[Mp3EncodeOperation alloc] init];
    encodeOperation.currentMp3File = self.currentMp3File;
    encodeOperation.recordQueue = recordingQueue;
    [operationQueue addOperation:encodeOperation];
}

- (void)stop
{
    [recorder stopRecording];
    encodeOperation.setToStopped = YES;
}

@end
