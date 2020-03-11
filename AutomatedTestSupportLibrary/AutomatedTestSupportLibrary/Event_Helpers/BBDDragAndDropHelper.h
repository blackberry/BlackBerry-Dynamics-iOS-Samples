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

typedef NS_ENUM(NSInteger, BBDDragAndDropTestResult)
{
    BBDDragAndDropResultTextDragged, // Specified text was dragged
    BBDDragAndDropResultTextNotDragged, // Specified text was not dragged
    BBDDragAndDropResultError // Test failed for some reasons(incorrect argument were passed, text selection failed and others)
};

@interface BBDDragAndDropHelper : NSObject

/**
 * Check if split sreeen is shown with app.
 *
 * @param app
 * XCUIApplication instance which is needed to be checked for being presented on the screen with split screen mode.
 *
 * @return YES, if target app is presented on the screen with split screen mode.
 */
+ (BOOL)isSplitScreenShown:(XCUIApplication *)app;

/**
 * Open split screen for target apps.
 * Second app will be added to a split screen even if the split screen is already opened with another app.
 * In this case a new app will shown instead of existing one.
 * Method works only in portrait orientation.
 *
 * @param currentApp
 * XCUIApplication instance which is already presented on the screen.
 *
 * @param secondApp
 * XCUIApplication instance which should be added to a split screen.
 *
 * @param secondAppName
 * Product name for the second app. Will be used to match appropriative icon in suggestion menu.
 *
 * @return YES, if second app was successfully added on the split screen.
 */
+ (BOOL)openSplitScreen:(XCUIApplication *)currentApp
              secondApp:(XCUIApplication *)secondApp
          secondAppName:(NSString *)secondAppName;

/**
 * Drag and drop operation from simple UITableView or UICollectionView cell to text field/text view.
 * Destination field will be cleared before drag and drop operation.
 *
 * @param cell
 * Simple cell of UITableView or UICollectionView. Cell should have only text.
 *
 * @param field
 * XCUIElement instance of text field/ text view where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropTableCell:(XCUIElement *)cell
                                       destField:(XCUIElement *)field
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation from text field to table view/ collection view.
 *
 * @param sourceField
 * XCUIElement instance of text field which text will be dragged.
 *
 * @param destTable
 * Table view/ collection view instance where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceField
                                         toTable:(XCUIElement *)destTable
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation from text field/text view to alert field.
 *
 * @param sourceField
 * XCUIElement instance of text field which text will be dragged.
 *
 * @param destEl
 * Alert field where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceField
                                    toAlertField:(XCUIElement *)destEl
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation from text field/text view to webview field.
 * Webview field will be cleared before drag and drop operation.
 *
 * @param sourceTextField
 * XCUIElement instance of text field/text view which text will be dragged.
 *
 * @param destEl
 * Webview field where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceTextField
                                      toWebField:(XCUIElement *)destEl
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation from web text to text field/text view.
 * Destination field will be cleared before drag and drop operation.
 *
 * @param webText
 * Text element of webview which text will be dragged.
 *
 * @param destElement
 * Destination field where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropWebText:(XCUIElement *)webText
                              destinationField:(XCUIElement *)destElement
                                     sourceApp:(XCUIApplication *)sourceApp
                                destinationApp:(XCUIApplication *)destApp
                                   forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation from text field/text view to text field/text view.
 * Destination field will be cleared before drag and drop operation.
 *
 * @param sourceTextField
 * Text field which text will be dragged.
 *
 * @param destElement
 * Destination field where text will be dropped.
 *
 * @param sourceApp
 * XCUIApplication instance of source app from which text will be dragged.
 *
 * @param destApp
 * XCUIApplication instance of destination app where text will be dropped.
 *
 * @return BBDDragAndDropTestResult with the result of drag and drop operation.
 */
+ (BBDDragAndDropTestResult)dragAndDropTextField:(XCUIElement *)sourceTextField
                            destinationTextField:(XCUIElement *)destElement
                                       sourceApp:(XCUIApplication *)sourceApp
                                  destinationApp:(XCUIApplication *)destApp
                                     forTestCase:(XCTestCase *)testCase;

/**
 * Drag and drop operation between two elements.
 * This method simply makes drag and drop operation by pressing on the source element and dragging it to the destination one.
 * This method is not responsible for text selection of source element, text clearing and keyboard events.
 * Use value comparison to determine if drag and drop operation is successfull.
 *
 * @param sourceEl
 * An XCUIElement instance which will be dragged.
 *
 * @param destElement
 * Destination element where text will be dropped.
 */
+ (void)dragAndDropElement:(XCUIElement *)sourceEl
        destinationElement:(XCUIElement *)destElement;
@end
