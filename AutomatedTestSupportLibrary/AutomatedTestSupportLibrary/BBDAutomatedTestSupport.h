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

@import Foundation;
@import XCTest;

#import "BBDProvisionData.h"
#import "BBDPublicConstans.h"
#import "BBDUITestCaseRef.h"
#import "ActivationTypeUI.h"
#import "GDUIApplication.h"

@interface BBDAutomatedTestSupport : NSObject

@property (nonatomic, strong) BBDProvisionData *provisionData;

@property (nonatomic) BBDTestOption options;

/**
 * Get singleton instance of BBDAutomatedTestSupport class
 *
 * @return singleton instance of BBDAutomatedTestSupport
 */
+ (instancetype)sharedInstance;

/**
 * Set apps list that were installed by DeepTest before test starts.
 * This method was added as a part of EasyActivation flow changes.
 */
- (void)setInstalledApps:(NSArray *)installedApps;

/**
 * Get apps list that were installed by DeepTest before test starts.
 * This method was added as a part of EasyActivation flow changes.
 * 
 * @return apps list
 */
- (NSArray *)getInstalledApps;

/**
 * Fetches BBDProvisionData instance from JSON file by given location.
 * This method uses defined structure for file contents.
 * JSON string should have the following format:
 *
 * {
 *  "GD_TEST_PROVISION_EMAIL":"PROVIDE_YOUR_EMAIL",
 *  "GD_TEST_PROVISION_PASSWORD":"PROVIDE_YOUR_CONTAINER_PASSWORD",
 *  "GD_TEST_PROVISION_ACCESS_KEY":"PROVIDE_YOUR_ACCESS_KEY",
 *  "GD_TEST_UNLOCK_KEY":"PROVIDE_YOUR_UNLOCK_KEY",
 *  "GD_TEST_CERTIFICATES_PASSWORDS":["PROVIDE_YOUR_PASSWORD"],
 *  "GD_TEST_CERTIFICATES":[{
 *                           "GD_TEST_CERTIFICATE_TYPE":"GD_TEST_CERTIFICATE_TYPE_CERTIFICATE_DEFINITION",
 *                           "GD_TEST_CERTIFICATE_NAME":"PROVIDE_YOUR_CERTIFICATE_NAME",
 *                           "GD_TEST_CERTIFICATE_PASSWORD":"PROVIDE_YOUR_CERTIFICATE_PASSWORD"
 *                          },
 *                          {
 *                           "GD_TEST_CERTIFICATE_TYPE":"GD_TEST_CERTIFICATE_TYPE_CLIENT_CERTIFICATE",
 *                           "GD_TEST_CERTIFICATE_FILE_NAME":"PROVIDE_YOUR_CERTIFICATE_FILE_NAME",
 *                           "GD_TEST_CERTIFICATE_NAME":"PROVIDE_YOUR_CERTIFICATE_NAME",
 *                           "GD_TEST_CERTIFICATE_PASSWORD":"PROVIDE_YOUR_CERTIFICATE_PASSWORD"
 *                          }]
 * }
 *
 * @param path
 * absolute path for JSON file location.
 *
 * @return YES if credentials were fetched without errors, otherwise NO
 */
- (BOOL)fetchCredentialsFromFileAtPath:(NSString *)path;

/**
 * Basic setup of automated test framework.
 * This method should be called for every time new XCUIApplication or XCTestCase object was created under UITest target
 *
 * @param application
 * instance of target XCUIApplication object
 *
 * @param testcase
 * instance of XCTestCase object
 *
 */
- (void)setupBBDAutomatedTestSupportWithApplication:(XCUIApplication *)application forTestCase:(XCTestCase *)testcase;


/**
 * Basic setup of automated test framework.
 * This method should be called for every time new XCUIApplication or XCTestCase object was created under UITest target
 *
 * @param application
 * instance of target XCUIApplication object
 *
 * @param potentialDelegateApplication
 * instance of target XCUIApplication object
 *
 * @param testcase
 * instance of XCTestCase object
 *
 */
- (void)setupBBDAutomatedTestSupportWithApplication:(XCUIApplication *)application withPotentialDelegate:(XCUIApplication *)potentialDelegateApplication forTestCase:(XCTestCase *)testcase;

/**
 * @return the application ats is currently configured for.
 */
- (GDUIApplication *)getCurrentSetupApplication;

/**
 * @return BBDUITestCaseRef for which ATS is currently configured.
 */
