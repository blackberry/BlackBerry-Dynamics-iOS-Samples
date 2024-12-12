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

#import "FileTransferService.h"
#import <BlackBerryDynamics/GD/GDServices.h>
#import <BlackBerryDynamics/GD/GDFileManager.h>
#import "GDServiceRequest.h"

@interface FileTransferService () <GDServiceClientDelegate, GDServiceDelegate>

@property (strong, nonatomic) GDServiceClient *goodServiceClient;
@property (strong, nonatomic) GDService *goodService;
@property (strong, nonatomic, readwrite) NSDictionary *lastFileInfo;

@end

@implementation FileTransferService

#pragma mark - Lifecycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.goodServiceClient = [[GDServiceClient alloc] init];
        self.goodServiceClient.delegate = self;
        self.goodService = [[GDService alloc] init];
        self.goodService.delegate = self;
    }
    return self;
}

#pragma mark - GDServiceClientDelegate

- (void) GDServiceClientDidReceiveFrom:(NSString*)application
                            withParams:(id)params
                       withAttachments:(NSArray*)attachments
              correspondingToRequestID:(NSString*)requestID
{
    // For now, simply log the request made...
    NSLog(@"%s Called with parameters \n\tapplication:(%@) \n\tparams:(%@) \n\tattachments(y/n):(%@) \n\trequestID:(%@)", __PRETTY_FUNCTION__, application, params ? @"YES" : @"NO", attachments ? @"YES" : @"NO", requestID);
    
    // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
    // Dispatch it to the main thread as some UI updates are required.
    dispatch_async(dispatch_get_main_queue(), ^ {
        if([params isKindOfClass:[NSError class]])
        {
            NSError *error = (NSError *)params;
            [self sendServiceError:error];
        }
    });
}

#pragma mark - GDServiceDelegate

// This GD delegate call will be called when the service sends a file to us.
- (void)GDServiceDidReceiveFrom:(NSString*)application
                     forService:(NSString*)service
                    withVersion:(NSString*)version
                      forMethod:(NSString*)method
                     withParams:(id)params
                withAttachments:(NSArray*)attachments
                   forRequestID:(NSString*)requestID
{
        // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
        // Dispatch it to the main thread as some UI updates are required.
        dispatch_async(dispatch_get_main_queue(), ^ {
            GDServiceRequest *request = [[GDServiceRequest alloc] initWithApplication:application
                                                                              service:service
                                                                              version:version
                                                                               method:method
                                                                               params:params
                                                                          attachments:attachments
                                                                            requestID:requestID];
            NSError *error = nil;
            if (![request isServiceValid:&error] ||
                ![request isMethodValid:&error] ||
                ![request isParametersValid:&error] ||
                ![request isAttachmentsValid:&error]) {
                [self sendServiceError:error];
            } else
            {
                NSString *filePath = attachments.firstObject;
                NSString *fileName = [filePath lastPathComponent];
                NSString *localFilePathToSave = [[self documentsFolderPath] stringByAppendingPathComponent:fileName];
                if ([[GDFileManager defaultManager] fileExistsAtPath:localFilePathToSave isDirectory:nil]) {
                    [self sendNotification:kFileCollisionKey
                             forFileAtPath:filePath
                                pathToSave:localFilePathToSave];
                    return;
                }
                
                [self sendNotification:kSaveFileMethodKey
                         forFileAtPath:filePath
                            pathToSave:localFilePathToSave];
            }
          
            // Lastly, we reply to the sender with the replyParams and a nil attachment
            NSError *replyErr;
            BOOL replyOK = [GDService replyTo:application
                                  withParams:error
                          bringClientToFront:GDENoForegroundPreference
                             withAttachments:nil
                                   requestID:requestID
                                       error:&replyErr];
            // If the reply failed, we simply log it in this example
            if (!replyOK)
            {
                NSLog(@"%s failed to reply \"%@\" %ld \"%@\"", __PRETTY_FUNCTION__, [replyErr domain], (long)[replyErr code],
                      [replyErr description]);
            }
        });
}

#pragma mark - Notifications

- (void)sendServiceError:(NSError *)error
{
    // notify UI to show Service error
    NSDictionary *userInfo = @{
                               kServiceErrorKey:error,
                               };
    self.lastFileInfo = userInfo;
    NSNotification *notificationObject = [NSNotification notificationWithName:kShowServiceAlert
                                                                       object:self
                                                                     userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

- (void)sendNotification:(NSString *)notification
           forFileAtPath:(NSString *)path
              pathToSave:(NSString *)pathToSave
{
    NSDictionary *userInfo = @{
                               kFilePathKey:path,
                               kNewFilePathKey:pathToSave,
                               };
    self.lastFileInfo = userInfo;
    NSNotification *notificationObject = [NSNotification
                                          notificationWithName:notification
                                          object:self
                                          userInfo:userInfo];

    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

#pragma mark - Helpers

- (NSString*)documentsFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

@end
