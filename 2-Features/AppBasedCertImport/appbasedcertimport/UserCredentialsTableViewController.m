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
 * Lists credentials in brief format, managed by a User Credential Profile (UCP).
 * When a credential is selected, it navigates to a view showing more credential details.
 */

#import "UserCredentialsTableViewController.h"
#import "UserCredentialTableViewController.h"
#import "FilePickerTableViewController.h"

#include "BlackBerryDynamics/GD/GDCommon.h"
#include "BlackBerryDynamics/GD/GDCredential.h"

@interface UserCredentialsTableViewController ()
    @property (nonatomic) NSMutableArray* items;
@end

@implementation UserCredentialsTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    _items = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refresh];
}

/* Refresh the credentials list managed by the current UCP.
 */
- (void)refresh {
    
    [_items removeAllObjects];

    struct GDError error;
    struct GDCredential* creds = NULL;
    size_t nCreds = 0;
    
    // Build a list of credentials managed by the current UCP.
    if (GDCredential_list([_profile[0] UTF8String], &nCreds, &creds, &error)) {
        for (size_t n = 0; n < nCreds; ++n) {
            [_items addObject:@[@[@"Serial Number", [NSString stringWithUTF8String:creds[n].userCertificate->serialNumber]],
                                @[@"Issuer", [NSString stringWithUTF8String:creds[n].userCertificate->issuer]],
                                @[@"Subject", [NSString stringWithUTF8String:creds[n].userCertificate->subject]],
                                @[@"Subject Alternative Name", [NSString stringWithUTF8String:creds[n].userCertificate->subjectAlternativeName]],
                                @[@"Not Before Date", [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:creds[n].userCertificate->notBefore] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle]],
                                @[@"Not After Date", [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:creds[n].userCertificate->notAfter] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle]],
                                @[@"MD5 Fingerprint", [NSString stringWithUTF8String:creds[n].userCertificate->certificateMD5]],
                                @[@"SHA1 Fingerprint", [NSString stringWithUTF8String:creds[n].userCertificate->certificateSHA1]],
                                @[@"Public Key MD5 Fingerprint", [NSString stringWithUTF8String:creds[n].userCertificate->publicKeyMD5]],
                                @[@"Public Key SHA1 Fingerprint", [NSString stringWithUTF8String:creds[n].userCertificate->publicKeySHA1]]
            ]];
        }
        GDCredential_free(creds, nCreds);
    }

    // Set title to name of current UCP.
    self.title = _profile[2]; // Name
    
    // Disable 'Files' and 'Settings' buttons if an app-based UCP, since credentials are
    // automatically mapped to the applicable UCP.
    // 'Settings' displays any provider-specific configuration associated with the UCP.
    BOOL importImplicit = [_profile[1] compare:@"localCertProvider"] == NSOrderedSame; // Type
    UIBarButtonItem* toolbarItem;
    NSEnumerator* enumerator = self.toolbarItems.objectEnumerator;
    while (toolbarItem = [enumerator nextObject]) {
        [toolbarItem setEnabled:!importImplicit];
    }

    // Enable undo button so imported credentials may be removed.
    if (nCreds > 0) {
        [self.toolbarItems.lastObject setEnabled:YES];
    }

    // Refresh the list of credentials built above.
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return [_items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* cellIdentifier = @"UserCredential";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Show only brief credentials details.
    cell.textLabel.text = _items[indexPath.section][2][0]; // Title: 'Subject'
    cell.detailTextLabel.text = _items[indexPath.section][2][1]; // Detail: actual subject value.
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"ShowUserCredential"]) {
        // User has chosen a credential to inspect in more detail.
        UserCredentialTableViewController* vc = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        vc.credentialFields = _items[indexPath.section];
    }
    else if ([[segue identifier] isEqualToString:@"ShowFilePicker"]) {
        // User has chosen to pick a PKCS12 file to be managed by the current UCP.
        FilePickerTableViewController* vc = [segue destinationViewController];
        vc.profile = self.profile;
    }
}

#pragma mark - Actions

/* 'Settings' button tapped.
 * Show provider-specific settings.
 */
- (IBAction)showSettings:(id)sender {
    
    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Provider Settings" message:_profile[3] preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing.
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (IBAction)undoImport:(id)sender {

    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Undo Import"
                                                                message:@"Do you want to remove all credentials for this profile?"
                                                         preferredStyle:UIAlertControllerStyleAlert];

    [ac addAction:[UIAlertAction actionWithTitle:@"No"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing
                                         }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Yes"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
        GDCredential_undoImport([self.profile[0] UTF8String]);
        [self refresh];
    }]];

    [self presentViewController:ac animated:YES completion:nil];
}

@end
