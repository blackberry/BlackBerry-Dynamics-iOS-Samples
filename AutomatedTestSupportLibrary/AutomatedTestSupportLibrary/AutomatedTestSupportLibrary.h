/* Copyright (c) 2019 BlackBerry Ltd.
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

#import <UIKit/UIKit.h>

//! Project version number for iOS_ATSL.
FOUNDATION_EXPORT double iOS_ATSLVersionNumber;

//! Project version string for iOS_ATSL.
FOUNDATION_EXPORT const unsigned char iOS_ATSLVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <iOS_ATSL/PublicHeader.h>

// Constants
#import <AutomatedTestSupportLibrary/BBDPublicConstans.h>
#import <AutomatedTestSupportLibrary/BBDUIAccessibilityIdentifiers.h>

// Core
#import <AutomatedTestSupportLibrary/BBDAutomatedTestSupport.h>

// Utilities
#import <AutomatedTestSupportLibrary/BBDUITestUtilities.h>

// Event Helpers
#import <AutomatedTestSupportLibrary/BBDConditionHelper.h>
#import <AutomatedTestSupportLibrary/BBDDragAndDropHelper.h>
#import <AutomatedTestSupportLibrary/BBDInputEventHelper.h>
#import <AutomatedTestSupportLibrary/BBDMultiAppTestHelper.h>
#import <AutomatedTestSupportLibrary/BBDTouchEventHelper.h>
#import <AutomatedTestSupportLibrary/BBDUITestAppLogic.h>

// Entities
#import <AutomatedTestSupportLibrary/BBDProvisionData.h>
#import <AutomatedTestSupportLibrary/BBDUITestCaseRef.h>

// Categories
#import <AutomatedTestSupportLibrary/LAContext+BBDBiometryType.h>
#import <AutomatedTestSupportLibrary/XCTestCase+Expectations.h>
#import <AutomatedTestSupportLibrary/XCTestExpectation+DetachExpectation.h>
#import <AutomatedTestSupportLibrary/XCUIDevice+BiometricsHelpers.h>
#import <AutomatedTestSupportLibrary/XCUIDevice+TouchIDHelpers.h>
