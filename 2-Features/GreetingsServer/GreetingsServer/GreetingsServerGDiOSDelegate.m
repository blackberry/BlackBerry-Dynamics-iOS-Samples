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

#import <BlackBerryDynamics/GD/GDState.h>
#import "GreetingsServerGDiOSDelegate.h"
#import "ServiceController.h"

@interface GreetingsServerGDiOSDelegate()

@property(assign, nonatomic) BOOL hasAuthorized;

@end

@implementation GreetingsServerGDiOSDelegate

- (void)setRootViewController:(RootViewController *)rootViewController
{
    _rootViewController = rootViewController;
    [self didAuthorize];
}

- (void)setAppKineticsTableAppDelegate:(AppDelegate *)greetingsClientAppDelegate
{
    greetingsClientAppDelegate = greetingsClientAppDelegate;
    [self didAuthorize];
}

- (void)didAuthorize
{
    if (self.hasAuthorized && self.rootViewController && self.greetigsServerAppDelegate)
    {
        [self.greetigsServerAppDelegate didAuthorize];
    }
}

+ (instancetype)sharedInstance
{
    static GreetingsServerGDiOSDelegate *greetigsClientGDiOSDelegate = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        greetigsClientGDiOSDelegate = [[GreetingsServerGDiOSDelegate alloc] init];
    });
    return greetigsClientGDiOSDelegate;
}

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        _serviceController = [[ServiceController alloc] init];
        [self addStateObserverUsingNotificationCenter];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Good Dynamics observer for state changes (Notification Center)

- (void)addStateObserverUsingNotificationCenter
{
    // register to receive notification center notifications for GD state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStateChangeNotification:) name:GDStateChangeNotification object:nil];
}

- (void) receiveStateChangeNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:GDStateChangeNotification]) {
        NSDictionary* userInfo = [notification userInfo];
        NSString *propertyName = [userInfo objectForKey:GDStateChangeKeyProperty];
        GDState* state = [userInfo objectForKey:GDStateChangeKeyCopy];
        
        // For the purposes of this example, we want to log a different message so that it is known
        // these calls are coming from Notification Center
        if ([propertyName isEqualToString:GDKeyIsAuthorized]) {
            NSLog(@"receiveStateChangeNotification - isAuthorized: %@", state.isAuthorized ? @"true" : @"false");
            [self handleStateChange:state];
    
        } else if ([propertyName isEqualToString:GDKeyReasonNotAuthorized]) {
            NSLog(@"receiveStateChangeNotification - reasonNotAuthorized: %ld", (long) state.reasonNotAuthorized);
            
        } else if ([propertyName isEqualToString:GDKeyUserInterfaceState]) {
            NSLog(@"receiveStateChangeNotification - userInterfaceState: %ld", (long) state.userInterfaceState);
            
        } else if ([propertyName isEqualToString:GDKeyCurrentScreen]) {
            NSLog(@"receiveStateChangeNotification - currentScreen: %ld", (long) state.currentScreen);
        }
    }
}

#pragma mark - Good Dynamics handler methods for state changes

- (void)handleStateChange:(GDState *)state
{
    if (state.isAuthorized) {
        NSLog(@"gdState: authorized");
        [self onAuthorized];
        
    } else {
        GDAppResultCode errorCode = [state reasonNotAuthorized];
        NSLog(@"gdState: not authorized, error:%ld", (long) errorCode);
        [self onNotAuthorized:errorCode];
        
    }
}

- (void)onAuthorized
{
    if (!self.hasAuthorized) {
        // launch application UI here
        self.hasAuthorized = YES;
        
        NSString *storyboardName;
        // detect the device
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            storyboardName = @"Main_iPhone";
        } else {
            storyboardName = @"Main_iPad";
        }
        
        UIStoryboard *uiStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        UIViewController *uiViewController = [uiStoryboard instantiateInitialViewController];
        
        self.greetigsServerAppDelegate.window.rootViewController = uiViewController;
        
        [self didAuthorize];
    }
}

- (void)onNotAuthorized:(GDAppResultCode)code
{
    /* Handle the Good Libraries not authorized event. */
    
    switch (code)
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
            NSLog(@"gdState: not authorized, error:%ld", (long) code);
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

@end
