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

import UIKit
import BlackBerryDynamics.SecureCommunication


class SocketViewController: UIViewController, GDSocketDelegate {
    
    var gdSocket = GDSocket()
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddressText: UITextField!
    @IBOutlet weak var dataRecievedTextVIew: UITextView!
    @IBOutlet weak var portText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.statusLabel.text = "Disconnected"
        self.ipAddressText.text = "developer.blackberry.com"
        self.portText.text = "80"
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func connectToServer(_ sender: Any) {
        
        let intCast : Int32 = Int32(self.portText.text!)!
        
        let nsstring : NSString = NSString.init(string: self.ipAddressText.text!)
        
        gdSocket = GDSocket(nsstring.utf8String!, onPort: intCast, andUseSSL: false)
        
        gdSocket.delegate = self
        
        self.statusLabel.text = "Socket connecting."
        
        gdSocket.connect()
        
        self.statusLabel.text = "Socket connected."
        
    }
    
    @IBAction func clearText(_ sender: Any) {
        self.dataRecievedTextVIew.text = ""
    }
    
    //GDSocket callbacks
    
    func onOpen(_ socket: Any) {
        print("DEBUG: Socket open. Loading stream...")
        
         //format HTTP request and open/send data through GDSocket
        
        let httpString = "GET http://\(self.ipAddressText.text!)/ HTTP/1.1\r\nHost:\(self.ipAddressText.text!):\(self.portText.text!)\r\nConnection: close\r\n\r\n" as NSString
        
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
            self.dataRecievedTextVIew.text = str as String!
        }
        gSocket.disconnect()
        
    }
    
    func onClose(_ socket: Any) {
        DispatchQueue.main.async {
            self.statusLabel.text = "Socket disconnected"
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
        }
        
        if (errorStr != "") {
            self.statusLabel.text = "Socket error \(error) \(errorStr)"
        }
        else {
            self.statusLabel.text = "Socket error \(error)"
        }
    }
    
    
}
