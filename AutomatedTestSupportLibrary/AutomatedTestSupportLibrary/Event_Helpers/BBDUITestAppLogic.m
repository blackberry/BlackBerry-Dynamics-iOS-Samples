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

#import "BBDUITestAppLogic.h"
#import "BBDConditionHelper.h"
#import "BBDInputEventHelper.h"
#import "BBDUIAccessibilityIdentifiers.h"
#import "BBDUITestCaseRef.h"
#import "BBDProvisionData.h"
#import "BBDTouchEventHelper.h"
#import "BBDUITestUtilities.h"
#import "XCTestCase+Expectations.h"
#import "XCUIDevice+BiometricsHelpers.h"
#import "BBDAutomatedTestSupport.h"
#import "BBDExpectationsHandler.h"
#import "XCUIApplication+State.h"

#define XCTLAssertTrue(expression, ...) \
    _XCTPrimitiveAssertTrue(testCaseRef.testCase, expression, @#expression, __VA_ARGS__)

static const NSTimeInterval SPLASH_UI_APPEARANCE_TIMEOUT            = 3.f;
static const NSTimeInterval PROVISION_TIMEOUT                       = 60.f;
static const NSTimeInterval APEARANCE_TIMEOUT                       = 20.f;
static const NSTimeInterval VALIDATION_TIMEOUT                      = 5.f;
static const NSTimeInterval FACE_ID_AUTHORIZATION_PROMPT_TIMEOUT    = 2.f;

static const NSString* CERTIFICATE_DEFINITION_TITLE = @"Required Client Certificate";
static const NSString* CLIENT_CERTIFICATE_TITLE = @"Client Certificate";

@implementation BBDUITestAppLogic

+ (BOOL)isBBDAuthorizedforTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [BBDConditionHelper isElementShownWithIdentifier:BBDUnlockUI
                                                          ofType:XCUIElementTypeAny
                                                         timeout:APEARANCE_TIMEOUT
                                                  forTestCaseRef:testCaseRef];
    return isSuccess;
}

+ (BOOL)provisionBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL provisionScreenShown = [self waitForProvisionScreenForTestCaseRef:testCaseRef];
    if (provisionScreenShown)
    {
        return [self internalProvisionBBDAppUsingData:provisionData withAuthType:authType forTestCaseRef:testCaseRef];
    }
    NSLog(@"Provision screen isn't shown\nHierarchy: %@", [testCaseRef.application  debugDescription]);
    return NO;
}

+ (BOOL)internalProvisionBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL emailAndPasswordEntered = [self enterEmail:provisionData.email
                                          accessKey:provisionData.accessKey
                                     forTestCaseRef:testCaseRef];
    
    if (!emailAndPasswordEntered)
    {
        NSLog(@"Error during entering email and access key");
        return NO;
    }
    
    BOOL provisionDisappear = [self waitForProvisionProgressScreenDisappearForTestCaseRef:testCaseRef];
    
    if (!provisionDisappear)
    {
        return NO;
    }
    
    BOOL isBlockScreen = [self isBlockScreenShownForTestCaseRef:testCaseRef];
    if (isBlockScreen)
    {
        return NO;
    }
    
    if (testCaseRef.options & BBDTestOptionDisclaimer) {
        BOOL agreementAccepted = [self acceptAgreementMessageForTestCaseRef:testCaseRef];
        if (!agreementAccepted)
            return NO;
    }
    
    if (authType == BBDPasswordAuthType) {
        BOOL containerPasswordSet = [self setContainerPassword:provisionData.password
                                                forTestCaseRef:testCaseRef];
        
        if (!containerPasswordSet)
        {
            NSLog(@"Error during setting container password");
            return NO;
        }
    }
    
    NSLog(@"Provision success");
    return YES;
}


+ (BOOL)loginBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    
    BOOL splashScreenDisappeared = [self waitForSplashScreenDisappearForTestCaseRef:testCaseRef];
    
    if (!splashScreenDisappeared)
    {
        return NO;
    }
    
    if (testCaseRef.options & BBDTestOptionDisclaimer) {
        BOOL agreementAccepted = [self acceptAgreementMessageForTestCaseRef:testCaseRef];
        if (!agreementAccepted)
            return NO;
    }
    
    if(authType == BBDNoPasswordAuthType) {
        return YES;
    } else {
        if (testCaseRef.options & BBDTestOptionBiometricsID) {
            return [testCaseRef.device biometryShouldMatch:YES];
        }
        else
        {
            return [self internalLoginBBDAppUsingData:provisionData forTestCaseRef:testCaseRef];
        }
    }
}

