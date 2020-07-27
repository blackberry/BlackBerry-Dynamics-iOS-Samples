/* Copyright (c) 2020 BlackBerry Limited.
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

#ifndef BBDActivationUI_h
#define BBDActivationUI_h

#import "AbstractBBDUI.h"

static NSString* const SHOW_PASSWORD_ICON_ID = @"showActive";

/**
 * Represents an ActivationUI instance, which are ActivationUI, ForgotPasswordUI and "Remote" unlock UI.
 * Basically, it is a UI with 2 fields - Email and Activation Password (S-series SDK).
 */
@interface ActivationTypeUI : AbstractBBDUI

@property XCUIElement* emailField;
@property XCUIElement* activationPasswordField;
@property XCUIElement* showPasswordButton;
@property XCUIElement* bottomInfoButton;

- (instancetype)init;
- (instancetype)initWithId:(NSString *)screenId;

/**
 * Enters passed email to the corresponding field.
 *
 * @param email email to be entered
 */
- (BOOL)enterEmail:(NSString *)email;

/**
 * Enters passed activation password to the corresponding field.
 *
 * @param activationPassword activation password to be entered
 */
- (BOOL)enterActivationPassword:(NSString *)activationPassword;

/**
 * Taps an eye icon which indicates showing password instead of * and vice versa.
 */
- (BOOL)showPassword;

/**
 * Tap on bottom info button to open/close Advanced settings
 */
- (BOOL)clickBottomInfoButton;

/**
 * Checks that activation UI is shown, enters email, activation password and taps Go button on the keyboard, after which waits for activation UI to dissappear.
 *
 * @param email email to use for activation
 * @param activationPassword activation password to use
 */
- (BOOL)startActivationWithEmail:(NSString *)email activationPassword:(NSString *)activationPassword;

/**
 * Clears email and key fields.
 *
 * @return success of the fields cleaning
 */
- (BOOL)clearFields;

@end

#endif /* BBDActivationUI_h */
