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
#import "ServiceController.h"
#import "constants.h"

@interface ServiceController ()

@property (strong, nonatomic) GDServiceClient *_goodServiceClient;
@property (strong, nonatomic) GDService *_goodService;
@property (strong, nonatomic) NSDictionary *lastFileInfo;

@end


@implementation ServiceController


NSInteger const kServiceErrorNotImplemented = -1;
NSString* const kServiceErrorNotImplementedDescription = @"The requested service, version, and method is not implemented.";

NSInteger const kEditServiceErrorInvalidRequest = 1;
NSString* const kEditServiceErrorInvalidRequestDescription = @"The request had no file attachments, or included an unknown parameter.";

NSInteger const kEditServiceErrorUnsupportFile = 2;
NSString* const kEditServiceErrorUnsupportFileDescription = @"The file in the service request is of a type that cannot be handled.";

NSInteger const kEditServiceErrorFileCorrupt = 3;
NSString* const kEditServiceErrorFileCorruptDescription = @"The file of a known format appeared incomplete or corrupt.";



-(id) init
{
    self = [super init];
    
    self._goodServiceClient = [[GDServiceClient alloc] init];
    self._goodServiceClient.delegate = self;
    // create service to receive edited file
    self._goodService = [[GDService alloc] init];
    self._goodService.delegate = self;
    return self;
}

/*
 * Error sending method
 */

+ (BOOL)sendError:(NSError*)error toApplication:(NSString*)application requestID:(NSString*)requestID
{
    NSError *goodError = nil;
    BOOL didSendErrorResponse = [GDService replyTo:application
                                        withParams:error
                                bringClientToFront:GDEPreferPeerInForeground
                                   withAttachments:nil
                                         requestID:requestID
                                             error:&goodError];
    if (!didSendErrorResponse && goodError)
    {
        // A Good run-time error occured while sending either a success or error response.
        // Display the Good run-time error.
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error"
                                                                         message:[goodError localizedDescription]
                                                                  preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        // find keyWindow
        UIWindow *keyWindow = nil;
        NSArray *windowScenes = [[UIApplication sharedApplication].connectedScenes allObjects];
        UIWindowScene *scene = [windowScenes firstObject];
        NSArray *groupOfWindows = scene.windows;
        
        for (UIWindow *window in groupOfWindows) {
            if ([window isKeyWindow]) {
                keyWindow = window;
                break;
            }
        }
        
        if (keyWindow) {
            [[keyWindow rootViewController] presentViewController:alertVC animated:YES completion:nil];
        }
    }
    
    return didSendErrorResponse;
}

/*
 * This method will test the service ID of an incoming request and consume a front request. Although the current service
 * definition only has one method we should check anyway as later versions may add methods.
 * 
 */

+ (BOOL)consumeFrontRequestService:(NSString*) serviceID
                    forApplication:(NSString*) application
                         forMethod:(NSString*) method
                       withVersion:(NSString*) version
						 requestID:(NSString*) requestID
{
    if ([serviceID isEqual:GDFrontRequestService] && [version isEqual:@"1.0.0.0"])
    {
        if ([method isEqual:GDFrontRequestMethod])
        {
            [GDService bringToFront:application completion:^(BOOL success) { } error:nil];
        }
        else
        {
            // method not supported so return an error
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue: kServiceErrorNotImplementedDescription forKey:NSLocalizedDescriptionKey];
            NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain 
                                                               code:GDServicesErrorMethodNotFound
                                                           userInfo:errorDetail];
            
            [ServiceController sendError:serviceError toApplication:application requestID:requestID];
        }
        return YES;
    }
    return NO;
}

- (void)sendServiceError:(NSError *)error
{
    // notify UI to show Service error
    NSDictionary *userInfo = @{
                               kServiceErrorKey:error,
                               };
    self.lastFileInfo = userInfo;
    NSNotification *notificationObject = [NSNotification
                                          notificationWithName:kShowServiceAlert
                                          object:self
                                          userInfo:userInfo];
    [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
}

#pragma mark - GDServiceDelegate

- (BOOL) isValidService:(NSString *)service withMethod:(NSString *)method
{
    // Check service and method
    if (![service isEqualToString:kSaveEditedFileServiceId] || ![method isEqualToString:kSaveEditMethod])
    {
        NSLog(@"Service or method not found!\n");
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue: kServiceErrorNotImplementedDescription forKey:NSLocalizedDescriptionKey];
        NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain
                                                           code:GDServicesErrorMethodNotFound
                                                       userInfo:errorDetail];
        [self sendServiceError:serviceError];
        
        return NO;
    }
    return YES;
}

