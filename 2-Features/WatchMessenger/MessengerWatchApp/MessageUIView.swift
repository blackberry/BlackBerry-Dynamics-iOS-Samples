/* Copyright (c) 2024 BlackBerry Ltd.
 *
 * Licensed under the Apache License, Version 2.0 (the "License")
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

struct MessageUIView: View {
    
    @ObservedObject @MainActor var messenger = Messenger.shared

    @State var expectReply = true

    @State private var secureOnLaunch = UserDefaults.standard.bool(forKey: "secureOnLaunch")

    var body: some View {
        ScrollView(.vertical) {
            VStack {
                Button("Send Message") {
                    messenger.sendMessage()
                }
                Button("Send Image") {
                    messenger.sendMessageData()
                }
                HStack() {
                    Spacer()
                    Text("Expect Reply")
                    Toggle("", isOn: $expectReply).labelsHidden()
                        .onChange(of: expectReply) { value in
                            messenger.expectReply = expectReply
                        }
                    Spacer()
                }
                Text(messenger.messageText)
                    .fixedSize(horizontal: false, vertical: true)
                Image(uiImage:(UIImage(data: messenger.messageData) ?? UIImage()))
                    .resizable()
                    .scaledToFit()
                    .frame(width:30.0, height: 30.0)
            }
        }
        .onAppear {
            if (secureOnLaunch) {
                messenger.secureCommunication()
            }
        }
    }
}
#Preview {
    MessageUIView()
}
