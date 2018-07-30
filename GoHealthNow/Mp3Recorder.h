//
//  Mp3Recorder.h
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#define kNumberAudioQueueBuffers 3
#define kBufferDurationSeconds 0.1f


@interface Mp3Recorder : NSObject
{
    AudioQueueRef				_audioQueue;
    AudioQueueBufferRef			_audioBuffers[kNumberAudioQueueBuffers];
    AudioStreamBasicDescription	_recordFormat;
    
}

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSMutableArray *recordQueue;

- (void) startRecording;
- (void) stopRecording;


@end
