/* Copyright (c) 2020 BlackBerry Limited.
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

#import "GDUIApplication.h"
#import "XCUIApplication+State.h"

static const NSTimeInterval APP_STATE_WAITING_TIMEOUT = 5.0f;

@implementation GDUIApplication

- (instancetype)initWithBundleIdentifier:(NSString *)bundleIdentifier
{
    self = [super initWithBundleIdentifier:bundleIdentifier];
    if (self)
    {
        _expectedState = GDUIApplicationStateForeground;
    }
    return self;
}

- (BOOL)hasUsableState
{
    if (self.state == XCUIApplicationStateUnknown || self.state == XCUIApplicationStateNotRunning)
    {
        NSLog(@"Application is in unusable state: %lu", self.state);
        return NO;
    }
    
    switch (self.expectedState)
    {
        case GDUIApplicationStateAny:
        {
            return self.state == XCUIApplicationStateRunningForeground || self.state == XCUIApplicationStateRunningBackground;
        }
        case GDUIApplicationStateForeground:
        {
            return self.state == XCUIApplicationStateRunningForeground;
        }
        case GDUIApplicationStateBackground:
        {
            return self.state == XCUIApplicationStateRunningBackground || self.state == XCUIApplicationStateRunningBackgroundSuspended;
        }
    }
}

- (BOOL)waitForUsableState
{
    return [self waitForUsableState:APP_STATE_WAITING_TIMEOUT];
}

- (BOOL)waitForUsableState:(NSTimeInterval)timeout
{
    switch (self.expectedState)
    {
        case GDUIApplicationStateAny:
        {
            
            int i = timeout / 1.f;
            
            for (int j = 0; j < i; j++) {
                if (self.state == XCUIApplicationStateRunningForeground || self.state == XCUIApplicationStateRunningBackground) {
                    return YES;
                }
                NSLog(@"Waiting for state Foreground or Background. Current state: %d", self.state);
                sleep(1);
            }
            
            return NO;
        }
        case GDUIApplicationStateForeground:
        {
            return [self waitForState:XCUIApplicationStateRunningForeground timeout:timeout];
        }
        case GDUIApplicationStateBackground:
        {
            return [self waitForState:XCUIApplicationStateRunningBackground timeout:timeout] ||
                   [self waitForState:XCUIApplicationStateRunningBackgroundSuspended timeout:timeout];
        }
    }
}

@end