+ (BOOL)internalLoginBBDAppUsingData:(BBDProvisionData *)provisionData forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    
    BOOL passwordEntered = [BBDInputEventHelper  enterText:provisionData.password
                                              inViewOfType:XCUIElementTypeAny
                                              withAccessID:BBDValidatePasswordFieldID
                                                   timeout:APEARANCE_TIMEOUT
                                            forTestCaseRef:testCaseRef];
    [testCaseRef.application.buttons[@"Go"] tap];
    if(!passwordEntered)
    {
        NSLog(@"Entering password failed");
        return NO;
    }
    return YES;
}

+ (BOOL)loginOrProvisionBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isProvisonScreen = [self waitForProvisionScreenForTestCaseRef:testCaseRef];
    if (isProvisonScreen)
    {
        return [self internalProvisionBBDAppUsingData:provisionData
                                         withAuthType:authType
                                       forTestCaseRef:testCaseRef];
    }
    
    if (testCaseRef.options & BBDTestOptionDisclaimer) {
        BOOL agreementAccepted = [self acceptAgreementMessageForTestCaseRef:testCaseRef];
        if (!agreementAccepted)
            return NO;
    }
    
    if(authType == BBDNoPasswordAuthType) {
        return YES;
    } else {
        
        BOOL isLoginScreen = [BBDConditionHelper isScreenShown:BBDUnlockUI
                                                forTestCaseRef:testCaseRef];
        if (isLoginScreen)
        {
            return [self internalLoginBBDAppUsingData:provisionData
                                       forTestCaseRef:testCaseRef];
        }
        
        if (testCaseRef.options & BBDTestOptionBiometricsID) {
            BOOL isBiometricScreen = [BBDConditionHelper isScreenShown:BBDBiometricUnlockUI
                                                        forTestCaseRef:testCaseRef];
            if (isBiometricScreen)
            {
                return [testCaseRef.device biometryShouldMatch:YES];
            }
        }
        
        NSLog(@"BBD Activation failed! No provision or login screen found.\nHierarchy: %@",[testCaseRef.application  debugDescription]);
        return NO;
    }
}

+ (BOOL)setContainerPassword:(NSString *)password forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isProvisionUIShown = [BBDConditionHelper isScreenShown:BBDSetPasswordUI
                                                        timeout:APEARANCE_TIMEOUT
                                                 forTestCaseRef:testCaseRef];
    if (!isProvisionUIShown)
    {
        NSLog(@"Provision screen didn't appear after timeout: %f\nHierarchy: %@", APEARANCE_TIMEOUT, [testCaseRef.application  debugDescription]);
        return NO;
    }
    
    BOOL enterPasswordInFirstField =  [BBDInputEventHelper  enterText:password
                                                         inViewOfType:XCUIElementTypeAny
                                                         withAccessID:BBDSetPasswordFieldID
                                                              timeout:APEARANCE_TIMEOUT
                                                       forTestCaseRef:testCaseRef];
    [testCaseRef.application.buttons[@"Go"] tap];
    if (!enterPasswordInFirstField)
    {
        NSLog(@"First password field typing failed");
        return NO;
    }
    
    BOOL enterValidatePasswordField = [BBDInputEventHelper  enterText:password
                                                         inViewOfType:XCUIElementTypeAny
                                                         withAccessID:BBDValidatePasswordFieldID
                                                              timeout:APEARANCE_TIMEOUT
                                                       forTestCaseRef:testCaseRef];
    [testCaseRef.application.buttons[@"Go"] tap];
    if (!enterValidatePasswordField)
    {
        NSLog(@"Validate password field typing failed");
        return NO;
    }
    
    XCUIElement *setPasswordScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                           withIndentifier:BBDSetPasswordUI
                                                               inContainer:testCaseRef.application];
    
    [testCaseRef.testCase waitForElementDisappearance:setPasswordScreen
                                              timeout:VALIDATION_TIMEOUT
                                    failTestOnTimeout:NO
                                              handler:nil];
    
    if (setPasswordScreen.exists)
    {
        BOOL validatePasswordAlertShown = [BBDConditionHelper isAlertShownWithAccessID:BBDSetPasswordErrorAlertID
                                                                               timeout:VALIDATION_TIMEOUT
                                                                        forTestCaseRef:testCaseRef];
        if (validatePasswordAlertShown)
            NSLog(@"Password entered with error");
        else
            NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return NO;
    }
    NSLog(@"Container password entered successfully");
    return YES;
}

+ (BOOL)enterEmail:(NSString *)email accessKey:(NSString *)accessKey forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self enterEmail:email accessKey:accessKey forScreenType:BBDActivationUI forTestCaseRef:testCaseRef];
}

