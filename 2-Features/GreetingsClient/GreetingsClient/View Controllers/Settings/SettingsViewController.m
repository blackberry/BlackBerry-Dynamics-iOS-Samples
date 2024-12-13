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

#import "SettingsViewController.h"
#import <BlackBerryDynamics/GD/GDLogManager.h>
#import <BlackBerryDynamics/GD/GDiOS.h>
#import <BlackBerryDynamics/GD/GDDiagnostic.h>
#import "UIAccessibilityIdentifiers.h"

@implementation SettingsViewController

bool userEnabledLogging = false;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = GRCAboutViewID;
    
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"Settings"];
    
    [self updateStatusText];
    
    //Only add tap dismiss on iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        //Dismiss on tapping anywhere except over buttons or segmented controllers (see gesture recognizer methods)
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSettings:)];
        [tapGesture setDelegate:self];
        [self.view addGestureRecognizer:tapGesture];
    }
}

- (void)dealloc
{
    // Release any retained subviews of the main view.
    self.requestSegControl = nil;
    self.uploadLogsButton = nil;
    self.requestAPILabel = nil;
    self.troubleshootLabel = nil;
}

//For iPhone
#pragma mark - tap dismiss
- (void)dismissSettings:(UITapGestureRecognizer*)tapGesture
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - gesture recognizers
//Dismiss on tapping anywhere except over buttons or segmented controllers
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if(![_detailedLoggingButton isEnabled] || [touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UISegmentedControl class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - actions
- (IBAction)requestAPIChanged:(id)sender
{
    //Change current request mode
}

- (IBAction)uploadLogsPressed:(id)sender
{
        [[GDLogManager sharedInstance] openLogUploadUI];
}

- (IBAction)detailedLoggingPressed:(id)sender
{
    NSTimeInterval duration = userEnabledLogging ? 0 : 60;
    [_detailedLoggingButton setTitle:userEnabledLogging ? @"Turn ON User Detailed Logging for 60s" : @"Turn OFF User Detailed Logging" forState:UIControlStateNormal];
    
    bool result = [[GDLogManager sharedInstance] detailedLoggingFor: duration];
    NSLog(@"GDLogManager detailedLoggingFor called with success: %@", result ? @"true" : @"false");
    
    if (!userEnabledLogging)
    {
        // user successfully enabled user logging
        userEnabledLogging = result;
    }
    else
    {
        // user tried to turn off detailed logging, so toggle back to false only if it succeeded.
        userEnabledLogging = !result;
    }
    
    [self updateStatusText];
}

- (IBAction)refreshLoggingStatusPressed:(id)sender
{
    [self updateStatusText];
}

- (IBAction)getApplicationConfig:(id)sender
{
    NSDictionary* config = [[GDiOS sharedInstance] getApplicationConfig];
    NSString* configString = [NSString stringWithFormat:@"%@", config];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Application Configurations"
                                                                     message:configString
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
     
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)getDiagnosticSettings:(id)sender
{
    NSString* info = [[GDDiagnostic sharedInstance] currentSettings];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Diagnostic Settings"
                                                                     message:info
                                                              preferredStyle:UIAlertControllerStyleAlert];
    
    alertVC.view.accessibilityIdentifier = GDCDiagnosticsViewID;
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)updateStatusText
{
    NSDictionary* appConfig = [[GDiOS sharedInstance] getApplicationConfig];
    NSNumber* preventUserDetailedLogging = [appConfig objectForKey:GDAppConfigKeyPreventUserDetailedLogs];
    NSNumber* loggingEnabled = [appConfig objectForKey:GDAppConfigKeyDetailedLogsOn];
    
    bool loggingEnabledValue = [loggingEnabled boolValue];
    bool preventUserDetailedLoggingValue = [preventUserDetailedLogging boolValue];
    
    [_loggingStatus setText:
     [NSString stringWithFormat:@"Detailed Logging: %@.\rPrevent User Detailed Logging Policy: %@",
      loggingEnabledValue ? @"ON" : @"OFF",
      preventUserDetailedLoggingValue ? @"ON" : @"OFF"]];
    // figure out the User Detailed Logging button text
    if (userEnabledLogging)
    {
        if (loggingEnabledValue)
        {
            [_detailedLoggingButton setTitle:@"Turn OFF User Detailed Logging" forState:UIControlStateNormal];
            [_detailedLoggingButton setEnabled:true];
        }
        else
        {
            // user turned on detailed logging but it is not enabled any more.  must have expired.
            userEnabledLogging = false;
        }
    }
    
    if (!userEnabledLogging)
    {
        [_detailedLoggingButton setTitle:@"Turn ON User Detailed Logging for 60s" forState:UIControlStateNormal];
        // disable the button if they aren't allowed to turn it on.
        [_detailedLoggingButton setEnabled:!preventUserDetailedLoggingValue];
    }
}

@end
