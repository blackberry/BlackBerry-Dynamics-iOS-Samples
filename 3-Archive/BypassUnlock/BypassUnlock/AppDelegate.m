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
#import "BPCallManager.h"
#import "BypassUnlockGDiOSDelegate.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@property (assign) BOOL coldStart;
@property (strong, nonatomic) GDState *gdState;
@property (nonatomic, strong) AVAudioSession *session;

@end

static void *gdAuthorizedContext = &gdAuthorizedContext;
static void *gdNotAuthorizedReasonContext = &gdNotAuthorizedReasonContext;
static void *gdUserInterfaceStateContext = &gdUserInterfaceStateContext;
static void *gdCurrentScreenContext = &gdCurrentScreenContext;

@implementation AppDelegate



/**
    Remember to change the application ID and version on Info.plist
*/


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self disableAnimationsInUITests];

    self.coldStart = YES;
    [BPCallManager sharedManager].appStarted = NO;
    
    [BypassUnlockGDiOSDelegate sharedInstance].appDelegate = self;

    // Set a GDState instance and example KVO / Notification Center observers
    self.gdState = [[GDiOS sharedInstance] state];
    [self addStateObserversUsingNotificationCenter];
    [self addStateObserversUsingKVO];

    [[GDiOS sharedInstance] authorize:[BypassUnlockGDiOSDelegate sharedInstance]];
    
    [self setupVolumeOutputKVO];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // must set AVAudioSession active to true when returning to foreground
    [self setupVolumeOutputKVO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation {
    if (![sourceApplication isEqualToString:@"com.good.example.sdk.bypassunlock.notifier"]) {
        return NO;
    }
    
    if (self.coldStart) {
        NSLog(@"Will attempt bypass unlock screen from cold start ...");

        self.coldStart = NO;
    } else {
        NSLog(@"Will attempt bypass unlock screen from background state ...");
    }
    
    [[BPCallManager sharedManager] simulateCall];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)didAuthorize
{
    NSLog(@"%s", __FUNCTION__);
    if (![BPCallManager sharedManager].appStarted) {
        [BPCallManager sharedManager].appStarted = YES;
    }
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
        
    } else if ([keyPath isEqualToString:@"outputVolume"]) {
        [[BPCallManager sharedManager] simulateCall];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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

#pragma mark - Setup AVAudioSession

/*
 * Needed for simulating incoming event (i.e. income call). The action is a pressing one of the volume buttons.
 * This property returns a value in the range 0.0 to 1.0, with 0.0 representing the minimum volume, and 1.0 representing the maximum
 * volume.
 * A notification will not be sent if volume is already at min or max.
 */
- (void)setupVolumeOutputKVO {
    if (self.session == nil) {
        self.session = [AVAudioSession sharedInstance];
        
        [self.session addObserver:self forKeyPath: @"outputVolume"
                          options: NSKeyValueObservingOptionNew
                          context: nil];
    }
    [self.session setActive:YES error:nil];
}

@end
