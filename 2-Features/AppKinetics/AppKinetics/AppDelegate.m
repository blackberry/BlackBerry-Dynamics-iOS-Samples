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


#import "AppDelegate.h"
#import "MasterViewController.h"
#import "DetailViewController.h"
#import "AppKineticsGDiOSDelegate.h"

@implementation AppDelegate

static void *gdAuthorizedContext = &gdAuthorizedContext;
static void *gdNotAuthorizedReasonContext = &gdNotAuthorizedReasonContext;
static void *gdUserInterfaceStateContext = &gdUserInterfaceStateContext;
static void *gdCurrentScreenContext = &gdCurrentScreenContext;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self disableAnimationsInUITests];
    self.transferService = [[FileTransferService alloc] init];
    [AppKineticsGDiOSDelegate sharedInstance].appKineticsAppDelegate = self;
    // Set the main window
    // Set a GDState instance and example KVO / Notification Center observers
    self.gdState = [[GDiOS sharedInstance] state];
    [self addStateObserversUsingNotificationCenter];
    [self addStateObserversUsingKVO];
    [self addObserversForSettingsChangeNotifications];
    [self addObserversForContainerMigrationNotifications];
    
    [[GDiOS sharedInstance] authorize:[AppKineticsGDiOSDelegate sharedInstance]];
    
    return YES;    
}

- (void)didAuthorize
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kPassedAutorizationNotification object:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Good Dynamics observers for state changes (KVO)

- (void)addStateObserversUsingKVO
{
    NSKeyValueObservingOptions keyValueOptions = (NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld);
    
    [self.gdState addObserver:self
                   forKeyPath:GDKeyIsAuthorized
                      options: keyValueOptions
                      context: gdAuthorizedContext];
    [self.gdState addObserver:self
                   forKeyPath:GDKeyReasonNotAuthorized
                      options: keyValueOptions
                      context: gdNotAuthorizedReasonContext];
    [self.gdState addObserver:self
                   forKeyPath:GDKeyUserInterfaceState
                      options: keyValueOptions
                      context: gdUserInterfaceStateContext];
    [self.gdState addObserver:self
                   forKeyPath:GDKeyCurrentScreen
                      options: keyValueOptions
                      context: gdCurrentScreenContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    if (context == gdAuthorizedContext) {
        BOOL isAuthorized = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        [self handleChangeInAuthorized:isAuthorized];
        
    } else if (context == gdNotAuthorizedReasonContext) {
        NSLog(@"gdState: reasonNotAuthorized oldValue=%@, newValue=%@",
              change[NSKeyValueChangeOldKey], change[NSKeyValueChangeNewKey]);
        
    } else if (context == gdUserInterfaceStateContext) {
        GDUserInterfaceState oldState = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        GDUserInterfaceState newState = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        [self handleChangeInUiState:oldState withNewState:newState];
        
    } else if (context == gdCurrentScreenContext) {
        GDLibraryScreen oldScreen = [[change objectForKey:NSKeyValueChangeOldKey] intValue];
        GDLibraryScreen newScreen = [[change objectForKey:NSKeyValueChangeNewKey] intValue];
        [self handleChangeInLibraryScreen:oldScreen withNewScreen:newScreen];
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Notifications for settings change

- (void)addObserversForSettingsChangeNotifications
{
    // register notifications for 
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleRemoteSettingUpdateNotification:)
                                                 name:GDRemoteSettingsUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleServiceUpdateNotification:)
                                                 name:GDServicesUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handlePolicyUpdateNotification:)
                                                 name:GDPolicyUpdateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleEntitlementsUpdateNotification:)
                                                 name:GDEntitlementsUpdateNotification
                                               object:nil];
}

- (void)handleRemoteSettingUpdateNotification:(NSNotification *)notification
{
    NSLog(@"GDRemoteSettingsUpdateNotification received");
}

