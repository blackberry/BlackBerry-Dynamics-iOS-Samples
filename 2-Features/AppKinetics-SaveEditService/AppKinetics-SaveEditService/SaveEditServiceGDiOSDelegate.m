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

#import "SaveEditServiceGDiOSDelegate.h"

#import "ViewController.h"
#import "ServiceController.h"

@interface SaveEditServiceGDiOSDelegate()

@property (nonatomic, assign) BOOL hasAuthorized;
@property (strong, nonatomic) ServiceController *serviceController;

-(instancetype)init;
-(void)didAuthorize;

@end

@implementation SaveEditServiceGDiOSDelegate

+(instancetype)sharedInstance
{
    static SaveEditServiceGDiOSDelegate *saveEditServiceGDiOSDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        saveEditServiceGDiOSDelegate = [[SaveEditServiceGDiOSDelegate alloc] init];
    });
    return saveEditServiceGDiOSDelegate;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        // initialize serviceController which is responsible for file transfer logic
        // should be initialized here, directly after call of didFinishLaunchingWithOptions of UIApplication
        // because in some cases files could be received before app is authorized
        _serviceController = [ServiceController new];
    }
    return self;
}

-(void)setRootViewController:(ViewController *)rootViewController
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
            NSLog(@"Received Service Update event");
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
    
    switch (anEvent.code) {
        case GDErrorActivationFailed:
        case GDErrorProvisioningFailed:
        case GDErrorPushConnectionTimeout: {
            // application can either handle this and show it's own UI or just call back into
            // the GD library and the welcome screen will be shown
            [[GDiOS sharedInstance] authorize];
            break;
        }
        case GDErrorSecurityError:
        case GDErrorAppDenied:
        case GDErrorAppVersionNotEntitled:
        case GDErrorBlocked:
        case GDErrorWiped:
        case GDErrorRemoteLockout:
        case GDErrorPasswordChangeRequired: {
            // an condition has occured denying authorization, an application may wish to log these events
            NSLog(@"onNotauthorized %@", anEvent.message);
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

-(void)onAuthorized:(GDAppEvent*)anEvent {
    /* Handle the Good Libraries authorized event. */
    
    switch (anEvent.code) {
        case GDErrorNone: {
            if (!self.hasAuthorized) {
                // launch application UI here
                UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UINavigationController *uiNavController = [uiStoryboard instantiateInitialViewController];
                
                self.appDelegate.window.rootViewController = uiNavController;
                ViewController *rootVC = uiNavController.viewControllers.firstObject;
                // create dependencies 
                self.rootViewController = rootVC;
                rootVC.serviceController = self.serviceController;
                self.serviceController.receiveTextCompletion = ^(NSString * _Nonnull text) {
                    [rootVC receiveText:text];
                };
                
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
