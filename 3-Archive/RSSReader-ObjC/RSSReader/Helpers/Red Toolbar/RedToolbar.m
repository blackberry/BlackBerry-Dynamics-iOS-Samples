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


#import "RedToolbar.h"
#import "SettingsViewController.h"
#import "AboutViewController.h"
#import "RSSReaderGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"
#import "Utilities.h"

@implementation RedToolbar

-(id)initWithCoder:(NSCoder *)aDecoder{
    
	self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        //Adjust the tint
        [self setTintColor:maincolor];
        
        //Add the 'About' and 'Settings' bar button items
        UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [infoButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
              
        UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(showSettings:)];
        settingsButton.accessibilityIdentifier = RSSSettingsBarButtonID;
        
        UIBarButtonItem *autospacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]; 
        
        NSBundle* assetsBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[GDiOS class]] pathForResource:@"BlackBerryDynamicsAssets" ofType:@"bundle"]];
        UIImage *logo = [UIImage imageNamed:@"SECURED_BLACKBERRY_LOGO" inBundle:assetsBundle withConfiguration:nil];
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logo];
        UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoImageView];
        
        NSArray *itemsArray = [NSArray arrayWithObjects:
                               infoBarButtonItem,
                               autospacer,
                               logoItem,
                               autospacer,
                               settingsButton,
                               nil];
        
        [self setItems:itemsArray animated:NO];
    }
    
    return self;
}


//Launch the 'About' View Controller
-(void)showInfo:(id)sender{
    
    //launch info page
    UIStoryboard *uiStoryboard = [Utilities storyboard];
    AboutViewController *aboutViewController = [uiStoryboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [aboutViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [aboutViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [Utilities showVC:aboutViewController];
}


//Launch the 'Settings' View Controller
-(void)showSettings:(id)sender{
    
    //launch info page
    UIStoryboard *uiStoryboard = [Utilities storyboard];
    SettingsViewController *settingsViewController = [uiStoryboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    [settingsViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [settingsViewController setModalPresentationStyle:UIModalPresentationFullScreen];
    [Utilities showVC:settingsViewController];
}

@end
