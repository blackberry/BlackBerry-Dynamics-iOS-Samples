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

@class ViewController;
@class RootViewController;

typedef enum
{
    GreetMe,
    GreetMePeerInFG,
    GreetMeWithNoFGPref,
    BringServiceAppToFront,
    SendFiles,
    GetDateAndTime,
}
ClientRequestType;

@protocol ServiceControllerDelegate <NSObject>

- (void)showAlert:(id)serviceReply;

@end

@interface ServiceController : NSObject <GDServiceClientDelegate, GDServiceDelegate>

@property(nonatomic) id <ServiceControllerDelegate> delegate;
@property(strong, nonatomic) GDServiceClient *goodServiceClient;
@property(strong, nonatomic) GDService *goodServiceServer;
@property (assign, nonatomic) ClientRequestType lastRequest;

- (BOOL)sendRequest:(NSError**)error requestType:(ClientRequestType)type sendTo:(NSString*)appId;

@end
