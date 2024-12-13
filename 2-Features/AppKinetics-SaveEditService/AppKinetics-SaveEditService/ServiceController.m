/* Copyright (c) 2023 BlackBerry Ltd.
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

#import <BlackBerryDynamics/GD/GDFileManager.h>
#import <BlackBerryDynamics/GD/GDCReadStream.h>

#import "ServiceController.h"

@interface ServiceController ()

@property (strong, nonatomic) GDService *gdService;
@property (strong, nonatomic) NSString *gdApplication;
@property (strong, nonatomic) NSString *gdRequestID;
@property (strong, nonatomic) NSString *lastReceivedText;

@end

@implementation ServiceController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _gdService = [[GDService alloc] init];
        _gdService.delegate = self;
    }
    return self;
}

#pragma mark - GDServiceDelegate

- (BOOL)sendRequest:(NSError * _Nullable * _Nullable)error newText:(NSString * _Nonnull)text sendTo:(NSString * _Nonnull)appId
{
    if (!self.gdRequestID)
    {
        NSString *descr = @"Service hasn't connected client.";
        *error = [[NSError alloc] initWithDomain:kServiceErrorDomain
                                            code:kServiceErrorClientsNotConnected
                                        userInfo:@{NSLocalizedDescriptionKey:descr}];
        return NO;
    }
    
    
    NSString *fileName = [[[NSUUID new] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSString *documentPathForFile = [self documentsDirectoryPathForFile:fileName];
    
    // Write text to secure file storage
    NSData *content = [text dataUsingEncoding:NSUTF8StringEncoding];
    BOOL fileCreated = [[GDFileManager defaultManager] createFileAtPath:documentPathForFile
                                                               contents:content
                                                             attributes:nil];
    
    if (fileCreated)
    {
        NSString *requestId = nil;
        // Send edited file 
        BOOL sendResult = [GDServiceClient sendTo:self.gdApplication
                                      withService:kSaveEditedFileServiceId
                                      withVersion:kSaveEditedFileServiceVersion
                                       withMethod:kSaveEditMethod
                                       withParams:nil
                                  withAttachments:@[documentPathForFile]
                              bringServiceToFront:GDEPreferPeerInForeground
                                        requestID:&requestId
                                            error:error];
        if (!sendResult) {
            return NO;
        }
        NSLog(@"Sent edited file with requestId %@, with path: %@", requestId, documentPathForFile);
    }
    else
    {
        NSLog(@"Failed to save a changed text to secure file storage with path: %@", documentPathForFile );
        return NO;
    }
    return YES;
}

- (void)reportErrorToServiceClient:(NSString *)application
                         requestID:(NSString *)requestID
                       withMessage:(NSString *)message
                           andCode:(NSInteger)code
{
    NSError *error;
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey : message};
    NSError *replyParams = [NSError errorWithDomain:GDServicesErrorDomain
                                               code:code
                                           userInfo:userInfo];
    
    BOOL replyResult = [GDService replyTo:application
                               withParams:replyParams
                       bringClientToFront:GDENoForegroundPreference
                          withAttachments:nil
                                requestID:requestID
                                    error:&error];
    
    if (!replyResult || error)
    {
        NSLog(@"GDServiceDidReceiveFrom failed to reply \"%@\" %ld \"%@\"", [error domain],
              (long)[error code], [error description]);
    }
    
}

- (NSString *)extractReceivedDataFromAttachments:(NSArray *)attachments
{
    NSString *localFilePath = [attachments objectAtIndex:0];
    
    NSLog(@"File for extracting: %@", localFilePath);
    
    if (![[GDFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:NULL])
    {
        [self reportErrorToServiceClient:self.gdApplication
                               requestID:self.gdRequestID
                             withMessage:[NSString stringWithFormat:@"Attachment was not found \"%@\"",
                                          localFilePath]
                                 andCode:GDServicesErrorInvalidParams];
        return @"";
    }
    
    NSData *data = [[GDFileManager defaultManager] contentsAtPath:localFilePath];
    
    if (!data)
    {
        NSString *description = [NSString stringWithFormat:@"Error reading attachment at path : %@",
                                 localFilePath];
        [self reportErrorToServiceClient:self.gdApplication
                               requestID:self.gdRequestID
                             withMessage:description
                                 andCode:GDServicesErrorInvalidParams];
        return @"";
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)GDServiceDidReceiveFrom:(NSString *)application
                     forService:(NSString *)service
                    withVersion:(NSString *)version
                      forMethod:(NSString *)method
                     withParams:(id)params
                withAttachments:(NSArray *)attachments
                   forRequestID:(NSString *)requestID
{
    // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
    // Dispatch it to the main thread as some UI updates are required.
    dispatch_async(dispatch_get_main_queue(), ^
    {
        if (![service isEqualToString:kEditFileServiceId])
        {
            [self reportErrorToServiceClient:application
                                   requestID:requestID
                                 withMessage:[NSString stringWithFormat:@"Service not found \"%@\"",
                                              service]
                                     andCode:GDServicesErrorServiceNotFound];
            return;
        }
        
        if (![method isEqualToString:kEditFileMethod])
        {
            [self reportErrorToServiceClient:application
                                   requestID:requestID
                                 withMessage:[NSString stringWithFormat:@"Method not found \"%@\"",
                                              method]
                                     andCode:GDServicesErrorMethodNotFound];
            return;
        }
        
        if (attachments.count != 1)
        {
            [self reportErrorToServiceClient:application
                                   requestID:requestID
                                 withMessage:[NSString stringWithFormat:@"Attachments should have one "
                                              "element but has %lu", (unsigned long)attachments.count]
                                     andCode:GDServicesErrorInvalidParams];
            return;
        }
        self.gdApplication = application;
        self.gdRequestID = requestID;
        
        // Load received text to textview
        NSString *text = [self extractReceivedDataFromAttachments:attachments];
        self.lastReceivedText = text;
        
        if (self.receiveTextCompletion) {
            self.receiveTextCompletion(text);
        }
         NSLog(@"Data from client is received: %@", text);
    });
}

- (NSString *)documentsDirectoryPathForFile:(NSString *)fileName
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docDir stringByAppendingPathComponent:fileName];
}

@end
