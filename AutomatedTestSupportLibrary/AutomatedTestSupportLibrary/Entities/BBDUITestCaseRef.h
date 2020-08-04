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

#ifndef BBDUITestCaseRef_h
#define BBDUITestCaseRef_h

#import "GDUIApplication.h"
#import "BBDPublicConstans.h"

@interface BBDUITestCaseRef : NSObject

@property (nonatomic, strong) GDUIApplication *application;
@property (nonatomic, weak) XCUIApplication *potentialDelegateApplication;
@property (nonatomic, weak) XCUIDevice *device;
@property (nonatomic, weak) XCTestCase *testCase;
@property (nonatomic) BBDTestOption options;

/**
 * Creates BBDUITestCaseRef instance using XCTestCase and XCUIApplication.
 * Mostly every action for UI testing requires reference to XCUIApplication class - 
 * so we can access element inside view hierarchy, and optionally XCTestCase reference 
 * for such methods like wait, etc.
 * Use this initializer to instantiate object for helper's methods (if needed).
 *
 * @param testCase
 * instance of XCTestCase object
 *
 * @param application
 * instance of target XCUIApplication object
 *
 * @return BBDUITestCaseRef instance, which is used inside helpers to provide target functionality.
 */
- (instancetype)initWithTestCase:(XCTestCase *)testCase
                  forApplication:(XCUIApplication *)application;

/**
 * Creates BBDUITestCaseRef instance using XCTestCase and XCUIApplication.
 * Mostly every action for UI testing requires reference to XCUIApplication class -
 * so we can access element inside view hierarchy, and optionally XCTestCase reference
 * for such methods like wait, etc.
 * Use this initializer to instantiate object for helper's methods (if needed).
 *
 * @param testCase
 * instance of XCTestCase object
 *
 * @param application
 * instance of target XCUIApplication object
 *
 * @param delegateApplication
 * instance of target XCUIApplication object
 *
 * @return BBDUITestCaseRef instance, which is used inside helpers to provide target functionality.
 */
- (instancetype)initWithTestCase:(XCTestCase *)testCase
                  forApplication:(XCUIApplication *)application
           withPotentialDelegate:(XCUIApplication *)delegateApplication;

@end

#endif /*BBDUITestCaseRef_h*/
