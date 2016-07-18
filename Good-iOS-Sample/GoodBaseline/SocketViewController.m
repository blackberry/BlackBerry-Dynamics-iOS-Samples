/* Copyright (c) 2016 BlackBerry Ltd.
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

@interface SocketViewController ()

- (IBAction)connectToServer:(id)sender;
- (IBAction) sendMessage;
- (IBAction)disconnect:(id)sender;

@end

@implementation SocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _statusLabel.text = @"Disconnected";
    
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


- (IBAction) sendMessage {
    
    NSString *response  = [NSString stringWithFormat:@"msg:%@", _dataToSendText.text];
    NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSASCIIStringEncoding]];
    [outputStream write:[data bytes] maxLength:[data length]];
    
}
- (IBAction)clearMessage:(id)sender {
    _dataRecievedTextView.text = @"";
}

- (void) messageReceived:(NSString *)message {
    
    [messages addObject:message];
    
    _dataRecievedTextView.text = message;
    
    NSLog(@"DEBUG: %@", message);
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
    NSLog(@"DEBUG: stream event %lu", streamEvent);
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
            NSLog(@"DEBUG: Stream opened");
            _statusLabel.text = @"Connected";
            if (theStream == inputStream)
            {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"DEBUG: Msg received.");
                            [self messageReceived:output];
                        }
                    }
                }
            }
            break;
        case NSStreamEventHasBytesAvailable:
            
            if (theStream == inputStream)
            {
                uint8_t buffer[1024];
                NSInteger len;
                
                while ([inputStream hasBytesAvailable])
                {
                    len = [inputStream read:buffer maxLength:sizeof(buffer)];
                    if (len > 0)
                    {
                        NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                        
                        if (nil != output)
                        {
                            NSLog(@"DEBUG: Msg Received.");
                            [self messageReceived:output];
                        }
                    }
                }
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            NSLog(@"DEBUG: Stream has space available now");

            if (theStream == outputStream) {
                
                NSString *string1 = [NSString stringWithFormat:@"GET http://developer.blackberry.com/ HTTP/1.1\r\n"];
                NSString *string2 = [NSString stringWithFormat:@"Host: developer.blackberry.com:80\r\n"];
                NSString *string3 = [NSString stringWithFormat:@"Connection: close\r\n"];
                NSString *string4 = [NSString stringWithFormat:@"\r\n"];
                
                NSString *response  = [NSString stringWithFormat:@"%@%@%@%@",string1,string2,string3,string4 ];
                
                const uint8_t * rawstring = (const uint8_t *)[response UTF8String];
                
                [outputStream write:rawstring maxLength:strlen(rawstring)];
                [outputStream close];
             
             /* HTTP GET
             "GET http://developer.blackberry.com/ HTTP/1.1\r\n" +"Host: developer.blackberry.com:80\r\n" +"Connection: close\r\n" +"\r\n";
             */
            
            

            
            }
            break;
            
        case NSStreamEventErrorOccurred:
            NSLog(@"DEBUG: %@",[theStream streamError].localizedDescription);
            break;
            
        case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            _statusLabel.text = @"Disconnected";
            NSLog(@"DEBUG: close stream");
            break;

            
        default:
            NSLog(@"DEBUG: Unknown event");
    }
    
}

- (IBAction)connectToServer:(id)sender {
    
    NSLog(@"DEBUG: Setting up connection to %@ : %i", _ipAddressText.text, [_portText.text intValue]);
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef) _ipAddressText.text, [_portText.text intValue], &readStream, &writeStream);
    
    messages = [[NSMutableArray alloc] init];
    
    [self open];
}

- (IBAction)disconnect:(id)sender {
    
    [self close];
}

- (void)open {
    
    NSLog(@"DEBUG: Opening streams.");
    
    outputStream = (__bridge NSOutputStream *)writeStream;
    inputStream = (__bridge NSInputStream *)readStream;
    
    [outputStream setDelegate:self];
    [inputStream setDelegate:self];
    
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [outputStream open];
    [inputStream open];
    
    _statusLabel.text = @"Connected";
}

- (void)close {
    NSLog(@"DEBUG: Closing streams.");
    [inputStream close];
    [outputStream close];
    [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [inputStream setDelegate:nil];
    [outputStream setDelegate:nil];
    inputStream = nil;
    outputStream = nil;
    
    _statusLabel.text = @"Disconnected";
}

@end
