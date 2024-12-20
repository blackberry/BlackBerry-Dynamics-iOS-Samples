/* Copyright (c) 2023 BlackBerry Ltd.
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

#import <XCTest/XCTest.h>
#import <BlackBerryDynamicsAutomatedTestSupportLibrary/BBDAutomatedTestSupport.h>
#import "UIAccessabilityIdentifiers.h"

@interface AppbasedcertimportUITests : XCTestCase

@end

@implementation AppbasedcertimportUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // Use recording to get started writing UI tests.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)fetchCredentials
{
    NSString *credetialsJSONBundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"credentials"
                                                                                          ofType:@"json"];
    [[BBDAutomatedTestSupport sharedInstance] fetchCredentialsFromFileAtPath:credetialsJSONBundlePath];
}

- (void) testProvision
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [application launch];
    
    BBDAutomatedTestSupport *ats = [BBDAutomatedTestSupport sharedInstance];
    
    [self fetchCredentials];
    
    [ats setupBBDAutomatedTestSupportWithApplication:application forTestCase:self];
    
    BOOL isActivationSucceed = [ats loginOrProvisionBBDApp];
    XCTAssertTrue(isActivationSucceed, @"Activation Failed!");
  
    BOOL mainUIShown = [ats isScreenShown:AppUserCredentialProfileID timeout:10.f];
    XCTAssertTrue(mainUIShown, @"Main UI is not on screen");
    
}

@end
