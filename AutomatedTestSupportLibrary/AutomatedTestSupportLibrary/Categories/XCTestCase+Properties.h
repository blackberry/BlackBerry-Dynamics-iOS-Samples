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

@interface XCTestCase (Properties)

// Removes all expecatations for current TestCase.
- (void)removeAllExpectations;

// Returns TestCaseRunt for current TestCase.
- (XCTestCaseRun *)testCaseRun;

// Getter to track signals during waiting for asynchronous expectations.
- (BOOL)isSignaled;

// Setter to track signals during waiting for asynchronous expectations.
- (void)setSignaled:(BOOL)isSignaled;

// Getter for array of XCTestExpectation of current XCTestCase.
- (NSMutableArray *)expectations;

// Setter for array of XCTestExpectation of current XCTestCase.
- (void)setExpectations:(NSMutableArray *)expectations;

@end
