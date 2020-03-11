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

@interface BBDTouchEventHelper : NSObject

+ (void)pressHome;

/**
 * Immediately taps XCUIElement using accessibility identifier to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param accessID
 * unique ID for the accessibility element to tap
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
+ (BOOL)tapOnItemOfType:(XCUIElementType)type
           withAccessID:(NSString *)accessID
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps XCUIElement using accessibility identifier to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param accessID
 * unique ID for the accessibility element to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
+ (BOOL)tapOnItemOfType:(XCUIElementType)type
           withAccessID:(NSString *)accessID
                timeout:(NSTimeInterval)timeout
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Immediately taps XCUIElement containing specific static text to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param text
 * text inside element which is used to find target for tap
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
+ (BOOL)tapOnItemOfType:(XCUIElementType)type
         containingText:(NSString *)text
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps XCUIElement containing specific static text to find appropriate object.
 * Method waits for element appearence and will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param text
 * text inside element which is used to find target for tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
+ (BOOL)tapOnItemOfType:(XCUIElementType)type
         containingText:(NSString *)text
                timeout:(NSTimeInterval)timeout
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using index of row in table view to find appropriate cell.
 * Method will fail test if cell isn't found or cell can not be tapped.
 *
 * @param indexRow
 * unique index for row to tap
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target cell is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowByIndex:(NSInteger)indexRow
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using index of row in table view to find appropriate cell.
 * Method will fail test if cell isn't found or cell can not be tapped.
 *
 * @param indexRow
 * unique index for row to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target cell is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowByIndex:(NSInteger)indexRow
                timeout:(NSTimeInterval)timeout
         forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using accessibility identifier to find appropriate row.
 * Method will fail test if row isn't found or row can not be tapped.
 *
 * @param accessID
 * unique ID for the accessibility row to tap
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target row is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowWithAccessID:(NSString *)accessID
              forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using accessibility identifier to find appropriate row.
 * Method will fail test if row isn't found or row can not be tapped.
 *
 * @param accessID
 * unique ID for the accessibility row to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target row is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowWithAccessID:(NSString *)accessID
                     timeout:(NSTimeInterval)timeout
              forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using static text to find appropriate row.
 * Method will fail test if row isn't found or row can not be tapped.
 *
 * @param staticText
 * Static text which is contained in cell to tap
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target row is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowWithStaticText:(NSString *)staticText
                forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps UITableViewCell using static text to find appropriate row.
 * Method will fail test if row isn't found or row can not be tapped.
 *
 * @param staticText
 * Static text which is contained in cell to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target row is tapped, otherwise test fails
 */
+ (BOOL)tapOnRowWithStaticText:(NSString *)staticText
                       timeout:(NSTimeInterval)timeout
                forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps XCUIElement containing specific static text to find appropriate object.
 * Method waits for element appearence and will fail test if element isn't found or element can not be tapped.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param text
 * text inside container to scroll
 *
 * @param timeout
 * The amount of time within scrollable container should appear
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target element is scrolled, otherwise test fails
 */
+ (BOOL)scrollContainerWithAccessID:(NSString*) accessID
                             toText:(NSString *)text
                            timeout:(NSTimeInterval)timeout
                     forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Taps XCUIElement containing specific static text to find appropriate object.
 * Method waits for element appearence and will fail test if element isn't found or element can not be tapped.
 *
 * @param textRow
 * text inside container to scroll
 *
 * @param collectionElement
 * Accessibility element which need scroll
 *
 * @param isScrollUp
 * Direction in which need to scroll
 *
 * @return YES, if target element is scrolled, otherwise test fails
 */
+ (BOOL)scrollToRow:(NSString *)textRow collectionViewElement:(XCUIElement *)collectionElement scrollUp:(BOOL)isScrollUp;

/**
 * Taps specific keyboard button and hides keyboard.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if keyboard is hidden, otherwise test fails
 */
+ (BOOL)hideKeyboard:(BBDUITestCaseRef *)testCaseRef;

@end
