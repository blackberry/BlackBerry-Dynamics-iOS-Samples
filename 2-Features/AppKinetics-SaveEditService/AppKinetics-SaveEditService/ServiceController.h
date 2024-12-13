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

#import <Foundation/Foundation.h>

#import <BlackBerryDynamics/GD/GDServices.h>

static NSInteger const kServiceErrorClientsNotConnected = 1;
static NSString * _Nonnull const kServiceErrorDomain = @"kServiceErrorDomain";

@interface ServiceController : NSObject <GDServiceDelegate>

@property (strong, nonatomic, nullable, readonly) NSString *gdApplication;
@property (strong, nonatomic, nullable, readonly) NSString *lastReceivedText;
@property (strong, nonatomic, nullable, readonly) NSString *gdRequestID;
@property (nonatomic, copy, nullable) void (^receiveTextCompletion)(NSString * _Nonnull text);

- (BOOL)sendRequest:(NSError * _Nullable * _Nullable)error newText:(NSString * _Nonnull)text sendTo:(NSString * _Nonnull)appId;

@end