- (void)handleServiceUpdateNotification:(NSNotification *)notification
{
    NSLog(@"GDServicesUpdateNotification received");
}

- (void)handlePolicyUpdateNotification:(NSNotification *)notification
{
    NSLog(@"GDPolicyUpdateNotification received");
}

- (void)handleEntitlementsUpdateNotification:(NSNotification *)notification
{
    NSLog(@"GDEntitlementsUpdateNotification received");
}

#pragma mark - Notifications for container migration

- (void)addObserversForContainerMigrationNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContainerMigrationPendingNotification:)
                                                 name:GDContainerMigrationPendingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleContainerMigrationCompletedNotification:)
                                                 name:GDContainerMigrationCompletedNotification
                                               object:nil];
}

- (void)handleContainerMigrationPendingNotification:(NSNotification *)notification
{
    NSLog(@"GDContainerMigrationPendingNotification received");
}

- (void)handleContainerMigrationCompletedNotification:(NSNotification *)notification
{
    NSLog(@"GDContainerMigrationCompletedNotification received");
}

#pragma mark - Good Dynamics observers for state changes (Notification Center)

- (void)addStateObserversUsingNotificationCenter
{
    // register to receive notification center notifications for GD state changes
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveStateChangeNotification:)
                                                 name:GDStateChangeNotification
                                               object:nil];
}

- (void) receiveStateChangeNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:GDStateChangeNotification]) {
        
        NSDictionary* userInfo = [notification userInfo];
        NSString *propertyName = [userInfo objectForKey:GDStateChangeKeyProperty];
        GDState* state = [userInfo objectForKey:GDStateChangeKeyCopy];
        
        // The conditions here could invoke the same change handlers that are being called via the KVO
        // observeValueForKeyPath method above (ie. GDKeyIsAuthorized -> handleChangeInAuthorized, etc.)
        // For the purposes of this example, we want to log a different message so that it is known
        // these calls are coming from Notification Center rather than via the KVO observer.
        if ([propertyName isEqualToString:GDKeyIsAuthorized]) {
            NSLog(@"receiveStateChangeNotification - isAuthorized: %@", state.isAuthorized ? @"true" : @"false");
            
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

- (void)handleChangeInAuthorized:(BOOL)isAuthorized
{
    if (isAuthorized) {
        NSLog(@"gdState: authorized");
    } else {
        GDAppResultCode errorCode = [self.gdState reasonNotAuthorized];
        NSLog(@"gdState: not authorized, error:%ld", (long) errorCode);
    }
}

- (void)handleChangeInUiState:(GDUserInterfaceState)oldState withNewState:(GDUserInterfaceState)newState
{
    switch (newState) {
        case GDUIStateGDLibraryInFront:
            NSLog(@"gdState: GD library user interface is now in front");
            break;
            
        case GDUIStateApplicationInFront:
            NSLog(@"gdState: Application user interface is now in front");
            break;
            
        case GDUIStateBypassUnlockInFront:
            NSLog(@"gdState: Bypass unlock user interface is in now front");
            break;
            
        case GDUIStateNone:
            // window initialization is in progress
            break;
    }
}

- (void)handleChangeInLibraryScreen:(GDLibraryScreen)oldScreen withNewScreen:(GDLibraryScreen)newScreen
{
    switch (newScreen) {
        case GDLibraryScreenCertificateImport:
            NSLog(@"gdState: Certificate import screen is being shown");
            break;
        case GDLibraryScreenOther:
            NSLog(@"gdState: Another screen is being shown");
            break;
        case GDLibraryScreenNone:
            // window initialization is in progress, no current screen has been set yet
            break;
    }
}

- (void)disableAnimationsInUITests
{
    BOOL disableAnimations = [[[NSProcessInfo processInfo] arguments] containsObject:@"disableAnimations"];
    if (disableAnimations)
    {
        NSLog(@"Animations disabled in UITests");
        [UIView setAnimationsEnabled:false];
    }
}

@end
