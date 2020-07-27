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

#import "BBDAutomatedTestSupport.h"

#import "BBDConditionHelper.h"
#import "BBDInputEventHelper.h"
#import "BBDTouchEventHelper.h"
#import "BBDUITestAppLogic.h"
#import "BBDUITestCaseRef.h"
#import "BBDMultiAppTestHelper.h"
#import "BBDDragAndDropHelper.h"

@interface BBDAutomatedTestSupport()

@property (nonatomic, strong) BBDUITestCaseRef *testCaseRef;
@property (nonatomic, strong) BBDMultiAppTestHelper *multiAppHelper;
@property (nonatomic, strong) NSArray *installedApps;

@end

@implementation BBDAutomatedTestSupport

+ (instancetype)sharedInstance
{
    static BBDAutomatedTestSupport *coreAutomation;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreAutomation = [[BBDAutomatedTestSupport alloc] init];
    });
    return coreAutomation;
}

- (void)setInstalledApps:(NSArray *)installedApps
{
    _installedApps = installedApps;
}

- (NSArray *)getInstalledApps
{
    return _installedApps;
}

- (BBDMultiAppTestHelper*) multiAppHelper {
    if (! _multiAppHelper)
    {
         _multiAppHelper = [BBDMultiAppTestHelper new];
    }
    return _multiAppHelper;
}

- (BOOL)fetchCredentialsFromFileAtPath:(NSString *)path
{
    self.provisionData = [[BBDProvisionData alloc] initWithContensOfFileAtPath:path];
    return self.provisionData != nil;
}

- (void)setupBBDAutomatedTestSupportWithApplication:(XCUIApplication *)application forTestCase:(XCTestCase *)testcase
{
    self.testCaseRef = [[BBDUITestCaseRef alloc] initWithTestCase:testcase
                                                   forApplication:application];
}

- (void)setupBBDAutomatedTestSupportWithApplication:(XCUIApplication *)application withPotentialDelegate:(XCUIApplication *)potentialDelegateApplication forTestCase:(XCTestCase *)testcase
{
    self.testCaseRef = [[BBDUITestCaseRef alloc] initWithTestCase:testcase
                                                   forApplication:application
                                            withPotentialDelegate:potentialDelegateApplication];
}

- (GDUIApplication*)getCurrentSetupApplication
{
    return _testCaseRef.application;
}

- (BBDUITestCaseRef*)getCurrentSetupTestCaseRef
{
    return _testCaseRef;
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                     BBDUITestAppLogic / GDiOS action triggers/handlers
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)waitForIdle:(NSTimeInterval)idleLockInterval
{
    return [BBDUITestAppLogic waitForIdleLock:idleLockInterval forTestCaseRef:self.testCaseRef];
}

- (void)explicitWait:(NSTimeInterval)interval forTestCase:(XCTestCase *)testCase
{
    [BBDUITestAppLogic explicitWait:interval forTestCase:testCase];
}

// Helper method which checks that GD has sent the  GD Authorized callback (which needs to be sent before app code can run)
- (BOOL)isBBDAppAuthorized
{
    return [BBDUITestAppLogic isBBDAuthorizedforTestCaseRef:self.testCaseRef];
}

// Helper method to login to GD App
- (BOOL)loginBBDApp
{
    return [self loginBBDAppWithAuthType:BBDPasswordAuthType];
}

- (BOOL)loginBBDAppWithAuthType:(BBDAuthType)authType
{
    return [BBDUITestAppLogic loginBBDAppUsingData:self.provisionData withAuthType:authType forTestCaseRef:self.testCaseRef];
}

// Helper method to provision to GD App
- (BOOL)provisionBBDApp
{
    return [self provisionBBDAppWithAuthType:BBDPasswordAuthType];
}

- (BOOL)provisionBBDAppWithAuthType:(BBDAuthType)authType
{
    return [BBDUITestAppLogic provisionBBDAppUsingData:self.provisionData withAuthType:authType forTestCaseRef:self.testCaseRef];
}

// Helper method to provide a high level either login or provision. Will defer to implementation which handles Handheld/Wearable split
- (BOOL)loginOrProvisionBBDApp
{
    return [self loginOrProvisionBBDAppWithAuthType:BBDPasswordAuthType];
}

