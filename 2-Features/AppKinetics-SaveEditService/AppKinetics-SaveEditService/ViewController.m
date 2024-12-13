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

#import "ViewController.h"
#import "UIAccessibilityIdentifiers.h"
#import "ServiceController.h"

@interface ViewController () 

@property (assign, nonatomic) CGFloat originalTextViewBottomInset;

@end
		
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = AKSMainViewID;

    self.originalTextViewBottomInset = self.textView.textContainerInset.bottom;
    
    if (self.serviceController.gdRequestID) {
        self.textView.text = self.serviceController.lastReceivedText;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveTextViewForKeyboard:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moveTextViewForKeyboard:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextView

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    // Hide keyboard on "return" key
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)moveTextViewForKeyboard:(NSNotification *)notification
{
    UIEdgeInsets newInsets = self.textView.textContainerInset;
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        newInsets.bottom = keyboardRect.size.height - self.toolbar.frame.size.height + self.originalTextViewBottomInset;
    } else {
        newInsets.bottom = self.originalTextViewBottomInset;
    }
    self.textView.textContainerInset = newInsets;
    
    UIEdgeInsets vertScrollInset = self.textView.verticalScrollIndicatorInsets;
    UIEdgeInsets horizonScrollInset = self.textView.horizontalScrollIndicatorInsets;

    vertScrollInset.bottom = newInsets.bottom - self.originalTextViewBottomInset;
    horizonScrollInset.bottom = newInsets.bottom - self.originalTextViewBottomInset;

    self.textView.verticalScrollIndicatorInsets = vertScrollInset;
    self.textView.horizontalScrollIndicatorInsets = horizonScrollInset;
}

#pragma mark - Actions

- (IBAction)doneButtonAction:(id)sender
{
    NSError *error = nil;
    [self.serviceController sendRequest:&error newText:self.textView.text sendTo:self.serviceController.gdApplication];
    if (error) {
        [self showError:[error localizedDescription]];
    }
}

#pragma mark - Notification

- (void)showError:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       NSLog(@"User pressed OK button");
                                                   }];

    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)receiveText:(NSString *)text
{
    self.textView.text = text;
}

@end
