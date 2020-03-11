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


#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS __attribute__((deprecated("XCUIDevice+TouchIDHelpers extension has been deprecated, use XCUIDevice+BiometricsHelpers instead.")))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDENROLLED __attribute__((deprecated("Use XCUIDevice+BiometricsHelpers isBiometryEnrolled instead.")))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDSUPPORTED __attribute__((deprecated("Use XCUIDevice+BiometricsHelpers isBiometrySupported instead.")))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_FINGERTOUCHSHOULDMATCH __attribute__((deprecated("Use XCUIDevice+BiometricsHelpers biometryShouldMatch instead.")))
#else
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS __attribute__((deprecated))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDENROLLED __attribute__((deprecated))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDSUPPORTED __attribute__((deprecated))
#   define DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_FINGERTOUCHSHOULDMATCH __attribute__((deprecated))
#endif

DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS
@interface XCUIDevice (TouchIDHelpers)

/** isTouchIDEnrolled (deprecated).
*
* \deprecated This public method is deprecated and will be removed in a
* future release. Use
* \link XCUIDevice+BiometricsHelpers::isBiometryEnrolled\endlink
* instead.
*/
- (BOOL)isTouchIDEnrolled DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDENROLLED;

/** isTouchIDSupported (deprecated).
 *
 * \deprecated This public method is deprecated and will be removed in a
 * future release. Use
 * \link XCUIDevice+BiometricsHelpers::isBiometrySupported\endlink
 * instead.
 */
- (BOOL)isTouchIDSupported DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDSUPPORTED;

/** fingerTouchShouldMatch (deprecated).
 *
 * \deprecated This public method is deprecated and will be removed in a
 * future release. Use
 * \link XCUIDevice+BiometricsHelpers::biometryShouldMatch:\endlink
 * instead.
 */
- (BOOL)fingerTouchShouldMatch:(BOOL)shouldMatch DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_FINGERTOUCHSHOULDMATCH;

@end

#undef DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS
#undef DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDENROLLED
#undef DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_ISTOUCHIDSUPPORTED
#undef DEPRECATE_XCUIDEVICE_TOUCHIDHELPERS_FINGERTOUCHSHOULDMATCH
