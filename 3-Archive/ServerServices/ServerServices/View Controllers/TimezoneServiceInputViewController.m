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

#import "TimezoneServiceInputViewController.h"

#import <BlackBerryDynamics/GD/GDAppServer.h>
#import <CoreLocation/CoreLocation.h>

@interface TimezoneServiceInputViewController () <CLLocationManagerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *latitude;
@property (weak, nonatomic) IBOutlet UITextField *longitude;

@property (weak, nonatomic) IBOutlet UITextView *serviceResponseTextView;

@property (weak, nonatomic) IBOutlet UILabel *timeZoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeZoneWillBeHereLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceResponseLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIButton *getTimeZoneButton;

@property (nonatomic, strong) NSString *requestURL;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) BOOL shouldNotUseCoreLocationUpdates;
@property (nonatomic, strong) NSDictionary *jsonDictionary;

@end

@implementation TimezoneServiceInputViewController

+ (CGFloat)visibleViewSize
{
    return 440;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;

    self.timeZoneLabel.hidden = YES;
    self.timeZoneWillBeHereLabel.hidden = YES;
    self.timeZoneWillBeHereLabel.text = @"";
    self.serviceResponseTextView.hidden = YES;
    self.serviceResponseLabel.hidden = YES;
    
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
    if ([TimezoneServiceInputViewController visibleViewSize] > self.scrollView.contentSize.height)
    {
        if (!self.serviceResponseTextView.isHidden)
        {
            CGSize sizeThatShouldFitTheContent = [self.serviceResponseTextView sizeThatFits:self.serviceResponseTextView.contentSize];
            self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, sizeThatShouldFitTheContent.height + self.serviceResponseTextView.frame.origin.y);
        }
    }
    self.spinner.center = self.view.center;
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

- (IBAction)getTimeZone:(id)sender
{
    if (0 == [self.arrayGDServerDetail count]) {
        NSLog(@"Server details for Timezone Service were not specified on GC");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Configuration error"
                                                                                 message:@"Please specify Timezone Service on GC"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *alertOkAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:alertOkAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        return;
    }
    
    self.getTimeZoneButton.userInteractionEnabled = NO;
    
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
    
    self.requestURL = [self.requestURL stringByAppendingString:@"maps/api/timezone/json?"];
    
    if (self.latitude.text.length && self.longitude.text.length)
    {
        self.requestURL = [self.requestURL stringByAppendingString:@"location="];
        self.requestURL = [[self.requestURL stringByAppendingString:self.latitude.text] stringByAppendingString:@","];
        self.requestURL = [self.requestURL stringByAppendingString:self.longitude.text];
        
        
        self.requestURL = [self.requestURL stringByAppendingString:@"&timestamp="];
        int currentTime = CACurrentMediaTime();
        NSString *timeStamp = [[NSString alloc] init];
        
        self.requestURL = [self.requestURL stringByAppendingString:[timeStamp stringByAppendingFormat:@"%d", currentTime]];
        
        self.requestURL = [self.requestURL stringByAppendingString:@"&language=en"]; // english only for now
        
        self.requestURL = [self.requestURL stringByAppendingString:@"&sensor=true"];
        
        NSLog(@"request URL: %@", self.requestURL);
        
        self.requestURL = [@"https://" stringByAppendingString:self.requestURL];
        
        NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:self.requestURL]];
        
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
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Syntax error"
                                      message:@"Please fill latitude and latitude"
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
        
        [self.spinner removeFromSuperview];
        self.getTimeZoneButton.userInteractionEnabled = YES;
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
    if(sessionResponse.statusCode == 200)
    {
        NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", response);
        
        self.serviceResponseTextView.text = response;
        NSError *parseError = nil;
        self.jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parseError];
        if ([self.jsonDictionary[@"results"] count]) {
            self.timeZoneWillBeHereLabel.text = self.jsonDictionary[@"timeZoneName"];
        }
        [self.spinner removeFromSuperview];
        
        self.serviceResponseLabel.hidden = NO;
        self.serviceResponseTextView.hidden = NO;
        self.timeZoneLabel.hidden = NO;
        self.timeZoneWillBeHereLabel.hidden = NO;
        
        self.getTimeZoneButton.userInteractionEnabled = YES;
    }
    else if (sessionResponse.statusCode == 400)
    {
        NSLog(@"Errro: bad request.");
        self.serviceResponseTextView.text = @"Bad request...";
        self.serviceResponseTextView.hidden = NO;
        
        self.timeZoneLabel.hidden = YES;
        self.timeZoneWillBeHereLabel.hidden = YES;
        
        [self.spinner removeFromSuperview];
        self.getTimeZoneButton.userInteractionEnabled = YES;
    }
}

@end
