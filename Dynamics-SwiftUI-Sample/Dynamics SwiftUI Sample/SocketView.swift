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

struct SocketView: View {
    
    @StateObject var socketVC : SocketController
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack (alignment: .center, spacing: 0, content: {
                    Text("Enter a Server and Port Number").bold()
                    Spacer()
                })
                VStack (alignment: .center, spacing: 5, content: {
                    PaddedCustomTextfield(placeHolder: "Server", text: $socketVC.ipAddressText)
                    PaddedCustomTextfield(placeHolder: "Port", text: $socketVC.portText)
                })
                HStack (alignment: .center, spacing: 0, content: {
                    Button(action: {
                        socketVC.connectToServer()
                    }, label: {
                        Text("Connect").bold()
                    })
                }).padding()
                HStack (alignment: .center, spacing: 0, content: {
                    Text(socketVC.statusLabel)
                        .bold()
                    Spacer()
                    Button(action: {
                        socketVC.clearText()
                    }, label: {
                        Text("Clear")
                            .foregroundColor(.red)
                            .bold()
                    })
                })
                VStack (alignment: .leading, spacing: 0, content: {
                    MultilineTextView(text: $socketVC.dataRecieved)
                })
            }.navigationBarTitle("Socket", displayMode: .inline)
            .padding()
        }
    }
}

struct SocketView_Previews: PreviewProvider {
    static var previews: some View {
        SocketView(socketVC: SocketController())
    }
}
