/* Copyright (c) 2018 BlackBerry Ltd.
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

#import "DirectoryServicesVC.h"

@interface DirectoryServicesVC ()

@end

@implementation DirectoryServicesVC

- (void)viewDidLoad {
    [super viewDidLoad];
     SEARCH_PARAMS = @"\"MaxNumber\":10,\"SearchContacts\":true,\"UserShape\":[\"GivenName\", \"Surname\", \"Photo\",\"Birthday\", \"Title\",\"FullName\",\"EmailAddress\"]}";
    SERVICE_VERSION = @"1.0.0.0";
    SERVICE_ID = @"com.good.gdservice.enterprise.directory";
    _searchTextField.delegate = self;
}

-(void) viewDidAppear:(BOOL)animated {
    [self checkService];
}

- (IBAction)search:(id)sender {
    NSString *body = [NSString stringWithFormat:@"{\"Account\":\"%@\",\"SearchKey\":\"%@\",%@",[self getUserId],[self.searchTextField text],SEARCH_PARAMS];
    
    if ([[self.searchTextField text] isEqualToString:@""]) {
        [self alertWithTitle:@"Error" message:@"Params empty"];
    } else {
        [self executeSearchQuery:body completion:^(NSError *error, NSURLResponse *response, NSData *data){
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@",response);
                if (error == nil) {
                    [self.responseTextView setText:[NSString stringWithFormat:@"%@",[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil]]];
                } else {
                    [self alertWithTitle:@"Error" message:[error localizedDescription]];
                }
            });
        }];
    }
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:true];
}

-(void) alertWithTitle: (NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *alert) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:true];
    return true;
}

-(void) checkService {
    NSArray* arr = [[GDiOS sharedInstance] getServiceProvidersFor:SERVICE_ID andVersion:SERVICE_VERSION andServiceType:GDServiceTypeServer];
    
    if ([arr count] < 1) {
        [self alertWithTitle:@"Error" message:@"No Service Found"];
        return;
    }
    
    GDServiceProvider * serP = [arr objectAtIndex:0];
    GDAppServer *appSer = [[serP serverCluster] objectAtIndex:0];
    NSString *host = [appSer server];
    NSNumber *port = [appSer port];
    url= [NSString stringWithFormat:@"https://%@:%@/api/lookupuser",host,port];
    
    GDUtility *utils =[[GDUtility alloc] init];
    utils.gdAuthDelegate = self;
    [utils getGDAuthToken:@"challenge" serverName:url];
}

-(void) executeSearchQuery:(NSString*)body completion:(void (^)(NSError *error, NSURLResponse *response, NSData*data))completionBlock; {
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:nil];
    
    NSURL *urll = [NSURL URLWithString:url];
    
    if ([authToken  isEqual: @""]) {
        
        [self alertWithTitle:@"Error" message:@"Auth Token nil"];
        return;
    }
    
    NSMutableURLRequest *task = [NSMutableURLRequest requestWithURL:urll cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [task addValue:authToken forHTTPHeaderField:@"X-Good-GD-AuthToken"];
    [task addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [task addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [task setHTTPMethod:@"POST"];
    
    NSData *postData = [body dataUsingEncoding:NSUTF8StringEncoding];;
    [task setHTTPBody:postData];
    
    NSURLSessionDataTask *postDataTask = [session dataTaskWithRequest:task completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        completionBlock(error,response,data);
        
    }];
    [postDataTask resume];
}

- (void)onGDAuthTokenSuccess:(NSString*)gdAuthToken {
    authToken = gdAuthToken;
}

- (void)onGDAuthTokenFailure:(NSError*) authTokenError {
    [self alertWithTitle:@"Error" message:[authTokenError localizedDescription]];
}

-(NSString *) getUserId {
    NSDictionary *objs = [[GDiOS sharedInstance] getApplicationConfig];
    NSString *user = [objs valueForKey:GDAppConfigKeyUserId];
    return user;
}

@end