+ (BOOL)waitForIdleLock:(NSTimeInterval)idleLockInteval forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSString *waitScreenID;
    if (testCaseRef.options & BBDTestOptionDisclaimer) {
        waitScreenID = BBDDisclaimerUI;
    }
    else if (testCaseRef.options & BBDTestOptionBiometricsID){
        waitScreenID = BBDBiometricUnlockUI;
    }
    else{
        waitScreenID =  BBDUnlockUI;
    }
    double idleLockWaitDelay = 1.f;
    double idleLockWaitInterval = idleLockInteval + idleLockWaitDelay;
    BOOL enterPasswordScreenAppeared = [BBDConditionHelper isScreenShown:waitScreenID
                                                                 timeout:idleLockWaitInterval
                                                          forTestCaseRef:testCaseRef];
    if (!enterPasswordScreenAppeared)
    {
        NSLog(@"App is still unlock after idle timeout\nHierarchy: %@", [testCaseRef.application  debugDescription]);
        return NO;
    }
    return YES;
}

#pragma mark - Utilities

+ (BOOL)acceptAgreementMessageForTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    XCUIElement *agreementScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                         withIndentifier:BBDDisclaimerUI
                                                             inContainer:testCaseRef.application];
    if (!agreementScreen.exists) {
        NSLog(@"Agreement screen didn't appear after timeout: %f\nHierarchy: %@", APEARANCE_TIMEOUT, [testCaseRef.application  debugDescription]);
        return NO;
    }
    
    BOOL acceptTapped = [BBDTouchEventHelper tapOnItemOfType:XCUIElementTypeButton
                                                withAccessID:BBDDisclaimerAcceptButtonID
                                              forTestCaseRef:testCaseRef];
    if (!acceptTapped) {
        NSLog(@"Agreement screen didn't appear after timeout: %f\nHierarchy: %@", APEARANCE_TIMEOUT, [testCaseRef.application  debugDescription]);
        return NO;
    }
    if (agreementScreen.exists) {
        [testCaseRef.testCase waitForElementDisappearance:agreementScreen
                                                  timeout:APEARANCE_TIMEOUT
                                        failTestOnTimeout:YES
                                                  handler:^(NSError * _Nullable error) {
                                                      if (error)
                                                          NSLog(@"Agreement screen still on screen: %f\nHierarchy: %@", APEARANCE_TIMEOUT, [testCaseRef.application  debugDescription]);
                                                  }];
    }
    return YES;
}

+ (BOOL)enterEmail:(NSString *)email accessKey:(NSString *)accessKey forScreenType:(NSString *) screenType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL provisionScreenShown = [BBDConditionHelper isScreenShown:screenType //double check
                                                          timeout:APEARANCE_TIMEOUT
                                                   forTestCaseRef:testCaseRef];
    if (!provisionScreenShown)
    {
        NSLog(@"Provising screen didn't appear after timeout: %f\nHierarchy: %@", APEARANCE_TIMEOUT, [testCaseRef.application  debugDescription]);
        return NO;
    }
    
    // Handle a tip on the keyboard swipe option
    if (@available(iOS 13, *))
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat: @"value CONTAINS[c] 'Speed up'"];
        
        XCUIElement* container = [testCaseRef.application.otherElements containingPredicate:predicate].firstMatch;
        
        if ([container exists])
        {
            [container.buttons[@"Continue"].firstMatch tap];
        }
    }
    
    
    BOOL emailEntered =  [BBDInputEventHelper  enterText:email
                                            inViewOfType:XCUIElementTypeTextField
                                            withAccessID:BBDActivationEmailFieldID
                                                 timeout:APEARANCE_TIMEOUT
                                          forTestCaseRef:testCaseRef];
    if (!emailEntered)
    {
        NSLog(@"Email typing failed");
        return NO;
    }
    
    if(accessKey.length == 15)
    {
        BOOL enteredKeyInFirstField =  [BBDInputEventHelper enterText:[accessKey substringWithRange:NSMakeRange(0, 5)]
                                                         inViewOfType:XCUIElementTypeAny
                                                         withAccessID:BBDAccessKeyField1ID
                                                       forTestCaseRef:testCaseRef];
        if (!enteredKeyInFirstField) {
            NSLog(@"Access key typing failed\nHierarchy: %@", [testCaseRef.application debugDescription]);
            return NO;
        }
        
        XCUIElement *field2 = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                    withIndentifier:BBDAccessKeyField2ID
                                                        inContainer:testCaseRef.application];
        if (field2.exists)
        {
            [field2 typeText:[accessKey substringWithRange:NSMakeRange(5, 5)]];
            
        } else {
            NSLog(@"Access key typing failed\nHierarchy: %@", [testCaseRef.application debugDescription]);
            return NO;
        }
        
        XCUIElement *field3 = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                    withIndentifier:BBDAccessKeyField3ID
                                                        inContainer:testCaseRef.application];
        if (field3.exists)
        {
            [field3 typeText:[accessKey substringWithRange:NSMakeRange(10, 5)]];
            [testCaseRef.application.buttons[@"Go"] tap];
        } else {
            NSLog(@"Access key typing failed\nHierarchy: %@", [testCaseRef.application debugDescription]);
            return NO;
        }
    } else {
        NSLog(@"The amount of characters in the access key is less than 15 characters. Access key typing failed.");
        return NO;
    }
    
    XCUIElement *activationScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                          withIndentifier:screenType
                                                              inContainer:testCaseRef.application];
    
    [testCaseRef.testCase waitForElementDisappearance:activationScreen
                                              timeout:VALIDATION_TIMEOUT
                                    failTestOnTimeout:NO
                                              handler:nil];
    
    if (activationScreen.exists) {
        BOOL emailAccesKeyValidationFailed = [BBDConditionHelper isAlertShownWithAccessID:BBDEnterPinEmailErrorAlertID
                                                                                  timeout:VALIDATION_TIMEOUT
                                                                           forTestCaseRef:testCaseRef];
        NSLog(@"Target screen hasn't dissapeared");
        if (emailAccesKeyValidationFailed)
            NSLog(@"Checksum check failed");
        else
            NSLog(@"Enter email/access key failed!\nHierarchy: %@", [testCaseRef.application debugDescription]);
        return NO;
    }
    NSLog(@"Email and access key entered");
    return YES;
}

