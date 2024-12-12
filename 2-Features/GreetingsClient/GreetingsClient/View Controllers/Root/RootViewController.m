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

#import <BlackBerryDynamics/GD/GDiOS.h>
#import <BlackBerryDynamics/GD/GDServiceProvider.h>

#import "ServiceController.h"
#import "AppDelegate.h"
#import "constants.h"
#import "GreetingsClientGDiOsDelegate.h"
#import "UIAccessibilityIdentifiers.h"
#import <BlackBerryDynamics/GD/GDServices.h>

@interface ServiceInfo : NSObject
@property (strong, nonatomic) NSString* serviceId;
@property (strong, nonatomic) NSString* applicationId;
@property (strong, nonatomic) UIButton* button;

- (id)initWithServiceId:(NSString*)serviceId andButton:(UIButton*)button;

@end

@implementation ServiceInfo

@synthesize serviceId = _serviceId;
@synthesize applicationId = _applicationId;
@synthesize button = _button;

- (id)initWithServiceId:(NSString*)serviceId andButton:(UIButton*)button
{
    self = [super init];
    
    if (self)
    {
        self.serviceId = serviceId;
        self.button = button;
        self.button.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.button.titleLabel.numberOfLines = 2;
    }
    
    return self;
}

@end

@interface RootViewController()

@property (strong, nonatomic) NSMutableArray<UIAlertController*>* alerts;

@end

@implementation RootViewController
{
    NSArray *serviceButtons;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = GRCMainViewID;
    self.settingsButton.accessibilityIdentifier = GRCSettingsButtonID;
    self.bringToFrontButton.accessibilityIdentifier = GRCBringToFrontButtonID;
    self.sayHelloButton.accessibilityIdentifier = GRCSayHelloButtonID;
    self.sayHelloPeerInFG.accessibilityIdentifier = GRCSayHelloPeerInFGButtonID;
    self.sayHelloNoFG.accessibilityIdentifier = GRCSayHelloNoFGButtonID;
    self.sendFilesButton.accessibilityIdentifier = GRCSendFilesButtonID;
    self.testServiceButton.accessibilityIdentifier = GRCGetDateButtonID;
    
    //Change navigation bar title and tint
    [self setTitle:@"Greetings Client"];
    [self.navigationController.navigationBar setTintColor:maincolor];
    
    // map the UI buttons and service Ids
    serviceButtons = [NSArray arrayWithObjects:[[ServiceInfo alloc] initWithServiceId:kDateAndTimeServiceId andButton:_testServiceButton],
                      nil];
    
    // Get available service providers for each service and update buttons.
    [self processProviderDetails];

    [GreetingsClientGDiOSDelegate sharedInstance].rootViewController = self;
    [GreetingsClientGDiOSDelegate sharedInstance].serviceController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Listen for Service Config changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(serviceConfigDidChange:) name:kServiceConfigDidChangeNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //Stop listening for changes to Service Config
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
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
        alert.view.accessibilityIdentifier = GRCSuccessReplyAlertID;
    }
    else if ([serviceReply isKindOfClass:[NSError class]])
    {
        alert = [self alertViewForError:serviceReply];
    }
    else
    {
        // The Greeting Service returned an unexpected response...
        alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:@"Not implemented."
                                             preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                          
          //Cleanup
          [self.alerts removeObject:alert];
          
          //Continue showing remaining alerts
          if(self.alerts.count > 0)
          {
              [self showNextAlert];
          }
    }];
    
    [alert addAction:defaultAction];
    
    
    //Add the alert to the queue
    if(!_alerts) _alerts = [NSMutableArray new];
    
    [_alerts addObject:alert];
    if(_alerts.count == 1 )
    {
        //If there's no active alert queue then call show
        [self showNextAlert];
    }
}

- (UIAlertController *)alertViewForError:(NSError *)error
{
    // The Greeting Service returned a defined error response...
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[error domain]
                                                                   message:[error localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    alert.view.accessibilityIdentifier = GRCFailureReplyAlertID;
    
    if (error.code == GDServicesErrorProcessSuspended)
    {
        [alert addAction:[UIAlertAction actionWithTitle:@"Retry"
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
            NSError* serviceRequestError = nil;
            ServiceController* serviceController = [GreetingsClientGDiOSDelegate sharedInstance].serviceController;
            [serviceController sendRequest:&serviceRequestError
                               requestType:serviceController.lastRequest
                                    sendTo:kGreetingsServerAppId];
        }]];
    }
    
    return alert;
}

