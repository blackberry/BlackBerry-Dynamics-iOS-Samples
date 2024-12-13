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

#import "RSSManager.h"
#import <BlackBerryDynamics/GD/GDFileManager.h>

@interface RSSManager(private)

- (void)initaliseFeedsArray;
- (void)saveFeeds;

@end

static RSSManager *sharedRSSManager = nil;

@implementation RSSManager

//Private
#define kFeedSaveFile @"feedSaveFile.dat"
NSMutableArray *rssFeeds;

#pragma mark - singleton method
+(RSSManager*)sharedRSSManager
{
    @synchronized(self)
    {
        if(sharedRSSManager == nil)
        {
            sharedRSSManager = [[super allocWithZone:NULL] init];
        }
    }
    return sharedRSSManager;
}


-(id)init{
    
    self = [super init];
    
    if(self)
    {
        //Load the feeds to the local array
        [self initaliseFeedsArray];
        
    }
    
    return self;
}

#pragma mark - secure store and feed list

/*
 * Loads the feed table from secure storage
 */
- (void)initaliseFeedsArray
{
    NSData *dataPtr = [[GDFileManager defaultManager] contentsAtPath:[self fullPathOfFileWithName:kFeedSaveFile]];
    
    if ([dataPtr length] > 0)
    {
        NSError *error = nil;
        NSSet *allowedClasses = [NSSet setWithObjects:[NSArray class], [RSSFeed class], [NSString class], nil];
        rssFeeds = (NSMutableArray*)[NSKeyedUnarchiver unarchivedObjectOfClasses:allowedClasses
                                                                        fromData:dataPtr
                                                                           error:&error];
        if (error)
        {
            NSLog(@"Could not unarchive feeds: %@", error);
        }
    }
    else
    {
        rssFeeds = [[NSMutableArray alloc] init];
        
        //Add Good Technology Feed as an example
        RSSFeed *goodFeed = [[RSSFeed alloc] initWithName:kRSSTitle andURL:kRSSUrl andAllowCellularAccess:YES];
        [rssFeeds addObject:goodFeed];
    }
}

/*
 * Validates the RSS for name and URL and then saves locally and to secure storage
 */

-(BOOL)saveFeed:(RSSFeed*)rssFeed withName:(NSString*)feedName andURLString:(NSString*)urlString andAllowsCellular:(BOOL)allowsCellular
{
    
    if(urlString.length > 0 && feedName.length > 0)
    {
        NSMutableString* urlStringAltered = [NSMutableString stringWithString:urlString];
        
        //Check for protocol
        if([urlStringAltered rangeOfString:@"://"].location == NSNotFound)
        {
            [urlStringAltered insertString:@"http://" atIndex:0];
        }
        
        //Test URL is valid
        NSURL *rssURL = [NSURL URLWithString:[NSString stringWithString:urlStringAltered]];
        
        if(rssURL)
        {
            if(rssFeed)
            {
                //update existing
                [rssFeed setRssName:feedName];
                [rssFeed setRssUrl:rssURL];
                [rssFeed setAllowsCellularAccess:allowsCellular];
            }
            else
            {
                //Add the feed to the url
                RSSFeed *rssFeed = [[RSSFeed alloc] initWithName:feedName andURL:rssURL andAllowCellularAccess:allowsCellular];
                [rssFeeds addObject:rssFeed];
            }
            
            //Save to secure storage
            [self saveFeeds];
            
            //Tell listeners there's been a successful addition
            [[NSNotificationCenter defaultCenter] postNotificationName:kRSSFeedAddedNotification object:nil];
        }
        else
        {
            return NO;
        }
        
        //inform direct caller that the feed was added successfully
        return YES;
    }
    
    return NO;
}


/*
 * Removes a feed from the local array and saves the changes to secure storage
 */
-(void)removeFeedAtPosition:(NSInteger)pos{
    
    if(rssFeeds.count > pos)
    {
        //Remove from local array
        [rssFeeds removeObjectAtIndex:pos];
        
        //Update secure storage
        [self saveFeeds];
    }
    
}


/*
 * Saves the feed table to secure storage
 */
-(void)saveFeeds
{
    //Convert RSSFeeds dictionaries
    
    NSError *error = nil;
    NSData *encodedData = [NSKeyedArchiver archivedDataWithRootObject:rssFeeds
                                                requiringSecureCoding:YES
                                                                error:&error];
    
    if (encodedData && !error) {
        if(![[GDFileManager defaultManager] createFileAtPath:[self fullPathOfFileWithName:kFeedSaveFile]
                                                contents:encodedData
                                              attributes:nil])
        {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Error Saving Feeds"
                                                                             message:@"\n"
                                                                      preferredStyle:UIAlertControllerStyleAlert];
            
            [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              }]];
            
            [self.alertPresenter presentViewController:alertVC
                                              animated:YES
                                            completion:nil];
        }
    } else {
        NSLog(@"Could not encode feeds %@", error);
    }
}

#pragma mark - helpers
//Helpers - the array is private so only this controller can directly manipulate it
-(int)numberOfFeeds{
    return (int)rssFeeds.count;
}

-(RSSFeed*)feedAtPos:(NSInteger)pos{
    return (RSSFeed*)[rssFeeds objectAtIndex:pos];
}

-(NSString*)fullPathOfFileWithName:(NSString*)fileName {
    
    NSArray* libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* libPath = [libPaths objectAtIndex:0];
    NSString* applicationDirectory = [libPath stringByDeletingLastPathComponent];
    return [[applicationDirectory stringByAppendingString:@"/"] stringByAppendingString:fileName];
}

@end
