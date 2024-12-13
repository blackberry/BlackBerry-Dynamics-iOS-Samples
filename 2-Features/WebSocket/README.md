# WebSocket

Demonstrates use of WebSockets in BlackBerry Dynamics.

## Description

BlackBerry Dynamics WebSocket is an Objective-C library based on [Jetfire](https://github.com/acmacalister/jetfire) and [GDSocket](https://developer.blackberry.com/devzone/files/blackberry-dynamics/ios/interface_g_d_socket.html). It provides a secure WebSocket client for iOS and conforms to [RFC 6455](http://tools.ietf.org/html/rfc6455).

The library features:-

- TLS/WSS support. Utilize the BlackBerry Dynamics secure socket connection to connect to servers over the internet or behind the enterprise firewall.
- Nonblocking. Everything happens in the background.
- Simple delegate pattern design.

Check out the WebSocket project to see how to setup a simple connection to a WebSocket server.

## Requirements

See [Software Requirements](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271/vcw1490294551674) of the BlackBerry Dynamics SDK (iOS) 

## How To Build and Deploy

1. Set up BlackBerry Dynamics Development Environment.
2. Clone the repo. 
3. Run `pod install` to create project workspace.
4. Launch Xcode and open the project.
5. Edit the *Bundle Identifier* to your own.
6. Edit the *URL identifier* and *URL Schemes* according to your own in the *info.plist*. See [Declaring a URL type to support BlackBerry Dynamics features](https://docs.blackberry.com/en/development-tools/blackberry-dynamics-sdk-ios/current/blackberry-dynamics-sdk-ios-devguide/gwj1489687014271) in the Developer Guide.
7. Edit the *GDApplicationID* to your own or use the default '*com.blackberry.dynamics.sample*' in the *info.plist*.
8. Assign the app entitlement to a user in your UEM server. This may also require adding the BlackBerry Dynamics App entitlement to UEM if you are using your own. See [Add an internal BlackBerry Dynamics app entitlement](https://docs.blackberry.com/en/endpoint-management/blackberry-uem/current/managing-apps/managing-blackberry-dynamics-apps).
9. Build and run on simulator or a device.

For more information on how to develop BlackBerry Dynamics apps, refer to [Get Started with BlackBerry Dynamics](https://developers.blackberry.com/us/en/resources/get-started/blackberry-dynamics-getting-started) 

## Example Usage

First thing is to import the header file.

```objc
#import "JFRWebSocket.h"
```

Once imported, you can open a connection to your WebSocket server. Note that `socket` is probably best as a property, so your delegate can stick around. 
Also, you can specify protocols if needed.

```objc
self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:8080"] protocols:@[@"chat",@"superchat"]];
self.socket.delegate = self;
self.socket.socketID = [NSNumber numberWithInt:0]; // just example, it is optional
[self.socket connect];
```

After you are connected, there are some delegate methods that we need to implement.

### websocketDidConnect

```objc
-(void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
}
```

### websocketDidDisconnect

```objc
-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@",[error localizedDescription]);
}
```

### websocketDidReceiveMessage

```objc
-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"got some text: %@",string);
}
```

### websocketDidReceiveData

```objc
-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"got some binary data: %d",data.length);
}
```

Or you can use blocks.

```objc
self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://localhost:8080"] protocols:@[@"chat",@"superchat"]];
//websocketDidConnect
socket.onConnect = ^{
    println("websocket is connected")
};
//websocketDidDisconnect
socket.onDisconnect = ^(NSError *error) { 
    NSLog(@"websocket is disconnected: %@",[error localizedDescription]);
};
//websocketDidReceiveMessage
socket.onText = ^(NSString *text) { 
    NSLog(@"got some text: %@",string);
};
//websocketDidReceiveData
socket.onData = ^(NSData *data) {
     NSLog(@"got some binary data: %d",data.length);
};
//you could do onPong as well.
[socket connect];
```

The delegate methods give you a simple way to handle data from the server, but how do you send data?

### writeData

```objc
[self.socket writeData:[NSData data] gdSocketID:self.socket.socketID]; // write some NSData over the socket!
```

### writePing

```objc
[self.socket writePing:[NSData data] gdSocketID:self.socket.socketID]; // write some NSData ping over the socket!
```

### writeString

The writeString method is the same as writeData, but sends text/string.

```objc
[self.socket writeString:@"Hi Server!" gdSocketID:self.socket.socketID]; //example on how to write text over the socket!
```

### disconnect

```objc
[self.socket disconnect:self.socket.socketID];
```

### isConnected

Returns if the socket is connected or not.

```objc
if(self.socket.isConnected) {
  // do cool stuff.
}
```

### Custom Headers

You can also override the default websocket headers with your own custom ones like so:

```objc
[self.socket addHeader:@"Sec-WebSocket-Protocol" forKey:@"someother protocols"];
[self.socket addHeader:@"Sec-WebSocket-Version" forKey:@"14"];
[self.socket addHeader:@"My-Awesome-Header" forKey:@"Everything is Awesome!"];
```

### "ws:" and "wss:" schemes

Both "ws:" and "wss:" schemes are supported.

```objc
//chat and superchat are the example protocols here
self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"ws://echo.wss-websocket.net"] protocols:@[@"chat",@"superchat"]]; // "ws" scheme example
// OR
self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:@"wss://echo.wss-websocket.net"] protocols:@[@"chat",@"superchat"]]; // "wss" scheme example
self.socket.delegate = self;
[self.socket connect];
```

### Custom Queue

A custom queue can be specified when delegate methods are called. By default `dispatch_get_main_queue` is used, thus making all delegate methods calls run on the main thread. It is important to note that all WebSocket processing is done on a background thread, only the delegate method calls are changed when modifying the queue. The actual processing is always on a background thread and will not pause your app.

```objc
//create a custom queue
self.socket.queue = dispatch_queue_create("com.vluxe.jetfire.myapp", nil);
```

## WebSocketServer

### How to run WebSocketServer:

Open WebSocketServer app directory in Terminal window:

`$ cd <path_to_react_native_repository>/WebSocketServer`

Install dependencies:

`$ npm i`

Start server:

`$ node server.js`

## License

Apache 2.0 License

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
