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

#import "AddFeedViewController.h"
#import "UIAccessibilityIdentifiers.h"
#import "RSSManager.h"

@interface AddFeedViewController () <UITextFieldDelegate>

@property(strong, nonatomic) IBOutlet UITextField *feedNameTextField;
@property(strong, nonatomic) IBOutlet UITextField *feedURLTextField;
@property(strong, nonatomic) IBOutlet UIButton *addFeedButton;
@property(strong, nonatomic) IBOutlet UISwitch *allowCellularSwitch;

@end

@implementation AddFeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // UI Testing initialization
    self.view.accessibilityIdentifier = RSSAddFeedViewID;
    self.feedNameTextField.accessibilityIdentifier = RSSFeedNameFieldID;
    self.feedURLTextField.accessibilityIdentifier = RSSFeedURLFieldID;
    self.addFeedButton.accessibilityIdentifier = RSSAddFeedButtonID;
    
    // setting dismissing bar button item for iPhone
    if (self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                               target:self
                                                                                               action:@selector(closeView)];
    }
    
    //Update fields
    [self updateAccordingEditingState];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.feedNameTextField becomeFirstResponder];
}

- (IBAction)tapOnView:(UITapGestureRecognizer *)sender
{
    [self.view endEditing:YES];
}

- (void)updateAccordingEditingState
{
    if(self.editRSSFeed)
    {
        //Title for iPad
        [self setTitle:@"Edit RSS Feed"];
        [self.addFeedButton setTitle:@"Update Feed"
                            forState:UIControlStateNormal];
        [self.feedURLTextField setText:self.editRSSFeed.rssUrl.absoluteString];
        [self.feedNameTextField setText:self.editRSSFeed.rssName];
        [self.allowCellularSwitch setOn:self.editRSSFeed.allowsCellularAccess];
    } else {
        [self setTitle:@"Add RSS Feed"];
        [self.addFeedButton setTitle:@"Add Feed"
                            forState:UIControlStateNormal];
        [self.feedURLTextField setText:@""];
        [self.feedNameTextField setText:@""];
    }
}

#pragma mark - actions
//For iPhone buttons
-(void)closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)addFeed:(id)sender
{
    
    //Ask the RSSController to add the feed to secure storage
    if([[RSSManager sharedRSSManager] saveFeed:self.editRSSFeed withName:self.feedNameTextField.text andURLString:self.feedURLTextField.text andAllowsCellular:self.allowCellularSwitch.on])
    {
    	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
        	//Success - just dismiss this view
        	[self closeView];
        } else {
            //Clear the fields
            self.editRSSFeed = nil;
            [self updateAccordingEditingState];
            [self.feedNameTextField resignFirstResponder];
            [self.feedURLTextField resignFirstResponder];
        }
    } else {
    	//There was a problem adding the feed
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Feed Insert Error" message:@"There was a problem with the new feed details\nPlease check that you have entered a name for the feed and a valid URL" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


#pragma mark - text field delegate

//This allows the user to tab through to the Next UITextField
-(BOOL)textFieldShouldReturn:(UITextField*)textField;
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so add feed
        [self addFeed:nil];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

@end
