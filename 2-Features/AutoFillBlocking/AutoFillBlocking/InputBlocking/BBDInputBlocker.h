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

#import <UIKit/UIKit.h>

// Notification about dictation blocking event.
extern NSString * _Nonnull const BBDDictationWasBlockedNotification;

// Notification about keyboard extension appearance.
// Will be sent in a case if user chosed keyboard extension as input mode.
extern NSString * _Nonnull const BBDKeyboardExtensionDidAppearNotification;
// Notification about keyboard extension input blocking.
extern NSString * _Nonnull const BBDKeyboardExtensionInputWasBlockedNotification;

NS_ASSUME_NONNULL_BEGIN

/** Class responsible for dictation and keyboard extensions blocking.
 *
 * Usage: set needsBlockDictation and needsBlockCustomKeyboard properties to
 * determine the condition and text inputs for which dictation and custom keyboard would be blocked.
 * By default BBDKeyboardBlocker will dismiss dictation input or dismiss custom keyboard when the user
 * switched to custom keyboard or tried to input the text using custom keyboard.
 * Use BBDKeyboardExtensionInputWasBlockedNotification and BBDDictationWasBlockedNotification
 * notifications to handle an event of dictation or keyboard extension blocking.
 * These notifications can be used to make UI improvements, like showing an alert.
 *
 */
@interface BBDInputBlocker : NSObject

@property (nonatomic, copy) BOOL (^needsBlockDictation)(UIResponder *currentResponder);
@property (nonatomic, copy) BOOL (^needsBlockCustomKeyboard)(UIResponder *currentResponder);
    
+ (instancetype)sharedInstance;
    
- (BOOL)shouldBlockExtensionKeyboard;
    
@end

NS_ASSUME_NONNULL_END
