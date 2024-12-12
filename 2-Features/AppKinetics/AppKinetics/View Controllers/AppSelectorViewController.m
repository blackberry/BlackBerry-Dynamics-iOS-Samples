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

#import "AppSelectorViewController.h"
#import <BlackBerryDynamics/GD/GDiOS.h>
#import <BlackBerryDynamics/GD/GDServiceProvider.h>
#import <BlackBerryDynamics/GD/GDServices.h>
#import "UIAccessibilityIdentifiers.h"

@interface AppSelectorViewController ()
{
    IBOutlet    UITableView *_tableView;    
    NSArray                 *_arrayGDServiceProvider;
}

@property (strong, nonatomic) UIDocumentInteractionController* openInVC;

@end


@implementation AppSelectorViewController

#pragma mark - View Management

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize local array with the list of apps conforming to the Transfer-file service

    NSMutableArray *arrayGDServiceProvider = [[[GDiOS sharedInstance] getServiceProvidersFor:kFileTransferServiceName
                                                                                  andVersion:kFileTransferServiceVersion
                                                                              andServiceType:GDServiceTypeApplication] mutableCopy];
    // Remove the app that points to self i.e. this appId
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"SELF.identifier!=%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"GDApplicationID"]];
    _arrayGDServiceProvider = [arrayGDServiceProvider filteredArrayUsingPredicate:predicate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    CGRect      frame;
    frame = self.view.frame;
    frame.size.width = 300;
    frame.size.height = _tableView.rowHeight * ([_arrayGDServiceProvider count] + 1);
    
    if (frame.size.height > 300)
        frame.size.height = 300;
    
    
    CGSize size = CGSizeMake(frame.size.width, frame.size.height); // size of view in popover
    self.preferredContentSize = size;
    
    [super viewWillAppear:animated];
    
}

// Back button action for iPad storyboard in collapsed mode
- (IBAction)barButtonAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Remove Back button if controller is presented as a popover
- (void)prepareForPopoverPresentation:(UIPopoverPresentationController *)popoverPresentationController
{
    self.closeButton.title = nil;
}


#pragma mark - Table Management

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
    return [_arrayGDServiceProvider count] + 1;
}

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kAppSelectControllerCell];
    UIView          *selectedView;
    
    NSUInteger      row = [indexPath row];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: kAppSelectControllerCell];

        selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor whiteColor];
    
        [cell setSelectedBackgroundView: selectedView];
    }
    cell.textLabel.textColor = [UIColor blueColor];
    cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
    cell.textLabel.highlightedTextColor = [UIColor blackColor];
    if (indexPath.row < [_arrayGDServiceProvider count]) {
        // Extract name from the GDServiceProvider container
        GDServiceProvider *serviceProvider = [_arrayGDServiceProvider objectAtIndex: row];
        cell.textLabel.text = [serviceProvider name];
        cell.imageView.image = serviceProvider.icon;
        cell.textLabel.accessibilityIdentifier = AKSAppSelectorCellID;
    } else {
        cell.textLabel.text = @"Apple Open In..";
        cell.imageView.image = [UIImage systemImageNamed:@"square.and.arrow.up"];
    }
    return cell;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    if (indexPath.row <[_arrayGDServiceProvider count]) {
        GDServiceProvider     *serviceProvider = nil;
        serviceProvider = [_arrayGDServiceProvider objectAtIndex: [indexPath row]];
    
        [_delegate appSelected:[serviceProvider address] withVersion:[serviceProvider version] andName:[serviceProvider name]];
    } else {
        
        self.openInVC = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:_filePath]];
        [self.openInVC presentOpenInMenuFromRect:tableView.frame inView:self.view animated:YES];
    }
}


@end