+ (BOOL)isBlockScreenShownForTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    NSArray *blockScreenIds = @[BBDContainerWipedUI, BBDBlockedUI, BBDAuthDelegationBlockedUI];
    
    for (NSString *ID in blockScreenIds)
    {
        XCUIElement *blockScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                         withIndentifier:ID
                                                             inContainer:testCaseRef.application];
        if (blockScreen.exists)
        {
            XCUIElement *blockTitleElement = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                                   withIndentifier:BBDContainerWipedTitleID
                                                                       inContainer:blockScreen];
            
            XCUIElement *blockMessageElement = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                                     withIndentifier:BBDContainerWipedMessageID
                                                                         inContainer:blockScreen];
            
            NSLog(@"\nBlock screen shown!\nMessage: %@\nTitle: %@", blockTitleElement.label, blockMessageElement.value);
            return YES;
        }
    }
    return NO;
}

+ (BOOL)skipEAOldFlow:(BBDUITestCaseRef *)testCaseRef
{
    NSLog(@"Looking for EasyActivationSelection (Old EA flow)");
    if (testCaseRef.application.exists && testCaseRef.application.state != XCUIApplicationStateRunningForeground)
    {
        NSLog(@"Could not skip Old EA flow. %@", [testCaseRef.application invalidStateDescription]);
        return NO;
    }
    
    if ([BBDConditionHelper isScreenShown:BBDEasyActivationSelectionUI forTestCaseRef:testCaseRef])
    {
        XCUIElement *eaScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny withIndentifier:BBDEasyActivationSelectionUI inContainer:testCaseRef.application];
        XCTLAssertTrue([BBDTouchEventHelper tapOnItemOfType:XCUIElementTypeButton withAccessID:BBDEasyActivationAccessKeyButtonID forTestCaseRef:testCaseRef],
                       @"Could not tap on BBDEasyActivationAccessKeyButtonID to show BBDActivationUI for Manual Provisioning");
        [testCaseRef.testCase waitForElementDisappearance:eaScreen timeout:VALIDATION_TIMEOUT failTestOnTimeout:YES handler:nil];
        NSLog(@"Successfully skipped Old EA flow with delegate - %@", testCaseRef.application);
        return YES;
    }
    
    return NO;
}

+ (BOOL)skipEANewFlow:(BBDUITestCaseRef *)testCaseRef
{
    BOOL skipped = NO;
    NSLog(@"Looking for EasyActivationUnlock (New EA Flow)");
    XCUIApplication *appToBeProvisioned = testCaseRef.application;
    NSArray *apps = [[BBDAutomatedTestSupport sharedInstance] getInstalledApps];
    NSLog(@"Apps: %@", apps);
    for (NSString *delegateID in apps)
    {
        XCUIApplication *delegateApp = [[XCUIApplication alloc] initWithBundleIdentifier:delegateID];
        NSLog(@"New EA Flow: checking app %@, app state: %lu", delegateID, delegateApp.state);
        if (delegateApp.exists && delegateApp.state == XCUIApplicationStateRunningForeground)
        {
            testCaseRef.application = delegateApp;
            NSLog(@"Looking for EasyActivationUnlock in app %@", delegateID);
            if ([BBDConditionHelper isScreenShown:BBDEasyActivationUnlockUI timeout:VALIDATION_TIMEOUT forTestCaseRef:testCaseRef])
            {
                XCUIElement *eaScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny withIndentifier:BBDEasyActivationUnlockUI inContainer:testCaseRef.application];
                XCTLAssertTrue([BBDTouchEventHelper tapOnItemOfType:XCUIElementTypeButton withAccessID:BBDCancelButtonID forTestCaseRef:testCaseRef],
                               @"Could not tap BBDCancelButtonID on BBDEasyActivationUnlockUI for potential EA delegate - %@", delegateApp);
                [testCaseRef.testCase waitForElementDisappearance:eaScreen timeout:VALIDATION_TIMEOUT failTestOnTimeout:YES handler:nil];
                NSLog(@"Successfully skipped New EA flow with delegate - %@", delegateApp);
                skipped = YES;
                break;
            }
        }
    }
    
    testCaseRef.application = appToBeProvisioned;
    return skipped;
}

