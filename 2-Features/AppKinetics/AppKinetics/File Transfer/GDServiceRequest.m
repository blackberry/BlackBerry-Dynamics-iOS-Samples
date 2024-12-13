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

#import "GDServiceRequest.h"
#import <BlackBerryDynamics/GD/GDServices.h>

@implementation GDServiceRequest

#pragma mark - Lifecycle

- (instancetype)initWithApplication:(NSString *)application
                            service:(NSString *)service
                            version:(NSString *)version
                             method:(NSString *)method
                             params:(id)params
                        attachments:(NSArray<NSString *> *)attachments
                          requestID:(NSString *)requestID
{
    self = [super init];
    if (self)
    {
        self.application = application;
        self.service = service;
        self.version = version;
        self.method = method;
        self.params = params;
        self.attachments = attachments;
        self.requestID = requestID;
    }
    return self;
}

@end

@implementation GDServiceRequest (Validation)

- (BOOL)isServiceValid:(NSError **)error {
    if (![self.service isEqualToString:kFileTransferServiceName])
    {
        if (error)
        {
            NSString *decription = [NSString stringWithFormat:@"Service not found \"%@\"", self.service];
            *error = [NSError errorWithDomain:GDServicesErrorDomain
                                         code:GDServicesErrorServiceNotFound
                                     userInfo:@{NSLocalizedDescriptionKey:decription}];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isMethodValid:(NSError **)error {
    if (![self.method isEqualToString:kFileTransferMethod])
    {
        if (error)
        {
            NSString *decription = [NSString stringWithFormat:@"Method not found \"%@\"",  self.method];
            *error = [NSError errorWithDomain:self.service ? : GDServicesErrorDomain
                                         code:GDServicesErrorMethodNotFound
                                     userInfo:@{NSLocalizedDescriptionKey:decription}];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isParametersValid:(NSError **)error {
    if (self.params)
    {
        if (error)
        {
           NSString *decription = [NSString stringWithFormat:@"Parameters for method \"%@\" should be nil but are \"%@\"", self.method, [self.params description]];
           *error = [NSError errorWithDomain:self.service ? : GDServicesErrorDomain
                                        code:GDServicesErrorInvalidParams
                                    userInfo:@{NSLocalizedDescriptionKey:decription}];
        }
        return NO;
    }
    return YES;
}

- (BOOL)isAttachmentsValid:(NSError **)error {
    if (self.attachments && self.attachments.count != 1)
    {
        if (error)
        {
            NSString *decription = [NSString stringWithFormat:@"Attachments should have one element but has %lu", (unsigned long)self.attachments.count];
            *error = [NSError errorWithDomain:self.service ? : GDServicesErrorDomain
                                         code:GDServicesErrorInvalidParams
                                     userInfo:@{NSLocalizedDescriptionKey:decription}];
        }
        return NO;
    }
    return YES;
}

@end
