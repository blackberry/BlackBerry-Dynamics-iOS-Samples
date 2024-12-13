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

#import "DetailViewController.h"
#import <BlackBerryDynamics/GD/GDServices.h>
#import <BlackBerryDynamics/GD/GDFileManager.h>
#import "UIAccessibilityIdentifiers.h"
#import "AboutWindow.h"

@interface DetailViewController ()
{
    NSMutableDictionary *_mimeTypes;
}

@property (strong, nonatomic) UIBarButtonItem *filesBarButtonItem;
@property (strong, nonatomic) IBOutlet UIButton *aboutButton;

- (void)configureView;
@end

static NSString *const kfilesButtonTitle = @"Files";

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    _detailItem = newDetailItem;
    
    // Update the view.
    // Note: we update the detailed view even in case of re-setting the same item,
    // in case the content this item points to has since been overwritten.
    [self configureView];
}

// This function should be called to re-render the item's content (if it is currently the item being shown)
- (void) refreshIfDetailItem:(id)item
{
    if ([item isMemberOfClass:[NSURL class]] && ([self.detailItem isEqual:item]))
    {
        [self configureView];        
    }
}

- (void)configureView
{
    
    // We configure WKWebView to display the content of the detailed item.

    if (self.detailItem && [self.detailItem isMemberOfClass:[NSURL class]])
    {
        NSURL *urlToFile = (NSURL*)self.detailItem;
      
        // Present the file inside the webView, resolve mime type of the file, show only supported types
        NSString *filePathString = [urlToFile path];
        NSData *fileData = [[GDFileManager defaultManager] contentsAtPath:filePathString];
        NSString *pathExtension = [[filePathString pathExtension] lowercaseString]; // our extensions are all lower case in plist
        NSString *mimeType = [_mimeTypes objectForKey:pathExtension];
        if (mimeType)
        {
            // load the selected file into the webView
            [self.webView loadData:fileData MIMEType:mimeType characterEncodingName:@"utf-8" baseURL:urlToFile];
        }
        else
        {
            // Show 'file type not supported' message on the webView
            static NSString * const HTMLContent = @"<html>"
            "<head>"
            "<title>   </title>"
            "<style type=\"text/css\">"
            "<!--h1	{text-align:center; font-family:Arial, Helvetica, Sans-Serif;}"
            "p	{text-indent:20px;"
            "}--></style></head><body bgcolor = \"#ffffcc\" text = \"#000000\"><div style=\"margin-top: 40px;\"></div><h1>This file type is not supported!</h1></body></html>";
            [self.webView loadHTMLString:HTMLContent baseURL:nil];

        }
         
    }
    else
    {
        // Clear the web-view content
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"about:blank"]]];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.accessibilityIdentifier = AKSDocumentsListViewID;
    // Here we configure views and buttons on the controller
    self.navigationItem.rightBarButtonItem.accessibilityIdentifier = AKSDocumentShareButtonID;
    self.aboutButton.accessibilityIdentifier = AKSAboutButtonID;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;\
    
    if ([_webView respondsToSelector:@selector(scrollView)])
    {
        [[_webView scrollView] setBounces: NO];
    }
    NSString *mimeTypesFile = [[NSBundle mainBundle] pathForResource:@"SupportedMimeTypes" ofType:@"plist"];
    _mimeTypes= [[NSMutableDictionary alloc] initWithContentsOfFile:mimeTypesFile];
    NSLog(@"mime dictionary: %@", _mimeTypes);
    
    // Setting up splitViewController in case iPad storyboard is used
    if(self.splitViewController != nil)
    {
        self.splitViewController.delegate = self;
        self.filesBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:kfilesButtonTitle style:UIBarButtonItemStylePlain target:self.splitViewController.displayModeButtonItem.target action:self.splitViewController.displayModeButtonItem.action];
        self.filesBarButtonItem.tintColor = maincolor;
        if(self.splitViewController.displayMode != UISplitViewControllerDisplayModeOneBesideSecondary)
        {
            self.navigationItem.leftBarButtonItem = self.filesBarButtonItem;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self configureView];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    const CGPoint curContentOffsetPoint = [[self.webView scrollView] contentOffset];
    const CGFloat curZoomScale          = [[self.webView scrollView] zoomScale];
    
    // default values
    const CGPoint defaultContentOffsetPoint = CGPointMake(0, -64);
    const CGFloat defaultZoomScale          = 1;
    

    // define transition code in a block
    void (^transitionBlock) (CGPoint, CGFloat) = ^(CGPoint curPoint, CGFloat curZoom){
        [UIView animateWithDuration:0.3 animations:^ {
            const CGFloat newZoomScale = [[self.webView scrollView] zoomScale];
            const CGFloat newProperOffsetPoint = newZoomScale * curPoint.y / curZoom;
            
            [[self.webView scrollView] setContentOffset:CGPointMake(0, newProperOffsetPoint) animated:NO];
        }];
    };
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /*
         * In some circumstances, such as rotating immediately after an invocation 
         * via openURL, the current values may not be valid. In this case use default values.
         */
        if(curZoomScale != 0)
        {
            transitionBlock(curContentOffsetPoint, curZoomScale);
        }
        else
        {
            transitionBlock(defaultContentOffsetPoint, defaultZoomScale);
        }

   
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) { }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

