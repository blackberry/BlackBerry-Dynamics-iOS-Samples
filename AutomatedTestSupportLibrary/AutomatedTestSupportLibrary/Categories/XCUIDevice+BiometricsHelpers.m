/*
 * (c) 2018 BlackBerry Limited. All rights reserved.
 *
 */

#import "XCUIDevice+BiometricsHelpers.h"
#import "LAContext+BBDBiometryType.h"

#import <LocalAuthentication/LocalAuthentication.h>
#include <notify.h>

@implementation XCUIDevice (BiometricsHelpers)

- (BOOL)isBiometryEnrolled
{
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    BOOL isBiometricsAvailable = [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    return isBiometricsAvailable ? YES : (error.code != LAErrorBiometryNotEnrolled) && (error.code != LAErrorBiometryNotAvailable);
}

- (BOOL)isBiometrySupported
{
    return [self supportedBiometryType] != BBDBiometryTypeNone;
}

- (BOOL)setBiometricEnrollment:(BOOL)enrolled {
    int token;
    notify_register_check("com.apple.BiometricKit.enrollmentChanged", &token);
    notify_set_state(token, enrolled);
    return notify_post("com.apple.BiometricKit.enrollmentChanged") == NOTIFY_STATUS_OK;
}

- (BOOL)biometryShouldMatch:(BOOL)shouldMatch
{
    const char *name;
    if (shouldMatch) {
        name = "com.apple.BiometricKit_Sim.fingerTouch.match";
    }
    else {
        name = "com.apple.BiometricKit_Sim.fingerTouch.nomatch";
    }
    return notify_post(name) == NOTIFY_STATUS_OK;;
}

- (BBDBiometryType)supportedBiometryType
{
    LAContext *context = [LAContext new];
    if (!context) {
        return BBDBiometryTypeNone;
    }
    return context.bbdBiometryType;
}

@end
