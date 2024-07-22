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
import UIKit

struct HTTPView: View {
    
    @StateObject var httpVC : HttpController
    @State private var status: String = "Data..."
    
    var body: some View {
        NavigationView {
            ScrollView {
                HStack (alignment: .center, spacing: 0, content: {
                    Text("Enter URL to connect or:").bold()
                    Spacer()
                })
                HStack (alignment: .center, spacing: 4, content: {
                    PaddedCustomTextfield(placeHolder: "Enter URL", text: $httpVC.urlText)
                    Button(action: {
                        httpVC.connectToUrl()
                    }, label: {
                        Text("Get Data")
                    })
                })
                VStack (alignment: .leading, spacing: 0, content: {
                    MultilineTextView(text: $httpVC.dataReceived)
                })
            }.navigationBarTitle("HTTP", displayMode: .inline)
            .padding()
        }
    }
}

struct HTTPView_Previews: PreviewProvider {
    static var previews: some View {
        HTTPView(httpVC: HttpController())
    }
}