- (void)showNextAlert
{
    if(!_alerts || _alerts.count <= 0)
    {
        return;
    }
    
    UIAlertController* firstAlert = [_alerts firstObject];
    if(!firstAlert)
    {
        return;
    }
    
    [self presentViewController:firstAlert animated:YES completion:NULL];
}

#pragma mark - Buttons Actions
- (IBAction)sayHelloToGreetingsServiceButtonOnTouchUpInside:(UIButton *)sender
{
    NSError* serviceRequestError = nil;
    
    ServiceController* serviceController = [GreetingsClientGDiOSDelegate sharedInstance].serviceController;
    
    // send a 'Greet me' request to the Greetings Server...
    BOOL didSendRequest;
    if (sender == self.sayHelloButton) {
        didSendRequest = [serviceController sendRequest:&serviceRequestError requestType:GreetMe sendTo:kGreetingsServerAppId];
    } else if (sender == self.sayHelloPeerInFG) {
        didSendRequest = [serviceController sendRequest:&serviceRequestError requestType:GreetMePeerInFG sendTo:kGreetingsServerAppId];
    } else {
        didSendRequest = [serviceController sendRequest:&serviceRequestError requestType:GreetMeWithNoFGPref sendTo:kGreetingsServerAppId];
    }

    if (NO == didSendRequest)
    {
        // The request could not be sent...
        [self showErrorAlert:serviceRequestError];
    }
}

- (IBAction)bringGreetingsServiceToFrontButtonOnTouchUpInside:(id)sender
{
    NSError* serviceRequestError = nil;

    ServiceController* serviceController = [GreetingsClientGDiOSDelegate sharedInstance].serviceController;
    
    //Send a request to bring the Greetings Server app to the front
    BOOL didBringToFront = [serviceController sendRequest:&serviceRequestError requestType:BringServiceAppToFront sendTo:kGreetingsServerAppId];
    
    if (NO == didBringToFront)
    {
        [self showErrorAlert:serviceRequestError];
    }
}

- (IBAction)sendFilesToGreetingsServiceButtonOnTouchUpInside:(id)sender
{
    NSError* serviceRequestError = nil;

    ServiceController* serviceController = [GreetingsClientGDiOSDelegate sharedInstance].serviceController;
    
    // request files be sent to the Greetings Server...
    BOOL didRequestFilesToBeSent = [serviceController sendRequest:&serviceRequestError requestType:SendFiles sendTo:kGreetingsServerAppId];

    if (NO == didRequestFilesToBeSent)
    {
        // The request could not be sent...
        [self showErrorAlert:serviceRequestError];
    }
}

- (IBAction)getDateFromService:(id)sender
{
    NSError* serviceRequestError = nil;
    
    ServiceController* serviceController = [GreetingsClientGDiOSDelegate sharedInstance].serviceController;
    
    // request date and Time from the service provider
    BOOL didRequestDateAndTime = [serviceController sendRequest:&serviceRequestError requestType:GetDateAndTime sendTo:kGreetingsServerAppId];
    
    if (NO == didRequestDateAndTime)
    {
        [self showErrorAlert:serviceRequestError];
    }
}

- (void)showErrorAlert:(NSError*)serviceError
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showErrorAlert:) withObject:serviceError waitUntilDone:NO];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"An error occurred."
                                                                   message:[serviceError localizedDescription]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Service Config change notifications
- (void)serviceConfigDidChange:(NSNotification*)notification
{
    [self processProviderDetails];
}

- (void)processProviderDetails
{
   AppDelegate *appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    for(ServiceInfo* serviceInfo in serviceButtons)
    {
        // query the service provider details for this service
        NSArray* providers = [appDel getProvidersForService:serviceInfo.serviceId];
        
        // enable button if service provider is available for this service
        if([providers count] > 0)
        {
            [serviceInfo.button setEnabled:YES];
            [serviceInfo.button setAlpha:1.0];
            
            // map the app id to the service button
            GDServiceProvider *appService = [providers objectAtIndex:0];
            serviceInfo.applicationId = [appService identifier];
        }
        else
        {
            [serviceInfo.button setEnabled:NO];
            [serviceInfo.button setAlpha:0.4];
            
            serviceInfo.applicationId = nil;
        }
    }
}

@end
