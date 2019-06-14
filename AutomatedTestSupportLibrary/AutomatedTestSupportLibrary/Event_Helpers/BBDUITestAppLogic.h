/* Copyright (c) 2019 BlackBerry Ltd.
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

@import Foundation;
@import XCTest;

#import "BBDProvisionData.h"

@class BBDUITestCaseRef;

@interface BBDUITestAppLogic : NSObject

/**
 * Checks that GD has sent the  GD Authorized callback (which needs to be sent before app code can run)
 * by testing presence of the unlock view on the screen waiting synchronously until fulfillment.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if unlock view is presented, otherwise NO.
 */
+ (BOOL)isBBDAuthorizedforTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which provisions application using email and access key provided inside BBDProvisionData object.
 * Checks any alert presence during activation process, interacts with textfield for input and buttons for next steps.
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param authType
 * Indicates application configuration status
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application was successfully provisioned, otherwise NO.
 */
+ (BOOL)provisionBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef ;

/**
 * Method which logins application using password provided inside BBDProvisionData object.
 * Checks any alert presence during login process, interacts with textfield for input and buttons for next steps.
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param authType
 * Indicates application configuration status
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */
+ (BOOL)loginBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which logins application or provisions it if needed using data provided inside BBDProvisionData object.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param authType
 * Indicates application configuration status
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application successfully completed login or provision operation, otherwise NO.
 */
+ (BOOL)loginOrProvisionBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which sets container password using data provided inside BBDProvisionData object
 * for first time after activation.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param password
 * container unlock password
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if container password was successfully setted, otherwise NO.
 */
+ (BOOL)setContainerPassword:(NSString *)password forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which inputs email using email and access key for activation screen.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param email
 * Email address which is used for activation
 *
 * @param accessKey
 * Provisioned Access Key
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if data was successfully typed, otherwise NO.
 */
+ (BOOL)enterEmail:(NSString *)email accessKey:(NSString *)accessKey forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for biometric unlock screen presence with Touch ID/Face ID popup.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if biometric unlock screen with biometric popup appeared, otherwise NO.
 */
+ (BOOL)waitForBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for biometric easy activation unlock screen presence with Touch ID/Face ID popup.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if biometric easy activation unlock screen with biometric popup appeared, otherwise NO.
 */
+ (BOOL)waitForEasyActivationBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for unlock screen presence
 *
 * @param idleLockInteval
 * The amount of time within which idle lock is expected (exect value depends upon GC policy)
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if unlock screen appeared, otherwise NO.
 */
+ (BOOL)waitForIdleLock:(NSTimeInterval)idleLockInteval forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for block screen presence
 *
 * @param timeout
 * The amount of time within which block screen is expected after unlock UI(login)
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if block screen appeared, otherwise NO.
 */

+ (BOOL)waitForBlockScreen:(NSTimeInterval)timeout
                  withData:(BBDProvisionData *)provisionData
            forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for remote lock screen presence.
 * Target application should be provisioned before.
 * Method logins application and then waits for remote lock screen.
 *
 * @param remoteLockTimeout
 * The amount of time within which remote lock is expected after container unlock
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if remote lock screen appeared, otherwise NO.
 */
+ (BOOL)waitForRemoteLock:(NSTimeInterval)remoteLockTimeout
                 withData:(BBDProvisionData *)provisionData
           forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for wipe/block screen presence.
 * Target application should be provisioned before.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if wipe/block screen appeared, otherwise NO.
 */
+ (BOOL)waitForContainerWipe:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Synchronously waits for provision UI screen presence.
 * Target application shouldn't be provisioned before or app was relaunched after container wipe.
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if provision screen appeared, otherwise NO.
 */
+ (BOOL)waitForProvisionScreenForTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Unlocks application which was previously locked by GC.
 * Target application should be provisioned before.
 * Method uses BBDProvisionData instance for all needed information .
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */

+ (BOOL)unLockBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which processes certificate enrollment screen using data provided inside BBDProvisionData object.
 * certificatesPasswords property is used for entering data into UI textfield.
 * Paswords should be given in order of certificates appearing.
 *
 * @param provisionData
 * instance of BBDProvisionData which contains data needed for UI interactions
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */
+ (BOOL)processPKSC12ScreenUsingData:(BBDProvisionData *)provisionData forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which processes client certificate enrollment screen using name and password.
 *
 * @param name
 * Name of client certificate
 *
 * @param password
 * Password for client certificate
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */
+ (BOOL)processPKSC12ClientCertificateWithName:(NSString *)name
                                      password:(NSString *)password
                                forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

/**
 * Method which processes certificate definition enrollment screen using name and password.
 *
 * @param name
 * Name of certificate definition
 *
 * @param password
 * Password for certificate definition
 *
 * @param testCaseRef
 * instance of BBDUITestCaseRef class
 * which properties should have references to XCUIApplication and XCTestCase objects to be tested
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */

+ (BOOL)processPKSC12CertificateDefinitionWithName:(NSString *)name
                                          password:(NSString *)password
                                    forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;

@end

