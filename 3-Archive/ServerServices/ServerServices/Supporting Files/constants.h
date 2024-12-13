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

/* usage of Google timezone service
 *
 * Google timezone service is publically available service
 * URL: https://maps.googleapis.com/maps/api/timezone/json?location=37,122&timestamp=85187&language=en&sensor=true
 * we are talking Latitude and Longitude from user, to get the result back from googleapis.
 * GD Service ID: com.blackberry.example.gdservice.time-zone
 * Latest Version: 1.0.0.0
 *
 */
#define kServerServiceName    @"com.blackberry.example.gdservice.time-zone"
#define kServerServiceVersion @"1.0.0.0"

#define kServerServiceName2    @"com.blackberry.example.gdservice.reverse-geocoding"
