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

#import <UIKit/UIKit.h>

//! Project version number for iOS_ATSL.
FOUNDATION_EXPORT double iOS_ATSLVersionNumber;

//! Project version string for iOS_ATSL.
FOUNDATION_EXPORT const unsigned char iOS_ATSLVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <iOS_ATSL/PublicHeader.h>

// Constants
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDPublicConstans.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDUIAccessibilityIdentifiers.h>

// Core
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDAutomatedTestSupport.h>

// Utilities
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDUITestUtilities.h>

// Event Helpers
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDConditionHelper.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDDragAndDropHelper.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDInputEventHelper.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDMultiAppTestHelper.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDTouchEventHelper.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDUITestAppLogic.h>

// Entities
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDProvisionData.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDUITestCaseRef.h>

// Categories
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/LAContext+BBDBiometryType.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/XCTestCase+Expectations.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/XCTestExpectation+DetachExpectation.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/XCUIDevice+BiometricsHelpers.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/XCUIDevice+TouchIDHelpers.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/XCUIDevice+HardwareKeyboardHelpers.h>

#import <BlackBerryDynamicsAutomatedTestSupportLibrary/ActivationTypeUI.h>
