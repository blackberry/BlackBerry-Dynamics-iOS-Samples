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

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>

@interface BBDUITestUtilities : NSObject

/**
 * Search UI via application view hierarchy matching the specified conditions.
 *
 * @param type
 * target element type
 *
 * @param indentifier
 * accesibility label or indentifier or static text for target element
 *
 * @param containerElement
 * The application which is specified in the Xcode target settings as the "Target Application"
 *
 * @return XCUIElement mathching the searching arguments.
 */
+ (XCUIElement *)findElementOfType:(XCUIElementType)type withIndentifier:(NSString *)indentifier inContainer:(XCUIElement *)containerElement;

/**
 * Search UITableViewCell via table view hierarchy matching the specified conditions.
 *
 * @param staticText
 * Static text for target cell
 *
 * @param containerElement
 * The table which is specified as the "Target Table"
 *
 * @return XCUIElement mathching the searching arguments.
 */
+ (XCUIElement *)findRowWithStaticText:(NSString *)staticText inContainer:(XCUIElement *)containerElement;

/**
 * Search UITableViewCell via table view hierarchy matching the specified conditions.
 *
 * @param accessID
 * accesibility label or indentifier for target cell
 *
 * @param containerElement
 * The table which is specified as the "Target Table"
 *
 * @return XCUIElement mathching the searching arguments.
 */
+ (XCUIElement *)findRowWithAccessID:(NSString *)accessID inContainer:(XCUIElement *)containerElement;

/**
 * Search UITableViewCell via index number of cell matching to index of row in table.
 *
 * @param index
 * target element index
 *
 * @param containerElement
 * The application which is specified in the Xcode target settings as the "Target Application"
 *
 * @return XCUIElement mathching the searching arguments.
 */
+ (XCUIElement *)findRowByIndex:(NSInteger)index inContainer:(XCUIElement *)containerElement;

@end
