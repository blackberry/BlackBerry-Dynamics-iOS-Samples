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

#import "LocalComplianceManager.h"
#import "AppDelegate.h"

#import <BlackBerryDynamics/GD/GDiOS.h>
#import <BlackBerryDynamics/GD/GDFileManager.h>
#import <MediaPlayer/MediaPlayer.h>

@interface LocalComplianceManager ()

@property (nonatomic, assign) BOOL isBlockExecuted;

@end

NSString * const kPersistentBlockId = @"BypassUnlockBlockID";
NSString * const kBlockFor10SecId = @"BypassUnlockBlockID2";
// file which stores the ID of local block
NSString * const kBlockSaveFile = @"BypassUnlockBlockSaveFile.txt";

@implementation LocalComplianceManager

#pragma mark - setup

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self setupManager];
    }
    return self;
}

- (void)setupManager
{
    NSString *lastSavedBlockID = [self retrieveLastSavedBlock];
    if (!lastSavedBlockID)
    {
        return;
    }
    if ([lastSavedBlockID isEqualToString:kPersistentBlockId])
    {
        self.isBlockExecuted = YES;
        [self addUnblockButton];
    }
    // if the user chosed block for 10 seconds and then the app was terminated for some reason
    // then remove local block
    else if ([lastSavedBlockID isEqualToString:kBlockFor10SecId])
    {
        [self internalExecuteUnblock:lastSavedBlockID];
    }
}

#pragma mark - public methods

- (void)executeBlockFor10Seconds
{
    if (!self.isBlockExecuted)
    {
        NSString *blockMessage = @"An application is blocked locally for 10 seconds.\n";
        [self internalExecuteBlock:kBlockFor10SecId
                        blockTitle:@"Application access blocked"
                      blockMessage:blockMessage];
        [NSTimer scheduledTimerWithTimeInterval:10
                                         target:self
                                       selector:@selector(fireLocalBlockTimeout)
                                       userInfo:nil
                                        repeats:NO];
    }
}

- (void)executeBlock
{
    if (!self.isBlockExecuted)
    {
        NSString *blockMessage = @"An application is blocked. Tap at the bottom of the screen to unblock it.\n";
        [self internalExecuteBlock:kPersistentBlockId
                        blockTitle:@"Application access blocked"
                      blockMessage:blockMessage];
        [self addUnblockButtonAfterTimeInterval:0.3];
    }
}

#pragma mark - Unblock button

- (void)addUnblockButton {
    [self addUnblockButtonAfterTimeInterval:0.5];
}

- (void)addUnblockButtonAfterTimeInterval:(NSTimeInterval)timeInterval {
    [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                     target:self
                                   selector:@selector(internalAddUnblockButton)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)internalAddUnblockButton {
    
    UIViewController *blockViewController = [self getBlockViewController];
    if (blockViewController)
    {
        UIButton *unlockButton = [[UIButton alloc] init];
        [unlockButton addTarget:self action:@selector(unblock) forControlEvents:UIControlEventTouchUpInside];
        
        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:unlockButton
                                                                            attribute:NSLayoutAttributeBottom
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:blockViewController.view
                                                                            attribute:NSLayoutAttributeBottom
                                                                           multiplier:1
                                                                             constant:0];
        
        NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:unlockButton
                                                                             attribute:NSLayoutAttributeLeading
                                                                             relatedBy:NSLayoutRelationEqual
                                                                                toItem:blockViewController.view
                                                                             attribute:NSLayoutAttributeLeading
                                                                            multiplier:1
                                                                              constant:0];
        
        NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:unlockButton
                                                                              attribute:NSLayoutAttributeTrailing
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:blockViewController.view
                                                                              attribute:NSLayoutAttributeTrailing
                                                                             multiplier:1
                                                                               constant:0];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:unlockButton
                                                                            attribute:NSLayoutAttributeHeight
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:blockViewController.view
                                                                            attribute:NSLayoutAttributeHeight
                                                                           multiplier:0.3
                                                                             constant:0];
        
        [blockViewController.view addSubview:unlockButton];
        unlockButton.translatesAutoresizingMaskIntoConstraints = NO;
        [NSLayoutConstraint activateConstraints:@[bottomConstraint, leadingConstraint, trailingConstraint, heightConstraint]];
    }
    
}

// Code below is an example of illegal using of GD
// framework and used only in test purposes.
- (UIViewController *)getBlockViewController {
    UIWindow *gdWindow;
    UIViewController *blockViewController;
    NSArray *windowScenes = [[UIApplication sharedApplication].connectedScenes allObjects];
    UIWindowScene *scene = [windowScenes firstObject];
    NSArray *windows = scene.windows;
    Class gdWindowClass = NSClassFromString(@"GDWindow");
    Class gdBlockVCClass = NSClassFromString(@"GDBlockViewController");
    for (id window in windows)
    {
        if ([window isKindOfClass:gdWindowClass])
        {
            gdWindow = window;
        }
    }
    
    if (gdWindow)
    {
        UINavigationController *navigationController = (UINavigationController *)gdWindow.rootViewController;
        UIViewController *blockVC = navigationController.topViewController;
        if ([blockVC isKindOfClass:gdBlockVCClass])
        {
            blockViewController = blockVC;
        }
    }
    return blockViewController;
}

#pragma mark - helpers

- (void)unblock
{
    [self internalExecuteUnblock:kPersistentBlockId];
}

- (void)fireLocalBlockTimeout
{
    [self internalExecuteUnblock:kBlockFor10SecId];
}

- (void)internalExecuteBlock:(NSString *)blockId
                  blockTitle:(NSString *)blockTitle
                blockMessage:(NSString *)blockMessage
{
    self.isBlockExecuted = YES;
    [self saveNewBlock:blockId];
    [[GDiOS sharedInstance] executeBlock:blockId withTitle:blockTitle withMessage:blockMessage];
}

- (void)internalExecuteUnblock:(NSString *)blockId
{
    if ([[self retrieveLastSavedBlock] isEqualToString:blockId]) {
        self.isBlockExecuted = NO;
        [self saveNewBlock:@""];
        [[GDiOS sharedInstance] executeUnblock:blockId];
    }
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

#pragma mark - Storage

- (void)saveNewBlock:(NSString *)blockID
{
    NSData *data = [blockID dataUsingEncoding:NSUTF8StringEncoding];
    [[GDFileManager defaultManager] createFileAtPath:[self fullPathOfFileWithName:kBlockSaveFile]
                                            contents:data
                                          attributes:nil];
}

- (NSString *)retrieveLastSavedBlock
{
    NSData *dataPtr = [[GDFileManager defaultManager] contentsAtPath:[self fullPathOfFileWithName:kBlockSaveFile]];
    
    if ([dataPtr length] > 0)
    {
        NSString *blockId = [[NSString alloc] initWithData:dataPtr encoding:NSUTF8StringEncoding];
        return blockId;
    }
    return nil;
}

-(NSString*)fullPathOfFileWithName:(NSString*)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}

@end
