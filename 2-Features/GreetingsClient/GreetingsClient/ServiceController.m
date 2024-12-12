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


#import "ServiceController.h"
#import <BlackBerryDynamics/GD/GDFileManager.h>

@implementation ServiceController

@synthesize goodServiceClient = _goodServiceClient;
@synthesize delegate = _delegate;
@synthesize goodServiceServer = _goodServiceServer;

// error descriptions relating to the front request service
NSString* const kServiceNotImplementedDescription = @"The requested service is not implemented.";
NSString* const kMethodNotImplementedDescription = @"The requested method is not implemented.";

- (id) init
{
    self = [super init];
    
    if (self)
    {
        _goodServiceClient = [[GDServiceClient alloc] init];
        _goodServiceClient.delegate = self;
        
        _goodServiceServer = [[GDService alloc] init];
        _goodServiceServer.delegate = self;
    }
    
    return self;
}

- (void)sendErrorTo:(NSString*)application withError:(NSError*)error requestID:(NSString*)requestID
{
    NSError* goodError = nil;
    BOOL didSendErrorResponse = [GDService replyTo:application 
                                        withParams:error
                                   bringClientToFront:GDEPreferPeerInForeground
                                   withAttachments:nil
                                         requestID:requestID
                                             error:&goodError];
    if (!didSendErrorResponse)
    {
        if(goodError != nil)
        {
            // A Good run-time error occured while sending either a success or error response.
            // Display the Good run-time error.
            if(_delegate && [_delegate respondsToSelector:@selector(showAlert:)])
            {
                [_delegate showAlert:goodError];
            }
        }
    }
}

/*
 * This method will test the service ID of an incoming request and consume a front request. Although the current service
 * definition only has one method we should check anyway as later versions may add methods.
 *
 */

- (BOOL)consumeFrontRequestService:(NSString*)serviceID
					forApplication:(NSString*)application
						 forMethod:(NSString*)method
					   withVersion:(NSString*)version
						 requestID:(NSString*)requestID
{
    if([serviceID isEqual:GDFrontRequestService] && [version isEqual:@"1.0.0.0"])
    {
        if([method isEqual:GDFrontRequestMethod])
        {
            [GDServiceClient bringToFront:application completion:^(BOOL success) { } error:nil];
        }
        else
        {
            // method not supported so return an error
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue: kMethodNotImplementedDescription forKey:NSLocalizedDescriptionKey];
            NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain 
                                                               code:GDServicesErrorMethodNotFound
                                                           userInfo:errorDetail];
            
            [self sendErrorTo:application withError:serviceError requestID:requestID];
            
        }
        return YES;
    }
    return NO;
}


- (BOOL)sendRequest:(NSError**)error requestType:(ClientRequestType)type sendTo:(NSString*)appId
{
    self.lastRequest = type;
    BOOL result = NO;
    switch(type)
    {
        case GreetMe:
        {
            result = [self sendGreetMeRequestWithForegroundOption:GDEPreferMeInForeground
                                                            error:error
                                                           sendTo:appId];
        }
            break;
        case GreetMePeerInFG:
        {
            result = [self sendGreetMeRequestWithForegroundOption:GDEPreferPeerInForeground
                                                            error:error
                                                           sendTo:appId];
        }
            break;
        case GreetMeWithNoFGPref:
        {
            result = [self sendGreetMeRequestWithForegroundOption:GDENoForegroundPreference
                                                            error:error
                                                           sendTo:appId];
        }
            break;
        case BringServiceAppToFront:
        {
            result = [self bringServiceAppToFront:error sendTo:appId];
        }
            break;
        case SendFiles:
        {
            result = [self sendFilesRequest:error sendTo:appId];
        }
            break;
        case GetDateAndTime:
        {
            result = [self sendGetDateAndTimeRequest:error sendTo:appId];
        }
            break;
        default:
            NSAssert(false, @"Invalid request");
            break;
    }
    
    return result;
}

- (BOOL)sendGreetMeRequestWithForegroundOption:(GDTForegroundOption)option
                                         error:(NSError**)error
                                        sendTo:appId
{
    // Send a 'greet me' request to the Greeting Service...
    return [GDServiceClient sendTo:appId
                       withService:kGreetingsServiceId
                       withVersion:@"1.0.0"
                        withMethod:[NSString stringWithFormat:@"greetMe|%ld", option]
                        withParams:nil
                   withAttachments:nil
                   bringServiceToFront:option
                         requestID:nil
                             error:error];
}

- (BOOL)bringServiceAppToFront:(NSError**)error sendTo:appId
{
    return [GDServiceClient bringToFront:appId completion:^(BOOL success) {
        
        if (!success)
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(showAlert:)])
            {
                NSError* localError = [NSError errorWithDomain:GDServicesErrorDomain
                                                          code:GDServicesErrorApplicationNotFound
                                                      userInfo:@{NSLocalizedDescriptionKey : @"The application was not found"}];
                [self.delegate showAlert:localError];
            }
        }
        
    } error:error];
}

