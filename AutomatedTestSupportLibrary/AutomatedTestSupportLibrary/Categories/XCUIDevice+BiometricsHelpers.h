/* Copyright (c) 2017 - 2020 BlackBerry Limited.
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

#import <XCTest/XCTest.h>

typedef NS_ENUM(NSInteger, BBDBiometryType) {
    BBDBiometryTypeNone,
    BBDBiometryTypeTouchID,
    BBDBiometryTypeFaceID,
};

@interface XCUIDevice (TouchIDHelpers)

/**
 * Returns YES if biometry is enrolled on device or simulator
 */
- (BOOL)isBiometryEnrolled;

/**
 * Returns YES if biometry is supported by device or simulator
 */
- (BOOL)isBiometrySupported;

/**
 * Enrolls or unenrolls the booted iOS simulator.
 *
 * @param enrolled determines if Touch ID / Face ID should be enrolled
 * @return YES if enrollment state was changed successfully, otherwise NO.
 */
- (BOOL)setBiometricEnrollment:(BOOL)enrolled;

/**
 * Matches or mismatches biometry request on simulator
 *
 * @param shouldMatch
 * determines if TouchID should be matched
 *
 * @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)biometryShouldMatch:(BOOL)shouldMatch;

/**
 * Returns biometry type supported by device or simulator
 */
- (BBDBiometryType)supportedBiometryType;


@end
