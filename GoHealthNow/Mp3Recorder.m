//
//  Mp3Recorder.m
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//
#import "Mp3Recorder.h"
#import <AVFoundation/AVFoundation.h>

static const int bufferByteSize = 1600;
static const int sampeleRate = 16000;
static const int bitsPerChannel = 16;

@implementation Mp3Recorder

- (void) setupAudioFormat:(UInt32) inFormatID SampleRate:(int) sampeleRate
{
    memset(&_recordFormat, 0, sizeof(_recordFormat));
    _recordFormat.mSampleRate = sampeleRate;
    
	//UInt32 size = sizeof(_recordFormat.mChannelsPerFrame);
    //AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, &size, &_recordFormat.mChannelsPerFrame);
	_recordFormat.mFormatID = inFormatID;
	if (inFormatID == kAudioFormatLinearPCM){
		// if we want pcm, default to signed 16-bit little-endian
        _recordFormat.mChannelsPerFrame = 1;
		_recordFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
		_recordFormat.mBitsPerChannel = bitsPerChannel;
		_recordFormat.mBytesPerPacket = _recordFormat.mBytesPerFrame = (_recordFormat.mBitsPerChannel / 8) * _recordFormat.mChannelsPerFrame;
		_recordFormat.mFramesPerPacket = 1;
	}
    
}

void inputBufferHandler(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp *inStartTime,
                        UInt32 inNumPackets, const AudioStreamPacketDescription *inPacketDesc)
{
    Mp3Recorder *recorder = (__bridge Mp3Recorder *)inUserData;
    if (inNumPackets > 0 && recorder.isRecording){
        
        int pcmSize = inBuffer->mAudioDataByteSize;
        char *pcmData = (char *)inBuffer->mAudioData;
        NSData *data = [[NSData alloc] initWithBytes:pcmData length:pcmSize];
        [recorder.recordQueue addObject:data];
        
        AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
    }
}

- (void) startRecording
{

    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // category
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
        
    // format
    [self setupAudioFormat:kAudioFormatLinearPCM SampleRate:sampeleRate];
    
    AudioQueueNewInput(&_recordFormat, inputBufferHandler, (__bridge void *)(self), NULL, NULL, 0, &_audioQueue);
    
    for (int i = 0; i < kNumberAudioQueueBuffers; ++i){
        AudioQueueAllocateBuffer(_audioQueue, bufferByteSize, &_audioBuffers[i]);
        AudioQueueEnqueueBuffer(_audioQueue, _audioBuffers[i], 0, NULL);
    }

    AudioQueueStart(_audioQueue, NULL);
    _isRecording = YES;
   
}

- (void) stopRecording
{
    if (_isRecording) {
        
        _isRecording = NO;
        AudioQueueStop(_audioQueue, true);
        AudioQueueDispose(_audioQueue, true);
    }
}

@end
