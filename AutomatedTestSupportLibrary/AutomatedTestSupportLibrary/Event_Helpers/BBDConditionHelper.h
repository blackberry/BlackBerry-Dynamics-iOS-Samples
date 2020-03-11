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

@import Foundation;
@import XCTest;

@class BBDUITestCaseRef;

@interface BBDConditionHelper : NSObject

/**
 * Immediately verifies the presence of specified view on the screen.
 *
 * @param accessID 
 * unique ID for the accessibility element
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class 
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target screen is shown on the screen, otherwise returns NO
 */
+ (BOOL)isScreenShown:(NSString *)accessID forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Verifies presence of the specified view on the screen waiting synchronously until fulfillment 
 * or the amount of time specified in timeout parameter.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target screen is shown on the screen, otherwise test fails
 */
+ (BOOL)isScreenShown:(NSString *)accessID timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Immediately verifies presence of the specified text on the screen.
 *
 * @param text
 * target text which is searched on the view
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is shown on the screen, otherwise returns NO
 */
+ (BOOL)isTextShown:(NSString *)text forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Verifies presence of the specified text on the screen waiting synchronously until fulfillment
 * or the amount of time specified in timeout parameter.
 *
 * @param text
 * target text which is searched on the view
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target screen is shown on the screen, otherwise test fails
 */
+ (BOOL)isTextShown:(NSString *)text timeout:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Verifies presence of the specified alert by accessibility identifier on the screen 
 * waiting synchronously until fulfillment or the amount of time specified in timeout parameter
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target screen is shown on the screen, 
 *          NO, if failTestOnTimeout is set to NO, otherwise test fails
 */
+ (BOOL)isAlertShownWithAccessID:(NSString *)accessID
                         timeout:(NSTimeInterval)timeout
                  forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Verifies presence of the specified alert with static text on the screen
 * waiting synchronously until fulfillment or the amount of time specified in timeout parameter
 *
 * @param staticText
 * target static text which is searched on the view
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target screen is shown on the screen,
 *          NO, if failTestOnTimeout is set to NO, otherwise test fails
 */
+ (BOOL)isAlertShownWithStaticText:(NSString *)staticText
                           timeout:(NSTimeInterval)timeout
                    forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * draft
 *
 * @param identifier
 * draft
 *
 * @param type
 * draft
 *
 * @param timeout
 * draft
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class,
 * properties should have actual value for application and testCase to be tested
 *
 * @return YES, draft,
 *          NO, draft.
 */
+ (BOOL)isElementShownWithIdentifier:(NSString *)identifier
                              ofType:(XCUIElementType)type
                             timeout:(NSTimeInterval)timeout
                      forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Immediately verifies presence of specific keyboard element.
 * It also verifies that keyboard element is presented on the screen and is hittable.
 *
 * @param element
 * instance of XCUIElement which representes specific element of keyboard
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class,
 * properties should have actual value for application and testCase to be tested
 *
 * @return YES, if target element is shown on the screen and is hittable
 */
+ (BOOL)isKeyboardElementHittable:(XCUIElement *)element
                   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Immediately verifies presence of keyboard.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class,
 * properties should have actual value for application and testCase to be tested
 *
 * @return YES, if target element is shown on the screen and is hittable
 */
+ (BOOL)isKeyboardShown:(BBDUITestCaseRef *)testCaseRef;

@end
