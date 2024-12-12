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

#import "ServicesGDiOSDelegate.h"

@interface ServicesGDiOSDelegate ()


@property (nonatomic, assign) BOOL hasAuthorized;							

-(instancetype)init;
-(void)didAuthorize;						
                        
@end

@implementation ServicesGDiOSDelegate

+ (instancetype)sharedInstance {
    static ServicesGDiOSDelegate *gdiOSDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gdiOSDelegate = [[ServicesGDiOSDelegate alloc] init];
    });
    return gdiOSDelegate;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setRootViewController:(EmailServiceVC *)rootViewController {
    _rootViewController = rootViewController;
    [self didAuthorize];
}

- (void)setAppDelegate:(AppDelegate *)appDelegate {
    _appDelegate = appDelegate;
    [self didAuthorize];
}


- (void)didAuthorize {
    if (self.hasAuthorized && self.rootViewController && self.appDelegate)
    {
        [self.appDelegate didAuthorize];
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
        case GDErrorWiped:
        case GDErrorRemoteLockout: 
        case GDErrorPasswordChangeRequired: {
            // an condition has occured denying authorization, an application may wish to log these events
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorIdleLockout: {
            // idle lockout is benign & informational
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
                if (!self.hasAuthorized) {
                    // launch application UI here
                    NSString *storyboardName = nil;
                    storyboardName = @"Main";
        
                    UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                    UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
        
                    self.appDelegate.window.rootViewController = uiViewController;
        
                    self.hasAuthorized = YES;
        
                    [self didAuthorize];
        
                }
                break;
            }
        default:
        NSAssert(false, @"Authorized startup with an error");
        break;
        }
    }
}


@end
