/*
 * Copyright (c) 2019 BlackBerry Limited. All Rights Reserved.
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
 */

#import "BBDInputBlocker.h"

#import "UIView+FirstResponder.h"

NSString *const BBDDictationWasBlockedNotification = @"BBDDictationWasBlockedNotification";
NSString *const BBDKeyboardExtensionDidAppearNotification = @"BBDKeyboardExtensionDidAppearNotification";
NSString *const BBDKeyboardExtensionInputWasBlockedNotification = @"BBDKeyboardExtensionInputWasBlockedNotification";

@interface BBDInputBlocker ()
    
@property (nonatomic, strong) NSArray<NSObject *> *allowedExtensionClasses;
@property (nonatomic, strong) NSArray<NSObject *> *disallowedExtensionClasses;
// initializing classes which belongs to custom keyboards
// look at initExtensionClasses method for implementation details
@property (nonatomic, assign) BOOL isKeyboardExtBlockingInitialized;
@property (nonatomic, assign) BOOL shouldKeyboardExtBlockBypass;
    
@end

static NSString* const kDictationLanguageIndentifier = @"dictation";

@implementation BBDInputBlocker
    
static BBDInputBlocker *sharedInstance = nil;
    
+ (instancetype)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
        {
            sharedInstance = [[BBDInputBlocker alloc] init];
        }
    }
    return sharedInstance;
}
    
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:UIApplicationDidFinishLaunchingNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(inputModeDidChange:)
                                                     name:UITextInputCurrentInputModeDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldDidBeginEditing:) name:UITextFieldTextDidChangeNotification object:nil];
    }
    return self;
}
    
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self initExtensionClasses];
}
    
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if (!self.isKeyboardExtBlockingInitialized)
    {
        [self initExtensionClasses];
    }
}
    
- (void)textFieldDidBeginEditing:(NSNotification *)notification
{
    UIView *textInputView = [self getCurrentFirstResponder];
    UITextInputMode *inputMode = textInputView.textInputMode;
    if (!self.isKeyboardExtBlockingInitialized)
    {
        [self initExtensionClasses];
    }
    if ([self isExtensionKeyboard:[inputMode class]]
        && self.needsBlockCustomKeyboard(textInputView))
    {
        [self adjustKeyboardExtensionsInputBlocking:textInputView];
    }
}
    
- (void)inputModeDidChange:(NSNotification *)notification
{
    UIView *textInputView = [self getCurrentFirstResponder];
    UITextInputMode *inputMode = textInputView.textInputMode;
    if ([inputMode.primaryLanguage isEqualToString:kDictationLanguageIndentifier]
        && self.needsBlockDictation(textInputView))
    {
        [self adjustDictationBlocking:textInputView];
        return;
    }
    if (!self.isKeyboardExtBlockingInitialized)
    {
        [self initExtensionClasses];
    }
    if ([self isExtensionKeyboard:[inputMode class]]
        && self.needsBlockCustomKeyboard(textInputView))
    {
        [self adjustKeyboardExtensionsApperanceBlocking:textInputView];
    }
}
    
- (void)adjustDictationBlocking:(UIView *)textInputView
{
    // resign and become again to hide dictation input
    [textInputView resignFirstResponder];
    [textInputView becomeFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:BBDDictationWasBlockedNotification
                                                        object:textInputView];
}
    
- (void)adjustKeyboardExtensionsApperanceBlocking:(UIView *)textInputView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BBDKeyboardExtensionDidAppearNotification
                                                        object:textInputView];
}
    
- (void)adjustKeyboardExtensionsInputBlocking:(UIView *)textInputView
{
    if ([textInputView isKindOfClass:[UITextField class]])
    {
        UITextField *textField = (UITextField *)textInputView;
        textField.text = @"";
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:BBDKeyboardExtensionInputWasBlockedNotification
                                                        object:textInputView];
}
    
- (BOOL)shouldBlockExtensionKeyboard
{
    if (!self.isKeyboardExtBlockingInitialized)
    {
        return YES;
    }
    else if (self.shouldKeyboardExtBlockBypass)
    {
        return NO;
    }
    else return self.needsBlockCustomKeyboard([self getCurrentFirstResponder]);
}
    
- (BOOL)isExtensionKeyboard:(Class)keyboardClass
{
    for (Class currentClass in self.disallowedExtensionClasses)
    {
        if ([currentClass isMemberOfClass:keyboardClass])
        {
            return YES;
        }
    }
    return NO;
}
    
- (void)initExtensionClasses
{
    // The scenario is the next:
    // 1. Call activeInputMode method of UITextInputMode.
    // 2. This call makes an internal UIKit call to shouldAllowExtensionPointIdentifier method in application delegate,
    // which is swizzled inside an SDK in NSObject+UIApplicationDelegate extension.
    // 3. In swizzled method we return the value which depends on isKeyboardExtBlockingInitialized and shouldKeyboardExtBlockBypass properties.
    // 4. Depending on the result of shouldAllowExtensionPointIdentifier method, active input modes array will include(or not) keyboard extension classes.
    // 5. After a few activeInputModes we can determine whether the class belongs to keyboard extension or not.
    // It allows us to determine the keyboard extension classes without using PMU.
    if (!self.allowedExtensionClasses.count)
    {
        NSArray *list = [UITextInputMode activeInputModes];
        self.allowedExtensionClasses = list.copy;
    }
    self.isKeyboardExtBlockingInitialized = YES;
    self.shouldKeyboardExtBlockBypass = YES;
    NSArray *list = [UITextInputMode activeInputModes];
    // Check if keyboard extension classes were determined.
    // If there is no custom keyboards,
    // change isKeyboardExtBlockingInitialized flag to NO
    // to check for keyboard extension at the next time
    self.shouldKeyboardExtBlockBypass = NO;
    NSArray *disallowedArray = [self findArrayIntersection:list secondArray:self.allowedExtensionClasses];
    if (disallowedArray.count)
    {
        self.disallowedExtensionClasses = disallowedArray;
    }
    else
    {
        self.isKeyboardExtBlockingInitialized = NO;
    }
}
    
- (NSArray<Class> *)findArrayIntersection:(NSArray <NSObject *> *)firstArray secondArray:(NSArray <NSObject *> *)secondArray
{
    NSMutableArray *array = [NSMutableArray new];
    for (NSObject *classObject in firstArray)
    {
        BOOL isFound = NO;
        for (NSObject *classObject2 in secondArray)
        {
            if ([classObject isMemberOfClass:[classObject2 class]]) {
                isFound = YES;
                break;
            }
        }
        if (!isFound)
        {
            [array addObject:classObject];
        }
    }
    return array;
}

- (UIView *)getCurrentFirstResponder
{
    return [UIApplication sharedApplication].keyWindow.findFirstResponder;
}
    
@end
