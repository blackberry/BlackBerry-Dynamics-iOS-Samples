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

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/** Handler for dictation, custom keyboards and emoji blocking events for BBDAutoFillBlockerField.
 *
 * This class subscribes for dictation, emoji and custom keyboard events and is responsible for showing
 * an alert when such events occur.
 *
 */
@interface InputBlockingHandler : NSObject

- (void)startHandling;

@end

NS_ASSUME_NONNULL_END
