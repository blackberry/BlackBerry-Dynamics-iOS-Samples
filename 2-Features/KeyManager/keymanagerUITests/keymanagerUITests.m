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
#import "UIAccessibilityIdentifiers.h"

@interface keymanagerUITests : XCTestCase

@end

@implementation keymanagerUITests

- (void)setUp
{
    // Put setup code here. This method is called before the invocation of each test method in the class.
    [super setUp];
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProvision
{
    XCUIApplication *application = [[XCUIApplication alloc] init];
    [application launch];
    
    BBDAutomatedTestSupport *ats = [BBDAutomatedTestSupport sharedInstance];
    
    [self fetchCredentials];
    
    [ats setupBBDAutomatedTestSupportWithApplication:application
                                         forTestCase:self];
    
    BOOL activationSucceed = [ats loginOrProvisionBBDApp];
    XCTAssertTrue(activationSucceed, @"Activation Failed!");
    
    BOOL mainUIShown = [ats isScreenShown:KMMainScreenID timeout:10.f];
    XCTAssertTrue(mainUIShown, @"Main UI is not on screen");
}

- (void)fetchCredentials
{
    NSString *credetialsJSONBundlePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"credentials"
                                                                                          ofType:@"json"];
    [[BBDAutomatedTestSupport sharedInstance] fetchCredentialsFromFileAtPath:credetialsJSONBundlePath];
}

@end
