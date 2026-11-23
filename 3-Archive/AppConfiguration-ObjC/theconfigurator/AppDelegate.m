/* Copyright (c) 2017 BlackBerry Ltd.
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

#import "AppDelegate.h"
#import "AppConfigurationObjCSceneDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, assign) BOOL started;
    
// GD methods
- (void)onAuthorized:(GDAppEvent*)anEvent;
- (void)onNotAuthorized:(GDAppEvent*)anEvent;

@end

@implementation AppDelegate



/**
 Remember to change the application ID and version on Info.plist
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.started = NO;
   
    // Show the Good Authentication UI.
    [[GDiOS sharedInstance] authorize:self];
    
    return YES;
}

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *config = [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
    config.delegateClass = [AppConfigurationObjCSceneDelegate class];
    config.sceneClass = [UIWindowScene class];
    config.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return config;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
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
            
            /*
             Update UI in ViewController according to values from [[GDiOS sharedInstance] getApplicationPolicy]
             
             */
            if( self.started )
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AppPolicyUpdated" object:nil];
            }
            
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
            
            if( !self.started)
            {
                self.started = YES;
                [self.sceneDelegate launchApplicationUI];
            }
            break;
        }
        default:
            NSAssert(false, @"Authorized startup with an error");
            break;
    }
}

- (void)tryLaunchUIIfAuthorized {
    if (self.started) {
        [self.sceneDelegate launchApplicationUI];
    }
}

- (void) processApplicationConfig:(NSDictionary *) appConfig {
    NSLog(@"getApplicationConfig=%@",[[GDiOS sharedInstance] getApplicationConfig]);
}


@end
