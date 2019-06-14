/*
 * (c) 2017 BlackBerry Limited. All rights reserved.
 *
 */

#import <XCTest/XCTest.h>

//This category is used by ATS sources internally.
//No need to call this method directly from tests.
@interface XCTestExpectation (DetachExpectation)

- (BOOL)isDetached;
- (void)setDetached:(BOOL)isDetached;

@end
