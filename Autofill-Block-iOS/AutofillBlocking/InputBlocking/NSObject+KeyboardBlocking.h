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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** NSObject extension used to override aplication:shouldAllowExtensionPointIdentifier: method
 * of UIApplicationDelegate.
 *
 * In the case if an application has its own implementation of
 * this method in UIApplicationDelegate, then this category needs to be reworked.
 * Use shouldBlockExtensionKeyboard method of BBDInputBlocker inside overriden
 * aplication:shouldAllowExtensionPointIdentifier: to enable keyboard extensions blocking
 * for BBDAutoFillBlockerField.
 *
 */
@interface NSObject (KeyboardBlocking)

@end

NS_ASSUME_NONNULL_END
