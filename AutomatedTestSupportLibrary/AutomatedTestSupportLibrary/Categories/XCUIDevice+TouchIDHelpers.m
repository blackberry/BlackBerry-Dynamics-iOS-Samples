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

#import "XCUIDevice+TouchIDHelpers.h"

#import <LocalAuthentication/LocalAuthentication.h>
#include <notify.h>

@implementation XCUIDevice (TouchIDHelpers)

- (BOOL)isTouchIDEnrolled
{
    if (![self isTouchIDSupported])
    {
        return NO;
    }
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL isBiometricsAvailable = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return isBiometricsAvailable ? YES : (error.code != LAErrorTouchIDNotEnrolled);
}

- (BOOL)isTouchIDSupported
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL isBiometricsAvailable = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return isBiometricsAvailable ? YES : (error.code != LAErrorTouchIDNotAvailable);
}

- (BOOL)fingerTouchShouldMatch:(BOOL)shouldMatch
{
    const char *name;
    if (shouldMatch)
    {
        name = "com.apple.BiometricKit_Sim.fingerTouch.match";
    }
    else
    {
        name = "com.apple.BiometricKit_Sim.fingerTouch.nomatch";
    }
    return notify_post(name) == NOTIFY_STATUS_OK;;
}

@end