- (BOOL) isParamsValid:(id)params
{
    // Check type of params
    if ([params isKindOfClass:[NSError class]])
    {
        NSLog(@"Service send error!\n");
        
        [self sendServiceError:params];
        
        return NO;
    }
    return YES;
}

- (BOOL) isAttachmentsValid:(NSArray*)attachments
{
    // Check attachments
    if (attachments && (1 == [attachments count]))
    {
        return YES;
    }
    
    NSLog(@"Error with attachments! %@\n", kEditServiceErrorInvalidRequestDescription);
    
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:kEditServiceErrorInvalidRequestDescription forKey:NSLocalizedDescriptionKey];
    NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain code:kEditServiceErrorInvalidRequest userInfo:errorDetail];
    
    [self sendServiceError:serviceError];
    
    return NO;
}

- (void) GDServiceDidReceiveFrom:(NSString*)application
                      forService:(NSString*)service
                     withVersion:(NSString*)version
                       forMethod:(NSString*)method
                      withParams:(id)params
                 withAttachments:(NSArray<NSString *> *)attachments
                    forRequestID:(NSString*)requestID
{
    // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
    // Dispatch it to the main thread as some UI updates are required.
    dispatch_async(dispatch_get_main_queue(), ^
    {
        // Check service and method
        if (![self isValidService:service withMethod:method])
        {
            return;
        }
        // Check type of params
        if (NO == [self isParamsValid:params])
        {
            return;
        }
        // Check attachments
        if (NO == [self isAttachmentsValid:attachments])
        {
            return;
        }
        
        // Get file
        NSString *filePath      = [attachments objectAtIndex:0];
        NSString *fileExtension = [filePath pathExtension];
        
        // Check file extension
        if (NSOrderedSame != [fileExtension caseInsensitiveCompare:@"txt"])
        {
            NSLog(@"Invalid extension of file! %@\n", kEditServiceErrorInvalidRequestDescription);
            
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:kEditServiceErrorUnsupportFileDescription forKey:NSLocalizedDescriptionKey];
            NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain code:kEditServiceErrorUnsupportFile userInfo:errorDetail];
            
            [self sendServiceError:serviceError];
            return;
        }
        
        
        // Notify UI to show the attached file
        NSDictionary *userInfo = @{
                                   kApplicationIDKey:application,
                                   kFilePathKey:filePath,
                                   };
        NSNotification *notificationObject = [NSNotification
                                              notificationWithName:kOpenFileForEdit
                                              object:self
                                              userInfo:userInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:notificationObject];
    });
}

#pragma mark - GDServiceClientDelegate

// isn't called, edited file is received in GDServiceDelegate methods
- (void) GDServiceClientDidReceiveFrom:(NSString*)application
                            withParams:(id)params
                       withAttachments:(NSArray*)attachments
              correspondingToRequestID:(NSString*)requestID
{
    //FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
    //Dispatch it to the main thread as some UI updates are required
    dispatch_async(dispatch_get_main_queue(), ^
    {
        NSLog(@"Client received data (%@) from application (%@)!", params, application);
        [self isParamsValid:params];
    });
}

- (void) GDServiceClientDidFinishSendingTo:(NSString*)application
                           withAttachments:(NSArray*)attachments
                                withParams:(id)params
                  correspondingToRequestID:(NSString*)requestID
{
    /*
     * The message associated with this application and request ID now has no
     * dependency on any files in the attachments list or the params object.
     * This call can therefore be used for resource cleanup.
     */
    NSLog(@"Client finished sending data to application (%@)!", application);
    
    // Clearing after self. Delete file.
    NSError *error = nil;
    if ((attachments) || (1 == [attachments count]))
    {
        NSString *filePath = [attachments objectAtIndex:0];
        [[GDFileManager defaultManager] removeItemAtPath:filePath error:&error];
        if (error)
        {
            NSLog(@"Error! Can't delete old file %@. Error: %@", filePath, error);
        }
    }
}

- (void) GDServiceClientDidStartSendingTo:(NSString*)application withFilename:(NSString*)filename
{
    /*
    * The function that is invoked can delete or modify any of the original
    * file attachments, and free any resources used to hold the request
    * parameters.
    */
    NSLog(@"Client starts sending data (%@) to application (%@)!", filename, application);
}

- (BOOL) sendSaveEditFileReqeust:(NSError**)error
                          sendTo:appId
                      withParams:(id)params
                 withAttachments:(NSArray *)attchments
                      withMethod:(NSString*) method
{
    
     return [GDServiceClient sendTo:appId
                       withService:kEditFileServiceId
                       withVersion:kFileTransferServiceVersion
                        withMethod:method
                        withParams:params
                   withAttachments:attchments
               bringServiceToFront:GDEPreferPeerInForeground
                         requestID:nil/*&requestID*/
                             error:error];
}





@end
