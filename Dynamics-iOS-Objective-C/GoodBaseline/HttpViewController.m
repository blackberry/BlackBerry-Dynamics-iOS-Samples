/* Copyright (c) 2021 BlackBerry Ltd.
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

#import "HttpViewController.h"

@interface HttpViewController ()

@property (weak, nonatomic) IBOutlet UITextField *urlText;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *getURLButton;
@property (weak, nonatomic) IBOutlet UITextView *dataReceivedTextView;

- (IBAction)clearDataView:(id)sender;
- (IBAction)connectToURL:(id)sender;
- (NSURL *)smartURLForString:(NSString *)str;
- (void)receiveDidStart;

@end

@implementation HttpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.

    self.urlText.text = @"https://developer.blackberry.com";

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    
    dataBuffer = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    
    [dataBuffer appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    NSString *receivedData = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
    
    self.dataReceivedTextView.text = receivedData;
    self.statusLabel.text = @"Data loaded.";
    self.getURLButton.enabled = FALSE;
    
    // reset the buffer
    [dataBuffer setLength:0];
    
    // set currentConnection to nil to avoid problems if aborting after the connection has gone away
    connection = nil;
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    self.statusLabel.text = @"Connection failed.";
}

- (void)receiveDidStart
{
    // Clear the current data view so that we get a nice visual cue if the receive fails.
    //self.dataReceivedTextView.text = @"";
    self.statusLabel.text = @"Receiving data.";
}


- (IBAction)clearDataView:(id)sender {
    
    self.dataReceivedTextView.text = @"";
    
    // reset the buffer
    [dataBuffer setLength:0];
    
    self.statusLabel.text = @"Data cleard...";
    self.getURLButton.enabled = TRUE;
}

- (IBAction)connectToURL:(id)sender {
    
    BOOL                success;
    NSURL *             url;
    NSURLRequest *      request;
    
   
    // First get and check the URL.
    url = [self smartURLForString:self.urlText.text];
    success = (url != nil);
   
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ( ! success) {
        self.statusLabel.text = @"Invalid URL";
    }
    else
    {
        // Open a connection for the URL.
        request = [NSURLRequest requestWithURL:url];
          
        // Tell the UI we're receiving.
        [self receiveDidStart];
        
        dataBuffer = [NSMutableData new];
        
        //set this delegate as this object. Therefore "connection: didFailWithError:"
        //will get called if implemented
        connection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"http"  options:NSCaseInsensitiveSearch] == NSOrderedSame)
                || ([scheme compare:@"https" options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    return result;
}

@end
