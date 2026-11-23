/* Copyright (c) 2026 BlackBerry Ltd.
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

#import "GDiOSDelegate.h"
#import "AppBasedCertImport-Swift.h"

@interface GDiOSDelegate ()

@property (nonatomic, assign) BOOL hasAuthorizedInternal;
@property (nonatomic, strong) UIViewController *pendingRootViewController;

- (instancetype)init;
- (void)notifyApplicationDidAuthorizeIfNeeded;

@end

@implementation GDiOSDelegate

+ (instancetype)sharedInstance {

    static GDiOSDelegate *gdiOSDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gdiOSDelegate = [[GDiOSDelegate alloc] init];
    });
    return gdiOSDelegate;
}

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (BOOL)hasAuthorized {
    return self.hasAuthorizedInternal;
}

- (void)presentMainUIIfNeeded {
    if (!self.hasAuthorizedInternal || self.pendingRootViewController == nil) {
        return;
    }
    AppBasedCertImportSceneDelegate *scene = [AppBasedCertImportSceneDelegate current];
    if (scene == nil || scene.window == nil) {
        return;
    }
    scene.window.rootViewController = self.pendingRootViewController;
    self.pendingRootViewController = nil;
    [scene.window makeKeyAndVisible];
    [self notifyApplicationDidAuthorizeIfNeeded];
}

- (void)notifyApplicationDidAuthorizeIfNeeded {
    if (!self.hasAuthorizedInternal || self.pendingRootViewController != nil) {
        return;
    }
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (appDelegate != nil) {
        [appDelegate didAuthorize];
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
            break;
        }
        case GDAppEventServicesUpdate:
        {
            break;
        }
        case GDAppEventPolicyUpdate:
        {
            break;
        }
        case GDAppEventEntitlementsUpdate:
        {
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
            NSLog(@"onNotAuthorized %@", anEvent.message);
            break;
        }
        case GDErrorIdleLockout: {
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
        case GDErrorNone:
            if (!self.hasAuthorizedInternal) {
                UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
                self.pendingRootViewController = uiViewController;
                self.hasAuthorizedInternal = YES;
                [self presentMainUIIfNeeded];
            }
            break;
        default:
            NSAssert(false, @"Authorized startup with an error");
            break;
    }
}

@end
