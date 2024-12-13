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
#import <BlackBerryDynamics/GD/GDPortability.h>

@interface GDServiceRequest : NSObject

@property (copy, nonatomic) NSString *application;
@property (copy, nonatomic) NSString *service;
@property (copy, nonatomic) NSString *version;
@property (copy, nonatomic) NSString *method;
@property (copy, nonatomic) id params;
@property (copy, nonatomic) NSArray<NSString *> *attachments;
@property (copy, nonatomic) NSString *requestID;

- (instancetype)initWithApplication:(NSString *)application
                            service:(NSString *)service
                            version:(NSString *)version
                             method:(NSString *)method
                             params:(id)params
                        attachments:(NSArray<NSString *> *)attachments
                          requestID:(NSString *)requestID;

@end

@interface GDServiceRequest (Validation)

- (BOOL)isServiceValid:(NSError **)error;
- (BOOL)isMethodValid:(NSError **)error;
- (BOOL)isParametersValid:(NSError **)error;
- (BOOL)isAttachmentsValid:(NSError **)error;

@end
