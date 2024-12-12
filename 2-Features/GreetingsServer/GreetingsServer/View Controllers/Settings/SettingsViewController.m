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
#import "UIAccessibilityIdentifiers.h"

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = GRSSettingsViewID;
    
    // Do any additional setup after loading the view from its nib.
    
    [self setTitle:@"Settings"];
    
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
    self.requestSegControl = nil;
    self.uploadLogsButton = nil;
    self.requestAPILabel = nil;
    self.troubleshootLabel = nil;
}

//For iPhone
#pragma mark - tap dismiss
-(void)dismissSettings:(UITapGestureRecognizer*)tapGesture
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - gesture recognizers
//Dismiss on tapping anywhere except over buttons or segmented controllers
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if([touch.view isKindOfClass:[UIButton class]] || [touch.view isKindOfClass:[UISegmentedControl class]])
    {
        return NO;
    }
    
    return YES;
}

#pragma mark - actions
-(IBAction)requestAPIChanged:(id)sender
{
    //Change current request mode
}

-(IBAction)uploadLogsPressed:(id)sender
{
   
    [[GDLogManager sharedInstance] openLogUploadUI];
    
}

@end
