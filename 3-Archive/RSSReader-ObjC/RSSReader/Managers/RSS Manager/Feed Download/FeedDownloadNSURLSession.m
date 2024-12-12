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

#import <BlackBerryDynamics/GD/NSMutableURLRequest+GDNET.h>
#import <BlackBerryDynamics/GD_C/GD_C_NETUtility.h>
#import "FeedDownloadNSURLSession.h"

#define kAuthDialog 1
#define kSSLDialog  2
#define kErrorAlertDialog 101

@interface FeedDownloadNSURLSession ()

@property (nonatomic, assign) BOOL isRelaxSSL;

@end

@implementation FeedDownloadNSURLSession


#if !(__has_feature(objc_arc))
- (void)dealloc
{
    [challenge release];
    [super dealloc];
}
#endif

#pragma mark - Request Control

/* Requests the data from a specific URL. This can trigger SSL relaxation or authentication dialogs
 */
- (void)requestData:(NSString*)url allowCellular:(BOOL)allowCellular
{
    relaxCurrentSSL = NO;
    currentURL = url;
    
    [self requestData:url relaxSSL:relaxCurrentSSL allowCellular:allowCellular];
}

- (NSURLSessionConfiguration *)getSessionConfiguration {
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfiguration.timeoutIntervalForRequest = 60.0f;
    
    return sessionConfiguration;
}

/* Internal request method that can take auth parameters and relax the SSL if required
 */
- (void)requestData:(NSString*)url relaxSSL:(BOOL)relaxSSL allowCellular:(BOOL)allowCellular
{
    NSURL* nsUrl = [NSURL URLWithString:url];
    
    // create the url/request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:nsUrl];
    request.allowsCellularAccess = allowCellular;
    request.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    //    Optionally, to use an HTTP Proxy, uncomment the code below...
    //    NSURL* proxyUrl = [NSURL URLWithString:@"http://<hostname>:<port>"];
    //    NSURLCredential* proxyCred = [NSURLCredential credentialWithUser:@"username"
    //                                                            password:@"password"
    //                                                         persistence:NSURLCredentialPersistenceForSession];
    //
    //    NSURLProtectionSpace* proxyProtSpace = [[NSURLProtectionSpace alloc]
    //                                             initWithProxyHost:[proxyUrl host]
    //                                                          port:[[proxyUrl port] integerValue]
    //                                                          type:[proxyUrl scheme]
    //                                                         realm:nil
    //                                          authenticationMethod:NSURLAuthenticationMethodHTTPDigest];
    //    [request setAuthorizationCredentials:proxyCred withProtectionSpace:proxyProtSpace];
    
    self.isRelaxSSL = relaxSSL;
    
    // reset the data buffer for the new request
    [dataBuffer setLength:0];
    
    // open the request
    currentSession = [NSURLSession sessionWithConfiguration:[self getSessionConfiguration]
                                                   delegate:self
                                              delegateQueue:nil];
    NSURLSessionDataTask *dataTask = [currentSession dataTaskWithRequest:request];
    [dataTask resume];
}

- (void)abortRequest
{
    // cancel the session if still active
    [currentSession invalidateAndCancel];
    
    // set to nil
    currentSession = nil;
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSString* authMethod = [[challenge protectionSpace] authenticationMethod];
    NSLog(@"Auth method in use: %@", authMethod);
    
    if ([authMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic] ||
        [authMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest] ||
        [authMethod isEqualToString:NSURLAuthenticationMethodNTLM] ||
        [authMethod isEqualToString:NSURLAuthenticationMethodNegotiate])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayAuthQueryDialog];
        });
#if !(__has_feature(objc_arc))
        authChallenge = [challange retain];
#else
        authChallenge = challenge;
#endif
    }
    else if ([authMethod isEqualToString:NSURLAuthenticationMethodClientCertificate])
    {
        // do nothing - GD will automatically supply an appropriate client certificate
    }
    else if ([authMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        // check SSL relaxation
        if (self.isRelaxSSL &&
            [authMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    }
    else
    {
        // this application doesn't support the specified method
        [delegate downloadDone:nil];
    }
    
    // reset the buffer
    [dataBuffer setLength:0];
}

#pragma mark - NSURLSession delegate methods

// we have data so add to the data buffer
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // Sample test code invoke GD_getFqdn API
    NSString* hostName = [self decomposeUrl:currentURL];
    char* hostFqdn = GD_getFqdn([hostName UTF8String]);
    if(hostFqdn != NULL) {
        NSString *fqdn = [[NSString alloc] initWithUTF8String:hostFqdn];
        NSLog(@"Connected to the host: %@ with FQDN: %@", hostName, fqdn);
        free(hostFqdn);
    }
    // End of test code
    
    [dataBuffer appendData:data];
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            NSInteger code = [error code];
            if (NSURLErrorServerCertificateUntrusted == code)
            {
                [self displaySSLQueryDialog];
            }
            else
            {
                // display a dialog
                [self displayDialogWithError:error];
            }
        } else {
            FeedDownloadNSURLSession *strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf.delegate downloadDone:strongSelf->dataBuffer];
                
                // reset the buffer
                [strongSelf->dataBuffer setLength:0];
                
                // set currentSession to nil to avoid problems if aborting after the session has gone away
                strongSelf->currentSession = nil;
            }
        }
    });
}

@end
