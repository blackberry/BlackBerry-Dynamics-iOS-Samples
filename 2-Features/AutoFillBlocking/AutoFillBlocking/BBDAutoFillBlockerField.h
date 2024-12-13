/*
 * Copyright (c) 2018 BlackBerry Limited. All Rights Reserved.
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

NS_ASSUME_NONNULL_BEGIN

/*
 * This constant can be used to prevent AutoFill in UISearchBar and UITextView.
 * Modify textContentType of UISearchBar or UITextView to disable AutoFill suggestion for that instances.
 * It is also used by BBDAutoFillBlockerField to disable AutoFill.
 * Note: Dynamics Runtime already blocks textContentType property and prevents AufoFill
 * for UISearchBar and UITextView on App UI.
 */
static NSString *const BBDTextContentTypeUnspecified = @"";

// Notification about emoji input blocking.
// emoji input is blocked in secured BBDAutoFillBlockerField to match the system one.
extern NSString * _Nonnull const BBDEmojiInputBlockedNotification;

/** Text field for AutoFill Blocking.
 *
 * This class is a subclass of the native UITextField for AutoFill blocking.
 * AutoFill blocking is achieved by providing custom secureTextEntry implementation
 * and modifying textContentType property.
 * Custom secureTextEntry implementation tries to match the system one and includes:
 * - text obscuring with bullets.
 * - copy/paste blocking.
 * - text autocorrection prevention.
 *
 * Note: bullets appearance looks mostly the same as the system one, but not completely.
 * Modify secureTextFont property to set-up your own bullets font.
 *
 * Usage: to block AutoFill on a particular screen make sure
 * that all text fields on the screen inherit BBDAutoFillBlockerField.
 * If at least one UIView instance on the screen has secureTextEntry enabled,
 * then AutoFill suggestion may appear randomly on any other UITextField instances on the same screen.
 * See: https://openradar.appspot.com/radar?id=6070058497343488.
 * It is also true for UISearchBar and UITextView instances.
 * SecureTextEntry property in UISearchBar and UITextView instances doesn't affect an
 * AutoFill suggestions for that instances, but may affect UITextField instances.
 * To remove AutoFill suggestion on UISearchBar and UITextView instances, change textContentType
 * to BBDTextContentTypeUnspecified and don't use secureTextEntry.
 * Dynamic runtime already block textContentType property
 *
 */
@interface BBDAutoFillBlockerField : UITextField

/** Custom font for secureTextEntry bullets.
 *
 * Specify font for bullets shown when secureTextEntry is enabled.
 * In the case if no secureTextFont is specified,
 * The default alghoritm will be used to generate system-match font.
 *
 */
@property (nonatomic, strong, nullable) UIFont *secureTextFont;

/**
 *
 * Getter for secureTextEntry property.
 * Will be set to YES if secureTextEntry was set to YES.
 * isSecureTextEntry returns always NO for BBDAutoFillBlockerField.
 * Use bbdSecured property to determine if custom secureTextEntry implementation is used.
 *
 **/
@property (nonatomic, assign, readonly) BOOL bbdSecured;
    
@end

NS_ASSUME_NONNULL_END