// This delegate method is used to add/remove Back button to appSelectorViewController
// and to add/remove Files button in detail controller when displayMode is changed
- (void)splitViewController:(UISplitViewController *)svc willChangeToDisplayMode:(UISplitViewControllerDisplayMode)displayMode
{
    if(displayMode == UISplitViewControllerDisplayModeOneOverSecondary)
    {
        self.appSelectorListViewController.closeButton.title = nil;
        self.navigationItem.leftBarButtonItem = self.filesBarButtonItem;
    }
    else if(displayMode == UISplitViewControllerDisplayModeSecondaryOnly)
    {
        self.navigationItem.leftBarButtonItem = self.filesBarButtonItem;
    }
    else if(displayMode == UISplitViewControllerDisplayModeOneBesideSecondary)
    {
        self.appSelectorListViewController.closeButton.title = @"Back";
        self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
    }
}

// In some cases willChangeToDisplayMode is not called when switching from collapsed
// to expanded state, so here we make sure that Files button was added
- (UISplitViewControllerDisplayMode)targetDisplayModeForActionInSplitViewController:(UISplitViewController *)svc
{
    if(svc.displayMode == UISplitViewControllerDisplayModeSecondaryOnly)
    {
        self.navigationItem.leftBarButtonItem = self.filesBarButtonItem;
    }
    return UISplitViewControllerDisplayModeAutomatic;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kShowAppSelectorScreen])
    {
        AppSelectorViewController *destinationController = [segue destinationViewController];
        destinationController.delegate = self;
        destinationController.filePath = [self.detailItem path];
        self.appSelectorListViewController = destinationController;
        destinationController.popoverPresentationController.delegate = self.appSelectorListViewController;
    }
}

- (IBAction)infoButtonOnTouchUpInside:(id)sender
{
    [AboutWindow show];
}

#pragma mark - AppSelectorDelegate delegates
/*
 * The following delegate calls GDServiceClient directly to perform file-transfer service for brevity and as an illustrative sample. In the production level code though, one might consider creating a secure store manager class or a service class to contain and manage desired functionality.
 */
- (void)appSelected:(NSString *)applicationAddress withVersion:(NSString *)version andName:(NSString *)name
{
    if (self.detailItem==nil)
    {
        [self showAlertWithTitle:@"Note" andMessage:@"Please make sure a file is selected"];
        return;
    }
    
    // The designated app for sending of this file has been selected. Perform file-transfer service
    NSError *error = nil;
    static NSString * const errTitle = @"Error Sending File";
    
    NSString *secureFilePath = [(NSURL*)self.detailItem path];
    
    // Send the file
    if ([secureFilePath length]>0)
    {
        NSArray *attachments = [NSArray arrayWithObject:secureFilePath];
        NSString *requestID = nil;
        BOOL isRequestAccepted = [GDServiceClient sendTo:applicationAddress
                                             withService:kFileTransferServiceName
                                             withVersion:kFileTransferServiceVersion
                                              withMethod:kFileTransferMethod
                                              withParams:nil
                                         withAttachments:attachments
                                     bringServiceToFront:GDEPreferPeerInForeground
                                               requestID:&requestID
                                                   error:&error];
        if (!isRequestAccepted || error)
        {
            [self showAlertWithTitle:errTitle andMessage:[error localizedDescription]];
            return;

        }
    }
    else
    {
        [self showAlertWithTitle:errTitle andMessage:@"Filepath is missing"];
    }

}

- (void)showAlertWithTitle:(NSString *)title andMessage:(NSString *)message
{

    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:@"OK"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action)
                                   {
                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                       
                                   }];
    [alert addAction:cancelAction];
    [_appSelectorListViewController dismissViewControllerAnimated:YES completion:nil];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
