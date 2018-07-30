//
//  Mp3EncodeOperation.m
//  GlucoGuide
//
//  Created by John Wreford on 2016-09-26.
//  Copyright (c) 2016 GlucoGuide. All rights reserved.
//

#import "Mp3EncodeOperation.h"
#import "lame.h"


// GLobal var
lame_t lame;

@implementation Mp3EncodeOperation

- (void)main
{
    
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        [self createCachedAudioDirectory];
    });

    [[NSFileManager defaultManager] createFileAtPath:self.currentMp3File contents:[@"" dataUsingEncoding:NSASCIIStringEncoding] attributes:nil];
        
    NSFileHandle *handle = [NSFileHandle fileHandleForUpdatingAtPath:self.currentMp3File];
    [handle seekToEndOfFile];

    // lame param init
    lame = lame_init();
	lame_set_num_channels(lame, 1);
	lame_set_in_samplerate(lame, 16000);
	lame_set_brate(lame, 16);
	lame_set_mode(lame, 1);
	lame_set_quality(lame, 3);
	lame_init_params(lame);
    
    while (true) {
        
        NSData *audioData = nil;
        @synchronized(_recordQueue){// begin @synchronized
            
            if (_recordQueue.count > 0) {
                audioData = [_recordQueue objectAtIndex:0];
                [_recordQueue removeObjectAtIndex:0];
            }
        }// end @synchronized
        
        if (audioData != nil) {
                        
            short *recordingData = (short *)audioData.bytes;
            NSUInteger pcmLen = audioData.length;
            NSUInteger nsamples = pcmLen / 2;
            
            unsigned char buffer[pcmLen];
            // mp3 encode
            int recvLen = lame_encode_buffer(lame, recordingData, recordingData, (int)nsamples, buffer, (int)pcmLen);

            NSData *piece = [NSData dataWithBytes:buffer length:recvLen];
            [handle writeData:piece];
            
        }else{
            if (_setToStopped) {
                break;
            }else{
                [NSThread sleepForTimeInterval:0.05];
            }
        }
        
    }
    
    [handle closeFile];
    
    lame_close(lame);
    
}

-(void)createCachedAudioDirectory{
    
    NSString *path;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"cachedAudio"];
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path])    //Does directory already exist?
    {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path
                                       withIntermediateDirectories:NO
                                                        attributes:nil
                                                             error:&error])
        {
            NSLog(@"Create directory error: %@", error);
        }
    }
    
}

@end