+ (BOOL)waitForProvisionScreenForTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    // Wait for splash screen appearance.
    // In GD-40469 was observed the issue with LoadingUI appearance
    // after loginOrProvisionBBDApp call.

    if ([testCaseRef.application waitForState:XCUIApplicationStateRunningBackground timeout:1.f])
    {
        [testCaseRef.application waitForUsableState];
    }
    
    if (testCaseRef.application.state == XCUIApplicationStateRunningForeground && ![BBDConditionHelper isScreenShown:BBDLoadingUI timeout:SPLASH_UI_APPEARANCE_TIMEOUT forTestCaseRef:testCaseRef])
    {
        NSLog(@"Splash screen didn't appear");
    }
    
    if (testCaseRef.application.state == XCUIApplicationStateRunningForeground && ![self waitForSplashScreenDisappearForTestCaseRef:testCaseRef])
    {
        NSLog(@"Splash screen didn't disappear");
        return NO;
    }

    [testCaseRef.application waitForState:XCUIApplicationStateRunningBackground timeout:1.f];
    NSLog(@"app state: %lu", testCaseRef.application.state);
    if (![self skipEANewFlow:testCaseRef] && ![self skipEAOldFlow:testCaseRef])
    {
        NSLog(@"Could not skip EA flow");
    }
    
    return [BBDConditionHelper isScreenShown:BBDActivationUI timeout:VALIDATION_TIMEOUT forTestCaseRef:testCaseRef];
}

+ (BOOL)waitForSplashScreenDisappearForTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    XCUIElement *splashScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                      withIndentifier:BBDLoadingUI
                                                          inContainer:testCaseRef.application];
    
    [testCaseRef.testCase waitForElementDisappearance:splashScreen
                                              timeout:PROVISION_TIMEOUT
                                    failTestOnTimeout:NO
                                              handler:nil];
    
    if (splashScreen.exists) {
        BOOL isInfrastructureActivationAlertShown = [BBDConditionHelper isAlertShownWithAccessID:BBDActivationProgressFailedAlertID
                                                                                         timeout:APEARANCE_TIMEOUT
                                                                                  forTestCaseRef:testCaseRef];
        if (isInfrastructureActivationAlertShown)
            NSLog(@"Infrastructure activation failed");
        else
            NSLog(@"Splash screen still shown\nHierarchy: %@", [testCaseRef.application  debugDescription]);
        return NO;
    }
    return YES;
}

+ (BOOL)waitForProvisionProgressScreenDisappearForTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    XCUIElement *provisionProgressScreen = [BBDUITestUtilities findElementOfType:XCUIElementTypeAny
                                                                 withIndentifier:BBDActivationProgressUI
                                                                     inContainer:testCaseRef.application];
    
    [testCaseRef.testCase waitForElementDisappearance:provisionProgressScreen
                                              timeout:PROVISION_TIMEOUT
                                    failTestOnTimeout:NO
                                              handler:nil];
    
    if (provisionProgressScreen.exists)
    {
        BOOL errorDuringProvision = [BBDConditionHelper isAlertShownWithAccessID:BBDActivationProgressFailedAlertID
                                                                         timeout:PROVISION_TIMEOUT
                                                                  forTestCaseRef:testCaseRef];
        if (errorDuringProvision)
            NSLog(@"Provision failed");
        else
            NSLog(@"Provision progress screen still shown\nHierarchy: %@", [testCaseRef.application  debugDescription]);
        return NO;
    }
    
    return YES;
}

+ (BOOL)waitForBlockScreen:(NSTimeInterval)timeout
                  withData:(BBDProvisionData *)provisionData
            forTestCaseRef:(BBDUITestCaseRef *)testCaseRef {
    
    BOOL isSuccess = NO;
    
    isSuccess = [self waitForSplashScreenDisappearForTestCaseRef:testCaseRef];
    
    if (!isSuccess)
    {
        // if screen does not dissapear - test failed
        return isSuccess;
    }
    
    if ([BBDConditionHelper isScreenShown:BBDUnlockUI
                           forTestCaseRef:testCaseRef])
    {
        // if login screen is shown - input container password
        isSuccess = [self internalLoginBBDAppUsingData:provisionData
                                        forTestCaseRef:testCaseRef];
        
        if (!isSuccess)
        {
            // return if test failed to login
            return isSuccess;
        }
        
    }
    
    if ((testCaseRef.options & BBDTestOptionBiometricsID)
        && [BBDConditionHelper isScreenShown:BBDBiometricUnlockUI
                              forTestCaseRef:testCaseRef])
    {
        // if Biometric screen is shown - match Touch ID/Face ID
        isSuccess = [testCaseRef.device biometryShouldMatch:YES];
        
        if (!isSuccess)
        {
            // return if test failed to login
            return isSuccess;
        }
        
    }
    
    isSuccess = [BBDConditionHelper isScreenShown:BBDBlockedUI
                                          timeout:timeout
                                   forTestCaseRef:testCaseRef];
    
    return isSuccess;
}

