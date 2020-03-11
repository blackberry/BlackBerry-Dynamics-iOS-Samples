/* Copyright (c) 2017 - 2020 BlackBerry Limited.
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

#ifndef BBDPublicConstans_h
#define BBDPublicConstans_h

#if __has_extension(attribute_deprecated_with_message)
#   define DEPRECATE_BBDTESTOPTION_BBDTESTOPTIONTOUCHID __attribute__((deprecated("BBDTestOptionTouchID option has been deprecated, use XCUIDevice+BiometricsHelpers instead.")))
#else
#   define DEPRECATE_BBDTESTOPTION_BBDTESTOPTIONTOUCHID __attribute__((deprecated))
#endif

typedef NS_OPTIONS(NSInteger, BBDTestOption){
    BBDTestOptionNone,
    BBDTestOptionDisclaimer,
    BBDTestOptionBiometricsID, // simulator only
    BBDTestOptionTouchID DEPRECATE_BBDTESTOPTION_BBDTESTOPTIONTOUCHID
};

#undef DEPRECATE_BBDTESTOPTION_BBDTESTOPTIONTOUCHID

// Text menu items(Cut, Copy, Select All, Paste)
static NSString* const BBDTextMenuItemCopy = @"Copy";

static NSString* const BBDTextMenuItemPaste = @"Paste";

static NSString* const BBDTextMenuItemSelectAll = @"Select All";

static NSString* const BBDTextMenuItemCut = @"Cut";

// Keyboard buttons identifiers
static NSString* const BBDKeyboardHideButton = @"Hide keyboard";

static NSString* const BBDKeyboardDismissButton = @"Dismiss";

#endif /* BBDPublicConstans_h */
