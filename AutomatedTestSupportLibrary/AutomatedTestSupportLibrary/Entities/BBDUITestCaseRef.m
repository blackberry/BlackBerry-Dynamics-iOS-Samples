/* Copyright (c) 2019 BlackBerry Ltd.
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

@implementation BBDUITestCaseRef

- (instancetype)initWithTestCase:(XCTestCase *)testCase forApplication:(XCUIApplication *)application
{
    self = [super init];
    if (self) {
        _testCase = testCase;
        _application = application;
        _options = BBDTestOptionNone;
        _device = [XCUIDevice sharedDevice];
    }
    return self;
}

@end
