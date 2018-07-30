//
//  HttpClient.m
//  GlucoGuide
//
//  Created by Robert Wang on 2014-12-13.
//  Copyright (c) 2014 GlucoGuide. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sstream>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>

#import "HttpClient.h"
#import "ServicesConstants.h"

#include "curl/curl.h"

//#define BUF_SIZE 1024*12

size_t writeData(void *contents, size_t size, size_t nmemb, void* userp) {
    size_t len = size*nmemb;

    std::stringstream* stream = (std::stringstream*)userp;
    stream->write((char*)contents, len);

    
    return len;
};

size_t writeToFile(void *ptr, size_t size, size_t nmemb, FILE *stream) {
    size_t written = fwrite(ptr, size, nmemb, stream);
    return written;
}



//@implementation FormParameter ;
//
//@end

@implementation HttpClient ;


+(Response) sendPostMessage: (NSString*) url :(NSString*)paraName :(NSString*)paraValue {
    
    CURL* request = NULL;
    CURLcode res = CURLE_OK;

    std::stringstream buffer;
    
    request = curl_easy_init();
    if(request) {
        
        char* postData = curl_easy_escape(request, [paraValue UTF8String], 0);
        std::string data = [paraName UTF8String];
        data.append("=");
        data.append(postData);
        
        curl_easy_setopt(request, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(request, CURLOPT_TIMEOUT, 45);
        curl_easy_setopt(request, CURLOPT_SSL_VERIFYPEER, 0L);
        curl_easy_setopt(request, CURLOPT_SSL_VERIFYHOST, 0L);
        curl_easy_setopt(request, CURLOPT_WRITEFUNCTION, writeData);
        curl_easy_setopt(request, CURLOPT_WRITEDATA, &buffer);
        curl_easy_setopt(request, CURLOPT_POST, 1);
        curl_easy_setopt(request, CURLOPT_POSTFIELDS, data.c_str());
        curl_easy_setopt(request, CURLOPT_POSTFIELDSIZE, data.size());
        
        res = curl_easy_perform(request);
        curl_easy_cleanup(request);
        curl_free(postData);
        
        if(res == CURLE_OK) {
            //NSLog(@"response: %@", [NSString stringWithUTF8String: buffer]);
            return @{ @"retCode": @0, @"data": [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String: buffer.str().c_str()]]};
        }else {
            NSLog(@"error code: %d", res);
            
            //return @{ @"retCode": [NSNumber numberWithInt:res], @"data": HTTP_MESSAGE_NETWORK_UNAVAILABLE};

            NSString *data = @"";
            switch (res) {
                case CURLE_COULDNT_RESOLVE_HOST:
                case CURLE_COULDNT_CONNECT:
                case CURLE_COULDNT_RESOLVE_PROXY:
                    data = HTTP_MESSAGE_NETWORK_UNAVAILABLE;// @"Unable to connect to server";
                    break;
                default:
                    break;
            }
            
            return @{ @"retCode": [NSNumber numberWithInt:res], @"data": data};

        }
    }
    
    return @{ @"retCode": @-1, @"data": @""};
};

+(Response) downloadFile:(NSString*) url path: (NSString*) path fileName: (NSString*) fileName {
    
    CURL *curl;
    FILE *fp;
    CURLcode res = CURLE_OK;
    
    NSString *data = @"";
    
    const char* outFileName = [[NSString stringWithFormat:@"%@/%@", path, fileName] UTF8String];
    
    curl = curl_easy_init();
    if (curl) {
        fp = fopen(outFileName,"wb");
        if(fp) {
            curl_easy_setopt(curl, CURLOPT_URL, [url UTF8String]);
            //// Switch on full protocol/debug output while testing
            //curl_easy_setopt(curl, CURLOPT_VERBOSE, 1L);
            
            // disable progress meter, set to 0L to enable and disable debug output 
            curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 1L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYPEER, 0L);
            curl_easy_setopt(curl, CURLOPT_SSL_VERIFYHOST, 0L);
            curl_easy_setopt(curl, CURLOPT_FAILONERROR, true);
            curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, NULL);//writeToFile);
            curl_easy_setopt(curl, CURLOPT_WRITEDATA, fp);
            
            res = curl_easy_perform(curl);
            curl_easy_cleanup(curl);
            fclose(fp);
            if(res != CURLE_OK) {
                
                NSLog(@"failed to download %@, error code: %d", fileName, res);
                
                remove(outFileName);
                
                //return @{ @"retCode": [NSNumber numberWithInt:res], @"data": HTTP_MESSAGE_NETWORK_UNAVAILABLE};
                
                switch (res) {
                    case CURLE_COULDNT_RESOLVE_HOST:
                    case CURLE_COULDNT_CONNECT:
                    case CURLE_COULDNT_RESOLVE_PROXY:
                        data = HTTP_MESSAGE_NETWORK_UNAVAILABLE;// @"Unable to connect to server";
                        break;
                    default:
                        break;
                }
                
                
            }
        }
        
    } else {
        res = CURLE_FAILED_INIT;
    }
    
    return @{ @"retCode": [NSNumber numberWithInt:res], @"data": data};
}

