/*
 * (c) 2017 BlackBerry Limited. All rights reserved.
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