+ (BOOL)waitForRemoteLock:(NSTimeInterval)remoteLockTimeout
                 withData:(BBDProvisionData *)provisionData
           forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [self waitForSplashScreenDisappearForTestCaseRef:testCaseRef];
    
    if (!isSuccess)
    {
        // if screen does not dissapear - test failed
        return isSuccess;
    }
    
    if ([BBDConditionHelper isScreenShown:BBDUnlockUI
                           forTestCaseRef:testCaseRef])
    {
        // if login screen is shown - input container password
        isSuccess = [self internalLoginBBDAppUsingData:provisionData
                                        forTestCaseRef:testCaseRef];
        
        if (!isSuccess)
        {
            // return if test failed to login
            return isSuccess;
        }
        
        isSuccess = [BBDConditionHelper isScreenShown:BBDBlockedUI
                                              timeout:remoteLockTimeout
                                       forTestCaseRef:testCaseRef];
    }
    else
    {
        // wait for BBDRemoteUnlockUI or BBDForgotPasswordUI screen appearance with enter email/unlock key
        isSuccess = ([BBDConditionHelper isScreenShown:BBDRemoteUnlockUI
                                               timeout:remoteLockTimeout
                                        forTestCaseRef:testCaseRef] ||
                     [BBDConditionHelper isScreenShown:BBDForgotPasswordUI
                                        forTestCaseRef:testCaseRef]  );
    }
    
    return isSuccess;
}

+ (BOOL)waitForContainerWipe:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;
{
    if ([BBDConditionHelper isScreenShown:BBDContainerWipedUI
                                  timeout:timeout
                           forTestCaseRef:testCaseRef])
    {
        return YES;
        
    } else
    {
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return NO;
    }
}

+ (BOOL)waitForBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef;
{
    return [self waitForBiometricLock:timeout forTestCaseRef:testCaseRef withUnlockScreenID:BBDBiometricUnlockUI];
}

+ (BOOL)waitForEasyActivationBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self waitForBiometricLock:timeout forTestCaseRef:testCaseRef withUnlockScreenID:BBDEasyActivationBiometricUnlockUI];
}

+ (BOOL)waitForEasyReauthenticationBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    return [self waitForBiometricLock:timeout forTestCaseRef:testCaseRef withUnlockScreenID:BBDReauthenticationBiometricUnlockUI];
}

+ (BOOL)waitForBiometricLock:(NSTimeInterval)timeout forTestCaseRef:(BBDUITestCaseRef *)testCaseRef withUnlockScreenID:(NSString *)unlockScreenID;
{
    //need to wait for FaceID authorization prompt, only applicable for FaceID
    if (testCaseRef.device.supportedBiometryType == BBDBiometryTypeFaceID) {
        [self waitForFaceIDAuthorizationPrompt:FACE_ID_AUTHORIZATION_PROMPT_TIMEOUT];
    }
    
    if (![NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){13,0,0}]) {
        NSLog(@"Device runs iOS 12 or earlier, check biometric pop-up.\n");
        XCUIApplication *targetApp = testCaseRef.application;
        XCUIApplicationState appState = XCUIApplicationStateRunningBackground;
        
        return [targetApp waitForState:appState timeout:timeout] /*&& [BBDConditionHelper isScreenShown:unlockScreenID forTestCaseRef:testCaseRef]*/;;
    } else {
        NSLog(@"Device runs iOS 13 or higher, check biometric pop-up.\n");
        XCUIApplication *systemView = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
        XCUIElement *biometriscAllowAlert;
        
        if (testCaseRef.device.supportedBiometryType == BBDBiometryTypeFaceID)
        {
            NSLog(@"Handle alert for FaceID\n");
            NSPredicate *predicate = [NSPredicate predicateWithFormat:
                                      @"label CONTAINS [c] %@", @"Face ID"];
            biometriscAllowAlert = [systemView.images containingPredicate:predicate].firstMatch;
        } else
        {
            NSLog(@"Handle alert for TouchID\n");
            biometriscAllowAlert = [systemView.images matchingIdentifier:@"TouchID"].firstMatch;
        }
        return [biometriscAllowAlert waitForExistenceWithTimeout:timeout];
    }
}

