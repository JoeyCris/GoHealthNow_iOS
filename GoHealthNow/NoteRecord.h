//
//  NoteRecord.h
//  GlucoGuide
//
//  Created by Robert Wang on 2015-03-20.
//  Copyright (c) 2015 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_NoteRecord_h
#define GlucoGuide_NoteRecord_h

#import "GGRecord.h"
#import "DBHelper.h"
#import "ServicesConstants.h"

@interface NotePhoto : NSObject

@property (nonatomic)     UIImage* image;
@property (nonatomic)     NSDate* createdTime;
@property (nonatomic)     NSString* imageName;

-(void)loadImageWithPath:(NSString *)path;
-(PMKPromise *)saveToFile;

@end

@interface NoteRecord : NSObject<GGRecord, DBProtocol>

//+(instancetype) createWithDictionary:(NSDictionary*) dict;

//+ (BOOL) save:(NSArray*) records;
+ (PMKPromise *)save:(NSArray*) records;


//NSArray<DBProtocol> queryDataByTime:(NSDate*)fromDate toDate:(NSDate*)toDate;
+ (PMKPromise *)queryDataByTime:(NSDate*)fromDate toDate:(NSDate*)toDate;

//- (BOOL) save;
-(PMKPromise *)save;

+(PMKPromise *)addNotePhoto: (UIImage *)photo;

-(NSString*) toXML;

-(void)uploadMP3:(NSString *)mp3FilePath;

//<NoteContent>JDJDJdDJ</NoteContent>
//<RecordedTime>2015-03-19T10:22:37-0400</RecordedTime>
//<UploadingVersion>0</UploadingVersion>
//<NoteType>Diet</NoteType>

@property (nonatomic)           NoteType type;
@property (nonatomic, copy)     NSString* content;
@property (nonatomic)           NSDate* recordedTime;
@property (atomic)           NotePhoto* image;
@property (nonatomic) NSString *audioPath;
@property (nonatomic) NSString *audioFileName;

/////
@property (nonatomic, assign) BOOL setToStopped;
@property (nonatomic, assign) NSMutableArray *recordQueue;

@end

#endif
