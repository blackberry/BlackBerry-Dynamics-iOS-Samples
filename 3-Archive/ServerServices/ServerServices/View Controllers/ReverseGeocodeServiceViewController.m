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

#import "ReverseGeocodeServiceViewController.h"

#import <BlackBerryDynamics/GD/GDAppServer.h>
#import <CoreLocation/CoreLocation.h>

@interface ReverseGeocodeServiceViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;

@property (weak, nonatomic) IBOutlet UITextView *serverResponseTextView;

@property (weak, nonatomic) IBOutlet UILabel *addressWillBeHereLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *serverResponseLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraintServerResponseTextView;

@property (weak, nonatomic) IBOutlet UIButton *getReverseGeocodeButton;

@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL shouldNotUseCoreLocationUpdates;
@property (strong, nonatomic) NSDictionary *jsonDictionary;

@property (assign, nonatomic) BOOL isEnhanced;

@end

@implementation ReverseGeocodeServiceViewController

+ (CGFloat)visibleViewSize
{
    return 440;
}

+ (CGFloat)heightConstraintForPhone
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]){
        if ([UIScreen mainScreen].scale > 2.1)
            return 500;  // Nativescale is always 3 for iPhone 6 Plus, even when running in scaled mode
    }
    
    if ([UIScreen mainScreen].bounds.size.height > 640) {
        return 400;
    }
    else
        return 300;
}

+ (CGFloat)heightConstraintForPad
{
    return 500;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    self.addressLabel.hidden = YES;
    self.addressWillBeHereLabel.hidden = YES;
    self.addressWillBeHereLabel.text = @"";
    self.serverResponseLabel.hidden = YES;
    self.serverResponseTextView.hidden = YES;
    [self setHeightConstraintForPortraitMode];
    
    self.longitude.delegate = self;
    self.latitude.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.serverResponseTextView.hidden)
    {
        if ([ReverseGeocodeServiceViewController visibleViewSize] > self.scrollView.contentSize.height)
        {
            CGSize sizeThatShouldFitTheContent = [self.serverResponseTextView sizeThatFits:self.serverResponseTextView.contentSize];
            self.heightConstraintServerResponseTextView.constant = sizeThatShouldFitTheContent.height;
            self.serverResponseTextView.contentSize = sizeThatShouldFitTheContent;
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, sizeThatShouldFitTheContent.height + self.serverResponseTextView.frame.origin.y);
            self.isEnhanced = YES;
            self.serverResponseTextView.scrollEnabled = NO;
        }
    }
    self.spinner.center = self.view.center;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        NSArray *windowScenes = [[UIApplication sharedApplication].connectedScenes allObjects];
        UIWindowScene *scene = [windowScenes firstObject];
        NSArray *groupOfWindows = scene.windows;
        UIWindow *theWindow = groupOfWindows.firstObject;
        if (theWindow) {
            UIInterfaceOrientation fromInterfaceOrientation = theWindow.windowScene.interfaceOrientation;
            if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation))
            {
                self.isEnhanced = NO;
            }
            
            if (!self.isEnhanced)
            {
                self.serverResponseTextView.scrollEnabled = YES;
                [self setHeightConstraintForPortraitMode];
            }
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)setHeightConstraintForPortraitMode
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.heightConstraintServerResponseTextView.constant = [ReverseGeocodeServiceViewController heightConstraintForPhone];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        self.heightConstraintServerResponseTextView.constant = [ReverseGeocodeServiceViewController heightConstraintForPad];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.shouldNotUseCoreLocationUpdates = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // use corelocation unless user types in a location
    if (!self.shouldNotUseCoreLocationUpdates)
    {
        float latitude = self.locationManager.location.coordinate.latitude;
        float longitude = self.locationManager.location.coordinate.longitude;
        
        self.latitude.text = [NSString stringWithFormat:@"%f", latitude];
        self.longitude.text = [NSString stringWithFormat:@"%f", longitude];
    }
}

- (IBAction)getReverseGeocode:(id)sender
{
    if (0 == [self.arrayGDServerDetail count]) {
        NSLog(@"Server details for Reverse Geocode Service were not specified on GC");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Configuration error"
                                                                                 message:@"Please specify Reverse Geocode Service on GC"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertOkAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    self.getReverseGeocodeButton.userInteractionEnabled = NO;
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleMedium];
    self.spinner.color = [UIColor grayColor];
    [self.view addSubview:self.spinner];
    [self.spinner startAnimating];
    
    self.requestURL = [self.arrayGDServerDetail.firstObject server];
    if ([self.requestURL length] > 0 && [[self.requestURL substringFromIndex: [self.requestURL length]-1] compare: @"/"] != 0)
    {
        NSLog(@"Appending '/' in Server Address: %@", self.requestURL);
        self.requestURL = [self.requestURL stringByAppendingString:@"/"];
    }
    
    NSLog(@"Server Address: %@", self.requestURL);
    
    self.requestURL = [self.requestURL stringByAppendingString:@"maps/api/geocode/json?"];
    
    if (self.latitude.text.length && self.longitude.text.length)
    {
        self.requestURL = [self.requestURL stringByAppendingString:@"latlng="];
        self.requestURL = [[self.requestURL stringByAppendingString:self.latitude.text] stringByAppendingString:@","];
        self.requestURL = [self.requestURL stringByAppendingString:self.longitude.text];
        
        self.requestURL = [self.requestURL stringByAppendingString:@"&sensor=true"];
        NSLog(@"request URL: %@", self.requestURL);
        
        NSString *urlString = [@"https://" stringByAppendingString:self.requestURL];
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
        
        //create the Method "GET"
        [urlRequest setHTTPMethod:@"GET"];
        
        NSURLSession *session = [NSURLSession sharedSession];
        
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self receivedResponse:httpResponse withData:data];
            });

        }];
        [dataTask resume];

    }
    else
    {
        UIAlertController *alertController=   [UIAlertController
                                      alertControllerWithTitle:@"Syntax error"
                                      message:@"Please fill latitude and latitude"
                                      preferredStyle:UIAlertControllerStyleAlert];

        UIAlertAction *alertOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertOkAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        [self.spinner removeFromSuperview];
        self.getReverseGeocodeButton.userInteractionEnabled = YES;
    }

    [self.latitude endEditing:YES];
    [self.longitude endEditing:YES];
}

- (void)receivedResponse:(NSHTTPURLResponse*)sessionResponse withData:(NSData*)data
{
    if (sessionResponse.statusCode == 0)
    {
        //self.responseView.text = @"Bad request...";
    }
    else if(sessionResponse.statusCode == 200)
    {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", response);
        
        self.serverResponseTextView.text = response;
        NSError *parseError = nil;
        self.jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if ([self.jsonDictionary[@"results"] count]) {
            self.addressWillBeHereLabel.text = self.jsonDictionary[@"results"][0][@"formatted_address"];
        }
        [self.spinner removeFromSuperview];
        
        self.serverResponseTextView.hidden = NO;
        self.serverResponseLabel.hidden = NO;
        self.addressLabel.hidden = NO;
        self.addressWillBeHereLabel.hidden = NO;
        
        self.getReverseGeocodeButton.userInteractionEnabled = YES;
    }
    else if (sessionResponse.statusCode == 400)
    {
        NSLog(@"Errro: bad request.");
        self.serverResponseTextView.text = @"Bad request...";
        self.serverResponseTextView.hidden = NO;
        
        self.addressLabel.hidden = YES;
        self.addressWillBeHereLabel.hidden = YES;
        
        [self.spinner removeFromSuperview];
        self.getReverseGeocodeButton.userInteractionEnabled = YES;
    }

}

@end