- (BBDUITestCaseRef *)getCurrentSetupTestCaseRef;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                    BBDUITestAppLogic / GDiOS action triggers/handlers
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Wait for enter user password screen after timeout
 *
 * @param idleLockInterval
 * value of idle timeout
 *
 * @return YES, if app requires to enter password after idle timeout, otherwise returns NO
 */
- (BOOL)waitForIdle:(NSTimeInterval)idleLockInterval;

/**
 * Explicit wait for specified time interval.
 *
 * @param interval time to wait
 * @param testCase instance of XCTestCase to wait for
 */
- (void)explicitWait:(NSTimeInterval)interval forTestCase:(XCTestCase *)testCase;

/**
 * Checks that GD has sent the  GD Authorized callback (which needs to be sent before app code can run)
 * by testing presence of the unlock view on the screen waiting synchronously until fulfillment.
 *
 * @return YES, if unlock view is presented, otherwise NO.
 */
- (BOOL)isBBDAppAuthorized;

/**
 * Method which provisions application using email and access key.
 * Checks any alert presence during activation process, interacts with textfield for input and buttons for next steps.
 *
 * @return YES, if application was successfully provisioned, otherwise NO.
 */
- (BOOL)provisionBBDApp;

/**
 * Method which provisions application using email and access key.
 * Checks any alert presence during activation process, interacts with textfield for input and buttons for next steps.
 *
 * @param authType
 * Indicates application configuration status
 *
 * @return YES, if application was successfully provisioned, otherwise NO.
 */
- (BOOL)provisionBBDAppWithAuthType:(BBDAuthType)authType;

/**
 * Method which logins application using password.
 * Checks any alert presence during login process, interacts with textfield for input and buttons for next steps.
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */
- (BOOL)loginBBDApp;

/**
 * Method which logins application using password.
 * Checks any alert presence during login process, interacts with textfield for input and buttons for next steps.
 *
 * @param authType
 * Indicates application configuration status
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */
- (BOOL)loginBBDAppWithAuthType:(BBDAuthType)authType;

/**
 * Method which logins application or provisions it if needed.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @return YES, if application successfully completed login or provision operation, otherwise NO.
 */

- (BOOL)loginOrProvisionBBDApp;

/**
 * Method which logins application or provisions it if needed.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param authType
 * Indicates application configuration status
 *
 * @return YES, if application successfully completed login or provision operation, otherwise NO.
 */

- (BOOL)loginOrProvisionBBDAppWithAuthType:(BBDAuthType)authType;

/**
 * Method which inputs email using email and access key provided by provisionData property for activation screen.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @deprecated
 *  Access Key is now renamed into Activation Password
 *
 * @return YES, if data was successfully typed, otherwise NO.
 */
- (BOOL)enterEmailAccessKey DEPRECATED_ATTRIBUTE;

/**
 * Method which inputs email using email and activation password provided by provisionData property for activation screen.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @return YES, if data was successfully typed, otherwise NO.
 */
- (BOOL)enterEmailActivationPassword;

/**
 * Synchronously waits for block screen presence.
 * Target application should be provisioned before.
 * Method logins application and then waits for block screen.
 *
 * @param timeout
 * The amount of time within block screen is expected after container unlock
 *
 * @return YES, if block screen appeared, otherwise NO.
 */
- (BOOL)waitForBlock:(NSTimeInterval)timeout;

/**
 * Synchronously waits for remote lock screen presence.
 * Target application should be provisioned before.
 * Method logins application and then waits for remote lock screen.
 *
 * @param remoteLockTimeout
 * The amount of time within which remote lock is expected after container unlock
 *
 * @return YES, if remote lock screen appeared, otherwise NO.
 */
- (BOOL)waitForRemoteLock:(NSTimeInterval)remoteLockTimeout;

/**
 * Synchronously waits for biometric unlock screen presence with Touch ID/Face ID popup.
 * Target application should be provisioned before.
 *
 * @param timeout
 * The amount of time within which biometric unlock screen with popup should appear
 *
 * @return YES, if biometric unlock screen with biometric popup appeared, otherwise NO.
 */
- (BOOL)waitForBiometricLock:(NSTimeInterval)timeout;

/**
 * Synchronously waits for biometric easy activation unlock screen presence with Touch ID/Face ID popup.
 * Target application should be provisioned before.
 *
 * @param timeout
 * The amount of time within which biometric easy activation unlock screen with popup should appear
 *
 * @return YES, if biometric easy activation unlock screen with biometric popup appeared, otherwise NO.
 */
