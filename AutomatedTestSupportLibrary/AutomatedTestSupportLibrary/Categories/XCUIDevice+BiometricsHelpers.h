/*
 * (c) 2018 BlackBerry Limited. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>

typedef NS_ENUM(NSInteger, BBDBiometryType) {
    BBDBiometryTypeNone,
    BBDBiometryTypeTouchID,
    BBDBiometryTypeFaceID,
};

@interface XCUIDevice (TouchIDHelpers)

/**
 * Returns YES if biometry is enrolled on device or simulator
 */
- (BOOL)isBiometryEnrolled;

/**
 * Returns YES if biometry is supported by device or simulator
 */
- (BOOL)isBiometrySupported;

/**
 * Enrolls or unenrolls the booted iOS simulator.
 *
 * @param enrolled determines if Touch ID / Face ID should be enrolled
 * @return YES if enrollment state was changed successfully, otherwise NO.
 */
- (BOOL)setBiometricEnrollment:(BOOL)enrolled;

/**
 * Matches or mismatches biometry request on simulator
 *
 * @param shouldMatch
 * determines if TouchID should be matched
 *
 * @return YES if the operation succeeds, otherwise NO.
 */
- (BOOL)biometryShouldMatch:(BOOL)shouldMatch;

/**
 * Returns biometry type supported by device or simulator
 */
- (BBDBiometryType)supportedBiometryType;


@end
