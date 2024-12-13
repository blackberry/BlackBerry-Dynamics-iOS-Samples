/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "EmailServiceVC.h"

@interface EmailServiceVC ()

@end

@implementation EmailServiceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.toOutlet setDelegate:self];
    [self.subjectOutlet setDelegate:self];
    [self.messageOutlet setDelegate:self];
    
    bbWorkIdentifier = @"com.good.gcs.g3";
    sendEmailIdentifier = @"com.good.gfeservice.send-email";
    sendEmailVersion = @"1.0.0.0";
}

//Send email via BlackBerry Work
- (IBAction)send:(id)sender {
    NSArray* arr = [[GDiOS sharedInstance] getServiceProvidersFor:sendEmailIdentifier andVersion:sendEmailVersion andServiceType:GDServiceTypeApplication];
    
    bool bbWorkPresent = false;
    GDServiceProvider * serP;
    
    for (GDServiceProvider *serviceProvider in arr) {
        if ([serviceProvider.identifier  isEqual: bbWorkIdentifier]) {
            bbWorkPresent = true;
            serP = serviceProvider;
            break;
        }
    }
    
    if (!bbWorkPresent) {
        [self alertWithTitle:@"Alert!" message:@"BlackBerry Work not installed"];
    }
    
    NSError *err = [[NSError alloc] init];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSArray *toRecipients = [_toOutlet.text componentsSeparatedByString:@","];
    [params setObject:toRecipients forKey:@"to"];
    [params setObject:_subjectOutlet.text forKey:@"subject"];
    [params setObject:_messageOutlet.text forKey:@"body"];
    
    [GDServiceClient sendTo:[serP address] withService:@"com.good.gfeservice.send-email" withVersion:@"1.0.0.0" withMethod:@"sendEmail" withParams:params withAttachments:nil bringServiceToFront:GDEPreferPeerInForeground requestID:nil error:&err];
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

-(void) alertWithTitle: (NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}

@end
