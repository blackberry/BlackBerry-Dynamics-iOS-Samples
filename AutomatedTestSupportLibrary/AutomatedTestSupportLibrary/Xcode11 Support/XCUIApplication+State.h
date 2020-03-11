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
#import "BBDAutomatedTestSupport.h"

#define WAIT_FOR_TESTCASE_USABLE_STATE                                                                                  \
    NSAssert([testCaseRef.application waitForUsableState], [testCaseRef.application invalidStateDescription]);

#define WAIT_FOR_TESTCASE_USABLE_STATE_WITH_TIMEOUT                                                                     \
    NSAssert([testCaseRef.application waitForUsableState:timeout], [testCaseRef.application invalidStateDescription]);

#define WAIT_FOR_APPLICATION_USABLE_STATE                                                                               \
    XCUIApplication *application = [[BBDAutomatedTestSupport sharedInstance] getCurrentSetupApplication];               \
    NSAssert([application waitForUsableState], [application invalidStateDescription]);

#define CHECK_FOR_APPLICATION_USABLE_STATE                                                                              \
    XCUIApplication *application = [[BBDAutomatedTestSupport sharedInstance] getCurrentSetupApplication];               \
    BOOL appInUsableState = [application waitForUsableState:timeout];                                                   \
    if (!appInUsableState && !exists)                                                                                   \
    {                                                                                                                   \
        return;                                                                                                         \
    }                                                                                                                   \
    else                                                                                                                \
    {                                                                                                                   \
        NSAssert(appInUsableState, [application invalidStateDescription]);                                              \
    }

@interface XCUIApplication (State)

- (BOOL)waitForUsableState;
- (BOOL)waitForUsableState:(NSTimeInterval)timeout;
- (NSString *)invalidStateDescription;

@end
