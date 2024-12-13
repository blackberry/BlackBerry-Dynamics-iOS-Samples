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

#import "FunctionListViewController.h"
#import "CertificateListViewController.h"
#import "UIAccessibilityIdentifiers.h"

@interface FunctionListViewController ()
    @property (nonatomic) NSArray* functions;
@end

@implementation FunctionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.accessibilityIdentifier = CRMainViewID;
    self.title = @"Crypto API Examples";
    self.tableView.allowsSelection = YES;
    _functions = @[ @[ @"PKCS#7 (CMS) Sign", @"PKCS7SignSegue" ],
                    @[ @"PKCS#7 (CMS) Verify", @"PKCS7VerifySegue" ],
                    @[ @"Compose SMIME e-mail", @"SMIMEComposeSegue" ],
                    @[ @"Read SMIME e-mail", @"SMIMEReadSegue" ],
                    @[ @"RSA/DSA/EC Sign", @"KeySignSegue" ],
                    @[ @"RSA/DSA/EC Verify", @"KeyVerifySegue" ],
                    @[ @"List Client Certificates", @"ListClientCertificatesSegue" ],
                    @[ @"List trusted CAs", @"ListTrustedCAsSegue" ],
                    @[ @"Evaluate Certificate", @"CertificateVerifySegue" ]
                 ];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return [_functions count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString* cellIdentifier = @"Function";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [_functions[indexPath.section] objectAtIndex:0];
    cell.textLabel.textColor = [UIColor colorWithRed:33.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}
    
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* segueName = [_functions[indexPath.section] objectAtIndex:1];
    [self performSegueWithIdentifier:segueName sender:self];
}
    
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.toolbarItems.firstObject setEnabled:[self.tableView.indexPathsForSelectedRows count]];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([[segue identifier] isEqualToString:@"ListTrustedCAsSegue"]) {
        __weak CertificateListViewController* vc = [segue destinationViewController];
        vc.trustedCAs = YES;
    }
}

@end
