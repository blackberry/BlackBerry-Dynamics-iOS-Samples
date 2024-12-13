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

@protocol FeedParserDelegate <NSObject>

- (void)didFinishParsingFeed:(NSArray *)feed;
- (void)didFailWithError:(NSError *)error;

@end

@interface FeedParser : NSObject <NSXMLParserDelegate>

@property (nonatomic, weak) id<FeedParserDelegate> delegate;

- (instancetype)initWithDelegate:(id<FeedParserDelegate>)delegate parsingData:(NSData *)data;

- (void)parse;

@end
