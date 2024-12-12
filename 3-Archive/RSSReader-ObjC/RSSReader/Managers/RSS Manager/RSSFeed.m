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

#import "RSSFeed.h"

@implementation RSSFeed

@synthesize rssName, rssUrl, allowsCellularAccess;

-(id)initWithName:(NSString*)_rssName andURL:(NSURL*)_rssUrl andAllowCellularAccess:(BOOL)_allowCellular{
    
    self = [super init];
    
    if(self)
    {
    	rssName = _rssName;
    	rssUrl = _rssUrl;
        allowsCellularAccess = _allowCellular;
    }
    
    return self;
    
}

-(NSString*)rssName{
    return rssName;
}

-(NSURL*)rssUrl{
    return rssUrl;
}

-(BOOL)allowsCellular{
    return allowsCellularAccess;
}

- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeObject:rssName forKey:@"rssName"];
    [coder encodeObject:rssUrl.absoluteString forKey:@"rssUrl"];
    [coder encodeBool:allowsCellularAccess forKey:@"allowsCellular"];
}

- (id)initWithCoder:(NSCoder *)coder {
     
    if (self=[super init]) {
        rssName = [coder decodeObjectForKey:@"rssName"];
        rssUrl = [NSURL URLWithString:[coder decodeObjectForKey:@"rssUrl"]];
        allowsCellularAccess = [coder decodeBoolForKey:@"allowsCellular"];
     }
    
    return self;
}

#pragma mark Secure Coding

+ (BOOL)supportsSecureCoding {
    return YES;
}

@end