- (BOOL)waitForEasyActivationBiometricLock:(NSTimeInterval)timeout;

/**
 * Synchronously waits for biometric reauthentication to confirm screen presence with Touch ID/Face ID popup.
 * Target application should be provisioned before.
 *
 * @param timeout
 * The amount of time within which biometric eauthentication to confirm unlock screen with popup should appear
 *
 * @return YES, if biometric eauthentication to confirm unlock screen with biometric popup appeared, otherwise NO.
 */
- (BOOL)waitForReauthenticationBiometricLock:(NSTimeInterval)timeout;

/**
 * Synchronously waits for wipe/block screen presence.
 * Target application should be provisioned before.
 *
 * @param timeout
 * The amount of time within which container wipe is expected after action from GC
 *
 * @return YES, if wipe/block screen appeared, otherwise NO.
 */
- (BOOL)waitForContainerWipe:(NSTimeInterval)timeout;

/**
 * Synchronously waits for provision screen presence.
 *
 * @return YES, if provision screen appeared, otherwise NO.
 */
- (BOOL)waitForProvisionUI;

/**
 * Unlocks application which was previously locked by GC.
 * Target application should be provisioned before.
 * Method uses BBDProvisionData instance for all needed information .
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */
- (BOOL)unLockBBDApp;

/**
 * Unlocks application which was previously locked by GC.
 * Target application should be provisioned before.
 * Method uses BBDProvisionData instance for all needed information .
 * 
 * @param authType
 * Indicates application configuration status
 *
 * @return YES, if application was successfully unlocked, otherwise NO.
 */
- (BOOL)unLockBBDAppWithAuthType:(BBDAuthType)authType;;

/**
 * Method which processes certificate enrollment screen.
 * Should be invoked after setupBBDAutomatedTestSupportWithApplication:forTestCase:
 * BBDProvisionData instance should be populated before with all needed values.
 * certificatesPasswords property is used for entering data into UI textfield.
 * Paswords should be given in order of certificates appearing.
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */
- (BOOL)processPKSC12Screen;

/**
 * Method which processes client certificate enrollment screen.
 * Should be invoked after setupBBDAutomatedTestSupportWithApplication:forTestCase:
 *
 * @param name
 * Name of client certificate
 *
 * @param password
 * Password for client certificate
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */
- (BOOL)processPKSC12ClientCertificateWithName:(NSString *)name
                                      password:(NSString *)password;

/**
 * Method which processes certificate definition enrollment screen.
 * Should be invoked after setupBBDAutomatedTestSupportWithApplication:forTestCase:
 *
 * @param name
 * Name of certificate definition
 *
 * @param password
 * Password for certificate definition
 *
 * @return YES, if application successfully completed certification enrollment without error alert, otherwise NO.
 */
- (BOOL)processPKSC12CertificateDefinitionWithName:(NSString *)name
                                          password:(NSString *)password;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      BBDConditionHelper
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Immediately tests existing of target view on the screen.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @return YES, if target screen is shown on the screen, otherwise returns NO
 */
- (BOOL)isScreenShown:(NSString *)accessID;

/**
 * Tests existing of target view on the screen.
 * Synchronous method which waits for the target element appearance.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target screen is shown on the screen, otherwise test fails
 */
- (BOOL)isScreenShown:(NSString *)accessID timeout:(NSTimeInterval)timeout;

/**
 * Immediately tests existing of static text on the screen.
 *
 * @param text
 * target text which is seacrhed on the view
 *
 * @return YES, if target screen is shown on the screen, otherwise returns NO
 */
- (BOOL)isTextShown:(NSString *)text;

/**
 * Tests existing of static text on the screen.
 * Synchronous method which waits for the target static text appearance.
 *
 * @param text
 * target text which is searched on the view
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target screen is shown on the screen, otherwise test fails
 */
- (BOOL)isTextShown:(NSString *)text timeout:(NSTimeInterval)timeout;

/**
 * Tests alert appearance with target accessibility identifier.
 * Synchronous method which waits for the target static text appearance.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target screen is shown on the screen,
 *          NO, if failTestOnTimeout is set to NO, otherwise test fails
 */
- (BOOL)isAlertShownWithAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout;

