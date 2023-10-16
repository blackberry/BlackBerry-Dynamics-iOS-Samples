  
/* Copyright (c) 2020 BlackBerry Limited.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#import "GDURLSchemeHandler.h"
#import <BlackBerryDynamics/GD/GDFileManager.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kBufferSize (64 * 1024)

@implementation GDURLSchemeHandler

- (NSInteger)getContentLengthForFilePath:(NSString *)filePath {
    NSError *error;
    if ([[GDFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSDictionary *fileAttribDict = [[GDFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        NSNumber *filesize = [fileAttribDict objectForKey:NSFileSize];
        return [filesize integerValue];
    } else {
        return -1;
    }
    return -1;
}

- (NSData *)getFileDataForFilePath:(NSString *)filePath {
    NSInteger contentLength = [self getContentLengthForFilePath: filePath];
    if (contentLength == -1) {
        return nil;
    }
    NSError *error = nil;
    NSInputStream *inputStream = [GDFileManager getReadStream:filePath error:&error];
    
    if (error != nil) {
       // NSLog(@"Error opening read stream to file %@: %@", filePath, error);
    }
    if (inputStream != nil) {
        NSMutableData *fileData = [[NSMutableData alloc] init];
        while ([inputStream hasBytesAvailable])
        {
            uint8_t buffer[kBufferSize] = {0};
            NSInteger inRead = [inputStream read:buffer maxLength:kBufferSize];
            NSData *dataChunk = [[NSData alloc] initWithBytes:buffer length:inRead];
            [fileData appendData:dataChunk];
        }
        [inputStream close];
    
        return fileData;
    } else {
        return nil;
    }
}

- (void)webView:(nonnull WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask  API_AVAILABLE(ios(11.0)){
    NSURLRequest *request = urlSchemeTask.request;
    NSString *truePath = request.URL.standardizedURL.path;
    NSURL *requestURL = request.URL;
    NSInteger fileSize = [self getContentLengthForFilePath:truePath];
    NSString *mimeType = [self getMIMEType:requestURL.pathExtension];
    NSURLResponse *response = [[NSURLResponse alloc] initWithURL:requestURL MIMEType:mimeType expectedContentLength:fileSize textEncodingName:nil];
    NSData *fileData = [self getFileDataForFilePath:truePath];
    [urlSchemeTask didReceiveResponse:response];
    if (fileData != nil) {
        [urlSchemeTask didReceiveData:fileData];
    }
    [urlSchemeTask didFinish];
    
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    
}

- (NSString *)getMIMEType:(NSString *)fileExtension {
    if (nil == fileExtension) {
        return nil;
    }
    NSString *mimeType = nil;
    fileExtension = fileExtension.lowercaseString;
    if ([fileExtension isEqualToString:@"rtf"]) {
        mimeType = @"application/rtf";
    } else if ([fileExtension isEqualToString:@"numbers"]) {
        mimeType = @"application/x-iwork-numbers-sffnumbers";
    } else if ([fileExtension isEqualToString:@"pages"]) {
        mimeType = @"application/x-iwork-pages-sffpages";
    } else if ([fileExtension isEqualToString:@"keynote"]) {
        mimeType = @"application/x-iwork-keynote-sffkey";
    } else if ([fileExtension isEqualToString:@"log"]) {
        mimeType = @"text/x-log";
    } else {
        CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)fileExtension, NULL);
        CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
        CFRelease(UTI);
        mimeType = (__bridge_transfer NSString *)MIMEType;
    }
    
    return mimeType;
}

@end
