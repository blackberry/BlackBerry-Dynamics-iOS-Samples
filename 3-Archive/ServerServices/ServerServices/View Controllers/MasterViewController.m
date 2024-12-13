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

#import "MasterViewController.h"

#import <BlackBerryDynamics/GD/GDServiceProvider.h>
#import <BlackBerryDynamics/GD/GDAppServer.h>

#import "GDAppDetailCell.h"
#import "ServerServiceGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"

@interface MasterViewController ()

@property (nonatomic, retain) NSMutableArray *arrayGDServiceProvider;
@property (nonatomic, retain) NSMutableArray *arrayGDServiceProvider2;

@property (nonatomic, strong) GDServiceProvider *appServices;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = SRSAppsListViewID;
    
    [ServerServiceGDiOSDelegate sharedInstance].rootViewController = self;
}


-(void)didAuthenticate
{
    if (self.authenticated) {
        [self callGetServiceProvidersForService];
        
        // kServerServiceName details should be in your 1st call.
        NSLog(@"list all apps which  supports service one");
        [self listAppsWhichSupportService:self.arrayGDServiceProvider];
        
        // kServerServiceName2 details should be in your 2nd call.
        NSLog(@"list all apps which  supports service two");
        [self listAppsWhichSupportService:self.arrayGDServiceProvider2];
    }
}

- (void)callGetServiceProvidersForService
{
    GDiOS *sharedInstance = [GDiOS sharedInstance];
    
    self.arrayGDServiceProvider = [[sharedInstance getServiceProvidersFor:kServerServiceName andVersion:kServerServiceVersion andServiceType:GDServiceTypeServer ] mutableCopy];
    
    self.arrayGDServiceProvider2 = [[sharedInstance getServiceProvidersFor:kServerServiceName2 andVersion:kServerServiceVersion andServiceType:GDServiceTypeServer] mutableCopy];
}

- (void)listAppsWhichSupportService:(NSArray *)serviceProvidersArray
{
    for (GDServiceProvider *appService in serviceProvidersArray)
    {
        NSLog(@"name: %@", [appService name]);
        NSLog(@"applicationId: %@", [appService identifier]);
        NSLog(@"version: %@", [appService version]);
        NSLog(@"address: %@", [appService address]);
        
        for (GDAppServer *serverService in appService.serverCluster)
        {
            NSLog(@"name: %@", [serverService server]);
            NSLog(@"port: %@", [serverService port]);
            NSLog(@"priority: %@", [serverService priority]);
        }
    }
}

#pragma mark - Table View delgates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayGDServiceProvider.count + self.arrayGDServiceProvider2.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SC";
    GDAppDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (self.arrayGDServiceProvider.count || self.arrayGDServiceProvider2.count)
    {
        self.appServices = nil;

        // either in first or second array of app details
        if (indexPath.row < self.arrayGDServiceProvider.count) {
            self.appServices = self.arrayGDServiceProvider[indexPath.row];
            cell.nameLabel.text = kServerServiceName;
        }
        else if (indexPath.row - self.arrayGDServiceProvider.count < self.arrayGDServiceProvider2.count) {
            self.appServices = self.arrayGDServiceProvider2[indexPath.row - self.arrayGDServiceProvider.count];
            cell.nameLabel.text = kServerServiceName2;
        }
        
        cell.appIDLabel.text = self.appServices.identifier;
        cell.addressLabel.text = [self.appServices.serverCluster.firstObject server];
        cell.versionLabel.text = self.appServices.version;
        cell.providerTypeLabel.text = ([(GDServiceDetail *)self.appServices.services.firstObject serviceType] == GDServiceTypeApplication) ? @"Application" : @"Server";
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.appServices = nil;
    
    // either in first or second array of app details
    if (indexPath.row < self.arrayGDServiceProvider.count)
    {
        self.appServices = self.arrayGDServiceProvider[indexPath.row];
        [self performSegueWithIdentifier:@"Timezone" sender:self];
    }
    else if (indexPath.row - self.arrayGDServiceProvider.count < self.arrayGDServiceProvider2.count)
    {
        self.appServices = self.arrayGDServiceProvider2[indexPath.row - self.arrayGDServiceProvider.count];
        [self performSegueWithIdentifier:@"Geocode" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Timezone"])
    {
        self.timezoneInputViewController = segue.destinationViewController;
        self.timezoneInputViewController.arrayGDServerDetail = [self.appServices.serverCluster mutableCopy];
    }
    else if ([segue.identifier isEqualToString:@"Geocode"])
    {
        self.reverseGeocodeInputViewController = segue.destinationViewController;
        self.reverseGeocodeInputViewController.arrayGDServerDetail = [self.appServices.serverCluster mutableCopy];
    }
}

@end
