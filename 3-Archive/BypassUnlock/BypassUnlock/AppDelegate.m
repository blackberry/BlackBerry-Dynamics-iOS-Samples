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
#import "BypassUnlock-Swift.h"
#import <AVFoundation/AVFoundation.h>

static const NSTimeInterval kVolumeKVOSuppressionInterval = 1.0;

@interface AppDelegate ()

@property (assign) BOOL coldStart;
@property (strong, nonatomic) GDState *gdState;
@property (nonatomic, strong) AVAudioSession *session;
@property (nonatomic, assign) float lastLoggedOutputVolume;
@property (nonatomic, assign) BOOL isGDLibraryInFront;
@property (nonatomic, assign) CFAbsoluteTime volumeKVOSuppressedUntil;

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
    self.isGDLibraryInFront = NO;
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

#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    UISceneConfiguration *sceneConfig = [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                                                       sessionRole:connectingSceneSession.role];
    sceneConfig.delegateClass = [BypassUnlockSceneDelegate class];
    sceneConfig.sceneClass = [UIWindowScene class];
    sceneConfig.storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    return sceneConfig;
}

- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
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
    
    [[BPCallManager sharedManager] simulateCall:@"notifierURL"];
    
    return YES;
}

-(void)didAuthorize
{
    NSLog(@"%s", __FUNCTION__);
    if (![BPCallManager sharedManager].appStarted) {
        [BPCallManager sharedManager].appStarted = YES;
    }
}

- (BOOL)shouldHandleVolumeBypassForOutputVolumeChange {
    if (CFAbsoluteTimeGetCurrent() < self.volumeKVOSuppressedUntil) {
        NSLog(@"BypassUnlock: ignoring outputVolume change during AVAudioSession stabilization");
        return NO;
    }
    
    UIApplicationState applicationState = [UIApplication sharedApplication].applicationState;
    BOOL appStarted = [BPCallManager sharedManager].appStarted;
    
    if (applicationState == UIApplicationStateBackground) {
        NSLog(@"BypassUnlock: ignoring outputVolume change while app is in background");
        return NO;
    }
    
    // when biometric unlock or the system volume HUD shown the app is often inactive,
    // not active
    // allow volume bypass once the app has started.
    // foreground activation screens still require active.
    if (!appStarted) {
        if (applicationState != UIApplicationStateActive) {
            NSLog(@"BypassUnlock: ignoring outputVolume change during activation while app is not active");
            return NO;
        }
        
        if (!self.isGDLibraryInFront) {
            NSLog(@"BypassUnlock: ignoring outputVolume change before GD activation UI is in front");
            return NO;
        }
    }
    
    return YES;
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
        id oldValue = change[NSKeyValueChangeOldKey];
        id newValue = change[NSKeyValueChangeNewKey];
        float oldVolume = [oldValue isKindOfClass:[NSNumber class]] ? [oldValue floatValue] : NAN;
        float newVolume = [newValue isKindOfClass:[NSNumber class]] ? [newValue floatValue] : self.session.outputVolume;
        
        NSLog(@"BypassUnlock: outputVolume changed old=%.4f new=%.4f appStarted=%@ gdLibraryInFront=%@",
              oldVolume,
              newVolume,
              [BPCallManager sharedManager].appStarted ? @"YES" : @"NO",
              self.isGDLibraryInFront ? @"YES" : @"NO");
        
        self.lastLoggedOutputVolume = newVolume;
        
        if (![self shouldHandleVolumeBypassForOutputVolumeChange]) {
            return;
        }
        
        [[BPCallManager sharedManager] simulateCall:@"volumeButtonKVO"];
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
            self.isGDLibraryInFront = YES;
            NSLog(@"gdState: GD library user interface is now in front");
            break;
            
        case GDUIStateApplicationInFront:
            self.isGDLibraryInFront = NO;
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
        self.lastLoggedOutputVolume = self.session.outputVolume;
        
        [self.session addObserver:self forKeyPath:@"outputVolume"
                          options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
                          context: nil];
    }
    
    self.volumeKVOSuppressedUntil = CFAbsoluteTimeGetCurrent() + kVolumeKVOSuppressionInterval;
    
    NSError *sessionError = nil;
    [self.session setActive:YES error:&sessionError];
    if (sessionError != nil) {
        NSLog(@"BypassUnlock: AVAudioSession setActive failed: %@", sessionError.localizedDescription);
    }
    
    self.lastLoggedOutputVolume = self.session.outputVolume;
}

@end
