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

#import "RootViewController.h"
#import "ServiceController.h"
#import "GreetingsServerGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"

@interface RootViewController(private)

- (void)processRequestForApplication:(NSString*)application
                          forService:(NSString*)service
                         withVersion:(NSString*)version
                           forMethod:(NSString*)method
                          withParams:(id)params
                     withAttachments:(NSArray*)attachments
                        forRequestID:(NSString*)requestID;
@end

@implementation RootViewController

@synthesize detailNavController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = GRSMainViewID;
    self.bringToFrontButton.accessibilityIdentifier = GRSBringToFrontButtonID;
    
    [GreetingsServerGDiOSDelegate sharedInstance].serviceController.delegate = self;
    [GreetingsServerGDiOSDelegate sharedInstance].rootViewController = self;
}

#pragma mark - ServiceControllerDelegate Methods
- (void)showAlert:(id)serviceReply
{
    UIAlertController *alert = nil;
    if ([serviceReply isKindOfClass:[NSString class]])
    {
        alert = [UIAlertController alertControllerWithTitle:@"Success"
                                                    message:serviceReply
                                             preferredStyle:UIAlertControllerStyleAlert];
        alert.view.accessibilityIdentifier = GRSSuccessAlertID;
        
    }
    else if ([serviceReply isKindOfClass:[NSError class]])
    {
        NSError* error = (NSError*)serviceReply;
        // The Greeting Service returned a defined error response...
        alert = [UIAlertController alertControllerWithTitle:[error domain]
                                                    message:[error localizedDescription]
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    else
    {
        // The Greeting Service returned an unexpected response...
        alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:@"Not implemented."
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Buttons Actions

- (IBAction)bringGreetingsClientToFrontButtonOnTouchUpInside:(id)sender
{
    NSError* error = nil;
    [GDServiceClient bringToFront:kGreetingsClientAppId completion:^(BOOL success) {
        if (!success)
        {
            NSError* localError = [NSError errorWithDomain:GDServicesErrorDomain
                                                      code:GDServicesErrorApplicationNotFound
                                                  userInfo:@{NSLocalizedDescriptionKey : @"The application was not found"}];
            [self showErrorAlert:localError];
        }
    } error:&error];
}


#pragma mark - helpers

- (void)showErrorAlert:(NSError*)goodError
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showErrorAlert:) withObject:goodError waitUntilDone:NO];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error occurred."
                                                                   message:[goodError localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
