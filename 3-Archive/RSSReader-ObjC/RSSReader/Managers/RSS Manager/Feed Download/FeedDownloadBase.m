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

#import "FeedDownloadBase.h"


@interface FeedDownloadBase()<FeedDownloadProtocol>

@property (nonatomic, weak) UIViewController* alertPresenter;

@end
@implementation FeedDownloadBase

@synthesize delegate;

- (instancetype)initWithAlertPresenter:(UIViewController*) parentViewControler
{
    self = [super init];
    if (self) {
        _alertPresenter = parentViewControler;
        dataBuffer = [[NSMutableData alloc] init];
    }
    return self;
}

// should not be called as we are overriding the class
- (void)requestData:(NSString*)url allowCellular:(BOOL)allowCellular
{
    NSLog(@"Base class %@ called",NSStringFromSelector(_cmd));
}

- (void)abortRequest
{
    NSLog(@"Base class %@ called",NSStringFromSelector(_cmd));
}

- (void)requestData:(NSString*)url relaxSSL:(BOOL)relaxSSL allowCellular:(BOOL)allowCellular
{
     NSLog(@"Base class %@ called",NSStringFromSelector(_cmd));
}

- (NSString*) decomposeUrl:(NSString *) url
{
    NSURL *theURL = [NSURL URLWithString:url];
    if(theURL)
        return theURL.host;
    return nil;
}

- (void)displayDialogWithError:(NSError*)error
{
    // display a dialog
    NSString* str = [error localizedDescription];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error Fetching File" message:str preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (weakSelf.delegate) {
            [weakSelf.delegate downloadDone:nil];
        }
    }]];
    
    [self.alertPresenter presentViewController:alertVC
                                      animated:YES
                                    completion:nil];
}

/*
 * This method displays a dialog allowing the user allow relaxation of certificate verification
 */
- (void)displaySSLQueryDialog
{
    // create an alert view to query certificate verification
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"SSl Certificate Error"
                                                                     message:@"Relax certificate verification for this site ?\n"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        FeedDownloadBase *strongSelf = weakSelf;
        // set the url
        if (strongSelf) {
            strongSelf->relaxCurrentSSL = YES;
            [weakSelf requestData:strongSelf->currentURL relaxSSL:strongSelf->relaxCurrentSSL allowCellular:YES];
        }
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self.alertPresenter presentViewController:alertVC
                                      animated:YES
                                    completion:nil];
}

#pragma mark - Invoke Auth Query Dialog
/*
 * This method displays a dialog allowing the user to enter a user id and password
 */
- (void)displayAuthQueryDialog
{
    // create an alert view with our user and password fields
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Enter ID and Password"
                                                                     message:@""
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    __weak typeof(self) weakSelf = self;
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // setup the credentials using session cache (in memory)
        FeedDownloadBase *strongSelf = weakSelf;
        if (strongSelf) {
            NSURLCredential* cred = [NSURLCredential credentialWithUser:strongSelf->userNameField.text
                                                               password:strongSelf->passwordField.text
                                                            persistence:NSURLCredentialPersistenceForSession];
            [[strongSelf->authChallenge sender] useCredential:cred forAuthenticationChallenge:strongSelf->authChallenge];
            
            strongSelf->authChallenge = nil;
        }
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // We don't have any credentials so continue without
        FeedDownloadBase *strongSelf = weakSelf;
        if (strongSelf) {
            [[strongSelf->authChallenge sender] continueWithoutCredentialForAuthenticationChallenge:strongSelf->authChallenge];
            strongSelf->authChallenge = nil;
        }
    }]];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Login";
        FeedDownloadBase *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->userNameField = textField;
        }
    }];
    
    [alertVC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = YES;
        FeedDownloadBase *strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf->passwordField = textField;
        }
    }];
    
    [self.alertPresenter presentViewController:alertVC
                                      animated:YES
                                    completion:nil];
}
@end
