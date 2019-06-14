/*
 * (c) 2018 BlackBerry Limited. All rights reserved.
 *
 */

#import "LAContext+BBDBiometryType.h"
#import <Availability.h>

#if !defined(__IPHONE_11_0)
// LABiometryType was introduced in iOS 11. We need to define it here to properly
// handle dynamic calls to [LAContext biometryType] when building SDK with Xcode 8.
typedef NS_ENUM(NSInteger, LABiometryType)
{
    LABiometryNone,
    LABiometryTypeTouchID,
    LABiometryTypeFaceID,
};
#endif


@implementation LAContext (BBDBiometryType)

- (BBDBiometryType)bbdBiometryType
{
    
    NSError *error = nil;
    BOOL isBiometricsAvailable = [self canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    if (!isBiometricsAvailable && (error.code == LAErrorBiometryNotAvailable))
    {
        NSLog(@"Device has no biometry support. Error: %@\n", error);
        return BBDBiometryTypeNone;
    }

    // If device is running iOS 10 (or earlier) we can assume that it
    // supports only Touch ID (there is no API for checking biometry type)
    if (![NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){11,0,0}]) {
        NSLog(@"Device runs iOS 10 or earlier, only TouchID is supported.\n");
        return BBDBiometryTypeTouchID;
    }

    // Device is running iOS 11 (or newer) so we can use biometryType property
#if defined(__IPHONE_11_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
    // SDK is compiled with SDK 11 (or newer) so we can access biometryType property
    LABiometryType biometryType = self.biometryType;
#else
    LABiometryType biometryType = LABiometryNone;

    // SDK is compiled with SDK 10 (or earlier) so we need to access biometryType property dynamically
    SEL biometryTypeSelector = NSSelectorFromString(@"biometryType");
    if ([self respondsToSelector:biometryTypeSelector])
    {
        NSMethodSignature *biometryTypeMethodSignature = [LAContext instanceMethodSignatureForSelector:biometryTypeSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:biometryTypeMethodSignature];
        [invocation setSelector:biometryTypeSelector];
        [invocation setTarget:self];
        [invocation invoke];

        // Get actual value of biometryType property
        [invocation getReturnValue:&biometryType];
    }
#endif

    // Just to make sure that we return proper BBDBiometryType in case the enum values
    // order is changed by clueless developer
    switch (biometryType)
    {
        case LABiometryTypeTouchID:
            NSLog(@"TouchID is supported and enabled.\n");
            return BBDBiometryTypeTouchID;

        case LABiometryTypeFaceID:
            NSLog(@"FaceID is supported and enabled.\n");
            return BBDBiometryTypeFaceID;

        case LABiometryNone:
            NSLog(@"No biometry.\n");
            return BBDBiometryTypeNone;
    }

    // Protection from Apple adding new values to LABiometryType enum.
    //
    // This is our way of making sure that we are prepared for new biometry types and
    // possible device with support for both Touch ID and Face ID. There is no way
    // to predict how such API will work but this will make sure that our biometry
    // processing flow won't enter unexpected paths.
    //
    // In worst case scenario biometry on such device will be disabled completely and
    // will require BBD SDK update.
    NSLog(@"Unexpected biometry type!.\n");
    return BBDBiometryTypeNone;
}

@end
