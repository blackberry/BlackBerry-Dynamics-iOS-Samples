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

#import "BBDMultiAppTestHelper.h"

static NSString* const BBDMainApplicationKey = @"BBDMainApplicationKey";
static NSString* const BBDSelectorStringActivate = @"activate";
static NSString* const BBDSelectorStringInit = @"initWithBundleIdentifier:";



@interface BBDTestActivity: NSObject

@property (nonatomic, strong) NSString *appID;
@property (nonatomic, copy) actionBlock activityBlock;

@end

@implementation BBDTestActivity

@end

@interface BBDMultiAppTestHelper()

@property (nonatomic, strong) NSMutableArray<BBDTestActivity *>* activities;
@property (nonatomic, strong) NSMutableDictionary<NSString*,XCUIApplication*>* applications;

@property (nonatomic,assign) SEL selActivate;
@property (nonatomic,assign) SEL selInitWithBundleIdentifier;

@end

@implementation BBDMultiAppTestHelper

/////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------//
#pragma mark - init methods
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////

- (instancetype)init
{
    self = [super init];
    if (self) {
        _selActivate = NSSelectorFromString(BBDSelectorStringActivate);
        _selInitWithBundleIdentifier = NSSelectorFromString(BBDSelectorStringInit);
    }
    return self;
}

/////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------//
#pragma mark - getter/setter methods
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////

- (NSMutableArray<BBDTestActivity*>*) activities {
    if (_activities == nil)
    {
        _activities = [NSMutableArray array];
    }
    return _activities;
}

- (NSMutableDictionary<NSString*,XCUIApplication*>*) applications {
    if (! _applications)
    {
        _applications = [NSMutableDictionary dictionary];
    }
    return _applications;
}

/////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------//
#pragma mark - public methods
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////

- (void) addTestCommandsForApplication:(NSString*)appID withBlock: (actionBlock) actionBlock
{
    NSAssert([self isAPIAvailable],@"Multi application api is not available on this version");
    
    BBDTestActivity *activity = [BBDTestActivity new];
    activity.appID            = appID;
    activity.activityBlock    = actionBlock;
    
    [self.activities addObject:activity];
    
}
- (void) runTest
{
    NSAssert([self isAPIAvailable],@"Multi application api is not available on this version");
    
    for (BBDTestActivity *activity in self.activities)
    {
        XCUIApplication *application = [self attachedApplication:activity];
        // stop test if previous action returned NO
        // failing tests as soon as it can be done
        if (!activity.activityBlock(application))
            break;
    }
    
    [self.activities removeAllObjects];
}

/////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------//
#pragma mark - private helper methods
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////

- (XCUIApplication*) attachedApplication:(BBDTestActivity*) activity {
    
    NSString *appKey = activity.appID?:BBDMainApplicationKey;
    
    XCUIApplication *targetApp = self.applications[appKey];
    if (!targetApp)
    {
        targetApp = [self buildApplicationByID:activity.appID];
        
        self.applications[appKey] = targetApp;
        
        NSMethodSignature * signature = [targetApp methodSignatureForSelector:self.selActivate];
        NSInvocation * invocation = [NSInvocation
                                       invocationWithMethodSignature:signature];
        invocation.target = targetApp;
        invocation.selector = self.selActivate;
        [invocation invoke];
     }
    return targetApp;
}

- (XCUIApplication*) buildApplicationByID:(NSString*) appID {
    
    XCUIApplication *targetApp;

    // BundleIdentifier is non null argument,
    // so if appID is empty - just launch main UITest target application
    // with original init method
    if (appID)
    {
        targetApp = [XCUIApplication alloc];
        
        NSMethodSignature * signature = [targetApp methodSignatureForSelector:self.selInitWithBundleIdentifier];
        NSInvocation * invocation = [NSInvocation
                                     invocationWithMethodSignature:signature];
        invocation.target = targetApp;
        invocation.selector = self.selInitWithBundleIdentifier;
        [invocation setArgument:&appID atIndex:2];
        [invocation invoke];
        [invocation getReturnValue:&targetApp];
        
        
    }
    else
        targetApp = [[XCUIApplication alloc] init];
    
    return targetApp;
}

/////////////////////////////////////////////////////////////////////////////////////////
//-------------------------------------------------------------------------------------//
#pragma mark - API availablility checker
//-------------------------------------------------------------------------------------//
/////////////////////////////////////////////////////////////////////////////////////////

- (BOOL) isAPIAvailable {
    BOOL isActivateAvailable = [XCUIApplication instancesRespondToSelector:self.selActivate];
    BOOL isInitAvailable = [XCUIApplication instancesRespondToSelector:self.selInitWithBundleIdentifier];
    return isActivateAvailable && isInitAvailable;
}


@end
