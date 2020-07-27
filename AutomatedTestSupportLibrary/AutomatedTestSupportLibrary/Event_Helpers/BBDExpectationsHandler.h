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

@interface BBDExpectationsHandler : NSObject

/**
 * Clears all the expectations for the given XCTestCase object.
 * @param testCase XCTestCase obejct to clear expectations.
 */
+ (void)clearExpectationsForTestCase:(XCTestCase *)testCase;

/**
 * Fulfills the expectations for the given XCTestCase object.
 * @param expectation expectation to be fulfilled.
 * @param testCase associated to the expectations XCTestCase object.
 */
+ (void)fullFillExpectation:(XCTestExpectation *)expectation forTestCase:(XCTestCase *)testCase;

/**
 * Adds the XCTestExpectation to the given XCTestCase.
 * @param expectation expectation that should be added.
 * @param testCase XCTestCase object to be associated with the given expectation.
 */
+ (void)addExpectation:(XCTestExpectation *)expectation forTestCase:(XCTestCase *)testCase;

/**
 * Adds the XCTestExpectations to the given XCTestCase.
 * @param expectations expectations that should be added.
 * @param testCase XCTestCase object to be associated with the given expectations.
 */
+ (void)addExpectations:(NSArray<XCTestExpectation *> *)expectations forTestCase:(XCTestCase *)testCase;

/**
 * Removes the XCTestExpectations from the given XCTestCase.
 * @param expectation expectation that should be removed.
 * @param testCase XCTestCase object that is associated with the given expectation.
 */
+ (void)removeExpectation:(XCTestExpectation *)expectation forTestCase:(XCTestCase *)testCase;

/**
 * Removes the XCTestExpectations from the given XCTestCase.
 * @param expectations expectations that should be removed.
 * @param testCase XCTestCase object that is associated with the given expectations.
 */
+ (void)removeExpectations:(NSArray<XCTestExpectation *> *)expectations forTestCase:(XCTestCase *)testCase;

@end
