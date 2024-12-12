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

#import "Utilities.h"
#import "RSSReaderGDiOSDelegate.h"

static NSString * const IPAD_STORYBOARD = @"Main_iPad";
static NSString * const IPHONE_STORYBOARD = @"Main_iPhone";

@implementation Utilities

+ (UIStoryboard *)storyboard {
    UIUserInterfaceIdiom type = [[UIDevice currentDevice] userInterfaceIdiom];
    NSString *name = type == UIUserInterfaceIdiomPhone ? IPHONE_STORYBOARD : IPAD_STORYBOARD;
    return [UIStoryboard storyboardWithName:name bundle:nil];
}

+ (void)showVC:(UIViewController *)vc
{
    RSSReaderGDiOSDelegate *appDel = [RSSReaderGDiOSDelegate sharedInstance];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:vc];
        [appDel.navController presentViewController:navigation animated:YES completion:NULL];
    }
    else
    {
        //iPad
        
        //Check this is not already the 'About' view controller
        UINavigationController *nc = appDel.detailNavigationController;
        if (![[nc.viewControllers lastObject] isKindOfClass:[vc class]])
            [nc setViewControllers:@[vc] animated:NO];
    }
}

@end
