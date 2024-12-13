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
#import "RSSManager.h"
#import "UIAccessibilityIdentifiers.h"
#import <BlackBerryDynamics/GD/GDLogManager.h>
#import <BlackBerryDynamics/GD/GDDiagnostic.h>
#import <BlackBerryDynamics/GD/GDiOS.h>

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *uploadLogs;
@property (weak, nonatomic) IBOutlet UITextField *urlToCheck;
@property (weak, nonatomic) IBOutlet UITextField *portToCheck;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];    
    //Update seg control selected index
    self.uploadLogs.accessibilityIdentifier = RSSUploadLogsButtonID;
    self.urlToCheck.accessibilityIdentifier = RSSURLToCheckFieldID;
    self.portToCheck.accessibilityIdentifier = RSSPortToCheckFieldID;
    self.navigationItem.title = @"Settings";
}


- (IBAction)dismissSettings:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)uploadLogsPressed:(UIButton *)sender
{
    [[GDLogManager sharedInstance] openLogUploadUI];
}

- (IBAction)runDiagnostics:(UIButton *)sender {
    [self.spinner startAnimating];
    __block NSString *allResults = @"";

    NSString *host = self.urlToCheck.text;
    NSString *portStr = self.portToCheck.text;
    NSInteger port = [portStr integerValue];
    [self.portToCheck resignFirstResponder];
    [self.urlToCheck resignFirstResponder];
    __weak SettingsViewController *weakSelf = self;
    [[GDDiagnostic sharedInstance] checkApplicationServerReachability:host withPort:port useSSL:NO validateCertificate:NO withTimeOut:10 callbackBlock:^(NSString *results, NSInteger requestID) {
        allResults = [allResults stringByAppendingString:results];
        [weakSelf presentRouteAlertWithText:allResults];
    }];
}

-(void)presentRouteAlertWithText:(NSString *)text {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Routes" message:text preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:okAction];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:^{
            [self.spinner stopAnimating];
        }];
    });
}

@end
