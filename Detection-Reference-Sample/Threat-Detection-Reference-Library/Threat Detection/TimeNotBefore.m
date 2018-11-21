/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "TimeNotBefore.h"

@implementation TimeNotBefore

-(void) check: (NSString*) time {
    NSLog(@"Initialize Check Time Not Before");
    NSString *dateStr = time;
    
    // Convert string to date object
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormat dateFromString:dateStr];
    
    NSTimeInterval timeChange = [date timeIntervalSinceNow];
    
    if (timeChange <= 0) {
        Utility *util = [[Utility alloc] init];
        [util postNotificationWithTitle:@"Alert" andMessage:@"Time in the Policy was in the past"];
    } else {
        NSLog(@"Time in the Policy is in the future");
    }
}

@end