+ (BOOL)unLockBBDAppUsingData:(BBDProvisionData *)provisionData withAuthType:(BBDAuthType)authType forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [self waitForRemoteLock:APEARANCE_TIMEOUT
                               withData:provisionData
                         forTestCaseRef:testCaseRef];
    
    if ([BBDConditionHelper isScreenShown:BBDBlockedUI
                           forTestCaseRef:testCaseRef])
    {
        isSuccess = [BBDTouchEventHelper tapOnItemOfType:XCUIElementTypeButton
                                            withAccessID:BBDUnlockButtonID
                                          forTestCaseRef:testCaseRef];
    }
    
    if (!isSuccess)
    {
        NSLog(@"Remote unlock screen has not appeared");
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    NSString *screenType = nil;
    NSString *screenName = nil;
    
    if([BBDConditionHelper isScreenShown:BBDRemoteUnlockUI
                          forTestCaseRef:testCaseRef]){
        
        screenType = BBDRemoteUnlockUI;
        screenName = @"remote unlock";
        
    }
    else if([BBDConditionHelper isScreenShown:BBDForgotPasswordUI
                               forTestCaseRef:testCaseRef]){
        
        screenType = BBDForgotPasswordUI;
        screenName = @"forgot password";
        
    }
    
    if(screenType){
        
        isSuccess = [self enterEmail:provisionData.email
                           accessKey:provisionData.unlockKey
                       forScreenType:screenType
                      forTestCaseRef:testCaseRef];
        
        if(!isSuccess)
        {
            NSLog(@"Failed to enter data into %@ screen", screenName);
            NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
            return isSuccess;
        }
    }
    
    isSuccess = [self waitForProvisionProgressScreenDisappearForTestCaseRef:testCaseRef];
    
    if (!isSuccess)
    {
        NSLog(@"Provision progress screen hasn't dissapeared");
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    if (testCaseRef.options & BBDTestOptionDisclaimer) {
        BOOL agreementAccepted = [self acceptAgreementMessageForTestCaseRef:testCaseRef];
        if (!agreementAccepted)
            return NO;
    }
    
    if(authType == BBDNoPasswordAuthType) {
        NSLog(@"Unlock success");
        return YES;
    } else {
        isSuccess = [self setContainerPassword:provisionData.password forTestCaseRef:testCaseRef];
        
        if (!isSuccess)
        {
            NSLog(@"Error during setting container password");
            NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
            return isSuccess;
        }
        
        NSLog(@"Unlock success");
        
        return isSuccess;
    }
}

+ (BOOL)processPKSC12ScreenUsingData:(BBDProvisionData *)provisionData forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    
    if (provisionData.certificatesPasswords.count > 0) {
        return [self processPKSC12ScreenUsingPasswords:provisionData.certificatesPasswords forTestCaseRef:testCaseRef];
    }
    
    BOOL processCertificateDefinition = NO;
    
    XCUIElement *certificateDefinitionTitle = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                               elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", CERTIFICATE_DEFINITION_TITLE]];
    processCertificateDefinition = certificateDefinitionTitle.exists;
    
    if (! processCertificateDefinition) {
        XCUIElement *clientCertificateTitle = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                               elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", CLIENT_CERTIFICATE_TITLE]];
        if (!clientCertificateTitle.exists) {
            NSLog(@"Undefined type of certificate enrollment screen");
            return NO;
        }
    }
    
    NSArray <NSString*>* names = (processCertificateDefinition
                                  ? provisionData.certificateDefinitionNames
                                  : provisionData.clientCertificateNames);
    for (NSString *name in names) {
        XCUIElement *nameElement = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                    elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", name]];
        if (nameElement.exists) {
            return  [self processPKSC12ScreenUsingPassword:(processCertificateDefinition
                                                            ? [provisionData certificateDefinitionPassword:name]
                                                            : [provisionData clientCertificatePassword:name])
                                            forTestCaseRef:testCaseRef];
        }
    }
    
    NSLog(@"Unexpected Certificate name");
    return NO;
}

