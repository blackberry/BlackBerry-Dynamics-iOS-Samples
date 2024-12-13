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

//This constants file is included in the pch file for common lightweight functions throughout the app

// colours
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f]
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

#define maincolor RGB(77,91,103)

// service ids
extern NSString* const kDateAndTimeServiceId;
extern NSString* const kGreetingsServiceId;

// greetings server app id
#define kGreetingsServerAppId @"com.good.gd.example.services.greetings.server"

// notifications
#define kServiceConfigDidChangeNotification @"kServiceConfigDidChangeNotification"
