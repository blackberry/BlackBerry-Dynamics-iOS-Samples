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

#import "CertificateListViewController.h"
#import "CertificateDetailViewController.h"

#include <BlackBerryDynamics/GD/GDCryptoKeyStore.h>
#include <BlackBerryDynamics/GD/GDCredential.h>

@interface CertificateListViewController ()

    @property (nonatomic) struct GDX509List* certificates;
@end

@implementation CertificateListViewController

- (void)viewDidLoad {

    [super viewDidLoad];
    _certificates = NULL;
    if (_trustedCAs)
        self.title = @"Trusted Authorities";
    else if (_signCertsOnly)
        self.title = @"Signing Certificates";
    else if (_encCertsOnly)
        self.title = @"Encryption Certificates";
    else
        self.title = @"User Certificates";
    self.tableView.allowsSelection = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self refresh];
}

- (void)dealloc {

    GDX509List_free(_certificates);
}

/* Refresh client certificates certificates known to Dynamics.
 */
- (void)refresh {
    
    GDX509List_free(_certificates);
    if (_trustedCAs)
        _certificates = GDX509List_trusted_authorities();
    else if (_signCertsOnly)
        _certificates = GDX509List_valid_user_signing_certs();
    else if (_encCertsOnly)
        _certificates = GDX509List_all_user_encryption_certs();
    else
        _certificates = GDX509List_all_user_certs();

    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return GDX509List_num(_certificates);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        
    static NSString* cellIdentifier = @"ClientCertificate";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    // Show only brief credentials details.
    struct GDX509Certificate* certDetails = GDX509Certificate_create(GDX509List_value(_certificates, (int)indexPath.section));
    if (certDetails) {
        cell.textLabel.text = [NSString stringWithFormat:@"Serial Number: %s", certDetails->serialNumber];
        cell.textLabel.textColor = [UIColor colorWithRed:33.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Subject: %s",certDetails->subject];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:69.0/255.0 blue:84.0/255.0 alpha:1.0];
        GDX509Certificate_free(certDetails);
    }

    return cell;
}
    
#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier:@"CertificateSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"CertificateSegue"]) {
        // User selected UCP - navigate to view showing a list of credentials, if any,
        // managed by the selected UCP.
        CertificateDetailViewController* vc = [segue destinationViewController];
        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        vc.certificate = GDX509List_value(_certificates, (int)indexPath.section);
    }
}

@end
