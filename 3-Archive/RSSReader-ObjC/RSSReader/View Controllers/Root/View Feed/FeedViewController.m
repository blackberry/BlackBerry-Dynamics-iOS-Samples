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

#import "FeedViewController.h"
#import <BlackBerryDynamics/GD/NSMutableURLRequest+GDNET.h>
#import "UIAccessibilityIdentifiers.h"
#import <BlackBerryDynamics/GD/GDReachability.h>
#import "Utilities.h"
#import "FeedParser.h"
#import "RSSManager.h"
#import "FeedDownloadNSUrlSession.h"


@interface FeedViewController () <FeedParserDelegate, UITableViewDelegate, FeedDownloadDelegate>

@property (strong, nonatomic) IBOutlet UITableView *rssStoriesTable;
@property (strong, nonatomic) NSArray *storyArray; // variables to store xml parsing elements
@property (strong, nonatomic) FeedDownloadBase *feedDownloader;
@property (strong, nonatomic) NSMutableString *currentURL; // http request
@property (nonatomic) BOOL currentAllowCellular;
@property (strong, nonatomic) FeedParser *parser;
@property (strong, nonatomic) UIActivityIndicatorView *spinner;

@end

@implementation FeedViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rssStoriesTable.rowHeight = UITableViewAutomaticDimension;
    self.rssStoriesTable.estimatedRowHeight = 90.f;
    
    [self setTitle:self.feedInfo.rssName];
    
    //Set the url
    self.currentURL = [[NSMutableString alloc] initWithString:[self.feedInfo.rssUrl absoluteString]];
    self.currentAllowCellular = self.feedInfo.allowsCellularAccess;
    
    self.feedDownloader = [[FeedDownloadNSURLSession alloc] initWithAlertPresenter:self.navigationController];
    self.feedDownloader.delegate = self;
        
    self.navigationItem.rightBarButtonItems = [self getRightBarButtonItems];
    [self refresh];
    
    self.view.accessibilityIdentifier = RSSListViewID;
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self cleanup];
}

-(NSArray *)getRightBarButtonItems
{
    // create the array to hold the buttons, which then gets added to the toolbar
    NSMutableArray* buttons = [[NSMutableArray alloc] init];
    
    // create the stop and refresh buttons
    UIBarButtonItem* bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(cancel)];
    [bi setStyle:UIBarButtonItemStylePlain];
    [buttons addObject:bi];
    
    if(![self.navigationItem respondsToSelector:@selector(setRightBarButtonItems:)])
    {
        // create a spacer
        bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        [buttons addObject:bi];
    }
    
    // create a standard "refresh" button
    bi = [[UIBarButtonItem alloc]
          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
    [bi setStyle:UIBarButtonItemStylePlain];
    [buttons addObject:bi];
    
    return [NSArray arrayWithArray:buttons];
}

- (void)setStoryArray:(NSArray *)storyArray
{
    _storyArray = storyArray;
    [self.rssStoriesTable reloadData];
}

-(void)cleanup
{
    [self cancel];
    [self.feedDownloader setDelegate:nil];
}

/*
 * This method reloads the feed file and redisplays the data
 */
- (IBAction)refresh
{
    GDReachabilityStatus flags = [GDReachability sharedInstance].status;
    NSString *strMsg = [NSString stringWithFormat:@"GDReachabilityNotReachable = %@, GDReachabilityViaWiFi = %@, GDReachabilityViaCellular = %@",
                        flags == GDReachabilityNotReachable ? @"true" : @"false",
                        flags == GDReachabilityViaWiFi ? @"true" : @"false",
                        flags == GDReachabilityViaCellular ? @"true" : @"false"];
    NSLog(@"Reachability state: %@", strMsg);
  
    self.storyArray = nil;
    [self parseDataFromSite:self.currentURL allowCellular:self.currentAllowCellular];
}

/*
 * This method cancels the load by calling abort
 */
- (IBAction)cancel
{
    [self.feedDownloader abortRequest];
}

/*
 * This method reloads the feed file and redisplays the data
 */
- (void)loadFeed:(NSString*)url title:(NSString*)title allowCellular:(BOOL)allowCellular
{
    
    // check if we are loading
    if ([self.spinner isAnimating])
    {
        // not loading so update the table
        [self.navigationItem setTitle:title];
        
        if (!self.currentURL)
        {
            self.currentURL = [[NSMutableString alloc] initWithString:url];
        }
        else
        {
            [self.currentURL setString:url];
        }
        self.currentAllowCellular = allowCellular;
        self.storyArray = nil;
        [self parseDataFromSite:url allowCellular:self.currentAllowCellular];
    }
    else
    {
        // pop alert view to say we are loading so please wait
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Load in Progress" message:@"Please Wait" preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self.navigationController presentViewController:alertVC
                                                animated:YES
                                              completion:nil];
    }
}


#pragma mark - Table view data source

/*
 * returns the required number of cells for the table
 */
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storyArray count];
}

/*
 * Called for each cell when the table loads. We use it to load each cell with a story from the array.
 */
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"Cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Set up the cell
    NSInteger index = indexPath.row;
    // check the dictionary containing our parsed elements
    NSString* title = self.storyArray[index][@"title"];
    // trim here as we may have some redundant preceding CR, LF or whitespaces
    NSString* desc = [self.storyArray[index][@"description"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // add the title and description
    cell.textLabel.text = title;
    cell.detailTextLabel.text = desc;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Does nothing in this example when an item is selected.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Parse the feed using the chosen request API to fetch the data

/*
 * This method requests the feed file from the supplied URL
 */
- (void)parseDataFromSite:(NSString*)url allowCellular:(BOOL)allowCellular
{
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    self.spinner.color = [UIColor darkGrayColor];
    self.spinner.center = self.view.center;
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    [self.feedDownloader requestData:url allowCellular:allowCellular];
}

#pragma mark - FeedDownloadDelegate Callback

/*
 * Called when the download has completed and is ready to be parsed.
 */
- (void)downloadDone:(NSData*)data
{
    [self.spinner stopAnimating];
    [self.spinner removeFromSuperview];
    
    if (data && ([data length] > 0))
    {
        FeedParser *parser = [[FeedParser alloc] initWithDelegate:self parsingData:data];
        [parser parse];
        self.parser = parser;
    }
}

- (void)didFinishParsingFeed:(NSArray *)feed
{
    self.storyArray = feed;
}

- (void)didFailWithError:(NSError *)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error Parsing File"
                                                                   message:[error description]
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:nil];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
