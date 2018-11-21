/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "BBDAutoFillBlockerField.h"

#import <objc/runtime.h>

@interface BBDAutoFillBlockerField () <UITextFieldDelegate>

//will be used once setDelegate method called, i.e. it's a replacement for "delegate"
@property (nullable, nonatomic, weak) id<UITextFieldDelegate> bbd_externalDelegate;
//replacement for "secureTextEntry" property
@property (nonatomic, assign) BOOL bbd_secureTextEntry;
//replacement for "text" property
@property (nonatomic, copy) NSString *bbd_internalText;
//save original "autocorrectionType" here
@property (nonatomic, assign) UITextAutocorrectionType bbd_autocorrectionType;
//save original font here
@property (nonatomic, strong) UIFont *bbd_font;
// fix for iOS 10 behavior
@property (nonatomic, assign) BOOL isResignFirstResponderFlow;

@end

@implementation BBDAutoFillBlockerField

#pragma mark - Initializers

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self defaultInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    _bbd_internalText = @"";
    _bbd_font = [super font];
    [self setTextContentType:BBDTextContentTypeUnspecified];
    //setup delegate
    //if setDelegate is called, bbd_externalDelegate will contain that value
    super.delegate = self;
    [self adjustFontAppearence];
    [self adjustAutocorrectionType];
}

#pragma mark - UITextFieldDelegate - pass calls to external delegate if needed

- (void)setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.bbd_externalDelegate = delegate;
}

- (id<UITextFieldDelegate>)delegate
{
    return self.bbd_externalDelegate;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldChange = YES;
    
    //make strong reference on delegate
    id <UITextFieldDelegate> externalDelegate = self.delegate;
    if ([externalDelegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)])
    {
        shouldChange = [self.bbd_externalDelegate textField:textField shouldChangeCharactersInRange:range replacementString:string];
    }
    
    if (!self.bbd_secureTextEntry)
    {
        return shouldChange;
    }
    
    if (shouldChange)
    {
       self.bbd_internalText = [self.bbd_internalText stringByReplacingCharactersInRange: range withString: string];
    }
    
    if (shouldChange)
    {
        [super setText:[self dotPlaceholderForString:self.bbd_internalText]];
        [self adjustFontAppearence];
        // as we are returning NO below but did change the text,
        // we have to post notification UITextFieldTextDidChangeNotification and send action UIControlEventEditingChanged explicitly to let subscribers know that field has changed
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:self];
                           [self sendActionsForControlEvents:UIControlEventEditingChanged];
                       });
    }
    return NO;
}

// override forwardInvocation and respondsToSelector to pass delegate calls
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    SEL selector = anInvocation.selector;
    if ([self isTextFieldDelegateSelector:selector])
    {
        id <UITextFieldDelegate> externalDelegate = self.delegate;
        if ([externalDelegate respondsToSelector:selector])
        {
            [anInvocation invokeWithTarget:externalDelegate];
        }
    }
    else
    {
        [super forwardInvocation:anInvocation];
    }
}

// Override respondsToSelector, so that UITextFieldDelegate optional methods
// were called by the system.
// In general it works in the next way:
// 1. system calls respondsToSelector
// 2. we return yes for UITextFieldDelegate selector if external delegate implements the selector
// 3. as we don't implement UITextFieldDelegate selectors, forwardInvocation gets called
// 4. invocation is being passed to external delegate
- (BOOL)respondsToSelector:(SEL)aSelector
{
    BOOL responds = [super respondsToSelector:aSelector];
    if (responds)
    {
        return responds;
    }
    if ([self isTextFieldDelegateSelector:aSelector])
    {
        return [self.delegate respondsToSelector:aSelector];
    }
    
    return responds;
}

- (BOOL)isTextFieldDelegateSelector:(SEL)selector
{
    unsigned int outCount = 0;
    struct objc_method_description *descriptions = protocol_copyMethodDescriptionList(@protocol(UITextFieldDelegate),
                                                                                      NO,
                                                                                      YES,
                                                                                      &outCount);
    for (unsigned int i = 0; i < outCount; ++i)
    {
        if (descriptions[i].name == selector)
        {
            free(descriptions);
            return YES;
        }
    }
    free(descriptions);
    return NO;
}

#pragma mark - Appearance

- (void)adjustFontAppearence
{
    if (!self.bbd_font)
    {
        self.bbd_font = [super font];
    }
    
    if (self.bbd_secureTextEntry && self.bbd_internalText.length > 0)
    {
        super.font = [self getBlackDotsFont];
    }
    else
    {
        super.font = self.bbd_font;
    }
}

