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
#import "constants.h"
#import <BlackBerryDynamics/GD/GDFileManager.h>

@implementation ServiceController
{
    GDService *_gdService;
}

@synthesize delegate = _delegate;

NSInteger const kGreetingsServiceErrorNotImplemented = -1;
NSString* const kGreetingsServiceErrorNotImplementedDescription = @"The requested service, version, and method is not implemented.";


- (id)init
{
    self = [super init];
    
    if (self)
    {
        _gdService = [[GDService alloc] init];
        [_gdService setDelegate:self];
    }
    
    return self;
}

/*
 * Error sending method
 */
- (void)sendError:(NSError*)error toApplication:(NSString*)application requestID:(NSString*)requestID
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
            [GDService bringToFront:application completion:^(BOOL success) { } error:nil];
        }
        else
        {
            // method not supported so return an error
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue: kGreetingsServiceErrorNotImplementedDescription forKey:NSLocalizedDescriptionKey];
            NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain
                                                               code:GDServicesErrorMethodNotFound
                                                           userInfo:errorDetail];
            
            [self sendError:serviceError toApplication:application requestID:requestID];
            
        }
        return YES;
    }
    return NO;
}

#pragma mark - GD Service Delegate method

- (void)GDServiceDidFinishSendingTo:(NSString*)application
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

- (void)GDServiceDidReceiveFrom:(NSString*)application
                     forService:(NSString*)service
                    withVersion:(NSString*)version
                      forMethod:(NSString*)method
                     withParams:(id)params
                withAttachments:(NSArray*)attachments
                   forRequestID:(NSString*)requestID
{
    // A request for Service has been received. Dispatch it for servicing and return immediately
    // so as not to block the Good run-time. This mechanism may be moved into the Good run-time in the near
    // future.
    
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
    NSError* goodError = nil;
    BOOL requestProcessed = NO;
    
    // Check for and possibly consume a front request
    if(![self consumeFrontRequestService:service forApplication:application forMethod:method withVersion:version requestID:requestID])
    {
        
        if ([service isEqual:kGreetingsServiceId])
        {
            requestProcessed = [self processGreetingsService:application
                                                 withVersion:version
                                                   forMethod:method
                                                  withParams:params
                                             withAttachments:attachments
                                                forRequestID:requestID
                                                   goodError:&goodError];
        }
        else if ([service isEqual:kTDateAndTimeServiceId])
        {
            requestProcessed = [self processDateAndTimeServiceRequest:application
                                                          withVersion:version
                                                            forMethod:method
                                                           withParams:params
                                                      withAttachments:attachments
                                                         forRequestID:requestID
                                                                error:&goodError];
        }
        
        if (!requestProcessed && nil == goodError)
        {
            // An unexpected request was received. Construct and return a Greeting Service
            // error response.
            
            NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
            [errorDetail setValue:kGreetingsServiceErrorNotImplementedDescription forKey:NSLocalizedDescriptionKey];
            NSError* serviceError = [[NSError alloc] initWithDomain:GDServicesErrorDomain code:GDServicesErrorServiceNotFound userInfo:errorDetail];
            
            [self sendError:serviceError toApplication:application requestID:requestID];
        }
    }
}

- (BOOL)processGreetingsService:(NSString*)application
                    withVersion:(NSString*)version
                      forMethod:(NSString*)method
                     withParams:(id)params
                withAttachments:(NSArray*)attachments
                   forRequestID:(NSString*)requestID
                      goodError:(NSError**)goodError
{
    
    BOOL requestProcessed = NO;
    if ([version isEqual:@"1.0.0"])
    {
        if ([method hasPrefix:@"greetMe"])
        {
            // This is an expected request. Send the response. And cause the client to move to
            // the foreground.
            NSString *parameter = [[method componentsSeparatedByString:@"|"] lastObject];
            GDTForegroundOption option = (GDTForegroundOption)[parameter integerValue];
            
            requestProcessed = [GDService replyTo:application
                                       withParams:@"G'day mate!"
                               bringClientToFront:option != GDEPreferPeerInForeground ? GDEPreferPeerInForeground : GDEPreferMeInForeground
                                  withAttachments:nil
                                        requestID:requestID
                                            error:goodError];
        }
        else if ([method isEqual:@"sendFiles"])
        {
            // This is an expected request.
            // We don't send a response - we just display the file list in an alert.
            
            NSMutableString *filesString = [NSMutableString stringWithCapacity:20];
            
            for (NSString *filePath in attachments)
            {
                NSError *error = nil;
                NSDictionary *fileAttributes = [[GDFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                
                if (fileAttributes)
                {
                    [filesString appendFormat:@"%@", filePath];
                    [filesString appendFormat:@" (%@ bytes)\n", [fileAttributes valueForKey:@"NSFileSize"]];
                    NSData *fileData = [[GDFileManager defaultManager] contentsAtPath:filePath];
                    if (fileData)
                    {
                        NSLog(@"Filepath: %@", filePath);
                        NSString *dataString = [[NSString alloc] initWithData:fileData
                                                                     encoding:NSUTF8StringEncoding];
                        NSLog(@"Data    : %@", dataString);
                    }
                    if (error)
                    {
                        NSLog(@"%@", error);
                    }
                }
            }
            
            if(_delegate && [_delegate respondsToSelector:@selector(showAlert:)])
            {
                [_delegate showAlert:filesString];
            }
            
            requestProcessed = YES;
        }
    }
    
    return requestProcessed;
}

- (BOOL)processDateAndTimeServiceRequest:(NSString*)application
                             withVersion:(NSString*)version
                               forMethod:(NSString*)method
                              withParams:(id)params
                         withAttachments:(NSArray*)attachments
                            forRequestID:(NSString*)requestID
                                   error:(NSError**)goodError
{
    // reply to service consumer with formatted string of current time
    BOOL didSendResponse = NO;
    if ([version isEqual:@"1.0.0"])
    {
        NSDate *now = [NSDate date];
        NSDateFormatter *dateFromat = [[NSDateFormatter alloc] init];
        [dateFromat setDateFormat:@"MM/dd/yyyy hh:mma"];
        NSString* dateString = [dateFromat stringFromDate:now];
        
        didSendResponse = [GDService replyTo:application
                                  withParams:dateString
                          bringClientToFront:GDEPreferPeerInForeground
                             withAttachments:nil
                                   requestID:requestID
                                       error:goodError];
    }
    
    return didSendResponse;
}

@end
