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
 * Shows PKCS12 files in the app's Documents folder and allows the user to select
 * which one(s) to import.
 *
 * PKCS12 files can be transferred from another machine to the app's Documents
 * folder using iTunes File Sharing.
 *
 * Refer to this class when investigating how to import a PKCS12 from another
 * source into the Dynamics ecosystem.
 */

#import "FilePickerTableViewController.h"

#include "BlackBerryDynamics/GD/GDCommon.h"
#include "BlackBerryDynamics/GD/GDCredential.h"

@interface FilePickerTableViewController ()

    @property (nonatomic) NSString* documentsFolder;
    @property (nonatomic) NSString* preLoadedResourcesFolder;
    @property (nonatomic) NSArray* items;
@end

@implementation FilePickerTableViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    [self preloadDocumentsFolder];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refresh];
}

/* Copy p12/pfx sample files from app bundle to Documents folder.
 */
- (void)preloadDocumentsFolder {
    
    self.documentsFolder = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    self.preLoadedResourcesFolder = [[NSBundle mainBundle] resourcePath];

    NSArray* resources = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_preLoadedResourcesFolder error:nil];
    for (id resource in resources) {
        NSString* extension = [[resource pathExtension] lowercaseString];
        if ([extension isEqualToString:@"pfx"] || [extension isEqualToString:@"p12"] ) {
            [[NSFileManager defaultManager] copyItemAtPath:[_preLoadedResourcesFolder stringByAppendingPathComponent:resource] toPath:[_documentsFolder stringByAppendingPathComponent:resource] error:nil];
        }
    }
}

/* Import selected PKCS12 files into the container.
 * The credentials cannot be used until GDCredential_importDone() is called later.
 */
- (void)performImport:(NSArray*)indexPaths commonPassword:(NSString*)password{
    
    for (NSIndexPath* indexPath in indexPaths) {
        char* profileId = (char*)[_profile[0] UTF8String];
        NSData* file = [NSData dataWithContentsOfFile:[_documentsFolder stringByAppendingPathComponent:_items[indexPath.section]]];
        struct GDData pkcs12;
        pkcs12.data = (void*)file.bytes;
        pkcs12.size = file.length;
        struct GDError error;
        if (!GDCredential_import(&profileId, &pkcs12, [password UTF8String], &error)) {
            [self showErrorAlert:indexPath error:error];
            return;
        }
    }
    [self showConfirmationAlert];
}

/* Refresh Documents folder.
 */
- (void)refresh {

    self.items = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:_documentsFolder error:nil];
    self.title = @"PKCS12 Files";
    [self.toolbarItems.firstObject setEnabled:[self.tableView.indexPathsForSelectedRows count]];
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
    
    static NSString* cellIdentifier = @"File";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = _items[indexPath.section];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
    [self.toolbarItems.firstObject setEnabled:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self.toolbarItems.firstObject setEnabled:[self.tableView.indexPathsForSelectedRows count]];
}

#pragma mark - Actions

/* Import selected p12/pfx files. */
- (IBAction)import:(id)sender {
 
    NSArray* indexPaths = self.tableView.indexPathsForSelectedRows;
    if ([indexPaths count])
        [self showPasswordAlert:indexPaths];
}

/* Finalize import.
 * This will trigger the public certificates to be sent to UEM so credentials can
 * be shared between containers and managed by self-service or admin.
 * If launched by another app, it will resume foreground and continue.
 */
- (IBAction)done:(id)sender {

    GDCredential_importDone();
}

#pragma mark - Alerts

- (void)showPasswordAlert:(NSArray*)indexPaths {
 
    NSString* message = ([indexPaths count] == 1) ?
                        [NSString stringWithFormat:@"Please enter the password for %@.", _items[((NSIndexPath*)indexPaths[0]).section]] :
                        @"The selected files must share the same password.";

    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Password Required" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.secureTextEntry = YES;
    }];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing
                                         }]];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [self performImport:indexPaths commonPassword:ac.textFields[0].text];
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)showConfirmationAlert {
    
    NSString* message = @"Credentials have been decrypted and are now pending import. You may continue to import other credentials by tapping 'More'. If you have finished, click 'Done' to complete the process. Credentials will not be available for use until you click 'Done'.";

    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Success"
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"More"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing. User wishes to import more credentials.
                                         }]];

    [ac addAction:[UIAlertAction actionWithTitle:@"Done"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Finalise transaction. This will trigger the public
                                             // certificates to be sent to UEM so credentials can
                                             // be shared between containers and managed by self-service
                                             // or admin.
                                             GDCredential_importDone();
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)showErrorAlert:(NSIndexPath*)indexPath error:(struct GDError)error {
    
    NSString* errorText = nil;
    if (error.code == GDErrorNotMapped) {
        errorText = [NSString stringWithFormat:@"The credential within %@ does not match any criteria for any profile.", _items[indexPath.section]];
    }
    else if (error.code == GDErrorWrongPassword) {
        errorText = [NSString stringWithFormat:@"The password supplied for %@ is not correct.", _items[indexPath.section]];
    }
    else if (error.code == GDErrorNotAllowed) {
        errorText = [NSString stringWithFormat:@"Importing %@ is not allowed as it doesn't comply with enterprise policy settings.", _items[indexPath.section]];
    }
    else {
        errorText = [NSString stringWithFormat:@"An unexpected error occurred while decrypting %@",_items[indexPath.section]];
    }

    UIAlertController* ac = [UIAlertController alertControllerWithTitle:@"Error" message:errorText preferredStyle:UIAlertControllerStyleAlert];
    
    [ac addAction:[UIAlertAction actionWithTitle:@"Okay"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             // Do nothing.
                                         }]];
    
    [self presentViewController:ac animated:YES completion:nil];
}

@end