- (void)setFont:(UIFont *)font
{
    self.bbd_font = font;
    [self adjustFontAppearence];
}

- (UIFont *)font
{
    return self.bbd_font;
}

- (UIFont *)getBlackDotsFont
{
    if (self.secureTextFont)
    {
        return self.secureTextFont;
    }
    // create system-match font
    // the function is created experimentally
    // it is still a point for improvement and the font may differ from the system one
    const CGFloat startValue = 14;
    CGFloat calculateValue = startValue + (self.bbd_font.pointSize - startValue) * 5/4 + 4;
    CGFloat fontSize = floorf((float)calculateValue);
    return [UIFont boldSystemFontOfSize:fontSize];
}

#pragma mark - Custom secure entry logic

- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
    BOOL isChanged = secureTextEntry != self.bbd_secureTextEntry;
    self.bbd_secureTextEntry = secureTextEntry;
    // In a case if secureTextEntry was set dynamically
    // remember the previously entered text
    if (isChanged && secureTextEntry)
    {
        self.bbd_internalText = [super text];
    }
    [self adjustFontAppearence];
    [self adjustAutocorrectionType];
}

- (void)setText:(NSString *)text
{
    NSString *stringToInput = text;
    
    if (self.bbd_secureTextEntry)
    {
        // when textfield resigns first responder, super.text returns empty string for iOS 10
        // and system tries to setup cashed text(which is black dots)
        // this behaviour is observed when UITextField instance is created from the code
        // it is not observed when an UITextField is created from XIB or Storyboard
        if (self.isResignFirstResponderFlow && [text isEqualToString:[self dotPlaceholderForString:self.bbd_internalText]])
        {
            stringToInput = self.bbd_internalText;
        }
        self.bbd_internalText = stringToInput;
        [super setText:[self dotPlaceholderForString:self.bbd_internalText]];
    }
    else
    {
        [super setText:stringToInput];
    }
    [self adjustFontAppearence];
}

- (NSString *)text
{
    if (self.bbd_secureTextEntry)
    {
        return self.bbd_internalText;
    }
    else
    {
        return [super text];
    }
}

//this is bullet generator
// /u2022 unicode of 'bullet' character
- (NSString*)dotPlaceholderForString:(NSString *)string
{
    return [@"" stringByPaddingToLength:string.length withString:@"\u2022" startingAtIndex:0];
}

- (void)insertText:(NSString *)text
{
    if (self.bbd_secureTextEntry)
    {
        NSRange selectedRange = [self currentSelectedRange];
        self.bbd_internalText = [self.bbd_internalText stringByReplacingCharactersInRange:selectedRange withString:text];
        [super insertText: [self dotPlaceholderForString:text]];
    }
    else
    {
        [super insertText: text];
    }
    [self adjustFontAppearence];
}

// fix for iOS 10 issue with resignFirstResponder
// systems resets the text in resignFirstResponder using cashed value
// and tries to set black dots instead of the real text
// note: issue doesn't occur text fields created from xib or storyboard
- (BOOL)resignFirstResponder
{
    self.isResignFirstResponderFlow = YES;
    BOOL resign = [super resignFirstResponder];
    self.isResignFirstResponderFlow = NO;
    return resign;
}

- (NSRange)currentSelectedRange
{
    UITextPosition* beginning = self.beginningOfDocument;
    UITextRange* selectedRange = self.selectedTextRange;
    UITextPosition* selectionStart = selectedRange.start;
    UITextPosition* selectionEnd = selectedRange.end;
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

#pragma mark - textContentType blocking

- (void)setTextContentType:(UITextContentType)textContentType
{
    [super setTextContentType:BBDTextContentTypeUnspecified];
}

#pragma mark - autocorrection blocking

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    self.bbd_autocorrectionType = autocorrectionType;
    [self adjustAutocorrectionType];
}

- (UITextAutocorrectionType)autocorrectionType
{
    return self.bbd_autocorrectionType;
}

- (void)adjustAutocorrectionType
{
    if (self.bbd_secureTextEntry)
    {
        [super setAutocorrectionType:UITextAutocorrectionTypeNo];
    }
    else
    {
        [super setAutocorrectionType:self.bbd_autocorrectionType];
    }
}

#pragma mark - copy/paste blocking

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (self.bbd_secureTextEntry)
    {
        return NO;
    }
    return [super canPerformAction:action withSender:sender];
}

@end
