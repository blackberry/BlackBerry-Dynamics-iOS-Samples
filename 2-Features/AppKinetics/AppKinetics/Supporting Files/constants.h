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

// This constants file is included in the pch file for common lightweight functions throughout the app


// Color related macros
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

// Define Good color
#define maincolor RGB(77,91,103)

/* File Transfer Service defines
 *
 * This service is for transferring a copy of a file from one application to a second application. 
 * The action to be taken by the second application on the file is unspecified. The intended providers of this service would be
 * applications that can take only a single action or that prompt the user what action to take as soon as the request is
 * received.
 *
 * Track this page to be notified of new versions of the service.
 * Service ID: com.good.gdservice.transfer-file
 * Latest Version: 1.0.0.0
 *
 */
#define kFileTransferServiceName    @"com.good.gdservice.transfer-file"
#define kFileTransferServiceVersion @"1.0.0.0"
#define kFileTransferMethod         @"transferFile"

//Cell identifiers
static NSString* const kAppSelectControllerCell = @"Cell";
static NSString* const kMasterControllerCell = @"masterCell";

//Notifications identifiers
static NSString* const kPassedAutorizationNotification = @"UpdateMasterVC";

//Segue identifiers
static NSString* const kShowDetailScreen = @"showDetailController";
static NSString* const kShowAppSelectorScreen = @"showAppSelectorController";

//Errors and Methods
static NSString* const kServiceErrorKey = @"kServiceErrorKey";
static NSString* const kFileCollisionKey = @"kFileCollisionKey";
static NSString* const kSaveFileMethodKey = @"kSaveFileMethod";
static NSString* const kShowServiceAlert = @"kShowServiceAlert";

static NSString* const kFilePathKey = @"kFilePathKey";
static NSString* const kNewFilePathKey = @"kNewFilePathKey";
