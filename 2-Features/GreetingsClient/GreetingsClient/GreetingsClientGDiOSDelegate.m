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

#import "GreetingsClientGDiOSDelegate.h"

@interface GreetingsClientGDiOSDelegate()

@property(assign, nonatomic) BOOL hasAuthorized;

- (instancetype)init;
- (void)didAuthorize;

@end

@implementation GreetingsClientGDiOSDelegate

- (void)setRootViewController:(RootViewController *)rootViewController
{
    _rootViewController = rootViewController;
    [self didAuthorize];
}

- (void)setAppKineticsTableAppDelegate:(AppDelegate *)greetingsClientAppDelegate
{
    _greetigsClientAppDelegate = greetingsClientAppDelegate;
    [self didAuthorize];
}

- (void)didAuthorize
{
    if (self.hasAuthorized && self.rootViewController && self.greetigsClientAppDelegate)
    {
        [self.greetigsClientAppDelegate didAuthorize];
    }
}

+ (instancetype)sharedInstance
{
    static GreetingsClientGDiOSDelegate *greetigsClientGDiOSDelegate = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        greetigsClientGDiOSDelegate = [[GreetingsClientGDiOSDelegate alloc] init];
    });
    return greetigsClientGDiOSDelegate;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _serviceController = [[ServiceController alloc] init];
    }
    
    return self;
}

#pragma mark - Good Dynamics Delegate Methods

- (void)handleEvent:(GDAppEvent*)anEvent
{
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
            // handle app config changes
            break;
        }
        case GDAppEventServicesUpdate:
        {
            NSLog(@"Received Service Update event");
            [self onServiceUpdate:anEvent];
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
            NSLog(@"event not handled: %@", anEvent.message);
            break;
        }
    }
}

- (void)onNotAuthorized:(GDAppEvent*)anEvent
{
    /* Handle the Good Libraries not authorized event. */
    
    switch (anEvent.code)
    {
        case GDErrorActivationFailed:
        case GDErrorProvisioningFailed:
        case GDErrorPushConnectionTimeout:
        case GDErrorSecurityError:
        case GDErrorAppDenied:
        case GDErrorAppVersionNotEntitled:
        case GDErrorBlocked:
        case GDErrorWiped:
        case GDErrorRemoteLockout:
        case GDErrorPasswordChangeRequired:
        {
            // an condition has occured denying authorization, an application may wish to log these events
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorIdleLockout:
        {
            // idle lockout is benign & informational
            break;
        }
        default:
            NSAssert(false, @"Unhandled not authorized event");
            break;
    }
}

- (void)onAuthorized:(GDAppEvent*)anEvent
{
    /* Handle the Good Libraries authorized event. */
    
    switch (anEvent.code)
    {
        case GDErrorNone:
        {
            if (!self.hasAuthorized)
            {
                // launch application UI here
                self.hasAuthorized = YES;
                // Following lines are new.
                NSString *storyboardName;
                //Detect the device
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    storyboardName = @"Main_iPhone";
                }
                else
                {
                    storyboardName = @"Main_iPad";
                }
                
                UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
                UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
                
                self.greetigsClientAppDelegate.window.rootViewController = uiViewController;

                [self didAuthorize];
            }
            break;
        }
        default: break;
    }
}

- (void)onServiceUpdate:(GDAppEvent*)anEvent
{
    switch(anEvent.code)
    {
        case GDErrorNone:
        {
            //Post change
            [[NSNotificationCenter defaultCenter] postNotificationName:kServiceConfigDidChangeNotification object:nil];
            
        }
            break;
        default:
            NSAssert(false, @"Service update error");
            break;
    }
}

@end
