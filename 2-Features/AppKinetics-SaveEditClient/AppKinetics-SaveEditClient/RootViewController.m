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

#import <QuartzCore/QuartzCore.h>
#import <BlackBerryDynamics/GD/GDiOS.h>
#import <BlackBerryDynamics/GD/GDServiceProvider.h>
#import <BlackBerryDynamics/GD/GDServices.h>
#import <BlackBerryDynamics/GD/GDFileManager.h>
#import "constants.h"
#import "AppDelegate.h"
#import "ServiceController.h"
#import "RootViewController.h"

#import "SaveEditClientGDiOSDelegate.h"
#import "UIAccessibilityIdentifiers.h"

@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UITextView *readOnlyTextView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)sendClick:(id)sender;
@end
		
@implementation RootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = ASECMainViewID;
    
    // Locate file
    NSBundle *testBundle = [NSBundle mainBundle];
    NSString *filePath = [testBundle pathForResource:@"DataFile" ofType:@"txt"];
    NSLog(@"Path: %@\n", filePath);
    
    // Read file's content
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    NSString *content = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    NSLog(@"Content: \"%@\"\n", content);
    
    // View content
    self.readOnlyTextView.text = content;
    
    // Round Rect Buttons
    CALayer *btnLayer = [self.sendButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    
    [SaveEditClientGDiOSDelegate sharedInstance].rootViewController = self;
    
    self.sendButton.accessibilityIdentifier = ASECSendButtonID;
    // edited file could be received before rootViewController is initialized
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    ServiceController *serviceController = appDelegate.serviceController;
    if (serviceController.lastFileInfo) {
        NSDictionary *fileInfo = serviceController.lastFileInfo;
        if (fileInfo[kServiceErrorKey]) {
            [self showServiceAlertWithInfo:fileInfo];
        }
        else {
            [self updateFileWithInfo:fileInfo];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Setup observers for notification about updated file and errors.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileUpdated:)
                                                 name:kOpenFileForEdit
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showServiceAlert:)
                                                 name:kShowServiceAlert
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Stop listening
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)checkGDServiceProvider:(NSMutableArray *)arrayGDServiceProvider
{
    if (0 == arrayGDServiceProvider.count)
    {
        NSLog(@"Error! Client can't find service application\n");
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Error!"
                                                                    message:@"Client can't find service application"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
        [ac addAction:okAction];
        ac.view.accessibilityIdentifier = ASECServiceUnavailableAlertID;
        
        [self presentViewController:ac
                           animated:YES
                         completion:nil];
        return FALSE;
    }
    return TRUE;
}

- (NSString *)saveTextViewToFile
{
    // We have a content data located in TextView, copy it to the secure file system
    NSData   *fileData            = [self.readOnlyTextView.text dataUsingEncoding:NSUTF8StringEncoding];
    NSArray  *paths               = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask ,YES );
    NSString *documentsDirectory  = [paths objectAtIndex:0];
    NSString *fileName = [[[NSUUID new] UUIDString] stringByAppendingPathExtension:@"txt"];
    NSString *documentPathForFile = [documentsDirectory stringByAppendingPathComponent:fileName];
    [[GDFileManager defaultManager] createFileAtPath:documentPathForFile contents:fileData attributes:nil];
    return documentPathForFile;
}

- (void)sendFileTo:(NSString *)documentPathForFile
                  arrayGDServiceProvider:(NSMutableArray *)arrayGDServiceProvider
                       serviceController:(ServiceController *)serviceController
{
    NSError *error = nil;
    
    // The designated app for sending of this file has been selected. Perform file-transfer service
    NSArray           *attachments       = [NSArray arrayWithObject:documentPathForFile];
    GDServiceProvider *serviceProvider   = [arrayGDServiceProvider objectAtIndex:0];
    
    for (int i = 0; i < arrayGDServiceProvider.count; i++ ) {
        GDServiceProvider *details = [arrayGDServiceProvider objectAtIndex:i];
        if ([details.identifier isEqualToString:@"com.good.gd.example.appkinetics.saveeditservice"]) {
            serviceProvider = details;
            break;
        }
    }
    
    BOOL isRequestAccepted = [serviceController sendSaveEditFileReqeust:&error
                                                                 sendTo:serviceProvider.identifier
                                                             withParams:nil
                                                        withAttachments:attachments
                                                             withMethod:kEditFileMethod];
    
    if (!isRequestAccepted || error)
    {
        UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"Error Sending File" message:[error localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
        
        [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

- (IBAction)sendClick:(id)sender
{
    // Get content
    NSString *readOnlyText = self.readOnlyTextView.text;
    NSLog(@"Content of file to send: \"%@\"\n", readOnlyText);
    
    // Initialize local array with the list of apps conforming to the Transfer-file service
    AppDelegate    *appDelegate      = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    NSMutableArray *arrayGDServiceProvider = [[[GDiOS sharedInstance] getServiceProvidersFor:kEditFileServiceId
                                                                                  andVersion:kFileTransferServiceVersion
                                                                                     andServiceType:GDServiceTypeApplication] mutableCopy];

    
    for (int i = 0; i < arrayGDServiceProvider.count; ++i)
    {
        GDServiceProvider *details = [arrayGDServiceProvider objectAtIndex:i];
        
        if ([details.identifier isEqualToString:[[NSBundle mainBundle] bundleIdentifier]])
        {
            [arrayGDServiceProvider removeObjectAtIndex:i];
            break;
        }
    }
    
    // Check argument
    if (![self checkGDServiceProvider:arrayGDServiceProvider])
    {
        return;
    }
    
    // Save TextView content to file in security storage
    NSString *documentPathForFile = [self saveTextViewToFile];

    // Send file to Server application
    [self sendFileTo:documentPathForFile arrayGDServiceProvider:arrayGDServiceProvider serviceController:appDelegate.serviceController];
    
    NSLog(@"Client sent file to %@\n", [[arrayGDServiceProvider objectAtIndex:0] identifier]);
}

- (void)fileUpdated:(NSNotification *)notification
{
    NSDictionary *userInfo      = [notification userInfo];
    [self updateFileWithInfo:userInfo];
}

- (void)updateFileWithInfo:(NSDictionary *)userInfo
{
    NSString     *consumerAppID = [userInfo objectForKey:kApplicationIDKey];
    NSString     *filePath      = [userInfo objectForKey:kFilePathKey];
    
    NSData   *fileData = [[GDFileManager defaultManager] contentsAtPath:filePath];
    NSString *content  = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
    
    self.readOnlyTextView.text = content;
    
    NSLog(@"Client received updated file = %@ from consumerAppID = %@\n", filePath, consumerAppID);
}

- (void) showServiceAlert:(NSNotification *)notification
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
    
    alertVC.view.accessibilityIdentifier = ASECFailureResponseAlertID;
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    
    if (error.code == GDServicesErrorProcessSuspended)
    {
        __weak typeof(self) weakSelf = self;
        [alertVC addAction:[UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf sendClick:nil];
        }]];
    }
    
    [self presentViewController:alertVC animated:YES completion:nil];
}


@end
