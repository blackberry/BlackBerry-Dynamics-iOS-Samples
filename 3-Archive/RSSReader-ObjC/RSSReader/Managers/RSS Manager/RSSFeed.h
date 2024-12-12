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

/*
 	An RSS Feed object is an alternative to using an array or dictionary to hold the details of an RSS Feed
 	This object is exposed to relavent code through the RSSManager
 */



#import <Foundation/Foundation.h>

@interface RSSFeed : NSObject <NSSecureCoding>

@property(strong, nonatomic) NSString *rssName;
@property(strong, nonatomic) NSURL *rssUrl;
@property(nonatomic) BOOL allowsCellularAccess;


-(id)initWithName:(NSString*)_rssName andURL:(NSURL*)_rssUrl andAllowCellularAccess:(BOOL)allowCellular;

-(NSString*)rssName;
-(NSURL*)rssUrl;

@end
