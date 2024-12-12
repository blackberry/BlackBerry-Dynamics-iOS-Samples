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

#import "ServerServiceGDiOSDelegate.h"


@interface ServerServiceGDiOSDelegate()

@property (nonatomic, assign) BOOL hasAuthorized;

-(instancetype)init;
-(void)didAuthorize;

@end

@implementation ServerServiceGDiOSDelegate

+(instancetype)sharedInstance
{
    static ServerServiceGDiOSDelegate *serverServiceGDiOSDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        serverServiceGDiOSDelegate = [[ServerServiceGDiOSDelegate alloc] init];
    });
    return serverServiceGDiOSDelegate;
}

-(instancetype)init
{
    self = [super init];
    return self;
}

-(void)setRootViewController:(MasterViewController *)rootViewController
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

#pragma mark - Good Dynamics Delegate Methods
-(void)handleEvent:(GDAppEvent*)anEvent
{
    /* Called from self.good when events occur, such as system startup. */
    
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
            NSLog(@"event not handled: %@", anEvent.message);
            break;
        }
    }
}

-(void)onNotAuthorized:(GDAppEvent*)anEvent {
    /* Handle the Good Libraries not authorized event. */
    
    switch (anEvent.code)
    {
        case GDErrorActivationFailed:
        case GDErrorProvisioningFailed:
        case GDErrorPushConnectionTimeout:
        case GDErrorSecurityError:
        case GDErrorAppDenied:
        case GDErrorBlocked:
        case GDErrorAppVersionNotEntitled:
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

-(void)onAuthorized:(GDAppEvent*)anEvent {
    /* Handle the Good Libraries authorized event. */
    
    switch (anEvent.code) {
        case GDErrorNone: {
            if (!self.hasAuthorized) {
                
                // launch application UI here
                UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName: @"Main" bundle:nil];
                UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
                
                MasterViewController *masterViewController = [uiStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:masterViewController];
                navigationController.navigationBar.tintColor = [UIColor colorWithRed:52. / 255.
                                                                               green:69. / 255.
                                                                                blue:84. / 255.
                                                                               alpha:255. / 255.];
                [navigationController.navigationBar setTitleTextAttributes:
                 @{NSForegroundColorAttributeName:[UIColor colorWithRed:33. / 255.
                                                                  green:50. / 255.
                                                                   blue:65. / 255.
                                                                  alpha:255. / 255.]}];
                
                self.appDelegate.window.rootViewController = uiViewController;
                
                self.hasAuthorized = YES;
                
                [self didAuthorize];
            }
            break;
        }
        default:
            NSAssert(false, @"authorized startup with an error");
            break;
    }
}


@end
