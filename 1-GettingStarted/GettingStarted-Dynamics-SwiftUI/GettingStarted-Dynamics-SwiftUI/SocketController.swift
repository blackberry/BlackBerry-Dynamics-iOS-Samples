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

import SwiftUI
import BlackBerryDynamics.SecureCommunication


class SocketController: ObservableObject, GDSocketDelegate {
    
    var gdSocket = GDSocket()
    
    @Published var statusLabel : String
    @Published var ipAddressText : String
    @Published var portText : String
    @Published var dataRecieved: String
    
    init() {
        
        self.statusLabel = "Disconnected"
        self.ipAddressText = "developer.blackberry.com"
        self.portText = "80"
        self.dataRecieved = "Data..."
        
        // Do any additional setup after loading the view.
    }
    
    func connectToServer() {
        
        if (self.portText.isEmpty) {
            self.portText = "0"
        }
        
        let intCast : Int32 = Int32(self.portText)!
        
        let nsstring : NSString = NSString.init(string: self.ipAddressText)
        
        gdSocket = GDSocket(nsstring.utf8String!, onPort: intCast, andUseSSL: false)
        
        gdSocket.delegate = self
        
        self.statusLabel = "Socket connecting."
        
        gdSocket.connect()
        
        self.statusLabel = "Socket connected."
        
    }
    
    func clearText() {
        self.dataRecieved = ""
        self.statusLabel = "Disconnected"
    }
    
    //GDSocket callbacks
    
    func onOpen(_ socket: Any) {
        print("DEBUG: Socket open. Loading stream...")
        
         //format HTTP request and open/send data through GDSocket
        
        let httpString = "GET http://\(self.ipAddressText)/ HTTP/1.1\r\nHost:\(self.ipAddressText):\(self.portText)\r\nConnection: close\r\n\r\n" as NSString
        
        print(httpString)
        
        print(httpString.utf8String!)
        
        gdSocket.writeStream?.write(httpString.utf8String!)
        
        gdSocket.write()
    }
    
    func onRead(_ socket: Any) {
        
        print("DEBUG: Socket reading...")
        
        //Handle GDSocket data received
        
        let gSocket = socket as! GDSocket
        
        let str = gSocket.readStream?.unreadDataAsString()
        
        DispatchQueue.main.async {
            self.dataRecieved = str! as String
        }
        gSocket.disconnect()
        
    }
    
    func onClose(_ socket: Any) {
        DispatchQueue.main.async {
            self.statusLabel = "Socket disconnected"
        }
    }
    
    func onErr(_ error: Int32, inSocket socket: Any) {
        
        var errorStr = ""
        
        let socketError : GDSocketErrorType = GDSocketErrorType(rawValue: Int(error))!
        
        switch (socketError) {
        case .none:
            errorStr = " GDSocketErrorNone"
            break
        case .networkUnvailable:
            errorStr = " GDSocketErrorNetworkUnvailable"
            break
        case .serviceTimeOut:
            errorStr = " GDSocketErrorServiceTimeOut"
            break
        default:
            errorStr = " Unhandled GDSocket Error"
            break
        }
        DispatchQueue.main.async {
            if (errorStr != "") {
                self.statusLabel = "Socket error"
                self.dataRecieved = "\(error) \(errorStr)"
            }
            else {
                self.statusLabel = "Socket error \(error)"
                self.dataRecieved = "\(error)"
            }
        }
    }
    
    
}
