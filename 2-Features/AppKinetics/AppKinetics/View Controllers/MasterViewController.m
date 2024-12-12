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
#import "DetailViewController.h"
#import "AlertViewWithOKCancelAndInvocation.h"
#import "AppKineticsGDiOSDelegate.h"

#import <BlackBerryDynamics/GD/GDFileManager.h>
#import <BlackBerryDynamics/GD/GDCReadStream.h>
#import "UIAccessibilityIdentifiers.h"


@interface MasterViewController ()
{
    NSMutableArray *fileList;
}
@property (strong, nonatomic) GDService *service;
@property (strong, nonatomic) GDServiceClient *serviceClient;
@property (strong, nonatomic) NSURL *selectedItemURL;

@end

@implementation MasterViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self subscribeToNotifications];
    self.view.accessibilityIdentifier = AKSDocumentsListViewID;
    fileList = [[NSMutableArray alloc] init]; // this will hold file paths (NSURL)
    
    //create edit and reset buttons
    UIBarButtonItem* resetButtonItem =  [[UIBarButtonItem alloc]
                                         initWithTitle:@"Reset"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(resetFileList :)];
    
    resetButtonItem.tintColor = maincolor;
    self.editButtonItem.tintColor = maincolor;
    [self.navigationItem setLeftBarButtonItems:@[self.editButtonItem, resetButtonItem]];
    
    [self documentsDirectoryToLocalList]; // populate local list of files from the Documents dir
    
    NSError *error = nil;
    NSArray *filesArray = [[GDFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsFolderPath] error:&error];
    
    //if there are no files and it's the first start of the application, we'll copy default files
    if ([filesArray count] == 0)
    {
        //retrieving flag applicationWasLoaded indicating whether the application had been loaded before
        NSUserDefaults *savedState = [NSUserDefaults standardUserDefaults];
        Boolean applicationWasLoaded = [savedState boolForKey : @"applicationWasLoaded"];
        if ( NO == applicationWasLoaded )
        {
            // Copy sample pdf docs from the main bundle to the secure file system
            [self resetFileList:self];
            
            //save applicationWasLoaded flag
            [savedState setBool: YES forKey:@"applicationWasLoaded" ];
            [savedState synchronize];
        }
    }
    [AppKineticsGDiOSDelegate sharedInstance].rootViewController = self;
    
    // edited file could be received before rootViewController is initialized
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    FileTransferService *transferService = appDelegate.transferService;
    if (transferService.lastFileInfo) {
        NSDictionary *fileInfo = transferService.lastFileInfo;
        if (fileInfo[kServiceErrorKey]) {
            [self showServiceAlertWithInfo:fileInfo];
        }
        else {
            [self saveFileWithInfo:fileInfo];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Private Methods

- (NSString*)documentsFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

- (NSURL*)urlForPath:(NSString*)path
{
    return [NSURL fileURLWithPath:[path stringByExpandingTildeInPath]];
}

- (void)addToUrlListPath:(NSString*)path
{
    [fileList addObject:[self urlForPath:path]];
    
}

- (void)insertToUrlListPath:(NSString*)path
{
    [fileList insertObject:[self urlForPath:path] atIndex:0];
}

- (void) copyDefaultFiles
{
    NSArray *arrayOfPdfFiles = [[NSBundle mainBundle] pathsForResourcesOfType:@"pdf" inDirectory:nil];
    for (NSString *filePath in arrayOfPdfFiles)
    {
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSString *documentPathForFile = [[self documentsFolderPath] stringByAppendingPathComponent:
                                         [[filePath pathComponents] lastObject]];
        
        BOOL fileCreated = [[GDFileManager defaultManager] createFileAtPath:documentPathForFile contents:fileData attributes:nil];
        
        if (fileCreated)
        {
            [self addToUrlListPath:documentPathForFile];
        }
    }
}

- (void)documentsDirectoryToLocalList
{
    BOOL isDirectory = NO;
    NSError *error = nil;
    
    if (![[GDFileManager defaultManager] fileExistsAtPath:[self documentsFolderPath] isDirectory:&isDirectory])
    {
        [[GDFileManager defaultManager] createDirectoryAtPath:[self documentsFolderPath] withIntermediateDirectories:YES attributes:nil error:&error];
    }
    NSArray *filesArray = [[GDFileManager defaultManager] contentsOfDirectoryAtPath:[self documentsFolderPath] error:&error];
    
    for (NSString *filePath in filesArray)
    {
        [self addToUrlListPath:[[self documentsFolderPath] stringByAppendingPathComponent:filePath]];
    }
}

//reset file list to the initial state: it will contain only the default files
-(IBAction) resetFileList:(id)sender
{
    //delete all the files
    for ( NSURL *urlToFile in fileList )
    {
        NSString *pathToFile = [urlToFile path];
        
        if ([self.detailViewController.detailItem isEqual:urlToFile])
        {
            self.detailViewController.detailItem = nil;
        }
        
        NSError *error = nil;
        [[GDFileManager defaultManager] removeItemAtPath:pathToFile error:&error];
    }
    [fileList removeAllObjects];
    
    [self copyDefaultFiles]; //copy all the default files
    [[self tableView] reloadData]; //refresh tableView
}

- (void)saveReceivedFile:(NSString *)localFilePathToSave filePath:(NSString *)filePath
{
    NSError *error = nil;
    
    if ([[GDFileManager defaultManager] fileExistsAtPath:localFilePathToSave])
    {
        NSError *errorDeletingFile = nil;
        [[GDFileManager defaultManager] removeItemAtPath:localFilePathToSave error:&errorDeletingFile];
        if (errorDeletingFile)
        {
            NSLog(@"Error deleting file:%@", [errorDeletingFile debugDescription]);
        }
    };
    
    [[GDFileManager defaultManager] moveItemAtPath:filePath toPath:localFilePathToSave error:&error];
    
    if (error)
    {
        NSDictionary *fileAttributes = [[GDFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
        
        if(fileAttributes)
        {
            NSLog(@"error message:%@",[[error localizedDescription]  stringByAppendingFormat:@"\nFile Attributes:\n %@", fileAttributes]);
        }
        
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error Sending File" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertVC animated:YES completion:nil];
        return;
    }
    else
    {
        // Upon the received file being successfully saved, inform the detailed controller to re-render its view, if this item's content is currently displayed (since the item's content has changed)
        [_detailViewController refreshIfDetailItem:[self urlForPath:localFilePathToSave]];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return fileList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMasterControllerCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMasterControllerCell];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    cell.textLabel.accessibilityIdentifier = AKSDocumentDetailCellID;
    NSURL *urlToFile = fileList[indexPath.row];
    cell.textLabel.text = [[urlToFile path] lastPathComponent];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSURL *urlElement = fileList[indexPath.row];
        NSString *pathToFile = [urlElement path];
        
        if([self.detailViewController.detailItem isEqual:urlElement])
            self.detailViewController.detailItem = nil;
        
        NSError *error = nil;
        [[GDFileManager defaultManager] removeItemAtPath:pathToFile error:&error];
        
        // Here we should check for error and handle it appropriately
        
        [fileList removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItemURL = fileList[indexPath.row];
    
    [self performSegueWithIdentifier:kShowDetailScreen sender:self];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModeSecondaryOnly;
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowDetailScreen])
    {
        // In iPhone storyboard the segue points to DetailViewController,
        // while in iPad storyboard it is embeded in NavigationController
        // for a proper transition between collapsed and expanded states.
        DetailViewController *detail;
        if([segue.destinationViewController isMemberOfClass:[DetailViewController class]]) {
            detail = [segue destinationViewController];
        } else if([segue.destinationViewController isMemberOfClass:[UINavigationController class]]) {
            UINavigationController *navigationController = [segue destinationViewController];
            detail = [[navigationController viewControllers] firstObject];
        }
        detail.detailItem = self.selectedItemURL;
    }
}

#pragma mark - Notifications

- (void)subscribeToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showServiceAlert:)
                                                 name:kShowServiceAlert
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveFile:)
                                                 name:kSaveFileMethodKey
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showAlertForCollisionNotification:)
                                                 name:kFileCollisionKey
                                               object:nil];
}

