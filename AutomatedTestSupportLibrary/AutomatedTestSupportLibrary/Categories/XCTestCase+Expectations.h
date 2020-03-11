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

@import XCTest;

@interface XCTestCase (Expectations)

/**
 * Category variant of waitForExpectationsWithTimeout:handler: with the following differences:
 * Waits for a specified expectation, not all expectations.
 * Can ignore time out expiry, or treat it as a test fail.
 *
 * @param expectation
 * An expected outcome in an asynchronous test
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param failTestOnTimeout
 * Parameter can be used to make the test continue after timeout if param is NO;
 * YES value will fail test on timeout (as default Apple implementation works)
 *
 * @param handler
 * If provided, the handler will be invoked both on timeout or fulfillment of all
 * expectations. Timeout is treated as a test failure only when failTestOnTimeout set to YES.
 *
 */
- (void)waitForExpectation:(nonnull XCTestExpectation *)expectation
                withTimeout:(NSTimeInterval)timeout
          failTestOnTimeout:(BOOL)failTestOnTimeout
                    handler:(nullable XCWaitCompletionHandler)handler;

/**
 * Synchronously waits for element appearance
 *
 * @param targetUIObject
 * UI element which appearance is expected
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param handler
 * If provided, the handler will be invoked both on timeout or fulfillment of all
 * expectations. Timeout is treated as a test failure.
 *
 */
- (void)waitForElementAppearance:(nonnull XCUIElement *)targetUIObject
                          timeout:(NSTimeInterval)timeout
                failTestOnTimeout:(BOOL)failTestOnTimeout
                          handler:(nullable XCWaitCompletionHandler)handler;

- (void)waitForElementDisappearance:(nonnull XCUIElement *)targetUIObject
                             timeout:(NSTimeInterval)timeout
                   failTestOnTimeout:(BOOL)failTestOnTimeout
                             handler:(nullable XCWaitCompletionHandler)handler;

/**
 * Synchronously waits for element getting hittable
 *
 * @param targetUIObject
 * UI element which is expected to be hittable
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @param handler
 * If provided, the handler will be invoked both on timeout or fulfillment of all
 * expectations. Timeout is treated as a test failure.
 *
 */
- (void)waitForElementGetHittable:(nonnull XCUIElement *)targetUIObject
                          timeout:(NSTimeInterval)timeout
                failTestOnTimeout:(BOOL)failTestOnTimeout
                          handler:(nullable XCWaitCompletionHandler)handler;

/**
 * Synchronously waits for any from detached expectations.
 * Sometimes we need to have any of expectations fulfilled
 *
 * @param expectations
 * Expectations which were created by detachedExpectationForPredicate:evaluatedWithObject:handler call only
 *
 * @param timeout
 * The amount of time within which any of expectations must be fulfilled
 *
 * @param failTestOnTimeout
 * Parameter can be used to make the test continue after timeout if param is NO;
 * YES value will fail test on timeout (as default Apple implementation works)
 *
 * @param handler
 * If provided, the handler will be invoked both on timeout or fulfillment of all
 * expectations. Timeout is treated as a test failure.
 *
 */

- (void)waitForAnyDetachedExpectation:(nonnull NSArray<XCTestExpectation*> *)expectations
                          withTimeout:(NSTimeInterval)timeout
                    failTestOnTimeout:(BOOL)failTestOnTimeout
                              handler:(nullable XCWaitCompletionHandler)handler;

/**
 * Creates detached expectation that is fulfilled if the predicate returns true when evaluated with the given
 * object. It is used by waitForAnyDetachedExpectation:withTimeout:failTestOnTimeout:handler
 * Sometimes we need to have any of expectations fulfilled
 *
 * @param predicate
 * Expectations which were created by detachedExpectationForPredicate:evaluatedWithObject:handler call only
 *
 * @param object
 * The amount of time within which any of expectations must be fulfilled
 *
 * @param handler
 * If provided, the handler will be invoked both on timeout or fulfillment of all
 * expectations. Timeout is treated as a test failure.
 *
 */

- (nonnull XCTestExpectation *)detachedExpectationForPredicate:(nonnull NSPredicate *)predicate
                                           evaluatedWithObject:(nonnull id)object
                                                       handler:(nullable XCPredicateExpectationHandler)handler;

@end
