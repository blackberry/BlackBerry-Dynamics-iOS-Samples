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

#import "ViewController.h"
// Credential Manager UI
#import <BlackBerryDynamics/GD/GDPKI.h> // View controller
#include <BlackBerryDynamics/GD/GDCredentialsProfile.h> // Register profiles of interest
#import "UIAccessibilityIdentifiers.h"

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = KMMainScreenID;
}

- (IBAction)openCredentialManager:(id)sender {
    
    // Register for  profile types that the user may need to manage:
    GDCredentialsProfile_register_type(GDCredentialsProfileTypeAppbased, NULL, NULL);
    GDCredentialsProfile_register_type(GDCredentialsProfileTypeDeviceKeystore, NULL, NULL);
    GDCredentialsProfile_register_type(GDCredentialsProfileTypeUserCertificate, NULL, NULL);
    GDCredentialsProfile_register_type(GDCredentialsProfileTypeAssistedSCEP, NULL, NULL);
    GDCredentialsProfile_register_type(GDCredentialsProfileTypeEntrust, NULL, NULL);
    GDCredentialsProfile_register_type(GDCredentialsProfileTypePKIConnector, NULL, NULL);

    // Return Credential Manager View Controller.  It will only show profiles that were
    // rgistered here, and assigned to the user by UEM admin.
    UIViewController* mainViewController = GDCredentialManagerUI.rootViewController;
    [mainViewController setModalPresentationStyle:UIModalPresentationCurrentContext];
    [self presentViewController:mainViewController animated:YES completion:^{
        NSLog(@"GDCredentialManagerUI presented");
    }];
}
@end
