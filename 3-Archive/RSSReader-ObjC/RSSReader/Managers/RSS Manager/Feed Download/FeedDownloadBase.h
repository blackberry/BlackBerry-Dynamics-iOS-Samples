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
#import "FeedDownloadProtocol.h"

/* A delegate to allow the downloader to notify it's user that it has finished.
 */
@protocol FeedDownloadDelegate <NSObject>
@required
/* The download is finished, if it failed then 'data' will be nil */
- (void) downloadDone:(NSData*) data;
@end


@interface FeedDownloadBase : NSObject<FeedDownloadProtocol> {
    
    id <FeedDownloadDelegate> __weak  delegate;
    
    NSString* currentURL;
    UITextField* userNameField;
    UITextField* passwordField;
    BOOL relaxCurrentSSL;

    NSMutableData* dataBuffer;
    NSURLAuthenticationChallenge* authChallenge;
}

#if !(__has_feature(objc_arc))
@property (nonatomic, assign) id<FeedDownloadDelegate> delegate;
#else  
@property (weak) id<FeedDownloadDelegate> delegate;
#endif

/* Designated init method (AlertViewController needs an object which can present it
 */
- (instancetype)initWithAlertPresenter:(UIViewController*) parentViewControler;

/* Requests the data from a specific URL. This can trigger SSL relaxation or authentication dialogs
 */
- (void)requestData:(NSString*) url allowCellular:(BOOL)allowCellular;

/* Aborts the current request at the HTTP level.
 */
- (void)abortRequest;

@end