/**
 * Tests alert appearance with target static text.
 * Synchronous method which waits for the target static text appearance.
 *
 * @param staticText
 * target static text which is searched on the view
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target screen is shown on the screen,
 *          NO, if failTestOnTimeout is set to NO, otherwise test fails
 */
- (BOOL)isAlertShownWithStaticText:(NSString *)staticText timeout:(NSTimeInterval)timeout;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      BBDInputEventHelper
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Immediately starts text input into XCUIElement using accessibility identifier to find appropriate container.
 * Method will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param accessID
 * unique ID for the accessibility element for input container
 *
 * @param type
 * target container element type
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type withAccessID:(NSString *)accessID ;

/**
 * Starts text input into XCUIElement using accessibility identifier to find appropriate container.
 * Method waits for element appearence and will fail test if timeout is reached or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 * @param type
 * target container element type
 *
 * @param accessID
 * unique ID for the accessibility element for input container
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type withAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout;

/**
 * Immediately starts text input into XCUIElement.
 * Method uses static text of container to find appropriate element through view hierarchy.
 * It will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 
 * @param type
 * target container element type
 *
 * @param staticText
 * text inside container which is used to find target element for input operation.
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type containingText:(NSString *)staticText;

/**
 * Starts text input into XCUIElement.
 * Method uses static text of container to find appropriate element through view hierarchy.
 * It will fail test if element isn't found or text can not be typed.
 *
 * @param text
 * target text which is typed into the container
 *
 
 * @param type
 * target container element type
 *
 * @param staticText
 * text inside container which is used to find target element for input operation.
 *
 * @param timeout
 * The amount of time within which all expectations must be fulfilled.
 *
 * @return YES, if target text is typed into the container, otherwise test fails
 */
- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type containingText:(NSString *)staticText timeout:(NSTimeInterval)timeout;

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
 * @deprecated
 * accessKey is now renamed into activationPassword
 *
 * @return YES, if data was successfully typed, otherwise NO.
 */
- (BOOL)enterEmail:(NSString *)email accessKey:(NSString *)accessKey DEPRECATED_ATTRIBUTE;

/**
 * Method which inputs email using email and access key for activation screen.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param email
 * Email address which is used for activation
 *
 * @param activationPassword
 * Provisioned Activation Password
 *
 * @return YES, if data was successfully typed, otherwise NO.
*/
- (BOOL)enterEmail:(NSString *)email activationPassword:(NSString *)activationPassword;

/**
 * Method which inputs email using email, activation password and activation URL for provisioning.
 * Methods open Advanced settings screen and inputs all data.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param email
 * Email address which is used for activation
 *
 * @param activationPassword
 * Provisioned Activation Password
 *
 * @param activationURL
 * Activation URL for provisioning
 *
 * @return YES, if data was successfully typed, otherwise NO.
*/
- (BOOL)enterEmail:(NSString *)email activationPassword:(NSString *)activationPassword activationURL:(NSString *)activationURL;

/**
 * Method which sets container password for first time after activation.
 * Checks any alert presence during testing, interacts with textfield for input and buttons for next steps.
 *
 * @param password
 * container unlock password
 *
 * @return YES, if container password was successfully setted, otherwise NO.
 */
- (BOOL)setContainerPassword:(NSString *)password;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      GDTouchEventHepler
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////


/**
 * Method which simulates pressing the home button for target application.
 *
 */
- (void)pressHome;

/**
 * Immediately taps XCUIElement using accessibility identifier to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param accessID
 * unique ID for the accessibility element to tap
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
- (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID;

/**
 * Taps XCUIElement using accessibility identifier to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param accessID
 * unique ID for the accessibility element to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
- (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout;

/**
 * Immediately taps XCUIElement containing specific static text to find appropriate object.
 * Method will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param text
 * text inside element which is used to find target for tap
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
- (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text;

/**
 * Taps XCUIElement containing specific static text to find appropriate object.
 * Method waits for element appearence and will fail test if element isn't found or element can not be tapped.
 *
 * @param type
 * target XCUIElement type
 *
 * @param text
 * text inside element which is used to find target for tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @return YES, if target element is tapped, otherwise test fails
 */
