/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "Constants.h"
#import "Detection.h"
#import "Utility.h"
#import "TimeNotBefore.h"

typedef NS_ENUM(NSInteger, GDServiceProviderType)
{
    GDServiceProviderApplication=0,
    GDServiceProviderServer,
};

typedef void (^GDGetEntitlementVersionsForBlock) (NSArray* entitlementVersions, NSError* error);

//Declaration of the functions in the BlackBerry Dynamics SDK.
@protocol GDMockupMethods <NSObject>
+ (instancetype) sharedInstance;
- (NSDictionary*) getApplicationConfig;
- (NSDictionary*) getApplicationPolicy;
- (void)getEntitlementVersionsFor:(NSString*)identifier
                    callbackBlock:(GDGetEntitlementVersionsForBlock)block;
- (BOOL)executeRemoteLock;
- (NSArray *)getServiceProviders;
- (NSString*)getVersion;
@end

@implementation Detection

//Local variables
NSDictionary *policy;
NSDictionary *config;
id gdSharedInstance;
Utility *util;

//Global singleton Initializer
+ (Detection *) sharedDetection {
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

-(instancetype) init {
    util = [[Utility alloc] init];
    [self registerForNotifications];
    
    Class GDiOS = NSClassFromString(dynamicsClass);
    gdSharedInstance = [GDiOS performSelector:@selector(sharedInstance)];
    [self checkEntitlement];
    return self;
}

//Returns the Application Configuration from the Dynamics SDK
-(NSDictionary *) getApplicationConfig {
    NSDictionary *appConfig = [gdSharedInstance performSelector:@selector(getApplicationConfig)];
    NSLog(@"%@",appConfig);
    return appConfig;
}

//Returns the Application Policy from the Dynamics SDK
-(NSDictionary *) getApplicationPolicy {
    NSDictionary *appPolicy = [gdSharedInstance performSelector:@selector(getApplicationPolicy)];
    NSLog(@"%@",appPolicy);
    return appPolicy;
}

//Will lock the container locally
-(void) executeOfflineLock {
    if ([[policy objectForKey:offlineAction] intValue] == 1) {
        [util postNotificationWithTitle:@"Threat Detected" andMessage:@"Offline Lock Executed"];
        BOOL appConfig = [gdSharedInstance performSelector:@selector(executeRemoteLock)];
        if (appConfig) {
            NSLog(@"WIPED");
        } else {
            NSLog(@"NOT WIPED");
        }
    } else {
        NSLog(@"Offline Action is not enabled by IT Admin");
    }
}

//Will lock the container locally
-(void) executeOnlineLock {
    if ([[policy objectForKey:onlineAction] intValue] == 1) {
        [util postNotificationWithTitle:@"Threat Detected" andMessage:@"Online Lock Executed"];
        NSLog(@"%@ is the container to lock",[policy valueForKey:containerIdKey]);
    } else {
        NSLog(@"Online Action is not enabled by IT Admin");
    }
}

-(void) initMTDSDK {
    if ([[policy objectForKey:activationKey] intValue] == 1) {
        //init SDK with API Key
        NSLog(@"IT Admin has enabled MTD");
        NSLog(@"%@ is the API-Key", [policy objectForKey:apiKey]);
        [self checkTimeNotBefore];
    } else {
        NSLog(@"IT Admin has not enabled MTD");
    }
    
    //Simulating the tests
    [self executeOnlineLock];
    [self executeOfflineLock];
    
}

-(void) checkTimeNotBefore {
    TimeNotBefore *timeNotBefore = [[TimeNotBefore alloc] init];
    [timeNotBefore check:[policy objectForKey:timeKey]];
}

-(void) registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart) name:notificationEntitlementUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart) name:notificationPolicyUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restart) name:notificationServiceUpdate object:nil];
}

-(void) deRegisterNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationEntitlementUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationPolicyUpdate object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:notificationServiceUpdate object:nil];
}

//check if the the app is entitled. I am checking GDApplicationID with the service providers identifier.
-(void) checkEntitlement {
    [gdSharedInstance getEntitlementVersionsFor:entitlementIdentifier callbackBlock:^(NSArray*entVersion, NSError *err) {
        if (err == nil && entVersion.count > 0) {
            NSLog(@"IT Admin has enabled MTD Reference Library");
            policy = [self getApplicationPolicy];
            config = [self getApplicationConfig];
            BOOL validateVersion = [self checkVersion];
            if (validateVersion) {
                NSLog(@"Version Validation Successful");
                [self initMTDSDK];
            } else {
                NSLog(@"Version Validation Unsuccessful");
            }
        } else {
            NSLog(@"IT Admin has not enabled MTD Reference Library");
        }
    }];
}

-(BOOL) checkVersion {
    NSString* requiredVersion = [policy objectForKey:mtdVersion];
    NSString* actualVersion = [gdSharedInstance performSelector:@selector(getVersion)];
    
    if ([requiredVersion compare:actualVersion options:NSNumericSearch] == NSOrderedDescending) {
        return false;
    } else {
        return true;
    }
}

-(void) restart {
    [self deRegisterNotifications];
    [self checkEntitlement];
}

@end
