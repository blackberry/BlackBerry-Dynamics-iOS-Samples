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

#import "CertificateDetailViewController.h"

#include <BlackBerryDynamics/GD/GDCryptoKeyStore.h>
#include <BlackBerryDynamics/GD/GDCredential.h>

@interface CertificateDetailViewController ()
    @property (nonatomic) struct GDX509Certificate* certDetails;
@end

@implementation CertificateDetailViewController

- (void)viewDidLoad {
 
    [super viewDidLoad];
    _certDetails = GDX509Certificate_create(_certificate);
    self.title = @"Certificate Details";
    self.tableView.allowsSelection = NO;
}

- (void)dealloc {

    GDX509Certificate_free(_certDetails);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 9;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CertificateField";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Issuer";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->issuer];
            break;
        case 1:
            cell.textLabel.text = @"Subject";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->subject];
            break;
        case 2:
            cell.textLabel.text = @"Subject Alt. Name";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->subjectAlternativeName];
            break;
        case 3:
            cell.textLabel.text = @"Serial Number";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->serialNumber];
            break;
        case 4:
            cell.textLabel.text = @"Start Date";
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:_certDetails->notBefore] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
            break;
        case 5:
            cell.textLabel.text = @"Expires Date";
            cell.detailTextLabel.text = [NSDateFormatter localizedStringFromDate:[NSDate dateWithTimeIntervalSince1970:_certDetails->notAfter] dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterFullStyle];
            break;
        case 6:
            cell.textLabel.text = @"Fingerprint (SHA1)";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->certificateSHA1];
            break;
        case 7:
            cell.textLabel.text = @"Key Usage";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->keyUsage];
            break;
        case 8:
            cell.textLabel.text = @"Extended Key Usage";
            cell.detailTextLabel.text = [NSString stringWithUTF8String:_certDetails->extendedKeyUsage];
            break;
        default:
            NSAssert(false, @"Too many sections in table view.");
    }

    cell.textLabel.textColor = [UIColor colorWithRed:33.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:52.0/255.0 green:69.0/255.0 blue:84.0/255.0 alpha:1.0];
    return cell;
}

@end
