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

typedef BOOL (^actionBlock)(XCUIApplication* application);

@interface BBDMultiAppTestHelper : NSObject

/**
 * Use this method to add block of test commands for an application based on its bundle identifier
 * Block is added to queue.
 * When block is invoked instance of used XCUIApplication is passed.
 * No need to call launch or activate, application is ready to be tested when it comes to block.
 *
 * @param appID
 * bundle identifier of application, nil argument will create main target application
 *
 * @param actionBlock
 * The block of test instructions to be executed under specific application
 *
 */
- (void) addTestCommandsForApplication:(NSString*)appID withBlock: (actionBlock) actionBlock;

/**
 * Use this method to execute all test commands which were previously added.
 * Blocks are executed synchronously in the same order they were added before.
 * Method uses - (void)activate of XCUIApplication
 * So it can be called before application is actually flipped by main application request
 * This will loose previous context and application will be launched from cold start
 * It's client code responsibility to track active application change using
 * expectation. Ensure that last test command waits for UI dissapearing
 * code can not rely on state property since currently it returns
 * XCUIApplicationStateRunningForeground for every previously activated application.
 * After all commands are completed, helper clears queue.
 *
 */
- (void) runTest;

@end
