/*
 * Copyright (c) 2019 BlackBerry Limited. All Rights Reserved.
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
 */

#import "InputBlockingHandler.h"

#import "BBDInputBlocker.h"
#import "AppDelegate.h"
#import "BBDAutoFillBlockerField.h"

@implementation InputBlockingHandler

- (void)startHandling
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dictationWasBlocked:)
                                                 name:BBDDictationWasBlockedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardExtensionAppeared:)
                                                 name:BBDKeyboardExtensionDidAppearNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardExtensionInputBlocked:)
                                                 name:BBDKeyboardExtensionInputWasBlockedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(emojiWasBlocked:)
                                                 name:BBDEmojiInputBlockedNotification
                                               object:nil];
}

- (void)keyboardExtensionInputBlocked:(NSNotification *)notification
{
    [self showCustomKeyboardBlockedAlert];
}

- (void)keyboardExtensionAppeared:(NSNotification *)notification
{
    [self showCustomKeyboardBlockedAlert];
}

- (void)dictationWasBlocked:(NSNotification *)notification
{
    [self showDictationBlockedAlert];
}

- (void)emojiWasBlocked:(NSNotification *)notification
{
    [self showEmojiBlockedAlert];
}

- (void)showCustomKeyboardBlockedAlert
{
    NSString *title = @"Custom keyboards disabled.";
    NSString *message = @"Custom keyboards can't be used on secured text fields";
    [self showSimpleAlertWithTitle:title withMessage:message];
}

- (void)showDictationBlockedAlert
{
    NSString *title = @"Dictation disabled";
    NSString *message = @"Dictation can't be used on secured text fields";
    [self showSimpleAlertWithTitle:title withMessage:message];
}

- (void)showEmojiBlockedAlert
{
    NSString *title = @"Emoji restricted";
    NSString *message = @"Emoji is restricted for secured text fields";
    [self showSimpleAlertWithTitle:title withMessage:message];
}

- (void)showSimpleAlertWithTitle:(NSString *)title
                     withMessage:(NSString *)message
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    /// OK
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil]];
    AppDelegate* delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

@end
