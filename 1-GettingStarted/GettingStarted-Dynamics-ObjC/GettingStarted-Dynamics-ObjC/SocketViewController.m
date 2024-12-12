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

#import "SocketViewController.h"
@import BlackBerryDynamics.Runtime;

@interface SocketViewController ()

- (IBAction)connectToServer:(id)sender;
- (IBAction)clearData:(id)sender;

@end

@implementation SocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.statusLabel.text = @"Disconnected";
    self.ipAddressText.text = @"developer.blackberry.com";
    self.portText.text = @"80";
    
    // Do any additional setup after loading the view.
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


- (IBAction)connectToServer:(id)sender {
    
    self.gdSocket = [[GDSocket alloc] init:[_ipAddressText.text UTF8String]
                                    onPort:[_portText.text intValue]
                                 andUseSSL:NO];
    self.gdSocket.delegate = self;
    
    self.statusLabel.text = @"Socket connect.";
    
    [self.gdSocket connect];
    
    self.statusLabel.text = @"Socket connected.";
}


- (IBAction)clearData:(id)sender {
    
    self.dataRecievedTextView.text = @"";
}


- (void) messageReceived:(NSString *)message {
    
    //[messages addObject:message];
    dispatch_sync(dispatch_get_main_queue(), ^{

        self.dataRecievedTextView.text = message;
    });
}


#pragma mark - GDSocket callbacks

-(void)onOpen:(id)socket_id {
    
    NSLog(@"DEBUG: Socket open. Loading stream...");
   
    /* HTTP GET
     "GET http://developer.blackberry.com/ HTTP/1.1\r\n" +"Host: developer.blackberry.com:80\r\n" +"Connection: close\r\n" +"\r\n";
     */
    
    GDSocket *socket = (GDSocket *)socket_id;

    NSString *string1 = [NSString stringWithFormat:@"GET http://developer.blackberry.com/ HTTP/1.1\r\n"];
    NSString *string2 = [NSString stringWithFormat:@"Host: developer.blackberry.com:80\r\n"];
    NSString *string3 = [NSString stringWithFormat:@"Connection: close\r\n"];
    NSString *string4 = [NSString stringWithFormat:@"\r\n"];
    
    NSString *response  = [NSString stringWithFormat:@"%@%@%@%@",string1,string2,string3,string4 ];
    
    [socket.writeStream write:[response UTF8String]];
    
    [socket write];
}

-(void)onRead:(id) socket_id {

    NSLog(@"DEBUG: Socket reading...");
    
    GDSocket *socket = (GDSocket *) socket_id;
    
    NSString *str = [socket.readStream unreadDataAsString];
    
    [self messageReceived:str];
    
    [socket disconnect];
}

-(void)onClose:(id) socket {
    
    dispatch_sync(dispatch_get_main_queue(), ^{

        self.statusLabel.text = @"Socket disconnected";
    });
}

- (void)onErr:(int)errorInt inSocket:(id) socket
{
    NSString *errorStr = nil;
    
    switch (errorInt) {
        case GDSocketErrorNone:
            errorStr = @" GDSocketErrorNone";
            break;
        case GDSocketErrorNetworkUnvailable:
            errorStr = @" GDSocketErrorNetworkUnvailable";
            break;
        case GDSocketErrorServiceTimeOut:
            errorStr = @" GDSocketErrorServiceTimeOut";
            break;
    }
    
    if (errorStr) {

        self.statusLabel.text = [NSString stringWithFormat:@"Socket error %d%@\n", errorInt, errorStr];
    }
    else {
         self.statusLabel.text = [NSString stringWithFormat:@"Socket error %d\n %d %@\n %d %@\n %d %@\n",
         errorInt,
         (int)GDSocketErrorNone, @"GDSocketErrorNone",
         (int)GDSocketErrorNetworkUnvailable, @"GDSocketErrorNetworkUnvailable",
         (int)GDSocketErrorServiceTimeOut, @"GDSocketErrorServiceTimeOut"
         ];
    }
}

@end
