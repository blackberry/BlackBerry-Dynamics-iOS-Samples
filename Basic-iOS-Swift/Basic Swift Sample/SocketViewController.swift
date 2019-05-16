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
import Foundation
import CoreFoundation

class SocketViewController: UIViewController, StreamDelegate {
    
    let serverAddress: CFString = "developer.blackberry.com" as CFString
    let serverPort: UInt32 = 80
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var ipAddressText: UITextField!
    @IBOutlet weak var dataRecievedTextVIew: UITextView!
    @IBOutlet weak var portText: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.text = "Disconnected"
        self.ipAddressText.text = "developer.blackberry.com"
        self.portText.text = "80"
    }
    
    //Connect to Developer.blackberry.com:80 using Sockets
    @IBAction func connectToServer(_ sender: Any) {
        
        var readStream:  Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        CFStreamCreatePairWithSocketToHost(nil, serverAddress, serverPort, &readStream, &writeStream)
        
        self.inputStream = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        
        self.inputStream?.delegate = self
        self.outputStream?.delegate = self
        
        self.inputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        self.outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        
        self.inputStream?.open()
        self.outputStream?.open()
        
    }
    
    //Clear text
    @IBAction func clearText(_ sender: Any) {
        self.dataRecievedTextVIew.text = ""
    }
    
    //Delegate method for CFStream
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        print(eventCode)
        
        switch eventCode {
        case Stream.Event.endEncountered: break
            
        case Stream.Event.errorOccurred:
            print("[SCKT]: ErrorOccurred: \(aStream.streamError?.localizedDescription ?? "yup")")
            
        case Stream.Event.openCompleted:
            print("open completed")
            
        //Response recieved
        case Stream.Event.hasBytesAvailable:
            print("has bytes")
            
            var buffer = [UInt8](repeating: 1, count: 4096)
            if ( aStream == inputStream){
                
                while (inputStream.hasBytesAvailable){
                    let len = inputStream.read(&buffer, maxLength: buffer.count)
                    if(len > 0){
                        let output = NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.utf8.rawValue)
                        if (output != ""){
                            dataRecievedTextVIew.text = output! as String
                        }
                    }
                } 
            }
            break
            
        //Write to stream
        case Stream.Event.hasSpaceAvailable:
            print("space available")
            
            let httpString = "GET http://developer.blackberry.com/ HTTP/1.1\n\n Host:developer.blackberry.com:80\n\n Connection: close\n\n \n\n"

            let encodedDataArray = [UInt8](httpString.utf8)
            let result = outputStream.write(encodedDataArray, maxLength: encodedDataArray.count)
            if result == 0 {
                print("Stream at capacity")
            } else if result == -1 {
                print("Operation failed: \(String(describing: outputStream.streamError))")
            } else {
                print("The number of bytes written is \(result)")
            }
            outputStream.close()
        default:
            print("default!")
        }
    }
    
    
}
