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

#import "XCUIApplication+State.h"

static const NSTimeInterval APP_STATE_WAITING_TIMEOUT = 5.0f;

@implementation XCUIApplication (State)

- (BOOL)waitForUsableState
{
    return [self waitForUsableState:APP_STATE_WAITING_TIMEOUT];
}

- (BOOL)waitForUsableState:(NSTimeInterval)timeout
{
    NSTimeInterval timeToWait = MAX(timeout, APP_STATE_WAITING_TIMEOUT);
    if (self.state != XCUIApplicationStateRunningForeground)
    {
        return [self waitForState:XCUIApplicationStateRunningForeground timeout:timeToWait];
    }
    return YES;
}

- (NSString *)stringState
{
    switch (self.state)
    {
        case XCUIApplicationStateUnknown:
            return @"XCUIApplicationStateUnknown";
        case XCUIApplicationStateNotRunning:
            return @"XCUIApplicationStateNotRunning";
#if !TARGET_OS_OSX
        case XCUIApplicationStateRunningBackgroundSuspended:
            return @"XCUIApplicationStateRunningBackgroundSuspended";
#endif
        case XCUIApplicationStateRunningBackground:
            return @"XCUIApplicationStateRunningBackground";
        case XCUIApplicationStateRunningForeground:
            return @"XCUIApplicationStateRunningForeground";
    }
}

- (NSString *)invalidStateDescription
{
    return [NSString stringWithFormat:@"The application \"%@\" should Be Running in Foreground to detect element appearance (Сurrent state is %@).", self, [self stringState]];
}

@end
