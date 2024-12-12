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
#import "RSSFeed.h"

/*
  
 This RSS Manager is a singleton that looks after RSS Settings and
 manages the available feeds list.
 
 It handles the secure store and has two NSNotifications to let
 observers know when a feed is added or the feed mode is changed
 
 */


//An NSNotification that is posted when a new feed is sucessfully added
#define kRSSFeedAddedNotification @"kRSSFeedAddedNotification"

@interface RSSManager : NSObject

@property (nonatomic,weak) UIViewController* alertPresenter;

+(RSSManager*)sharedRSSManager;

//Adds a new feed to the array and returns success / fail boolean
-(BOOL)saveFeed:(RSSFeed*)rssFeed withName:(NSString*)feedName andURLString:(NSString*)urlString andAllowsCellular:(BOOL)allowsCellular;

//Removes a feed from the array (and this controller handles secure storage management)
-(void)removeFeedAtPosition:(NSInteger)pos;

//Accessors to the private array
-(int)numberOfFeeds;
-(RSSFeed*)feedAtPos:(NSInteger)pos;

@end
