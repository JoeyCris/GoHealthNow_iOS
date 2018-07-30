//
//  HttpClient.h
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-13.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#ifndef GlucoGuide_HttpClient_h
#define GlucoGuide_HttpClient_h

//@interface FormParameter : NSObject
//
//@property (nonatomic, copy)     NSString* name;
//@property (nonatomic, copy)     NSString* value;
//@property (nonatomic)     BOOL isFile;
//@property (nonatomic, copy)     NSString*  mimeType;
//
//-(instancetype) initWithDictionary;
//-(NSDictionary*) toDictionary;
//
//@end

@interface HttpClient : NSObject



typedef NSDictionary* Response; //@{ @"retCode": @0, @"data": @""};

+(Response) sendPostMessage:(NSString*) url :(NSString*) paraName :(NSString*)paraValue;

+(Response) sendMultiPostMessage:(NSString*) url :(NSArray*) paraList; //NSArray<FormParameter>

+(Response) downloadFile:(NSString*) url path: (NSString*) path fileName: (NSString*) fileName; //NSArray<FormParameter>

@end

#endif