+ (BOOL)processPKSC12ClientCertificateWithName:(NSString *)name
                                      password:(NSString *)password
                                forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [BBDConditionHelper isScreenShown:BBDCertificateImportUI
                                          timeout:APEARANCE_TIMEOUT
                                   forTestCaseRef:testCaseRef];
    
    if (!isSuccess) {
        NSLog(@"Certificate Import UI screen has not appeared");
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    XCUIElement *certificateDefinitionTitle = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                               elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", CLIENT_CERTIFICATE_TITLE]];
    isSuccess = certificateDefinitionTitle.exists;
    if (!isSuccess) {
        NSLog(@"Unexpected client certificate title, expected title is \"%@\"", CERTIFICATE_DEFINITION_TITLE);
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    XCUIElement *nameElement = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", name]];
    isSuccess = nameElement.exists;
    
    if (!isSuccess) {
        NSLog(@"Certificate name mismatch, expected name is \"%@\"", name);
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    isSuccess = [self processPKSC12ScreenUsingPassword:password
                                        forTestCaseRef:testCaseRef];
    
    return isSuccess;
}

+ (BOOL)processPKSC12CertificateDefinitionWithName:(NSString *)name
                                          password:(NSString *)password
                                    forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [BBDConditionHelper isScreenShown:BBDCertificateImportUI
                                          timeout:APEARANCE_TIMEOUT
                                   forTestCaseRef:testCaseRef];
    
    if (!isSuccess) {
        NSLog(@"Certificate Import UI screen has not appeared");
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    XCUIElement *certificateDefinitionTitle = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                               elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", CERTIFICATE_DEFINITION_TITLE]];
    isSuccess = certificateDefinitionTitle.exists;
    if (!isSuccess) {
        NSLog(@"Unexpected certificate definition title, expected title is \"%@\"", CERTIFICATE_DEFINITION_TITLE);
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    XCUIElement *nameElement = [[testCaseRef.application descendantsMatchingType:XCUIElementTypeAny]
                                elementMatchingPredicate:[NSPredicate predicateWithFormat:@"label CONTAINS [cd] %@", name]];
    isSuccess = nameElement.exists;
    
    if (!isSuccess) {
        NSLog(@"Certificate name mismatch, expected name is \"%@\"", name);
        NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
        return isSuccess;
    }
    
    isSuccess = [self processPKSC12ScreenUsingPassword:password
                                        forTestCaseRef:testCaseRef];
    
    return isSuccess;
}

+ (BOOL)processPKSC12ScreenUsingPasswords:(NSArray <NSString*>*)passwords forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    for (NSString *certificatePassword in passwords)
    {
        isSuccess = [BBDConditionHelper isScreenShown:BBDCertificateImportUI
                                              timeout:APEARANCE_TIMEOUT
                                       forTestCaseRef:testCaseRef];
        
        if (!isSuccess)
        {
            NSLog(@"Certificate Import UI screen has not appeared");
            NSLog(@"Hierarchy: %@", [testCaseRef.application  debugDescription]);
            return isSuccess;
        }
        
        isSuccess = [self processPKSC12ScreenUsingPassword:certificatePassword
                                            forTestCaseRef:testCaseRef];
        if (!isSuccess) {
            break;
        }
    }
    return isSuccess;
}

+ (BOOL)processPKSC12ScreenUsingPassword:(NSString *)password forTestCaseRef:(BBDUITestCaseRef *)testCaseRef
{
    BOOL isSuccess = NO;
    
    isSuccess = [BBDInputEventHelper enterText:password
                                  inViewOfType:XCUIElementTypeAny
                                  withAccessID:BBDIdentityImportPasswordFieldID
                                forTestCaseRef:testCaseRef];
    
    if (!isSuccess) {
        NSLog(@"Failed to enter password");
        return isSuccess;
    }
    
    [testCaseRef.application.buttons[@"Go"] tap];
    
    isSuccess = [BBDConditionHelper isAlertShownWithAccessID:BBDIdentityImportSuccessAlertID
                                                     timeout:APEARANCE_TIMEOUT
                                              forTestCaseRef:testCaseRef];
    if (!isSuccess) {
        BOOL isError = [BBDConditionHelper isAlertShownWithAccessID:BBDIdentityImportErrorAlertID
                                                            timeout:APEARANCE_TIMEOUT
                                                     forTestCaseRef:testCaseRef];
        if (isError) {
            NSLog(@"Error appeared during certificate processing");
            return !isError;
        }
        
        NSLog(@"Alert has not appeared");
        return isSuccess;
    }
    
    XCUIElement *alert = [BBDUITestUtilities findElementOfType:XCUIElementTypeAlert
                                               withIndentifier:BBDIdentityImportSuccessAlertID
                                                   inContainer:testCaseRef.application];
    [[alert.buttons elementBoundByIndex:0] tap];
    
    return isSuccess;
}

#pragma mark - Private

+ (BOOL)waitForFaceIDAuthorizationPrompt:(NSTimeInterval)timeout {
    //This is a separate process so we use appropriate identifier here
    XCUIApplication *systemAlert = [[XCUIApplication alloc] initWithBundleIdentifier:@"com.apple.springboard"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"label CONTAINS [c] %@", @"Face ID"];
    XCUIElement *faceIdAllowAlert = [systemAlert.alerts containingPredicate:predicate].firstMatch;
    BOOL appeared = [faceIdAllowAlert waitForExistenceWithTimeout:timeout];
    if (appeared) {
        [faceIdAllowAlert.buttons[@"OK"] tap];
        NSLog(@"FaceID prompt appeared");
    }
    return appeared;
}

@end
