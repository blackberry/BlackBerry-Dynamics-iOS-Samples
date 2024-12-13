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

#ifndef __CONSTANT_H__
#define __CONSTANT_H__

static NSString* const kSaveEditedFileServiceId = @"com.good.gdservice.save-edited-file"; // service for receiving edited file, based on client app
static NSString* const kEditFileServiceId = @"com.good.gdservice.edit-file"; // service for editing file, based on service app
static NSString* const kFileTransferServiceVersion = @"1.0.0.0";
static NSString* const kSaveEditMethod = @"saveEdit"; // method for saving edited file in client app
static NSString* const kEditFileMethod = @"editFile"; // method for editing file in service app
static NSString* const kServiceErrorKey = @"kServiceErrorKey";
static NSString* const kShowServiceAlert = @"kShowServiceAlert";
static NSString* const kApplicationIDKey = @"kApplicationIDKey";
static NSString* const kFilePathKey = @"kFilePathKey";
static NSString* const kRequestParamsKey = @"kRequestParamsKey";
static NSString* const kOpenFileForEdit = @"kOpenFileForEdit";

#endif /*__CONSTANT_H__*/