- (BOOL)sendFilesRequest:(NSError**)error sendTo:appId
{
    // Send two dynamically created files to the Greeting Service...
    NSString *fileName1 = @"first.txt";
    NSData* data1 = [@"This is first.txt, the first test file to send." dataUsingEncoding:NSUTF8StringEncoding];
    BOOL written =  [[GDFileManager defaultManager] createFileAtPath:[self documentsDirectoryPathForFile:fileName1] contents:data1 attributes:nil];
    
    if (written == NO)
    {
        NSLog(@"Error writting to %@", fileName1);
        return NO;
    }

    NSString *fileName2 = @"second.txt";
    NSData* data2 = [@"This is second.txt, the second test file to send." dataUsingEncoding:NSUTF8StringEncoding];
    written = [[GDFileManager defaultManager] createFileAtPath:[self documentsDirectoryPathForFile:fileName2] contents:data2 attributes:nil];
    
    if (written == NO)
    {
        NSLog(@"Error writting to %@", fileName2);
        return NO;
    }

    NSMutableArray* files = [NSMutableArray array];
    [files addObject:[self documentsDirectoryPathForFile:fileName1]];
    [files addObject:[self documentsDirectoryPathForFile:fileName2]];

    return [GDServiceClient sendTo:appId
                       withService:kGreetingsServiceId
                       withVersion:@"1.0.0"
                        withMethod:@"sendFiles"
                        withParams:nil
                   withAttachments:files
               bringServiceToFront:GDEPreferPeerInForeground
                         requestID:nil
                             error:error];
}

- (BOOL)sendGetDateAndTimeRequest:(NSError**)error sendTo:(NSString*)appId
{
    return [GDServiceClient sendTo:appId
                       withService:kDateAndTimeServiceId
                       withVersion:@"1.0.0"
                        withMethod:@"getDateAndTime"
                        withParams:nil
                   withAttachments:nil
                   bringServiceToFront:GDEPreferMeInForeground
                         requestID:nil
                             error:error];
}


- (NSString *)documentsDirectoryPathForFile:(NSString *)fileName
{
    NSString *docDir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return [docDir stringByAppendingPathComponent:fileName];
}

#pragma mark - GDServiceClientDelegate

- (void)GDServiceClientWillStartReceivingFrom:(NSString *)application
                          numberOfAttachments:(NSUInteger)attachments
                                 forRequestID:(NSString *)requestID
{
    NSLog(@"GDServiceClientWillStartReceivingFrom:numberOfAttachments: %lu forRequestID: %@", (unsigned long)attachments, requestID);
}

- (void)GDServiceClientWillStartReceivingFrom:(NSString *)application
                               attachmentPath:(NSString *)path
                                     fileSize:(NSNumber *)size
                                 forRequestID:(NSString *)requestID
{
    NSLog(@"GDServiceClientWillStartReceivingFrom:attachmentPath: %@ fileSize: %@ forRequestID: %@", path, size, requestID);
}

- (void)GDServiceClientDidReceiveFrom:(NSString*)application
                           withParams:(id)params
                      withAttachments:(NSArray*)attachments
             correspondingToRequestID:(NSString*)requestID
{
    // FUTURE: AppKinetics callbacks will be moved to background queue in upcoming releases.
    // Dispatch it to the main thread as some UI updates are required.
    dispatch_async(dispatch_get_main_queue(), ^{
        if([params isKindOfClass:[NSString class]] || [params isKindOfClass:[NSError class]])
        {
            if(self.delegate && [self.delegate respondsToSelector:@selector(showAlert:)])
            {
                [self.delegate showAlert:params];
            }
        }
    });
}

- (void)GDServiceClientDidFinishSendingTo:(NSString*)application
                          withAttachments:(NSArray*)attachments
                               withParams:(id)params
                 correspondingToRequestID:(NSString*)requestID
{
    /*
     * The message associated with this application and request ID now has no 
     * dependency on any files in the attachments list or the params object. 
     * This call can therefore be used for resource cleanup.
     */
}

#pragma mark - GDServiceDelegate

- (void)GDServiceWillStartReceivingFrom:(NSString *)application
                    numberOfAttachments:(NSUInteger)attachments
                           forRequestID:(NSString *)requestID
{
    NSLog(@"GDServiceWillStartReceivingFrom:numberOfAttachments: %lu forRequestID: %@", (unsigned long)attachments, requestID);
}

- (void)GDServiceWillStartReceivingFrom:(NSString *)application
                         attachmentPath:(NSString *)path
                               fileSize:(NSNumber *)size
                           forRequestID:(NSString *)requestID
{
    NSLog(@"GDServiceWillStartReceivingFrom:attachmentPath: %@ fileSize: %@ forRequestID: %@", path, size, requestID);
}

/*
 * A request for Service has been received. We only support the front request service so check for that. If
 * its not then return an error as this is all we can process.
 */
- (void)GDServiceDidReceiveFrom:(NSString*)application
                     forService:(NSString*)service
                    withVersion:(NSString*)version
                      forMethod:(NSString*)method
                     withParams:(id)params
                withAttachments:(NSArray*)attachments
                   forRequestID:(NSString*)requestID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self processRequestForApplication:application
                                forService:service
                               withVersion:version
                                 forMethod:method
                                withParams:params
                           withAttachments:attachments
                              forRequestID:requestID
                      ];}); 
}

- (void)processRequestForApplication:(NSString*)application
                          forService:(NSString*)service
                         withVersion:(NSString*)version
                           forMethod:(NSString*)method
                          withParams:(id)params
                     withAttachments:(NSArray*)attachments
                        forRequestID:(NSString*)requestID
{
    
    // Check for and possibly consume a front request
    if(![self consumeFrontRequestService:service forApplication:application forMethod:method withVersion:version requestID:requestID])
    {        // send error reply
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:kServiceNotImplementedDescription
                       forKey:NSLocalizedDescriptionKey];
        NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain 
                                                           code:GDServicesErrorServiceNotFound
                                                       userInfo:errorDetail];
        
        [self sendErrorTo:application withError:serviceError requestID:requestID];
        
    }
}

@end
