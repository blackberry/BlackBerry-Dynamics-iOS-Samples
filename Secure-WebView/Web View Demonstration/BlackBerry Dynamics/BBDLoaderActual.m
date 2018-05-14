/* Copyright (c) 2016 BlackBerry Ltd.
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

#import "BBDLoader.h"
#include <UIKit/UIKit.h>
#import <GD/GDiOS.h>
#import "Utilities.h"
@interface BBDLoader() <GDiOSDelegate>
// Private constructor.
-(instancetype)init;

@property (assign) BOOL authorised;
@end

@implementation BBDLoader

+(void)load {
    id instance = [BBDLoader sharedInstance];
    
    NSLog(@"%s %@.", __FUNCTION__, instance);
}

+(instancetype)sharedInstance
{
    static BBDLoader *instance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[[BBDLoader class] alloc] init];
    });
    return instance;
}

-(instancetype)init {
    self = [super init];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(observeLaunch:) 
                   name:UIApplicationDidFinishLaunchingNotification
                 object:nil];
    
    return self;
}

-(void)observeLaunch:(NSNotification *)notification {
    NSLog(@"%s %@.", __FUNCTION__, notification.name);

    GDiOS *gdRuntime = [GDiOS sharedInstance];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self 
               selector:@selector(observeBlackBerryDynamics:) 
                   name:GDStateChangeNotification 
                 object:gdRuntime.state];
    
    [gdRuntime authorize:self];
}

-(void)observeBlackBerryDynamics:(NSNotification *)notification {
    BOOL nowAuthorised = [GDiOS sharedInstance].state.isAuthorized;
    if (nowAuthorised && !self.authorised) {
        static dispatch_once_t onceToken = 0;
        dispatch_once(&onceToken, ^{
            [Utilities launchStoryboard:@"BBDLoaderUIMainStoryboardFile"];
        });
    }
    self.authorised = nowAuthorised;
    NSLog(@"%s %@ %@.", __FUNCTION__, notification.name,
          nowAuthorised ? @"Authorised" : @"Not authorised");
}

- (void)handleEvent:(nonnull GDAppEvent *)gdAppEvent { 
    NSLog(@"%s %@.", __FUNCTION__, gdAppEvent);
    return;
}

+ (NSString *)settings {
    GDiOS *runtime = [GDiOS sharedInstance];
    NSDictionary *config = [runtime getApplicationConfig];
    NSNumber *outboundDLPSetting = 
    [config objectForKey:GDAppConfigKeyPreventDataLeakageOut]; 
    BOOL outboundDLPAllowed = [outboundDLPSetting integerValue] == 0; 
    return 
    [NSString
     stringWithFormat:@"BlackBerry Dynamics version %@\nOutbound DLP: %@.",
     [runtime getVersion],
     outboundDLPAllowed ? @"Allowed" : @"Not allowed"];
}

@end