- (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text timeout:(NSTimeInterval)timeout;

/**
 * Taps UITableViewCell using accessibility identifier to find appropriate cell.
 * Method will fail test if cell isn't found or cell can not be tapped.
 *
 * @param accessID
 * unique ID for the accessibility cell to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @return YES, if target cell is tapped, otherwise test fails
 */
- (BOOL)tapOnRowWithAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout;

/**
 * Taps UITableViewCell using static text to find appropriate cell.
 * Method will fail test if cell isn't found or cell can not be tapped.
 *
 * @param staticText
 * Static text which is contained in cell to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @return YES, if target cell is tapped, otherwise test fails
 */
- (BOOL)tapOnRowWithStaticText:(NSString *)staticText timeout:(NSTimeInterval)timeout;


/**
 * Taps UITableViewCell using index of row in table view to find appropriate cell.
 * Method will fail test if cell isn't found or cell can not be tapped.
 *
 * @param indexRow
 * unique index for cell to tap
 *
 * @param timeout
 * The amount of time within which expectation must be fulfilled
 *
 * @return YES, if target cell is tapped, otherwise test fails
 */
- (BOOL)tapOnRowByIndex:(NSInteger)indexRow timeout:(NSTimeInterval)timeout;

/**
 * Taps XCUIElement containing specific static text to find appropriate object.
 * Method waits for element appearence and will fail test if element isn't found or element can not be tapped.
 *
 * @param accessID
 * unique ID for the accessibility element
 *
 * @param text
 * text inside container to scroll
 *
 * @param timeout
 * The amount of time within scrollable container should appear
 *
 * @return YES, if target element is scrolled, otherwise test fails
 */
- (BOOL)scrollContainerWithAccessID:(NSString*) accessID
                             toText:(NSString *)text
                            timeout:(NSTimeInterval)timeout;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      Multiapp testing
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Use this method to add block of test commands for an application based on its bundle identifier
 * Block is added to queue.
 * When block is invoked instance of used XCUIApplication is passed.
 * No need to call launch or activate, application is ready to be tested when it comes to block.
 *
 * @param appID
 * bundle identifier of application, nil argument will create main target application
 *
 * @param actionBlock
 * The block of test instructions to be executed under specific application
 *
 */
- (void) addTestCommandsForApplication:(NSString*)appID
                             withBlock:(BOOL (^)(XCUIApplication* application))actionBlock;

/**
 * Use this method to execute all test commands which were previously added.
 * Blocks are executed synchronously in the same order they were added before.
 * Method uses - (void)activate of XCUIApplication
 * So it can be called before application is actually flipped by main application request
 * This will loose previous context and application will be launched from cold start
 * It's client code responsibility to track active application change using
 * expectation. Ensure that last test command waits for UI dissapearing
 * code can not rely on state property since currently it returns
 * XCUIApplicationStateRunningForeground for every previously activated application.
 * After all commands are completed, helper clears queue.
 *
 */
- (void) runMultiAppTest;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      Split screen & DragAndDrop helpers
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Open an app in a split screen mode.
 * An app will be opened in a split screen mode even if the split screen is already opened with another app.
 * In this case a new app will shown instead of existing one.
 * Method works only in portrait orientation.
 *
 * @param app
 * An instance of XCUIApplication which should be opened in a split screen mode.
 *
 * @param appName
 * Product name for the app which will be opened. Will be used to match appropriative icon in suggestions menu.
 *
 * @return YES, if an app was opened is a split screen mode.
 */
- (BOOL)openAppWithSplitScreen:(XCUIApplication *)app
                       appName:(NSString *)appName;

/**
 * Check if split sreeen is shown with app.
 *
 * @param app
 * XCUIApplication instance which is needed to be checked for being presented on the screen with split screen mode.
 *
 * @return YES, if target app is presented on the screen with split screen mode.
 */
- (BOOL)isSplitScreenShown:(XCUIApplication *)app;

/**
 * Drag and drop operation between two elements.
 * This method simply makes drag and drop operation by pressing on the source element and dragging it to the destination one.
 * This method is not responsible for text selection of source element, text clearing and keyboard events.
 * Use value comparision to determine if drag and drop operation is successfull.
 *
 * @param sourceEl
 * An XCUIElement instance which will be dragged.
 *
 * @param destElement
 * Destination element where text will be dropped.
 */
- (void)dragAndDropElement:(XCUIElement *)sourceEl
        destinationElement:(XCUIElement *)destElement;

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      GD Tools methods
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

/**
 * Immediately captures screenshot of current displayed data and saves it to given location.
 *
 * @param path
 * absolute path for captured image location.
 *
 * @return YES if screenshot was captured and saved without errors, otherwise NO
 */
- (BOOL)captureScreenshotSavingToPath:(NSString *)path;

@end



