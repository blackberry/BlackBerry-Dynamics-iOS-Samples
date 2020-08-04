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

@interface BBDInputEventHelper : NSObject

/**
 * Immediately starts text input into XCUIElement using accessibility identifier to find appropriate container.
 * Method will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param accessID
 * unique ID for the accessibility element for input container
 *
 * @param type
 * target container element type
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
     withAccessID:(NSString *)accessID
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Starts text input into XCUIElement using accessibility identifier to find appropriate container.
 * Method waits for element appearence and will fail test if timeout is reached or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param accessID
 * unique ID for the accessibility element for input container
 *
 * @param type
 * target container element type
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
     withAccessID:(NSString *)accessID
          timeout:(NSTimeInterval)timeout
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Immediately starts text input into XCUIElement.
 * Method uses static text of container to find appropriate element through view hierarchy.
 * It will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param type
 * target container element type
 *
 * @param staticText
 * text inside container which is used to find target element for input operation
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
   containingText:(NSString *)staticText
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Starts text input into XCUIElement.
 * Method uses static text of container to find appropriate element through view hierarchy.
 * It will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param type
 * target container element type
 *
 * @param staticText
 * text inside container which is used to find target element for input operation
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
+ (BOOL)enterText:(NSString *)text
     inViewOfType:(XCUIElementType)type
   containingText:(NSString *)staticText
          timeout:(NSTimeInterval)timeout
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Starts text input into the element specified.
 *
 * @param element
 * XCUIElement to type text into
 *
 * @param text
 * text to type
 *
 * @param timeout
 * the amount of time within which expectation must be fulfilled
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class  which properties should have references to XCUIApplication and XCTestCase objects to be tested
 */
+ (BOOL)typeInElement:(XCUIElement *)element
                 text:(NSString *)text
              timeout:(NSTimeInterval)timeout
       forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Clears current text input of XCUIElement and paste a new text.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param element
 * instance of XCUIElement which text input should be modified
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is cleared and the new text is typed into container, otherwise test fails
 */
+ (BOOL)clearTextAndPaste:(NSString *)text
                  element:(XCUIElement *)element
           forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Clears current text input of XCUIElement.
 *
 * @param element
 * instance of XCUIElement which text input should be cleared
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if target text is cleared, otherwise test fails
 */
+ (BOOL)clearText:(XCUIElement *)element
   forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Creates string with XCUIKeyboardKeyDelete characters
 * which may be used to clean text input with specified string.
 *
 * @param textValue
 * string parameter for which clear string will be constructed
 *
 * @return string with XCUIKeyboardKeyDelete characters with the length of stringParam
 */
+ (NSString *)stringForTextCleaning:(NSString *)textValue;

@end
