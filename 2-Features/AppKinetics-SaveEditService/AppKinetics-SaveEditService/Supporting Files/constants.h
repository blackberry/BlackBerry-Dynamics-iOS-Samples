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

#ifndef GD_APPKINETICS_SAVEEDITSERVICE_CONSTANTS_H
#define GD_APPKINETICS_SAVEEDITSERVICE_CONSTANTS_H

/* File Edit-Save Service defines
 *
 * This service is for editing a copy of a file from one application to a second application.
 * The action to be taken by the second application on the file is unspecified. The intended providers of this service would be
 * applications that can take only a single action or that prompt the user what action to take as soon as the request is
 * received.
 *
 * Track this page to be notified of new versions of the service.
 * Service ID: com.good.gdservice.edit-file
 * Latest Version: 1.0.0.0
 *
 */

static NSString* const kSaveEditedFileServiceId = @"com.good.gdservice.save-edited-file"; // service for receiving edited file, based on client app
static NSString* const kEditFileServiceId = @"com.good.gdservice.edit-file"; // service for editing document, based on service app
static NSString* const kEditFileServiceVersion = @"1.0.0.0";
static NSString* const kSaveEditedFileServiceVersion = @"1.0.0.1";
static NSString* const kSaveEditMethod = @"saveEdit"; // method for saving edited file in client app
static NSString* const kEditFileMethod = @"editFile"; // method for editing file in service app

#endif
