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

/*
 *
 * Lists User Credential Profiles (UCP) assigned to the user.
 * When a UCP is selected, it navigates to a view listing
 * credentials, if any, managed by the selected UCP.
 *
 * Refer to this class when investigating how to obtain a list
 * of UCPs assigned to a user account, and monitor for change
 * notifications.
 */

#import "UserCredentialProfilesTableViewController.h"
#import "UserCredentialsTableViewController.h"
#import "FilePickerTableViewController.h"
#import "UIAccessabilityIdentifiers.h"

#include "BlackBerryDynamics/GD/GDCommon.h"
#include "BlackBerryDynamics/GD/GDCredential.h"
#include "BlackBerryDynamics/GD/GDCredentialsProfile.h"

@interface UserCredentialProfilesTableViewController ()
    @property (nonatomic) NSMutableArray* items;
@end

@implementation UserCredentialProfilesTableViewController

/* Monitor for UCP change notifications.  Dynamics will call this function.
 */
static void onProfileEvent(struct GDCredentialsProfileEvent event, void* appData) {
    
    __block UserCredentialProfilesTableViewController* vc = (__bridge UserCredentialProfilesTableViewController*)appData;

    // Alert user if launched from another app when it detects that credentials are required.
    // GDCredentialsProfileStateImportNow is a transient state that decays to
    // GDCredentialsProfileStateImportDue after this callback returns.
    __block bool anotherAppIsBlockedBecauseItRequiresCredentials =
                     event.profile->state == GDCredentialsProfileStateImportNow;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (anotherAppIsBlockedBecauseItRequiresCredentials)
            [vc showImportRequiredAlert];
        // Refresh the list with latest details.
        [vc refresh];
    });
}

- (void)viewDidLoad {

    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
    GDCredentialsProfile_register(onProfileEvent, (__bridge void*)self);
    self.view.accessibilityIdentifier = AppUserCredentialProfileID;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refresh];
}

/* Refresh the UCP list with the latest state from the UEM server.
 */
- (void)refresh {

    [_items removeAllObjects];

    struct GDError error;
    struct GDCredentialsProfile* profiles = NULL;
    size_t nProfiles;
    BOOL importImplicit = NO;

    // Build a list of UCPs synchronized to the app.
    if (GDCredentialsProfile_list(&nProfiles, &profiles, &error)) {
        for (size_t n = 0; n < nProfiles; ++n) {

            NSString* status = nil;
            if (profiles[n].state == GDCredentialsProfileStateImportDue) {
                status = @"Import due";
            }
            else if (profiles[n].state == GDCredentialsProfileStateImported) {
                // Count credentials managed by this profile.
                struct GDError error;
                struct GDCredential* creds = NULL;
                size_t nCreds = 0;
                if (GDCredential_list(profiles[n].id, &nCreds, &creds, &error)) {
                    status = [NSString stringWithFormat:@"%zu %@ imported", nCreds, (nCreds==1?@"credential":@"credentials")];
                    GDCredential_free(creds, nCreds);
                }
            }
            else if (profiles[n].state == GDCredentialsProfileStateModified) {
                status = @"Profile updated";
            }

            if (strcmp(profiles[n].type, "localCertProvider") == 0) {
                importImplicit = YES; // System will decide which profile will manage the credential when imported
            }

            [_items addObject:@[[NSString stringWithUTF8String:profiles[n].id],
                                [NSString stringWithUTF8String:profiles[n].type],
                                [NSString stringWithUTF8String:profiles[n].name],
                                [NSString stringWithUTF8String:profiles[n].providerSettings],
                                [NSNumber numberWithBool:profiles[n].required],
                                status]];
        }
        GDCredentialsProfile_free(profiles, nProfiles);
    }

    self.title = @"User Credential Profiles";
    
    // Enable 'Files' button if there are 1 or more UCPs with a device-based connection.
    // 'Files' launches the Documents PKCS12 file picker so the user may begin the import process.
    // Dynamics decides which device-based UCP will manage a credential during
    // the import phase.  If there are no device-based UCPs, then 'Files' is disabled since
    // the user has not specified any other UCP type to import a credential directly to.
    [self.toolbarItems.firstObject setEnabled:importImplicit]; // 'Files' button

    // Refresh the list of UCPs built above.
    [self.tableView reloadData];
}

#pragma mark - UIAlert

/* When another app requires a credential to be imported, this alert is shown.
 */
- (void)showImportRequiredAlert {
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Import Required" message:@"Another app requires you to import credentials." preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing.
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [_items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
    static NSString* cellIdentifier = @"UserCredentialProfile";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Show only brief UCP details.
    // Title: UCP name + required/optional attribute.
    if ([_items[indexPath.section][4] boolValue]) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", _items[indexPath.section][2], @"required"];
    }
    else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (%@)", _items[indexPath.section][2], @"optional"];
    }
    cell.detailTextLabel.text = _items[indexPath.section][5]; // Detail: UCP status.
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ShowUserCredentials"]) {
        // User selected UCP - navigate to view showing a list of credentials, if any,
        // managed by the selected UCP.
        UserCredentialsTableViewController* vc = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        vc.profile = _items[indexPath.section];
    }
    else if ([[segue identifier] isEqualToString:@"ShowFilePicker"]) {
        // User has chosen to pick a PKCS12 file to be managed by the current UCP.
        FilePickerTableViewController* vc = [segue destinationViewController];
        vc.profile = nil;
    }
}

@end