- (void)showServiceAlert:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self showServiceAlertWithInfo:userInfo];
}

- (void)showServiceAlertWithInfo:(NSDictionary *)userInfo
{
    NSError *error = [userInfo objectForKey:kServiceErrorKey];
    // The  Service returned a defined error response...
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:[error domain]
                                                                     message:[error localizedDescription]
                                                              preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertVC addAction:okAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)saveFile:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self saveFileWithInfo:userInfo];
}

- (void)saveFileWithInfo:(NSDictionary *)info
{
    NSString *filePath = [info objectForKey:kFilePathKey];
    NSString *pathToSave = [info objectForKey:kNewFilePathKey];
    
    [self saveReceivedFile:pathToSave filePath:filePath];
    if (!fileList)
    {
        fileList = [[NSMutableArray alloc] init];
    }
    // Update our local list with the newly received file
    [self insertToUrlListPath:pathToSave];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

#pragma mark - Alerts

- (void)showAlertForCollisionNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    [self showAlertForCollisionWithInfo:userInfo];
}

- (void)showAlertForCollisionWithInfo:(NSDictionary *)info
{
    NSString *filename = [[info objectForKey:kFilePathKey] lastPathComponent];
    NSString *filePath = [info objectForKey:kFilePathKey];
    NSString *pathToSave = [info objectForKey:kNewFilePathKey];
    
    // Notify that file will be clobbered if saved as it exists
    AlertViewWithOKCancelAndInvocation *alert = [AlertViewWithOKCancelAndInvocation initWithTitle:@"File exists!"
                                                                                          message:[NSString stringWithFormat:@"File %@ already exist, select Cancel or Overwrite!", filename]
                                                                                cancelButtonTitle:@"Cancel"
                                                                                    okButtonTitle:@"Overwrite"];
    alert.view.accessibilityIdentifier = AKSFileNotExistAlertID;
    // We're only interested in OK action i.e. Overwrite, for Cancel we don't do anything.
    [alert prepareInvocationForOKButtonWithSelector:@selector(saveReceivedFile:filePath:)
                                         withObject:self andArguments:pathToSave, filePath, nil];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *presenter = appDelegate.window.rootViewController;
    [presenter presentViewController:alert animated:YES completion:nil];
}

@end
