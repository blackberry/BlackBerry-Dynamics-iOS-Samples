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

#import "BBDUITestCaseRef.h"
#import "BBDExpectationsHandler.h"

@implementation BBDUITestCaseRef

- (void)setApplication:(XCUIApplication *)application
{
    [BBDExpectationsHandler clearExpectationsForTestCase:self.testCase];
    _application = application;
}

- (instancetype)initWithTestCase:(XCTestCase *)testCase forApplication:(XCUIApplication *)application
{
    return [self initWithTestCase:testCase forApplication:application withPotentialDelegate:nil];
}

- (instancetype)initWithTestCase:(XCTestCase *)testCase
                  forApplication:(XCUIApplication *)application
           withPotentialDelegate:(XCUIApplication *)delegateApplication
{
    [BBDExpectationsHandler clearExpectationsForTestCase:testCase];
    self = [super init];
    if (self) {
        _testCase = testCase;
        _application = application;
        _potentialDelegateApplication = delegateApplication;
        _options = BBDTestOptionNone;
        _device = [XCUIDevice sharedDevice];
    }
    return self;
}

@end
