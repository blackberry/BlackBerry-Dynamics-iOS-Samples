/*
 * (c) 2017 BlackBerry Limited. All rights reserved.
 *
 */

#import <LocalAuthentication/LocalAuthentication.h>
#import "XCUIDevice+BiometricsHelpers.h"

@interface LAContext (BBDBiometryType)

- (BBDBiometryType)bbdBiometryType;

@end