- (BOOL)loginOrProvisionBBDAppWithAuthType:(BBDAuthType)authType
{
    return [BBDUITestAppLogic loginOrProvisionBBDAppUsingData:self.provisionData withAuthType:authType forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterEmailAccessKey
{
    return [self enterEmailActivationPassword];
}

- (BOOL)enterEmailActivationPassword
{
    return [self enterEmail:self.provisionData.email
         activationPassword:self.provisionData.activationPassword];
}

- (BOOL)waitForBlock:(NSTimeInterval)timeout
{
    return [BBDUITestAppLogic waitForBlockScreen:timeout
                                        withData:self.provisionData
                                  forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForRemoteLock:(NSTimeInterval)remoteLockTimeout
{
    return [BBDUITestAppLogic waitForRemoteLock:remoteLockTimeout
                                       withData:self.provisionData
                                 forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForBiometricLock:(NSTimeInterval)timeout
{
    return [BBDUITestAppLogic waitForBiometricLock:timeout
                                    forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForEasyActivationBiometricLock:(NSTimeInterval)timeout
{
    return [BBDUITestAppLogic waitForEasyActivationBiometricLock:timeout
                                                  forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForReauthenticationBiometricLock:(NSTimeInterval)timeout
{
    return [BBDUITestAppLogic waitForEasyReauthenticationBiometricLock:timeout
                                                        forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForContainerWipe:(NSTimeInterval)timeout
{
    return [BBDUITestAppLogic waitForContainerWipe:timeout
                           forTestCaseRef:self.testCaseRef];
}

- (BOOL)waitForProvisionUI {
    return [BBDUITestAppLogic waitForProvisionScreenForTestCaseRef:self.testCaseRef];
}

- (BOOL)unLockBBDApp
{
    return [self unLockBBDAppWithAuthType:BBDPasswordAuthType];
}

- (BOOL)unLockBBDAppWithAuthType:(BBDAuthType)authType
{
    return [BBDUITestAppLogic unLockBBDAppUsingData:self.provisionData
                                       withAuthType:authType
                                     forTestCaseRef:self.testCaseRef];
}

- (BOOL)processPKSC12Screen
{
    return [BBDUITestAppLogic processPKSC12ScreenUsingData:self.provisionData
                                            forTestCaseRef:self.testCaseRef];
}

- (BOOL)processPKSC12ClientCertificateWithName:(NSString *)name
                                      password:(NSString *)password
{
    return [BBDUITestAppLogic processPKSC12ClientCertificateWithName:name
                                                            password:password
                                                      forTestCaseRef:self.testCaseRef];
}

- (BOOL)processPKSC12CertificateDefinitionWithName:(NSString *)name
                                          password:(NSString *)password
{
    return [BBDUITestAppLogic processPKSC12CertificateDefinitionWithName:name
                                                                password:password
                                                          forTestCaseRef:self.testCaseRef];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      BBDConditionHelper
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isScreenShown:(NSString *)accessID
{
    return [BBDConditionHelper isScreenShown:accessID
                              forTestCaseRef:self.testCaseRef];
}

- (BOOL)isScreenShown:(NSString *)accessID timeout:(NSTimeInterval)timeout
{
    return [BBDConditionHelper isScreenShown:accessID
                                     timeout:timeout
                              forTestCaseRef:self.testCaseRef];
}

- (BOOL)isTextShown:(NSString *)text
{
    return [BBDConditionHelper isTextShown:text
                            forTestCaseRef:self.testCaseRef];
}

- (BOOL)isTextShown:(NSString *)text timeout:(NSTimeInterval)timeout
{
    return [BBDConditionHelper isTextShown:text
                                   timeout:timeout
                            forTestCaseRef:self.testCaseRef];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      BBDInputEventHelper
//>-----------------------------------------------------------------------------------<//
/////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type withAccessID:(NSString *)accessID
{
    return [BBDInputEventHelper enterText:text
                             inViewOfType:type
                             withAccessID:accessID
                           forTestCaseRef:self.testCaseRef];
}

//Helper method to enter text into screen element with specific timeout
- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type withAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout
{
    return [BBDInputEventHelper enterText:text
                             inViewOfType:type
                             withAccessID:accessID
                                  timeout:timeout
                           forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type containingText:(NSString *)staticText
{
    return [BBDInputEventHelper enterText:text
                             inViewOfType:type
                           containingText:staticText
                           forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterText:(NSString *)text inViewOfType:(XCUIElementType)type containingText:(NSString *)staticText timeout:(NSTimeInterval)timeout
{
    return [BBDInputEventHelper enterText:text
                             inViewOfType:type
                           containingText:staticText
                                  timeout:timeout
                           forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterEmail:(NSString *)email accessKey:(NSString *)accessKey
{
    return [self enterEmail:email activationPassword:accessKey];
}
- (BOOL)enterEmail:(NSString *)email activationPassword:(NSString *)activationPassword
{
    return [BBDUITestAppLogic enterEmail:email
                      activationPassword:activationPassword
                          forTestCaseRef:self.testCaseRef];
}

- (BOOL)enterEmail:(NSString *)email activationPassword:(NSString *)activationPassword activationURL:(NSString *)activationURL
{
    return [BBDUITestAppLogic enterEmail:email
                      activationPassword:activationPassword
                           activationURL:activationURL
                          forTestCaseRef:self.testCaseRef];
}

- (BOOL)setContainerPassword:(NSString *)password
{
    return [BBDUITestAppLogic setContainerPassword:password
                                    forTestCaseRef:self.testCaseRef];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      GDTouchEventHepler
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////


//Helper method which presses HOME
- (void)pressHome
{
    [BBDTouchEventHelper pressHome];
}

//Helper method to click on specific item, specified by resourceID, with a default timeout
- (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID
{
    return [BBDTouchEventHelper tapOnItemOfType:type
                                   withAccessID:accessID
                                 forTestCaseRef:self.testCaseRef];
}

- (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text
{
    return [BBDTouchEventHelper tapOnItemOfType:type
                                 containingText:text
                                 forTestCaseRef:self.testCaseRef];
}

//Helper method to click on specific item with configurable timeout

- (BOOL)tapOnItemOfType:(XCUIElementType)type containingText:(NSString *)text timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper tapOnItemOfType:type
                                 containingText:text
                                        timeout:timeout
                                 forTestCaseRef:self.testCaseRef];
}

- (BOOL)tapOnItemOfType:(XCUIElementType)type withAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper tapOnItemOfType:type
                                   withAccessID:accessID
                                        timeout:timeout
                                 forTestCaseRef:self.testCaseRef];
}

- (BOOL)tapOnRowWithAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper tapOnRowWithAccessID:accessID
                                             timeout:timeout
                                      forTestCaseRef:self.testCaseRef];
}

- (BOOL)tapOnRowWithStaticText:(NSString *)staticText timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper tapOnRowWithStaticText:staticText
                                               timeout:timeout
                                        forTestCaseRef:self.testCaseRef];
}

- (BOOL)tapOnRowByIndex:(NSInteger)indexRow timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper tapOnRowByIndex:indexRow
                                        timeout:timeout
                                 forTestCaseRef:self.testCaseRef];
}

// Scroll to a UiObject that has matches exact text within a scrollable UiObject
- (BOOL)scrollContainerWithAccessID:(NSString*) accessID
                             toText:(NSString *)text
                            timeout:(NSTimeInterval)timeout
{
    return [BBDTouchEventHelper scrollContainerWithAccessID:accessID
                                                     toText:text
                                                    timeout:timeout
                                             forTestCaseRef:self.testCaseRef];
}

- (BOOL)isAlertShownWithAccessID:(NSString *)accessID timeout:(NSTimeInterval)timeout
{
    return [BBDConditionHelper isAlertShownWithAccessID:accessID
                                                timeout:timeout
                                         forTestCaseRef:self.testCaseRef];
}

- (BOOL)isAlertShownWithStaticText:(NSString *)staticText timeout:(NSTimeInterval)timeout
{
    return [BBDConditionHelper isAlertShownWithStaticText:staticText
                                                  timeout:timeout
                                           forTestCaseRef:self.testCaseRef];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      Multiapp testing
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

- (void) addTestCommandsForApplication:(NSString*)appID
                       withBlock: (BOOL (^)(XCUIApplication* application))actionBlock
{
    __weak typeof(self) weakSelf = self;
    [self.multiAppHelper addTestCommandsForApplication:appID withBlock:^BOOL(XCUIApplication *application) {
        
        // For every action testcase reference remains the same.
        // The only thing needs to be changed - 
        [weakSelf setupBBDAutomatedTestSupportWithApplication:application
                                                  forTestCase:weakSelf.testCaseRef.testCase];
        BOOL result = actionBlock(application);
        
        return result;
    }];
}

- (void) runMultiAppTest
{
    [self.multiAppHelper runTest];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      Split screen & DragAndDrop helpers
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)openAppWithSplitScreen:(XCUIApplication *)app
                       appName:(NSString *)appName
{
    return [BBDDragAndDropHelper openSplitScreen:self.testCaseRef.application secondApp:app secondAppName:appName];
}

- (BOOL)isSplitScreenShown:(XCUIApplication *)app
{
    return [BBDDragAndDropHelper isSplitScreenShown:app];
}

- (void)dragAndDropElement:(XCUIElement *)sourceEl
        destinationElement:(XCUIElement *)destElement
{
    [BBDDragAndDropHelper dragAndDropElement:sourceEl destinationElement:destElement];
}

/////////////////////////////////////////////////////////////////////////////////////////
//>-----------------------------------------------------------------------------------<//
#pragma mark -                      GD Tools methods
//>----------------------------------------------------------------------------------->//
/////////////////////////////////////////////////////////////////////////////////////////

// Helper method to capture screenshot (requires app to have the write external storage permission)
- (BOOL)captureScreenshotSavingToPath:(NSString *)path
{
    return NO;
}

- (void)setOptions:(BBDTestOption)options
{
    self.testCaseRef.options = options;
}

- (BBDTestOption)options
{
    return self.testCaseRef.options;
}

@end
