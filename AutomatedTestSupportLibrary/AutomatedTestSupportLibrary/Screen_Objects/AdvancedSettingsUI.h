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

#ifndef AdvancedSettingsUI_h
#define AdvancedSettingsUI_h

#import "ActivationTypeUI.h"

@interface AdvancedSettingsUI : ActivationTypeUI

@property XCUIElement* activationURLField;

- (instancetype)init;

/**
 * Enters activation URL
 * @param activationURL
 * activation URL to be entered
 */
- (BOOL)enterActivationURL:(NSString *) activationURL;

/**
 * Checks that advansed settings screen displayed, enters email, activation password and activation URLL and taps Go button on the keyboard.
 *
 * @param email - email to enter on activation screen
 * @param activationPassword - password to use in activation
 * @param activationURL - activation URL for activation
 */
- (BOOL)startActivationWithEmail:(NSString *)email
              activationPassword:(NSString *)activationPassword
                   activationURL:(NSString *)activationURL;

@end

#endif /* AdvancedSettingsUI_h */
