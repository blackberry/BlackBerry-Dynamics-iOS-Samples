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

#import "RSSReaderGDiOSDelegate.h"
#import "Utilities.h"
#import "RSSManager.h"

@interface RSSReaderGDiOSDelegate()

@property(assign, nonatomic) BOOL hasAuthorized;

@end

@implementation RSSReaderGDiOSDelegate

-(void)setrssReaderAppDelegate:(AppDelegate *)rssReaderAppDelegate
{
    _rssReaderAppDelegate = rssReaderAppDelegate;
    [self didAuthorize];
}

-(void)didAuthorize
{
    if (self.hasAuthorized && self.rssReaderAppDelegate) {
        NSLog(@"%s", __FUNCTION__);
    }
    
    GDAuthDelegateInfo* gdAuthDelegateInfo = [[GDiOS sharedInstance] getAuthDelegate];

    NSLog(@"didAuthorize getAuthDelegate Name = %@, address = %@, applicationId = %@, isAuthenticationDelegated = %@",
          gdAuthDelegateInfo.name, gdAuthDelegateInfo.address, gdAuthDelegateInfo.applicationId,
          gdAuthDelegateInfo.isAuthenticationDelegated ? @"YES" : @"NO");
}

+(instancetype)sharedInstance
{
    static RSSReaderGDiOSDelegate *rssReaderGDiOSDelegate = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        rssReaderGDiOSDelegate = [[RSSReaderGDiOSDelegate alloc] init];
    });
    return rssReaderGDiOSDelegate;
}

#pragma mark - Good Dynamics Delegate Methods

-(void)handleEvent:(GDAppEvent*)anEvent
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

-(void) onNotAuthorized:(GDAppEvent*)anEvent
{
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

-(void) onAuthorized:(GDAppEvent*)anEvent
{
    /* Handle the Good Libraries authorized event. */
    
    switch (anEvent.code) {
        case GDErrorNone: {
            if (!self.hasAuthorized) {
                // launch application UI here
                UIWindow *appWindow = self.rssReaderAppDelegate.window;
                appWindow.tintColor = RGB(52.f, 69.f, 84.f);
                //Detect the device
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                {
                    /*
                     *	iPhone start - based on single UINavigationController
                     */
                    // Setup the rootviewcontroller and a navigation controller (for the splitviewcontroller)
                    self.navController = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"iPhoneNC"];
                    
                    appWindow.rootViewController = _navController;
                }
                else
                {
                    
                    /*
                     *	iPad start - based on UISplitViewController
                     */
                    self.splitViewController = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"SplitVC"];
                    
                    self.navController = [self.splitViewController.viewControllers firstObject];
                    self.detailNavigationController = [self.splitViewController.viewControllers lastObject];
                    self.rssReaderAppDelegate.window.rootViewController = self.splitViewController;
                    
                }
                [[RSSManager sharedRSSManager] setAlertPresenter:self.navController];
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


@end
