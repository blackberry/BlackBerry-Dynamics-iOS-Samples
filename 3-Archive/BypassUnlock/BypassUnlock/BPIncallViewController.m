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

#import "BPIncallViewController.h"
#import "BPContactsViewController.h"
#import "BPCallManager.h"

@interface BPIncallViewController ()

@property (nonatomic, assign) BPIncomingState currentState;

@property (weak, nonatomic) IBOutlet UIImageView *animatingHolderView;
@property (weak, nonatomic) IBOutlet UIImageView *holderView;

@property (weak, nonatomic) IBOutlet UILabel *callerIDLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *appLockedSegmentControl;

@property (weak, nonatomic) IBOutlet UIButton *contactsButton;
@property (weak, nonatomic) IBOutlet UIButton *declineInMiddle;
@property (weak, nonatomic) IBOutlet UIButton *decline;
@property (weak, nonatomic) IBOutlet UIButton *accept;
@property (nonatomic, assign) BOOL didRegisterForNotification;
- (void)animateLocking;

@end

@implementation BPIncallViewController
@synthesize currentState;

- (void)dealloc {
    if (_didRegisterForNotification)
        [[BPCallManager sharedManager] removeObserver:self forKeyPath:@"appIdleLocked"];
}

- (IBAction)decline:(UIButton *)sender {
    
    /*
     * Dismissing of granted view controller is managed by GD SDK when application is locked
     */
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)accept:(UIButton *)sender {
    [UIView animateWithDuration:3. animations:^{
        self.decline.frame = self.accept.frame = self.declineInMiddle.frame;
        self.currentState = BPIncomingStateIncall;
    }];
}

- (IBAction)showContacts:(UIButton *)sender {
    NSLog(@"Will attempt to show contacts view controller ...");
    
    UIViewController *contactsViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"contactsViewController"];
    
    /*
     * Presenting of protected view controller if app is locked is scheduled on unlock.
     */
    if ( [[BPCallManager sharedManager] appIdleLocked] ) {
        
        NSString *message = @"Application is locked!\nTo be able view restricted content unlock the application!";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel"
                                                         style:UIAlertActionStyleCancel
                                                       handler:NULL];
        [alert addAction:action];
        action = [UIAlertAction actionWithTitle:@"Ok"
                                          style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * _Nonnull action) {
                                            
                                            __typeof(self) _self = self;
                                            [BPCallManager sharedManager].appUnlockCompletion = ^{
                                                [[BPCallManager sharedManager] continueCallUsingViewController:_self completion:^{
                                                    [_self presentViewController:contactsViewController animated:YES completion:nil];
                                                }];
                                            };
                                            [_self dismissViewControllerAnimated:NO completion:NULL];
                                            
                                            
                                        }];
        [alert addAction:action];
        
        [self presentViewController:alert animated:YES completion:NULL];
        
    } else {
        
        [self presentViewController:contactsViewController animated:YES completion:NULL];
        
    }
}

- (void)onStateChanged {
    self.contactsButton.hidden = self.currentState == BPIncomingStateIncoming;
    self.decline.hidden = self.currentState == BPIncomingStateIncall;
    self.declineInMiddle.hidden = self.currentState == BPIncomingStateIncoming;
    self.accept.hidden = self.currentState == BPIncomingStateIncall;
}

#pragma  mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentState = BPIncomingStateIncoming;
    [[BPCallManager sharedManager] addObserver:self
                                    forKeyPath:@"appIdleLocked"
                                       options:NSKeyValueObservingOptionNew
                                       context:NULL];
    self.didRegisterForNotification = YES;
    [self switchOnLockSignaling];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([object isEqual:[BPCallManager sharedManager]] &&
        [keyPath isEqualToString:@"appIdleLocked"]) {
        [self switchOnLockSignaling:[BPCallManager sharedManager].appIdleLocked];
    }
}

- (void)switchOnLockSignaling {
    [self switchOnLockSignaling:[BPCallManager sharedManager].appIdleLocked];

    self.accept.layer.cornerRadius = 10;
    self.decline.layer.cornerRadius = 10;
    self.declineInMiddle.layer.cornerRadius = 10;
}

- (void)switchOnLockSignaling:(BOOL)toSignal {
    self.appLockedSegmentControl.selectedSegmentIndex = toSignal;
    if (toSignal)
        [self animateLocking];
}

- (void)animateLocking {
    [UIView animateWithDuration:1.
                          delay:0.
                        options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse
                     animations:^{
                         
                         self.animatingHolderView.backgroundColor = [UIColor colorWithRed:48.0/255.0 green:119.0/255.0 blue:235.0/255.0 alpha:1.0];
                         
                     } completion:^(BOOL finished) {
                         
                         if (![BPCallManager sharedManager].appIdleLocked) {
                             [UIView modifyAnimationsWithRepeatCount:0 autoreverses:true animations:^(void){ /* do nothing */ }];
                         }
                         self.animatingHolderView.backgroundColor = [UIColor colorWithRed:33.0/255.0 green:50.0/255.0 blue:65.0/255.0 alpha:1.0];
                         
                     }];
}

- (void)setCurrentState:(BPIncomingState)state {
    currentState = state;
    [self onStateChanged];
}

#pragma mark - Natural interface settings for call screen

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
