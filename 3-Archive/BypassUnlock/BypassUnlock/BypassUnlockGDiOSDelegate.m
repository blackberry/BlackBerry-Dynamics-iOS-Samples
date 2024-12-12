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

#import "BypassUnlockGDiOSDelegate.h"
#import "BPCallManager.h"

@interface BypassUnlockGDiOSDelegate()

@property (nonatomic, assign) BOOL hasAuthorized;
@property (strong, nonatomic) LocalComplianceManager *localComplianceManager;

-(instancetype)init;
-(void)didAuthorize;

@end

@implementation BypassUnlockGDiOSDelegate

+(instancetype)sharedInstance
{
    static BypassUnlockGDiOSDelegate *bypassUnlockGDiOSDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bypassUnlockGDiOSDelegate = [[BypassUnlockGDiOSDelegate alloc] init];
    });
    return bypassUnlockGDiOSDelegate;
}

-(instancetype)init
{
    self = [super init];
    return self;
}

-(void)setRootViewController:(BPStartViewController *)rootViewController
{
    _rootViewController = rootViewController;
    [self didAuthorize];
}

-(void)setAppDelegate:(AppDelegate *)appDelegate
{
    _appDelegate = appDelegate;
    [self didAuthorize];
}

-(void)didAuthorize
{
    if (self.hasAuthorized && self.rootViewController && self.appDelegate)
    {
        [self.appDelegate didAuthorize];
    }
}

- (void)setupLocalComplianceManager
{
    if (!self.localComplianceManager)
    {
        self.localComplianceManager = [[LocalComplianceManager alloc] init];
    }
}

#pragma mark - Good Dynamics Delegate Methods
- (void)handleEvent:(GDAppEvent *)anEvent {
    
    /* Called from _good when events occur, such as system startup. */
    switch (anEvent.type)
    {
        case GDAppEventAuthorized:
        {
            [self onAuthorized:anEvent];
            break;
        }
        case GDAppEventNotAuthorized:
        {
            [self onNotAuthorized:anEvent];
            break;
        }
        case GDAppEventRemoteSettingsUpdate:
        {
            //A change to application-related configuration or policy settings.
            break;
        }
        case GDAppEventServicesUpdate:
        {
            //A change to services-related configuration.
            break;
        }
        case GDAppEventPolicyUpdate:
        {
            //A change to one or more application-specific policy settings has been received.
            [[NSNotificationCenter defaultCenter] postNotificationName:@"GDAppEventPolicyUpdateNotification" object:nil];
            break;
        }
        case GDAppEventEntitlementsUpdate:
        {
            //A change to the entitlements data has been received.
            break;
        }
        default:
        {
            NSLog(@"Unhandled Event");
            break;
        }
    }
}

- (void)onNotAuthorized:(GDAppEvent *)anEvent {
    
    /* Handle the Good Libraries not authorized event. */
    switch (anEvent.code) {
        case GDErrorActivationFailed:
        case GDErrorProvisioningFailed:
        case GDErrorPushConnectionTimeout:
        case GDErrorSecurityError:
        case GDErrorAppDenied:
        case GDErrorAppVersionNotEntitled:
        case GDErrorBlocked:
        {
            [self setupLocalComplianceManager];
            [self.localComplianceManager addUnblockButton];
            break;
        }
        case GDErrorWiped:
        case GDErrorRemoteLockout: {
            // an condition has occured denying authorization, an application may wish to log these events
            
            [BPCallManager sharedManager].appStarted = NO;
            self.hasAuthorized = NO;
            
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorPasswordChangeRequired:{
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorIdleLockout: {
            // idle lockout is benign & informational
            
            [BPCallManager sharedManager].appIdleLocked = YES;
            
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        default:
            NSAssert(false, @"Unhandled not authorized event");
            break;
    }
}

- (void)onAuthorized:(GDAppEvent *)anEvent {
    
    /* Handle the Good Libraries authorized event. */
    switch (anEvent.code) {
        case GDErrorNone: {
            if (!self.hasAuthorized) {
                // launch application UI here
                
                UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
                UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
                
                self.appDelegate.window.rootViewController = uiViewController;
                
                self.hasAuthorized = YES;
                
                [self didAuthorize];
                [self setupLocalComplianceManager];
            }
            [BPCallManager sharedManager].appIdleLocked = NO;
            break;
        }
        default:
            NSAssert(false, @"Authorized startup with an error");
            break;
    }
}

@end
