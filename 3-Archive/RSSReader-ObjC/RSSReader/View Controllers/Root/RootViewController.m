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

#import "RootViewController.h"
#import "AddFeedViewController.h"
#import "RSSManager.h"
#import "FeedViewController.h"
#import "RSSReaderGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"
#import <BlackBerryDynamics/GD/GDReachability.h>
#import "Utilities.h"
#import <BlackBerryDynamics/GD/GDiOS.h>


@interface RootViewController() <UITableViewDataSource, UITableViewDelegate>

@property(strong, nonatomic) NSURL* lastURL;

@property(strong, nonatomic) IBOutlet UITableView *rssFeedsTable;

@property (weak, nonatomic) UIAlertController *networkAlert;

@end

@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = RSSFeedListViewID;
    
    self.rssFeedsTable.rowHeight = UITableViewAutomaticDimension;
    self.rssFeedsTable.estimatedRowHeight = 90.f;
    
	//Listen to RSSManager's new feed notification and just refresh the table
    [[NSNotificationCenter defaultCenter] addObserver:self.rssFeedsTable
                                             selector:@selector(reloadData)
                                                 name:kRSSFeedAddedNotification
                                               object:nil];
    //Add edit button to navigation bar
    [self.navigationItem setLeftBarButtonItem:self.editButtonItem];
    
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier = RSSAddFeedBarButtonID;

    if (![[GDReachability sharedInstance] isNetworkAvailable]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:@"Network is NOT Available"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:GDReachabilityChangedNotification
                                               object:[GDiOS sharedInstance]];
}

- (void)viewDidAppear:(BOOL)animated {
    GDAuthDelegateInfo* gdAuthDelegateInfo = [[GDiOS sharedInstance] getAuthDelegate];

    NSLog(@"viewDidAppear: getAuthDelegate Name = %@, address = %@, applicationId = %@, isAuthenticationDelegated = %@",
          gdAuthDelegateInfo.name, gdAuthDelegateInfo.address, gdAuthDelegateInfo.applicationId,
          gdAuthDelegateInfo.isAuthenticationDelegated ? @"YES" : @"NO");
}

- (void)reload{
    [self.rssFeedsTable reloadData];
}

#pragma mark - button actions
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [super setEditing:editing animated:animated];

	[self.rssFeedsTable setEditing:editing animated:animated];
}

-(IBAction)addFeed:(UIBarButtonItem*)sender
{    
	//Launch the add deed view controller
    [self launchAddFeedViewController:nil];
        
    //Stop editing the table
	[self setEditing:NO animated:YES];
}

-(void)launchAddFeedViewController:(RSSFeed *)rssfeed
{
    //Present the add feed view
    AddFeedViewController *addFeedViewController = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"AddFeedViewController"];
    if(rssfeed)
        [addFeedViewController setEditRSSFeed:rssfeed];
    [Utilities showVC:addFeedViewController];
}

#pragma mark - Observer

- (void)reachabilityChanged:(NSNotification *)notification {

    GDReachabilityStatus flags = [GDReachability sharedInstance].status;
    
    NSString *strMsg = [NSString stringWithFormat:@"GDReachabilityNotReachable = %@, GDReachabilityViaWiFi = %@, GDReachabilityViaCellular = %@",
                        flags == GDReachabilityNotReachable ? @"true" : @"false",
                        flags == GDReachabilityViaWiFi ? @"true" : @"false",
                        flags == GDReachabilityViaCellular ? @"true" : @"false"];
    if (self.networkAlert)
    {
        self.networkAlert.message = strMsg;
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network Status"
                                                                       message:strMsg
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * _Nonnull action) {
                                                       self.networkAlert = nil;
                                                   }];
        [alert addAction:ok];
        [self presentViewController:alert
                           animated:YES
                         completion:^{
                             self.networkAlert = alert;
                         }];
    }
}

#pragma mark - tableview methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [RSSManager sharedRSSManager].numberOfFeeds;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellidentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellidentifier];
    // Set the text of the cell to the name of the feed
    // Get the feed and show name
    RSSFeed *feed = [[RSSManager sharedRSSManager] feedAtPos:indexPath.row];
    [cell.textLabel setText:feed.rssName];
    [cell.detailTextLabel setText:feed.rssUrl.absoluteString];
    if (feed.allowsCellularAccess ) {
        cell.textLabel.textColor = [UIColor colorWithRed:67/255.0 green:211/255.0 blue:89/255.0 alpha:1.0];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
    }
    cell.accessibilityIdentifier = feed.rssName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.editingAccessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // Delete the row from the data source
        [tableView beginUpdates];
        
        //Tell the RSS Controller to remove this feed from the secure store
        [[RSSManager sharedRSSManager] removeFeedAtPosition:indexPath.row];
        
        //Remove the cell from the table
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [tableView endUpdates];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //iPhone
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
    {
        [self performSegueWithIdentifier:@"ShowFeed" sender:indexPath];
    }
    else
    {
        RSSFeed* selectedFeed = [[RSSManager sharedRSSManager] feedAtPos:indexPath.row];
        RSSReaderGDiOSDelegate *appDel = [RSSReaderGDiOSDelegate sharedInstance];
        if(!self.lastURL || ![selectedFeed.rssUrl isEqual:self.lastURL] ||  ![[appDel.detailNavigationController visibleViewController] isKindOfClass:[FeedViewController class]])
        {
            //iPad
            FeedViewController *fvc = [[Utilities storyboard] instantiateViewControllerWithIdentifier:@"FeedViewController"];
            
            fvc.feedInfo = selectedFeed;
            [appDel.detailNavigationController setViewControllers:@[fvc] animated:NO];
        }
        
        //Record URL
        self.lastURL = selectedFeed.rssUrl;
    }

    
    //Stop editing
	[self setEditing:NO animated:YES];
    
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //Go to editing screen
    if(tableView.isEditing)
    {
        //Launch the add feed view controller with values from this feed
        RSSFeed *feed = [[RSSManager sharedRSSManager] feedAtPos:indexPath.row];
        [self launchAddFeedViewController:feed];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowFeed"]) {
        FeedViewController *fvc = segue.destinationViewController;
        fvc.feedInfo = [[RSSManager sharedRSSManager] feedAtPos:[(NSIndexPath *)sender row]];
    }
}

@end
