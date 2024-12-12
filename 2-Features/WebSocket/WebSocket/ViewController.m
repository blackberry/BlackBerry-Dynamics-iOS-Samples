//////////////////////////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2020 BlackBerry Limited. All Rights Reserved.
// Some modifications to the original from https://github.com/acmacalister/jetfire
//
//  ViewController.m
//  WebSocket
//
//  Created by Austin and Dalton Cherry on on 2/24/15.
//  Copyright (c) 2014-2017 Austin Cherry.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//////////////////////////////////////////////////////////////////////////////////////////////////

#import "ViewController.h"
#import "JFRWebSocket.h"
#import "WebSocketGDiOSDelegate.h"

@interface ViewController ()<JFRWebSocketDelegate>

@property(nonatomic, strong)JFRWebSocket *socket;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:8080"] protocols:@[@"chat",@"superchat"]];
//    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://echo.wss-websocket.net"] protocols:@[@"chat",@"superchat"]];
//    self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://echo.wss-websocket.net"] protocols:@[@"chat",@"superchat"]];
    self.socket.delegate = self;
    self.socket.socketID = [NSNumber numberWithInt:0]; // just example, it is optional
    [self.socket connect];
}

// pragma mark: WebSocket Delegate methods.

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@", [error localizedDescription]);
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);
}

-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
}

// pragma mark: target actions.

- (IBAction)writeText:(UIBarButtonItem *)sender {
    NSString* str = @"hello there!";
    [self.socket writeString:str gdSocketID:_socket.gdSocket];
//    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
//    [self.socket writeData:data];
//    [self.socket writePing:data];
}

- (IBAction)disconnect:(UIBarButtonItem *)sender {
    if(self.socket.isConnected) {
        sender.title = @"Connect";
        [self.socket disconnect:_socket.gdSocket];
    } else {
        sender.title = @"Disconnect";
        [self.socket connect];
    }
}

@end