+(Response) sendMultiPostMessage:(NSString*) url :(NSArray*) paras {//(NSString*) localFilePath {
    
    CURL* request;
    CURLcode res;
    
    
    Response ret = @{ @"retCode": @-1, @"data": @""};
    
    std::stringstream buffer;
    struct curl_httppost *formpost=NULL;
    struct curl_httppost *lastptr=NULL;
    
    request = curl_easy_init();
    if(request) {
        
        for(NSDictionary* para in paras) {
            BOOL isFile = [para[FORM_PARAMETER_ISFILE] boolValue];
            if(isFile) {
                if(para[FORM_PARAMETER_MIMETYPE] != nil) {
                    curl_formadd(&formpost,
                                 &lastptr,
                                 CURLFORM_COPYNAME, [para[FORM_PARAMETER_NAME] UTF8String],
                                 CURLFORM_CONTENTTYPE,[para[FORM_PARAMETER_MIMETYPE] UTF8String],
                                 CURLFORM_FILE, [para[FORM_PARAMETER_VALUE] UTF8String],
                                 CURLFORM_END);
                    
                } else {
                    curl_formadd(&formpost,
                                 &lastptr,
                                 CURLFORM_COPYNAME, [para[FORM_PARAMETER_NAME] UTF8String],
                                 CURLFORM_FILE, [para[FORM_PARAMETER_VALUE] UTF8String],
                                 CURLFORM_END);
                }
            } else {
                if(para[FORM_PARAMETER_MIMETYPE] != nil) {
                    curl_formadd(&formpost,
                                 &lastptr,
                                 CURLFORM_COPYNAME, [para[FORM_PARAMETER_NAME] UTF8String],
                                 CURLFORM_CONTENTTYPE,[para[FORM_PARAMETER_MIMETYPE] UTF8String],
                                 CURLFORM_COPYCONTENTS, [para[FORM_PARAMETER_VALUE] UTF8String],
                                 CURLFORM_END);
                    
                } else {
                    curl_formadd(&formpost,
                                 &lastptr,
                                 CURLFORM_COPYNAME, [para[FORM_PARAMETER_NAME] UTF8String],
                                 CURLFORM_COPYCONTENTS, [para[FORM_PARAMETER_VALUE] UTF8String],
                                 CURLFORM_END);
                }
            }
        }
        
        
        curl_easy_setopt(request, CURLOPT_HTTPPOST,formpost);
        
        curl_easy_setopt(request, CURLOPT_URL, [url UTF8String]);
        curl_easy_setopt(request, CURLOPT_TIMEOUT, 45);
        //curl_easy_setopt(request, CURLOPT_VERBOSE, 1L);
        curl_easy_setopt(request, CURLOPT_FOLLOWLOCATION, 1);
        curl_easy_setopt(request, CURLOPT_WRITEFUNCTION, writeData);
        curl_easy_setopt(request, CURLOPT_WRITEDATA, &buffer);
        
        
        res = curl_easy_perform(request);
        curl_easy_cleanup(request);
        
        if(res == CURLE_OK) {
            //NSLog(@"response: %@", [NSString stringWithUTF8String: buffer]);
            return @{ @"retCode": @0, @"data": [NSString stringWithFormat:@"%@",[NSString stringWithUTF8String: buffer.str().c_str()]]};
        }else {
            NSLog(@"error code: %d", res);
            
            return @{ @"retCode": [NSNumber numberWithInt:res], @"data": HTTP_MESSAGE_NETWORK_UNAVAILABLE};
        }
    }
    
    
    return ret;
}

@end
