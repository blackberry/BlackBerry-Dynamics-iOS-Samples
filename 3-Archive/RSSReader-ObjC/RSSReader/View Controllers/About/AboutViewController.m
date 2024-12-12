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
#import <BlackBerryDynamics/GD/GDiOS.h>

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                               target:self
                                                                                               action:@selector(dismissAbout)];
    }
}

//For iPhone close button
#pragma mark - action
-(void)dismissAbout
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidAppear:(BOOL)animated {
    
    GDAuthDelegateInfo* gdAuthDelegateInfo = [[GDiOS sharedInstance] getAuthDelegate];
    
    NSLog(@"viewDidAppear: getAuthDelegate Name = %@, address = %@, applicationId = %@, isAuthenticationDelegated = %@",
          gdAuthDelegateInfo.name, gdAuthDelegateInfo.address, gdAuthDelegateInfo.applicationId,
          gdAuthDelegateInfo.isAuthenticationDelegated ? @"YES" : @"NO");
}

@end
