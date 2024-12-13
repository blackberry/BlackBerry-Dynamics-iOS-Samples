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

#import "BPStartViewController.h"
#import "BPContactsViewController.h"
#import "BypassUnlockGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"

@import BlackBerryDynamics.Runtime;
@import BlackBerryDynamics.SecureStore.File;

@interface BPStartViewController ()

@property (weak, nonatomic) IBOutlet UILabel *applicationPolicyLabel;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingsButton;

@property (nonatomic, strong) UIAlertController *actionSheet;
@property (nonatomic, strong) UIAlertController *alert;

@end

@implementation BPStartViewController

static NSString * actionCancelTitle       = @"Cancel";
static NSString * actionSheetTitle        = @"Troubleshooting options";
static NSString * actionSheetMessage      = @"You could upload or save logs";

static NSString * uploadLogsActionTitle   = @"Upload Logs";
static NSString * uploadLogsActionMessage = @"A snapshot of your logs will be taken now and uploaded to the server for troubleshooting.\nThe upload process may take some time but it will continue in the background whenever possible until all the logs have been uploaded.\n Do you want to upload the logs now?";

#pragma mark - Initialization

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPolicyLabel) name:@"GDAppEventPolicyUpdateNotification" object:nil];
    }
    return self;
}

- (IBAction)openContacts:(UIBarButtonItem *)sender {
    
    /*
     * Usual non restricted presentation of view controller other than granted
     */
    NSLog(@"Will attempt to show contacts view controller ...");
    
    UIViewController *contactsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"contactsViewController"];
    
    [self.navigationController presentViewController:contactsViewController animated:YES completion:NULL];
}

#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshPolicyLabel];
    [BypassUnlockGDiOSDelegate sharedInstance].rootViewController = self;
    self.view.accessibilityIdentifier = BYUMainScreenID;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)refreshPolicyLabel {
    self.applicationPolicyLabel.text = [[GDiOS sharedInstance] getApplicationPolicyString];
    NSLog(@"%@", self.applicationPolicyLabel.text);
}

#pragma mark - Local Compliance Actions

- (IBAction)executeBlockFor10SecondsButtonPressed:(id)sender {
    [[BypassUnlockGDiOSDelegate sharedInstance].localComplianceManager executeBlockFor10Seconds];
}

- (IBAction)executeBlockButtonPressed:(id)sender {
    [[BypassUnlockGDiOSDelegate sharedInstance].localComplianceManager executeBlock];
}

#pragma mark - Setting ActionSheet

- (IBAction)settingsPressed:(id)sender {
    [self showActionSheet];
}

- (void) showActionSheet {
    
    self.actionSheet = [UIAlertController alertControllerWithTitle:actionSheetTitle
                                                           message:actionSheetMessage
                                                    preferredStyle:UIAlertControllerStyleActionSheet];
    
    [self.actionSheet addAction:[UIAlertAction actionWithTitle:uploadLogsActionTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           
                                                           [self showConformationAlertForActionName:uploadLogsActionTitle
                                                                                      actionMessage:uploadLogsActionMessage
                                                                                      actionHandler:^{
                                                                                          NSLog(@"logs uploading has been started...");
                                                                                          [[GDLogManager sharedInstance] openLogUploadUI];
                                                                                      }];
                                                           
                                                       }]];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        [self.actionSheet addAction:[UIAlertAction actionWithTitle:actionCancelTitle
                                                             style:UIAlertActionStyleCancel
                                                           handler:^(UIAlertAction * _Nonnull action) {
                                                               [self.actionSheet dismissViewControllerAnimated:YES
                                                                                                    completion:^{
                                                                                                        self.actionSheet = nil;
                                                                                                    }];
                                                           }]];
    }
    else
    {
        
        self.actionSheet.modalPresentationStyle = UIModalPresentationPopover;
        self.actionSheet.popoverPresentationController.barButtonItem = self.settingsButton;
    }
    
    [self.navigationController presentViewController:self.actionSheet
                                            animated:YES
                                          completion:nil];
}

- (void) showConformationAlertForActionName:(NSString*)actionName
                              actionMessage:(NSString*) actionMessage
                              actionHandler:(void (^)(void))actionHandler  {
    
    NSString *title = [NSString stringWithFormat:@"%@ ?",actionName];
    
    self.alert = [UIAlertController alertControllerWithTitle:title
                                                     message:actionMessage
                                              preferredStyle:UIAlertControllerStyleAlert];
    
    
    [self.alert addAction:[UIAlertAction actionWithTitle:actionName
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     if (actionHandler)
                                                         actionHandler();
                                                 }]];
    
    
    [self.alert addAction:[UIAlertAction actionWithTitle:actionCancelTitle
                                                   style:UIAlertActionStyleCancel
                                                 handler:^(UIAlertAction * _Nonnull action) {
                                                     [self.alert dismissViewControllerAnimated:YES
                                                                                    completion:^{
                                                                                        self.alert = nil;
                                                                                    }];
                                                 }]];
    
    [self.navigationController presentViewController:self.alert
                                            animated:YES
                                          completion:nil];
    
}


@end


