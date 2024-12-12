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


#import "AboutViewController.h"

#import "AppDelegate.h"
#import "AboutWindow.h"
#import "BaseAlertController.h"
#import "UIAccessibilityIdentifiers.h"

#import <BlackBerryDynamics/GD/GDReachability.h>

@interface AboutViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *aboutTextView;

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.accessibilityIdentifier = AKSAboutViewID;
    self.aboutTextView.delegate = self;
    [self setTitle:@"About"];
}

// Action for close button
#pragma mark - action

-(IBAction)dismissAbout:(id)sender
{
    [AboutWindow hide];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction
{
    if (![self isInternetReachable])
    {
        [self showAlert];
        return NO;
    }
    return YES;
}

- (BOOL)isInternetReachable
{
    GDReachabilityStatus flags = [GDReachability sharedInstance].status;
    return flags != GDReachabilityNotReachable;
}

- (void)showAlert
{
    [BaseAlertController showOkAlert:@"Internet is not available." message:@"Please check your internet connection."];
}

@end
